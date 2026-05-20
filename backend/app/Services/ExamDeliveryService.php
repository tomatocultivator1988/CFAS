<?php

namespace App\Services;

use App\Models\Exam;
use App\Models\ExamAttempt;
use App\Models\AttemptAnswer;
use App\Models\AnswerChoice;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Collection;

class ExamDeliveryService
{
    protected RandomizationService $randomizationService;

    public function __construct(RandomizationService $randomizationService)
    {
        $this->randomizationService = $randomizationService;
    }

    /**
     * Get all active exams (no assignment required).
     *
     * @param int $revieweeId
     * @return Collection
     */
    public function getAssignedExams(int $revieweeId): Collection
    {
        // Return all active exams - no assignment check needed
        return Exam::active()
            ->with('questions')
            ->get()
            ->map(function ($exam) use ($revieweeId) {
                $attemptCount = ExamAttempt::where('exam_id', $exam->id)
                    ->where('reviewee_id', $revieweeId)
                    ->whereIn('status', ['completed', 'auto_submitted'])
                    ->count();

                $exam->attempts_taken = $attemptCount;
                $exam->attempts_remaining = max(0, $exam->max_attempts - $attemptCount);
                $exam->can_attempt = $attemptCount < $exam->max_attempts;

                return $exam;
            });
    }

    /**
     * Start a new exam attempt.
     *
     * @param int $examId
     * @param int $revieweeId
     * @return ExamAttempt
     * @throws \Exception
     */
    public function startExamAttempt(int $examId, int $revieweeId): ExamAttempt
    {
        $exam = Exam::with('questions.answerChoices')->findOrFail($examId);

        // Check attempt limit
        $attemptCount = ExamAttempt::where('exam_id', $examId)
            ->where('reviewee_id', $revieweeId)
            ->count();

        if ($attemptCount >= $exam->max_attempts) {
            throw new \Exception('Maximum attempts reached for this exam.');
        }

        // Check for existing in-progress attempt
        $existingAttempt = ExamAttempt::where('exam_id', $examId)
            ->where('reviewee_id', $revieweeId)
            ->where('status', 'in_progress')
            ->first();

        if ($existingAttempt) {
            // Return existing attempt instead of throwing error
            return $existingAttempt;
        }

        return DB::transaction(function () use ($exam, $revieweeId, $attemptCount) {
            $attemptNumber = $attemptCount + 1;

            // Generate randomization seed
            $seed = $this->randomizationService->generateSeed(
                $exam->id,
                $revieweeId,
                $attemptNumber
            );

            // Create attempt - use a safe integer seed
            $numericSeed = abs(crc32($seed)) % 2147483647; // Keep within signed int range

            $attempt = ExamAttempt::create([
                'exam_id' => $exam->id,
                'reviewee_id' => $revieweeId,
                'attempt_number' => $attemptNumber,
                'randomization_seed' => $numericSeed,
                'start_time' => now(),
                'time_limit_seconds' => $exam->time_limit_minutes * 60,
                'status' => 'in_progress',
                'total_questions' => $exam->questions->count(),
                'violation_count' => 0,
            ]);

            return $attempt;
        });
    }

    /**
     * Get attempt details with randomized questions.
     *
     * @param int $attemptId
     * @param int $revieweeId
     * @return array
     * @throws \Exception
     */
    public function getAttemptDetails(int $attemptId, int $revieweeId): array
    {
        $attempt = ExamAttempt::with(['exam.questions.answerChoices', 'answers'])
            ->findOrFail($attemptId);

        // Verify ownership
        if ($attempt->reviewee_id !== $revieweeId) {
            throw new \Exception('Unauthorized access to this attempt.');
        }

        // Check if time expired and auto-submit if needed
        if ($attempt->isInProgress() && $attempt->hasTimeExpired()) {
            $this->submitExam($attemptId, $revieweeId, true);
            $attempt->refresh();
        }

        // Get questions with randomization
        $seed = (string)$attempt->randomization_seed;
        $questions = $this->randomizationService->randomizeExamContent(
            $attempt->exam->questions,
            $seed,
            $attempt->exam->randomize_questions,
            $attempt->exam->randomize_choices
        );

        // Add answer status to questions
        $answeredQuestionIds = $attempt->answers->pluck('question_id')->toArray();
        $questions = $questions->map(function ($question) use ($answeredQuestionIds, $attempt) {
            $question->is_answered = in_array($question->id, $answeredQuestionIds);
            
            // Get selected answer if exists
            $answer = $attempt->answers->where('question_id', $question->id)->first();
            $question->selected_choice_id = $answer ? $answer->selected_choice_id : null;

            // Never expose answer correctness flags during active exam delivery.
            if (isset($question->answerChoices)) {
                $question->answerChoices = $question->answerChoices->map(function ($choice) {
                    return [
                        'id' => $choice->id,
                        'question_id' => $choice->question_id,
                        'choice_text' => $choice->choice_text,
                    ];
                });
            }
            
            return $question;
        });

        return [
            'attempt' => $attempt,
            'questions' => $questions,
            'remaining_seconds' => $attempt->getRemainingSeconds(),
        ];
    }

    /**
     * Submit an answer for a question.
     *
     * @param int $attemptId
     * @param int $questionId
     * @param int $choiceId
     * @param int $revieweeId
     * @return AttemptAnswer
     * @throws \Exception
     */
    public function submitAnswer(int $attemptId, int $questionId, int $choiceId, int $revieweeId): AttemptAnswer
    {
        $attempt = ExamAttempt::findOrFail($attemptId);

        // Verify ownership
        if ($attempt->reviewee_id !== $revieweeId) {
            throw new \Exception('Unauthorized access to this attempt.');
        }

        // Check if attempt is still in progress
        if (!$attempt->isInProgress()) {
            throw new \Exception('This attempt has already been completed.');
        }

        // Check if time expired
        if ($attempt->hasTimeExpired()) {
            $this->submitExam($attemptId, $revieweeId, true);
            throw new \Exception('Time has expired. Exam has been auto-submitted.');
        }

        // Verify question belongs to exam
        $questionExists = DB::table('exam_questions')
            ->where('exam_id', $attempt->exam_id)
            ->where('question_id', $questionId)
            ->exists();

        if (!$questionExists) {
            throw new \Exception('Question does not belong to this exam.');
        }

        // Get the correct answer
        $correctChoice = AnswerChoice::where('question_id', $questionId)
            ->where('is_correct', true)
            ->first();

        $isCorrect = $correctChoice && $correctChoice->id === $choiceId;

        // Update or create answer
        return AttemptAnswer::updateOrCreate(
            [
                'attempt_id' => $attemptId,
                'question_id' => $questionId,
            ],
            [
                'selected_choice_id' => $choiceId,
                'is_correct' => $isCorrect,
                'answered_at' => now(),
            ]
        );
    }

    /**
     * Submit the exam and calculate score.
     *
     * @param int $attemptId
     * @param int $revieweeId
     * @param bool $autoSubmit
     * @return ExamAttempt
     * @throws \Exception
     */
    public function submitExam(int $attemptId, int $revieweeId, bool $autoSubmit = false): ExamAttempt
    {
        $attempt = ExamAttempt::with(['answers', 'exam'])->findOrFail($attemptId);

        // Verify ownership
        if ($attempt->reviewee_id !== $revieweeId) {
            throw new \Exception('Unauthorized access to this attempt.');
        }

        // Check if already completed
        if ($attempt->isCompleted()) {
            throw new \Exception('This attempt has already been completed.');
        }

        return DB::transaction(function () use ($attempt, $autoSubmit) {
            // Calculate score
            $correctAnswers = $attempt->answers->where('is_correct', true)->count();
            $totalQuestions = $attempt->total_questions;
            $percentage = $totalQuestions > 0 ? ($correctAnswers / $totalQuestions) * 100 : 0;

            // Update attempt
            $attempt->update([
                'end_time' => now(),
                'status' => $autoSubmit ? 'auto_submitted' : 'completed',
                'score' => $correctAnswers,
                'percentage' => round($percentage, 2),
            ]);

            // Invalidate analytics cache
            try {
                $cacheInvalidation = app(CacheInvalidationService::class);
                $cacheInvalidation->invalidateExamCompletion(
                    $attempt->exam_id,
                    $attempt->reviewee_id,
                    $attempt->exam->category ?? 'Unknown'
                );
            } catch (\Exception $e) {
                // Log error but don't fail the submission
                \Illuminate\Support\Facades\Log::warning('Cache invalidation failed after exam submission', [
                    'attempt_id' => $attempt->id,
                    'exam_id' => $attempt->exam_id,
                    'reviewee_id' => $attempt->reviewee_id,
                    'error' => $e->getMessage()
                ]);
            }

            return $attempt->fresh();
        });
    }

    /**
     * Get remaining time for an attempt.
     *
     * @param int $attemptId
     * @param int $revieweeId
     * @return int Remaining seconds
     * @throws \Exception
     */
    public function getRemainingTime(int $attemptId, int $revieweeId): int
    {
        $attempt = ExamAttempt::findOrFail($attemptId);

        // Verify ownership
        if ($attempt->reviewee_id !== $revieweeId) {
            throw new \Exception('Unauthorized access to this attempt.');
        }

        return $attempt->getRemainingSeconds();
    }
}

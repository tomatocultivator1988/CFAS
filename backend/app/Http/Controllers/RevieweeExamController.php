<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Services\ExamDeliveryService;
use App\Services\ViolationTrackingService;

class RevieweeExamController extends Controller
{
    protected ExamDeliveryService $examService;
    protected ViolationTrackingService $violationService;

    public function __construct(
        ExamDeliveryService $examService,
        ViolationTrackingService $violationService
    ) {
        $this->examService = $examService;
        $this->violationService = $violationService;
    }

    /**
     * Get available exams for the authenticated reviewee.
     * Returns ALL active exams (no assignment required).
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function getAssignedExams(Request $request): JsonResponse
    {
        $revieweeId = $request->user()->id;
        
        // Get all active exams (no assignment check needed)
        $exams = \App\Models\Exam::active()
            ->with(['questions.answerChoices'])
            ->with(['examAttempts' => function ($query) use ($revieweeId) {
                $query->where('reviewee_id', $revieweeId)
                    ->whereIn('status', ['completed', 'auto_submitted'])
                    ->select('id', 'exam_id', 'reviewee_id', 'percentage', 'end_time')
                    ->orderByDesc('id');
            }])
            ->get()
            ->map(function ($exam) {
                $attemptsUsed = $exam->examAttempts->count();
                $latestAttempt = $exam->examAttempts->first();

                return [
                    'id' => $exam->id,
                    'title' => $exam->title,
                    'category' => $exam->category,
                    'description' => $exam->description,
                    'time_limit_minutes' => $exam->time_limit_minutes,
                    'max_attempts' => $exam->max_attempts,
                    'randomize_questions' => $exam->randomize_questions,
                    'randomize_choices' => $exam->randomize_choices,
                    'total_questions' => $exam->questions->count(),
                    'attempts_used' => $attemptsUsed,
                    'attempts_remaining' => $exam->max_attempts - $attemptsUsed,
                    'latest_score' => $latestAttempt ? $latestAttempt->percentage : null,
                    'latest_attempt_date' => $latestAttempt ? $latestAttempt->end_time : null,
                ];
            });

        return response()->json([
            'exams' => $exams
        ], 200);
    }

    /**
     * Start a new exam attempt.
     *
     * @param Request $request
     * @param int $examId
     * @return JsonResponse
     */
    public function startExam(Request $request, int $examId): JsonResponse
    {
        try {
            $revieweeId = $request->user()->id;
            $attempt = $this->examService->startExamAttempt($examId, $revieweeId);

            return response()->json([
                'message' => 'Exam attempt started successfully.',
                'attempt' => $attempt
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'message' => $e->getMessage()
            ], 400);
        }
    }

    /**
     * Get attempt details with questions.
     *
     * @param Request $request
     * @param int $attemptId
     * @return JsonResponse
     */
    public function getAttempt(Request $request, int $attemptId): JsonResponse
    {
        try {
            $revieweeId = $request->user()->id;
            $details = $this->examService->getAttemptDetails($attemptId, $revieweeId);

            return response()->json($details, 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => $e->getMessage()
            ], 400);
        }
    }

    /**
     * Submit an answer for a question.
     *
     * @param Request $request
     * @param int $attemptId
     * @return JsonResponse
     */
    public function submitAnswer(Request $request, int $attemptId): JsonResponse
    {
        $request->validate([
            'question_id' => 'required|integer|exists:questions,id',
            'choice_id' => 'required|integer|exists:answer_choices,id',
        ]);

        try {
            $revieweeId = $request->user()->id;
            $answer = $this->examService->submitAnswer(
                $attemptId,
                $request->question_id,
                $request->choice_id,
                $revieweeId
            );

            return response()->json([
                'message' => 'Answer submitted successfully.',
                'answer' => $answer
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => $e->getMessage()
            ], 400);
        }
    }

    /**
     * Submit the exam.
     *
     * @param Request $request
     * @param int $attemptId
     * @return JsonResponse
     */
    public function submitExam(Request $request, int $attemptId): JsonResponse
    {
        try {
            $revieweeId = $request->user()->id;
            $attempt = $this->examService->submitExam($attemptId, $revieweeId, false);

            return response()->json([
                'message' => 'Exam submitted successfully.',
                'attempt' => $attempt
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => $e->getMessage()
            ], 400);
        }
    }

    /**
     * Get remaining time for an attempt.
     *
     * @param Request $request
     * @param int $attemptId
     * @return JsonResponse
     */
    public function getRemainingTime(Request $request, int $attemptId): JsonResponse
    {
        try {
            $revieweeId = $request->user()->id;
            $remainingSeconds = $this->examService->getRemainingTime($attemptId, $revieweeId);

            return response()->json([
                'remaining_seconds' => $remainingSeconds
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => $e->getMessage()
            ], 400);
        }
    }

    /**
     * Report a security violation.
     *
     * @param Request $request
     * @param int $attemptId
     * @return JsonResponse
     */
    public function reportViolation(Request $request, int $attemptId): JsonResponse
    {
        $request->validate([
            'violation_type' => 'required|in:focus_loss,alt_tab,prohibited_key',
        ]);

        try {
            $revieweeId = $request->user()->id;
            $result = $this->violationService->recordViolation(
                $attemptId,
                $request->violation_type,
                $revieweeId
            );

            return response()->json([
                'message' => 'Violation recorded.',
                'data' => $result
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => $e->getMessage()
            ], 400);
        }
    }

    /**
     * Get violation count for an attempt.
     *
     * @param Request $request
     * @param int $attemptId
     * @return JsonResponse
     */
    public function getViolationCount(Request $request, int $attemptId): JsonResponse
    {
        try {
            $revieweeId = $request->user()->id;
            $count = $this->violationService->getViolationCount($attemptId, $revieweeId);

            return response()->json([
                'violation_count' => $count
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => $e->getMessage()
            ], 400);
        }
    }

    /**
     * Get exam history for the authenticated reviewee.
     * Returns all completed exam attempts with scores.
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function getExamHistory(Request $request): JsonResponse
    {
        try {
            $revieweeId = $request->user()->id;
            
            $history = \App\Models\ExamAttempt::where('reviewee_id', $revieweeId)
                ->whereIn('status', ['completed', 'auto_submitted'])
                ->with('exam:id,title')
                ->orderBy('end_time', 'desc')
                ->get()
                ->map(function ($attempt) {
                    return [
                        'id' => $attempt->id,
                        'exam_id' => $attempt->exam_id,
                        'exam_title' => $attempt->exam->title,
                        'score' => $attempt->score,
                        'total_questions' => $attempt->total_questions,
                        'percentage' => $attempt->percentage,
                        'attempt_number' => $attempt->attempt_number,
                        'status' => $attempt->status,
                        'start_time' => $attempt->start_time,
                        'end_time' => $attempt->end_time,
                    ];
                });

            return response()->json([
                'history' => $history
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => $e->getMessage()
            ], 400);
        }
    }

    /**
     * Get detailed review of a completed exam attempt.
     * Shows all questions with user's answers and correct answers.
     *
     * @param Request $request
     * @param int $attemptId
     * @return JsonResponse
     */
    public function getAttemptReview(Request $request, int $attemptId): JsonResponse
    {
        try {
            $revieweeId = $request->user()->id;
            
            // Get the attempt with randomization seed
            $attempt = \App\Models\ExamAttempt::where('id', $attemptId)
                ->where('reviewee_id', $revieweeId)
                ->whereIn('status', ['completed', 'auto_submitted'])
                ->with('exam:id,title,description,randomize_questions,randomize_choices')
                ->firstOrFail();
            
            // Get all questions with answers
            $questions = \App\Models\Question::whereIn('id', function($query) use ($attemptId) {
                $query->select('question_id')
                    ->from('attempt_answers')
                    ->where('attempt_id', $attemptId);
            })
            ->with(['answerChoices'])
            ->get();
            
            // Apply the SAME randomization that was used during the exam
            $randomizationService = app(\App\Services\RandomizationService::class);
            $seed = (string)$attempt->randomization_seed;
            
            $randomizedQuestions = $randomizationService->randomizeExamContent(
                $questions,
                $seed,
                $attempt->exam->randomize_questions,
                $attempt->exam->randomize_choices
            );

            $attemptAnswers = \App\Models\AttemptAnswer::where('attempt_id', $attemptId)
                ->select('question_id', 'selected_choice_id', 'is_correct')
                ->get()
                ->keyBy('question_id');
            
            // Map questions with answers (now in the same order student saw them)
            $questionsWithAnswers = collect($randomizedQuestions)->map(function ($question, $index) use ($attemptAnswers) {
                $userAnswer = $attemptAnswers->get($question->id);
                
                // Find correct answer
                $correctChoice = $question->answerChoices->firstWhere('is_correct', true);
                
                return [
                    'id' => $question->id,
                    'order' => $index + 1, // Use displayed order (1, 2, 3...) not database order
                    'question_text' => $question->question_text,
                    'choices' => $question->answerChoices->map(function ($choice) {
                        return [
                            'id' => $choice->id,
                            'choice_text' => $choice->choice_text,
                            'is_correct' => $choice->is_correct,
                        ];
                    }),
                    'user_answer_id' => $userAnswer ? $userAnswer->selected_choice_id : null,
                    'correct_answer_id' => $correctChoice ? $correctChoice->id : null,
                    'is_correct' => $userAnswer ? $userAnswer->is_correct : false,
                ];
            })
            ->values(); // Reset array keys

            return response()->json([
                'attempt' => [
                    'id' => $attempt->id,
                    'exam_title' => $attempt->exam->title,
                    'exam_description' => $attempt->exam->description,
                    'score' => $attempt->score,
                    'total_questions' => $attempt->total_questions,
                    'percentage' => $attempt->percentage,
                    'attempt_number' => $attempt->attempt_number,
                    'status' => $attempt->status,
                    'start_time' => $attempt->start_time,
                    'end_time' => $attempt->end_time,
                ],
                'questions' => $questionsWithAnswers
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => $e->getMessage()
            ], 400);
        }
    }
}

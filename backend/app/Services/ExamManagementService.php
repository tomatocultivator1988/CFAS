<?php

namespace App\Services;

use App\Models\Exam;
use App\Models\Question;
use App\Models\AnswerChoice;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\ValidationException;

class ExamManagementService
{
    /**
     * Create a new exam.
     *
     * @param array $data
     * @return Exam
     * @throws ValidationException
     */
    public function createExam(array $data): Exam
    {
        $validator = Validator::make($data, [
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'time_limit_minutes' => 'required|integer|min:1',
            'max_attempts' => 'required|integer|min:1',
            'passing_score' => 'integer|min:0|max:100',
            'randomize_questions' => 'boolean',
            'randomize_choices' => 'boolean',
            'violation_threshold' => 'integer|min:1',
        ]);

        if ($validator->fails()) {
            throw new ValidationException($validator);
        }

        return Exam::create($data);
    }

    /**
     * Update an existing exam.
     *
     * @param int $examId
     * @param array $data
     * @return Exam
     * @throws ValidationException
     */
    public function updateExam(int $examId, array $data): Exam
    {
        $exam = Exam::findOrFail($examId);

        $validator = Validator::make($data, [
            'title' => 'string|max:255',
            'description' => 'nullable|string',
            'time_limit_minutes' => 'integer|min:1',
            'max_attempts' => 'integer|min:1',
            'passing_score' => 'integer|min:0|max:100',
            'randomize_questions' => 'boolean',
            'randomize_choices' => 'boolean',
            'violation_threshold' => 'integer|min:1',
        ]);

        if ($validator->fails()) {
            throw new ValidationException($validator);
        }

        $exam->update($data);
        return $exam->fresh();
    }

    /**
     * Soft delete an exam.
     *
     * @param int $examId
     * @return bool
     */
    public function deleteExam(int $examId): bool
    {
        $exam = Exam::findOrFail($examId);
        $exam->is_deleted = true;
        return $exam->save();
    }

    /**
     * Create a new question with answer choices.
     *
     * @param array $data
     * @return Question
     * @throws ValidationException
     */
    public function createQuestion(array $data): Question
    {
        $validator = Validator::make($data, [
            'question_text' => 'required|string',
            'topic' => 'nullable|string|max:255',
            'difficulty' => 'nullable|in:easy,medium,hard',
            'answer_choices' => 'required|array|min:2|max:6',
            'answer_choices.*.choice_text' => 'required|string',
            'answer_choices.*.is_correct' => 'required|boolean',
            'exam_id' => 'nullable|integer|exists:exams,id',
        ]);

        if ($validator->fails()) {
            throw new ValidationException($validator);
        }

        // Validate exactly one correct answer
        $correctCount = collect($data['answer_choices'])->where('is_correct', true)->count();
        if ($correctCount !== 1) {
            throw ValidationException::withMessages([
                'answer_choices' => ['Exactly one answer choice must be marked as correct.']
            ]);
        }

        return DB::transaction(function () use ($data) {
            $question = Question::create([
                'question_text' => $data['question_text'],
                'topic' => $data['topic'] ?? null,
                'difficulty' => $data['difficulty'] ?? null,
            ]);

            foreach ($data['answer_choices'] as $index => $choice) {
                AnswerChoice::create([
                    'question_id' => $question->id,
                    'choice_text' => $choice['choice_text'],
                    'is_correct' => $choice['is_correct'],
                    'display_order' => $index + 1,
                ]);
            }

            // Attach question to exam if exam_id is provided
            if (isset($data['exam_id'])) {
                $exam = \App\Models\Exam::findOrFail($data['exam_id']);
                $maxOrder = DB::table('exam_questions')
                    ->where('exam_id', $data['exam_id'])
                    ->max('display_order') ?? 0;
                
                DB::table('exam_questions')->insert([
                    'exam_id' => $data['exam_id'],
                    'question_id' => $question->id,
                    'display_order' => $maxOrder + 1,
                ]);
            }

            return $question->load('answerChoices');
        });
    }

    /**
     * Update an existing question and its answer choices.
     *
     * @param int $questionId
     * @param array $data
     * @return Question
     * @throws ValidationException
     */
    public function updateQuestion(int $questionId, array $data): Question
    {
        $question = Question::findOrFail($questionId);

        $validator = Validator::make($data, [
            'question_text' => 'string',
            'topic' => 'nullable|string|max:255',
            'difficulty' => 'nullable|in:easy,medium,hard',
            'answer_choices' => 'array|min:2|max:6',
            'answer_choices.*.id' => 'nullable|integer|exists:answer_choices,id',
            'answer_choices.*.choice_text' => 'required|string',
            'answer_choices.*.is_correct' => 'required|boolean',
        ]);

        if ($validator->fails()) {
            throw new ValidationException($validator);
        }

        // Validate exactly one correct answer if choices provided
        if (isset($data['answer_choices'])) {
            $correctCount = collect($data['answer_choices'])->where('is_correct', true)->count();
            if ($correctCount !== 1) {
                throw ValidationException::withMessages([
                    'answer_choices' => ['Exactly one answer choice must be marked as correct.']
                ]);
            }
        }

        return DB::transaction(function () use ($question, $data) {
            // Update question text and metadata
            $question->update([
                'question_text' => $data['question_text'] ?? $question->question_text,
                'topic' => $data['topic'] ?? $question->topic,
                'difficulty' => $data['difficulty'] ?? $question->difficulty,
            ]);

            // Update answer choices if provided
            if (isset($data['answer_choices'])) {
                $existingChoices = $question->answerChoices()->orderBy('display_order')->get();
                $newChoices = $data['answer_choices'];
                
                // Update existing choices or create new ones
                foreach ($newChoices as $index => $choiceData) {
                    if (isset($existingChoices[$index])) {
                        // Update existing choice
                        $existingChoices[$index]->update([
                            'choice_text' => $choiceData['choice_text'],
                            'is_correct' => $choiceData['is_correct'],
                            'display_order' => $index + 1,
                        ]);
                    } else {
                        // Create new choice if we have more new choices than existing
                        AnswerChoice::create([
                            'question_id' => $question->id,
                            'choice_text' => $choiceData['choice_text'],
                            'is_correct' => $choiceData['is_correct'],
                            'display_order' => $index + 1,
                        ]);
                    }
                }
                
                // Delete extra choices if new list is shorter (only if not referenced)
                if (count($existingChoices) > count($newChoices)) {
                    for ($i = count($newChoices); $i < count($existingChoices); $i++) {
                        try {
                            $existingChoices[$i]->delete();
                        } catch (\Exception $e) {
                            // If deletion fails due to foreign key constraint, just leave it
                            // This means the choice was already selected by students
                        }
                    }
                }
            }

            return $question->fresh()->load('answerChoices');
        });
    }

    /**
     * Delete a question and its answer choices.
     *
     * @param int $questionId
     * @return bool
     */
    public function deleteQuestion(int $questionId): bool
    {
        $question = Question::findOrFail($questionId);
        return $question->delete();
    }

    /**
     * Attach questions to an exam.
     *
     * @param int $examId
     * @param array $questionIds
     * @return Exam
     */
    public function attachQuestionsToExam(int $examId, array $questionIds): Exam
    {
        $exam = Exam::findOrFail($examId);

        $syncData = [];
        foreach ($questionIds as $index => $questionId) {
            $syncData[$questionId] = ['display_order' => $index + 1];
        }

        $exam->questions()->sync($syncData);
        return $exam->load('questions.answerChoices');
    }

    /**
     * Assign exam to reviewees.
     *
     * @param int $examId
     * @param array $revieweeIds
     * @return array
     */
    public function assignExamToReviewees(int $examId, array $revieweeIds): array
    {
        $exam = Exam::findOrFail($examId);

        $validator = Validator::make(['reviewee_ids' => $revieweeIds], [
            'reviewee_ids' => 'required|array',
            'reviewee_ids.*' => 'integer|exists:users,id',
        ]);

        if ($validator->fails()) {
            throw new ValidationException($validator);
        }

        $validRevieweeIds = User::whereIn('id', $revieweeIds)
            ->where('role', 'reviewee')
            ->pluck('id')
            ->map(fn ($id) => (int) $id)
            ->all();

        if (empty($validRevieweeIds)) {
            return [];
        }

        $alreadyAssignedIds = $exam->assignedReviewees()
            ->whereIn('users.id', $validRevieweeIds)
            ->pluck('users.id')
            ->map(fn ($id) => (int) $id)
            ->all();

        $toAssign = array_values(array_diff($validRevieweeIds, $alreadyAssignedIds));

        if (!empty($toAssign)) {
            $exam->assignedReviewees()->attach($toAssign);
        }

        return $toAssign;
    }
}

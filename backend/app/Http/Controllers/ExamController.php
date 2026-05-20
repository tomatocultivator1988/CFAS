<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Services\ExamManagementService;
use App\Models\Exam;
use Illuminate\Validation\ValidationException;

class ExamController extends Controller
{
    protected $examService;

    public function __construct(ExamManagementService $examService)
    {
        $this->examService = $examService;
    }

    /**
     * Get all exams (admin).
     *
     * @return JsonResponse
     */
    public function index(): JsonResponse
    {
        $exams = Exam::notDeleted()
            ->with('questions.answerChoices')
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'exams' => $exams
        ], 200);
    }

    /**
     * Get a single exam by ID.
     *
     * @param int $id
     * @return JsonResponse
     */
    public function show(int $id): JsonResponse
    {
        $exam = Exam::with('questions.answerChoices')
            ->findOrFail($id);

        return response()->json([
            'exam' => $exam
        ], 200);
    }

    /**
     * Create a new exam.
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function store(Request $request): JsonResponse
    {
        try {
            $exam = $this->examService->createExam($request->all());

            return response()->json([
                'message' => 'Exam created successfully.',
                'exam' => $exam
            ], 201);
        } catch (ValidationException $e) {
            return response()->json([
                'message' => 'Validation failed.',
                'errors' => $e->errors()
            ], 422);
        }
    }

    /**
     * Update an existing exam.
     *
     * @param Request $request
     * @param int $id
     * @return JsonResponse
     */
    public function update(Request $request, int $id): JsonResponse
    {
        try {
            $exam = $this->examService->updateExam($id, $request->all());

            return response()->json([
                'message' => 'Exam updated successfully.',
                'exam' => $exam
            ], 200);
        } catch (ValidationException $e) {
            return response()->json([
                'message' => 'Validation failed.',
                'errors' => $e->errors()
            ], 422);
        }
    }

    /**
     * Delete an exam (soft delete).
     *
     * @param int $id
     * @return JsonResponse
     */
    public function destroy(int $id): JsonResponse
    {
        $this->examService->deleteExam($id);

        return response()->json([
            'message' => 'Exam deleted successfully.'
        ], 200);
    }

    /**
     * Attach questions to an exam.
     *
     * @param Request $request
     * @param int $id
     * @return JsonResponse
     */
    public function attachQuestions(Request $request, int $id): JsonResponse
    {
        $request->validate([
            'question_ids' => 'required|array',
            'question_ids.*' => 'integer|exists:questions,id',
        ]);

        $exam = $this->examService->attachQuestionsToExam($id, $request->question_ids);

        return response()->json([
            'message' => 'Questions attached to exam successfully.',
            'exam' => $exam
        ], 200);
    }

    /**
     * Assign exam to reviewees.
     *
     * @param Request $request
     * @param int $id
     * @return JsonResponse
     */
    public function assign(Request $request, int $id): JsonResponse
    {
        try {
            $assigned = $this->examService->assignExamToReviewees($id, $request->reviewee_ids);

            return response()->json([
                'message' => 'Exam assigned successfully.',
                'assigned_count' => count($assigned),
                'assigned_reviewee_ids' => $assigned
            ], 200);
        } catch (ValidationException $e) {
            return response()->json([
                'message' => 'Validation failed.',
                'errors' => $e->errors()
            ], 422);
        }
    }
    
    /**
     * Toggle exam status (active/inactive).
     *
     * @param Request $request
     * @param int $id
     * @return JsonResponse
     */
    public function toggleStatus(Request $request, int $id): JsonResponse
    {
        $exam = Exam::findOrFail($id);
        
        // Toggle between active and inactive
        $newStatus = $exam->status === 'active' ? 'inactive' : 'active';
        $exam->status = $newStatus;
        $exam->save();

        return response()->json([
            'message' => "Exam status changed to {$newStatus}.",
            'exam' => $exam->load('questions.answerChoices')
        ], 200);
    }
}

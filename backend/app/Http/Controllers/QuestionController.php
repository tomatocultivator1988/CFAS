<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Services\ExamManagementService;
use App\Services\AiDocxParserService;
use App\Models\Question;
use Illuminate\Validation\ValidationException;

class QuestionController extends Controller
{
    protected $examService;
    protected $aiParser;

    public function __construct(ExamManagementService $examService, AiDocxParserService $aiParser)
    {
        $this->examService = $examService;
        $this->aiParser = $aiParser;
    }

    /**
     * Get all questions.
     *
     * @return JsonResponse
     */
    public function index(): JsonResponse
    {
        $questions = Question::with('answerChoices')
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'questions' => $questions
        ], 200);
    }

    /**
     * Get a single question by ID.
     *
     * @param int $id
     * @return JsonResponse
     */
    public function show(int $id): JsonResponse
    {
        $question = Question::with('answerChoices')->findOrFail($id);

        return response()->json([
            'question' => $question
        ], 200);
    }

    /**
     * Create a new question.
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function store(Request $request): JsonResponse
    {
        try {
            $question = $this->examService->createQuestion($request->all());

            return response()->json([
                'message' => 'Question created successfully.',
                'question' => $question
            ], 201);
        } catch (ValidationException $e) {
            return response()->json([
                'message' => 'Validation failed.',
                'errors' => $e->errors()
            ], 422);
        }
    }

    /**
     * Bulk create questions.
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function bulkStore(Request $request): JsonResponse
    {
        try {
            $request->validate([
                'questions' => 'required|array',
                'questions.*.question_text' => 'required|string',
                'questions.*.answer_choices' => 'required|array|min:2',
                'questions.*.exam_id' => 'required|integer|exists:exams,id'
            ]);

            $questions = $request->input('questions');
            $created = [];
            $failed = 0;

            foreach ($questions as $questionData) {
                try {
                    $question = $this->examService->createQuestion($questionData);
                    $created[] = $question;
                } catch (\Exception $e) {
                    $failed++;
                }
            }

            return response()->json([
                'success' => true,
                'message' => count($created) . ' questions created successfully.',
                'created_count' => count($created),
                'failed_count' => $failed
            ], 201);
        } catch (ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed.',
                'errors' => $e->errors()
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Update an existing question.
     *
     * @param Request $request
     * @param int $id
     * @return JsonResponse
     */
    public function update(Request $request, int $id): JsonResponse
    {
        try {
            $question = $this->examService->updateQuestion($id, $request->all());

            return response()->json([
                'message' => 'Question updated successfully.',
                'question' => $question
            ], 200);
        } catch (ValidationException $e) {
            return response()->json([
                'message' => 'Validation failed.',
                'errors' => $e->errors()
            ], 422);
        }
    }

    /**
     * Delete a question.
     *
     * @param int $id
     * @return JsonResponse
     */
    public function destroy(int $id): JsonResponse
    {
        $this->examService->deleteQuestion($id);

        return response()->json([
            'message' => 'Question deleted successfully.'
        ], 200);
    }

    /**
     * Import questions from a Word document (.docx) using AI parsing.
     * Saves questions to database in real-time as they're parsed
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function importFromDocx(Request $request): JsonResponse
    {
        try {
            $request->validate([
                'file' => 'required|file|max:20480', // Max 20MB (increased for larger files)
                'exam_id' => 'required|integer|exists:exams,id'
            ]);

            $file = $request->file('file');
            
            // Manual file validation for DOCX and PDF
            $extension = strtolower($file->getClientOriginalExtension());
            $allowedExtensions = ['docx', 'doc', 'pdf'];
            
            if (!in_array($extension, $allowedExtensions)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid file type. Only .docx, .doc, and .pdf files are allowed.',
                    'errors' => ['file' => ['The file must be a Word document (.docx/.doc) or PDF (.pdf)']]
                ], 422);
            }
            
            $examId = $request->input('exam_id');

            // Save the uploaded file temporarily
            $tempDir = storage_path('app/temp');
            if (!file_exists($tempDir)) {
                mkdir($tempDir, 0755, true);
            }
            
            $tempFileName = 'import_' . time() . '_' . uniqid() . '.' . $extension;
            $fullPath = $tempDir . '/' . $tempFileName;
            
            // Use file_put_contents to avoid corruption with large files
            file_put_contents($fullPath, file_get_contents($file->getRealPath()));

            try {
                // Set longer execution time for large documents (2 hours for 1200+ questions)
                set_time_limit(7200); // 2 hours for large files
                ini_set('max_execution_time', 7200);
                ini_set('memory_limit', '1024M'); // Increase memory limit to 1GB
                
                $questions = [];
                
                // Choose parser based on file type
                if ($extension === 'pdf') {
                    // Use PDF parser
                    $pdfParser = new \App\Services\AiPdfParserService();
                    $questions = $pdfParser->parsePdfWithRealTimeSave($fullPath, $examId);
                } else {
                    // Use DOCX parser
                    $questions = $this->aiParser->parseDocxWithRealTimeSave($fullPath, $examId);
                }

                return response()->json([
                    'success' => true,
                    'message' => 'Document parsed and saved successfully',
                    'count' => count($questions),
                    'exam_id' => $examId,
                    'file_type' => $extension
                ], 200);

            } finally {
                // Clean up the temporary file
                if (file_exists($fullPath)) {
                    unlink($fullPath);
                }
            }

        } catch (ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $e->errors()
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error parsing document: ' . $e->getMessage()
            ], 500);
        }
    }
}

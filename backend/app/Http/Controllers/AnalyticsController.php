<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Log;
use App\Services\AnalyticsService;
use App\Services\CacheService;

class AnalyticsController extends Controller
{
    private AnalyticsService $analyticsService;
    private CacheService $cacheService;

    public function __construct()
    {
        $this->analyticsService = new AnalyticsService();
        $this->cacheService = new CacheService();
    }

    /**
     * Add cache-busting headers to response
     *
     * @param JsonResponse $response
     * @return JsonResponse
     */
    private function addNoCacheHeaders(JsonResponse $response): JsonResponse
    {
        return $response->header('Cache-Control', 'no-cache, no-store, must-revalidate')
                       ->header('Pragma', 'no-cache')
                       ->header('Expires', '0');
    }

    /**
     * Get overview metrics (total exams, attempts, reviewees, average score)
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function getOverviewMetrics(Request $request): JsonResponse
    {
        try {
            // Validate time filter
            $timeFilter = $request->input('timeFilter', 'all');
            $validFilters = ['7days', '30days', '3months', 'all'];
            
            if (!in_array($timeFilter, $validFilters)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid time filter. Valid values: 7days, 30days, 3months, all'
                ], 400);
            }

            // Check if cache bypass is requested
            $bypassCache = $request->input('bypassCache', false);
            $cached = false;

            // Use cache with 5-minute TTL or bypass if requested
            $cacheKey = "analytics:overview:{$timeFilter}";
            if ($bypassCache) {
                $data = $this->analyticsService->calculateOverviewMetrics($timeFilter);
            } else {
                $data = $this->cacheService->remember($cacheKey, function () use ($timeFilter) {
                    return $this->analyticsService->calculateOverviewMetrics($timeFilter);
                });
                $cached = true;
            }

            return response()->json([
                'success' => true,
                'data' => $data,
                'timeFilter' => $timeFilter,
                'cached' => $cached
            ]);
        } catch (\Exception $e) {
            Log::error('Get overview metrics failed', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to get overview metrics'
            ], 500);
        }
    }

    /**
     * Get exam performance list with pagination and sorting
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function getExamPerformance(Request $request): JsonResponse
    {
        try {
            // Validate time filter
            $timeFilter = $request->input('timeFilter', 'all');
            $validFilters = ['7days', '30days', '3months', 'all'];
            
            if (!in_array($timeFilter, $validFilters)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid time filter. Valid values: 7days, 30days, 3months, all'
                ], 400);
            }
            
            // Validate pagination
            $page = max(1, (int)$request->input('page', 1));
            
            // Validate sorting
            $sortBy = $request->input('sortBy', 'attempts');
            $validSortFields = ['attempts', 'avgScore', 'passRate'];
            if (!in_array($sortBy, $validSortFields)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid sortBy. Valid values: attempts, avgScore, passRate'
                ], 400);
            }
            
            // Validate order
            $order = $request->input('order', 'desc');
            if (!in_array(strtolower($order), ['asc', 'desc'])) {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid order. Valid values: asc, desc'
                ], 400);
            }
            
            // Check if cache bypass is requested
            $bypassCache = $request->input('bypassCache', false);
            $cached = false;

            // Use cache or bypass if requested
            $cacheKey = "analytics:exams:{$timeFilter}:{$page}:{$sortBy}:{$order}";
            if ($bypassCache) {
                $data = $this->analyticsService->getExamPerformanceList($timeFilter, $sortBy, $order, $page);
            } else {
                $data = $this->cacheService->remember($cacheKey, function () use ($timeFilter, $sortBy, $order, $page) {
                    return $this->analyticsService->getExamPerformanceList($timeFilter, $sortBy, $order, $page);
                });
                $cached = true;
            }
            
            return response()->json([
                'success' => true,
                'data' => $data,
                'timeFilter' => $timeFilter,
                'cached' => $cached
            ]);
        } catch (\Exception $e) {
            Log::error('Get exam performance failed', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to get exam performance'
            ], 500);
        }
    }

    /**
     * Get detailed exam analytics including score distribution
     *
     * @param int $id
     * @param Request $request
     * @return JsonResponse
     */
    public function getExamDetails(int $id, Request $request): JsonResponse
    {
        try {
            // Validate time filter
            $timeFilter = $request->input('timeFilter', 'all');
            $validFilters = ['7days', '30days', '3months', 'all'];
            
            if (!in_array($timeFilter, $validFilters)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid time filter. Valid values: 7days, 30days, 3months, all'
                ], 400);
            }
            
            // Check if cache bypass is requested
            $bypassCache = $request->input('bypassCache', false);
            $cached = false;

            // Use cache or bypass if requested
            $cacheKey = "analytics:exam:{$id}:{$timeFilter}";
            if ($bypassCache) {
                $data = $this->analyticsService->getExamScoreDistribution($id, $timeFilter);
            } else {
                $data = $this->cacheService->remember($cacheKey, function () use ($id, $timeFilter) {
                    return $this->analyticsService->getExamScoreDistribution($id, $timeFilter);
                });
                $cached = true;
            }
            
            // Check if exam exists
            if (empty($data['examTitle'])) {
                return response()->json([
                    'success' => false,
                    'message' => 'Exam not found'
                ], 404);
            }
            
            return response()->json([
                'success' => true,
                'data' => $data,
                'timeFilter' => $timeFilter,
                'cached' => $cached
            ]);
        } catch (\Exception $e) {
            Log::error('Get exam details failed', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to get exam details'
            ], 500);
        }
    }

    /**
     * Get student performance list with filtering and pagination
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function getStudentPerformance(Request $request): JsonResponse
    {
        try {
            // Validate time filter
            $timeFilter = $request->input('timeFilter', 'all');
            $validFilters = ['7days', '30days', '3months', 'all'];
            
            if (!in_array($timeFilter, $validFilters)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid time filter. Valid values: 7days, 30days, 3months, all'
                ], 400);
            }
            
            // Validate performance level filter
            $level = $request->input('level', 'all');
            $validLevels = ['all', 'struggling', 'average', 'top'];
            if (!in_array($level, $validLevels)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid level. Valid values: all, struggling, average, top'
                ], 400);
            }
            
            // Validate pagination
            $page = max(1, (int)$request->input('page', 1));
            
            // Check if cache bypass is requested
            $bypassCache = $request->input('bypassCache', false);
            $cached = false;

            // Use cache or bypass if requested
            $cacheKey = "analytics:students:{$timeFilter}:{$level}:{$page}";
            if ($bypassCache) {
                $data = $this->analyticsService->getStudentPerformanceList($timeFilter, $level, $page);
            } else {
                $data = $this->cacheService->remember($cacheKey, function () use ($timeFilter, $level, $page) {
                    return $this->analyticsService->getStudentPerformanceList($timeFilter, $level, $page);
                });
                $cached = true;
            }
            
            return response()->json([
                'success' => true,
                'data' => $data,
                'timeFilter' => $timeFilter,
                'cached' => $cached
            ]);
        } catch (\Exception $e) {
            Log::error('Get student performance failed', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to get student performance'
            ], 500);
        }
    }

    /**
     * Get student performance trend over time
     *
     * @param int $id
     * @param Request $request
     * @return JsonResponse
     */
    public function getStudentTrend(int $id, Request $request): JsonResponse
    {
        try {
            // Validate time filter
            $timeFilter = $request->input('timeFilter', 'all');
            $validFilters = ['7days', '30days', '3months', 'all'];
            
            if (!in_array($timeFilter, $validFilters)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid time filter. Valid values: 7days, 30days, 3months, all'
                ], 400);
            }
            
            // Check if cache bypass is requested
            $bypassCache = $request->input('bypassCache', false);
            $cached = false;

            // Use cache or bypass if requested
            $cacheKey = "analytics:student:{$id}:{$timeFilter}";
            if ($bypassCache) {
                $data = $this->analyticsService->getStudentTrendData($id, $timeFilter);
            } else {
                $data = $this->cacheService->remember($cacheKey, function () use ($id, $timeFilter) {
                    return $this->analyticsService->getStudentTrendData($id, $timeFilter);
                });
                $cached = true;
            }
            
            // Check if student exists
            if (empty($data['studentName'])) {
                return response()->json([
                    'success' => false,
                    'message' => 'Student not found'
                ], 404);
            }
            
            return response()->json([
                'success' => true,
                'data' => $data,
                'timeFilter' => $timeFilter,
                'cached' => $cached
            ]);
        } catch (\Exception $e) {
            Log::error('Get student trend failed', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to get student trend'
            ], 500);
        }
    }

    /**
     * Get question difficulty analysis for an exam
     *
     * @param int $examId
     * @param Request $request
     * @return JsonResponse
     */
    public function getQuestionAnalysis(int $examId, Request $request): JsonResponse
    {
        try {
            // Validate time filter
            $timeFilter = $request->input('timeFilter', 'all');
            $validFilters = ['7days', '30days', '3months', 'all'];
            
            if (!\in_array($timeFilter, $validFilters)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid time filter. Valid values: 7days, 30days, 3months, all'
                ], 400);
            }
            
            // Validate difficulty filter (optional)
            $difficultyFilter = $request->input('difficulty', 'all');
            $validDifficulties = ['all', 'difficult', 'easy'];
            if (!\in_array($difficultyFilter, $validDifficulties)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid difficulty filter. Valid values: all, difficult, easy'
                ], 400);
            }
            
            // Check if cache bypass is requested
            $bypassCache = $request->input('bypassCache', false);
            $cached = false;

            // Use cache or bypass if requested
            $cacheKey = "analytics:questions:{$examId}:{$timeFilter}:{$difficultyFilter}";
            if ($bypassCache) {
                $data = $this->analyticsService->getQuestionDifficultyAnalysis($examId, $timeFilter);
            } else {
                $data = $this->cacheService->remember($cacheKey, fn() => 
                    $this->analyticsService->getQuestionDifficultyAnalysis($examId, $timeFilter)
                );
                $cached = true;
            }
            
            // Check if exam exists
            if (empty($data['examTitle'])) {
                return response()->json([
                    'success' => false,
                    'message' => 'Exam not found'
                ], 404);
            }
            
            // Apply difficulty filtering if requested
            if ($difficultyFilter !== 'all') {
                $data['questions'] = array_filter($data['questions'], function($question) use ($difficultyFilter) {
                    return $question['difficultyLevel'] === $difficultyFilter;
                });
                $data['questions'] = array_values($data['questions']); // Re-index array
            }
            
            return response()->json([
                'success' => true,
                'data' => $data,
                'timeFilter' => $timeFilter,
                'difficultyFilter' => $difficultyFilter,
                'cached' => $cached
            ]);
        } catch (\Exception $e) {
            Log::error('Get question analysis failed', [
                'examId' => $examId,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to get question analysis'
            ], 500);
        }
    }

    /**
     * Get trend analysis data with category comparison
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function getTrendData(Request $request): JsonResponse
    {
        try {
            // Validate time filter
            $timeFilter = $request->input('timeFilter', 'all');
            $validFilters = ['7days', '30days', '3months', 'all'];
            
            if (!\in_array($timeFilter, $validFilters)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid time filter. Valid values: 7days, 30days, 3months, all'
                ], 400);
            }
            
            // Parse categories (comma-separated string or array)
            $categoriesInput = $request->input('categories', 'all');
            $categories = [];
            
            if (is_string($categoriesInput)) {
                if ($categoriesInput === 'all' || empty($categoriesInput)) {
                    $categories = ['all'];
                } else {
                    $categories = array_map('trim', explode(',', $categoriesInput));
                }
            } elseif (is_array($categoriesInput)) {
                $categories = $categoriesInput;
            } else {
                $categories = ['all'];
            }
            
            // Check if cache bypass is requested
            $bypassCache = $request->input('bypassCache', false);
            $cached = false;

            // Use cache or bypass if requested
            $categoriesKey = implode(',', $categories);
            $cacheKey = "analytics:trends:{$timeFilter}:{$categoriesKey}";
            if ($bypassCache) {
                $data = $this->analyticsService->getTrendAnalysis($timeFilter, $categories);
            } else {
                $data = $this->cacheService->remember($cacheKey, fn() => 
                    $this->analyticsService->getTrendAnalysis($timeFilter, $categories)
                );
                $cached = true;
            }
            
            return response()->json([
                'success' => true,
                'data' => $data,
                'timeFilter' => $timeFilter,
                'cached' => $cached
            ]);
        } catch (\Exception $e) {
            Log::error('Get trend data failed', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to get trend data'
            ], 500);
        }
    }

    /**
     * Get top 10 performers by average score
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function getTopPerformers(Request $request): JsonResponse
    {
        try {
            // Validate time filter
            $timeFilter = $request->input('timeFilter', 'all');
            $validFilters = ['7days', '30days', '3months', 'all'];
            
            if (!in_array($timeFilter, $validFilters)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid time filter. Valid values: 7days, 30days, 3months, all'
                ], 400);
            }
            
            // Check if cache bypass is requested
            $bypassCache = $request->input('bypassCache', false);
            $cached = false;

            // Use cache or bypass if requested
            $cacheKey = "analytics:top-performers:{$timeFilter}";
            if ($bypassCache) {
                $data = $this->analyticsService->getTopPerformers($timeFilter);
            } else {
                $data = $this->cacheService->remember($cacheKey, function () use ($timeFilter) {
                    return $this->analyticsService->getTopPerformers($timeFilter);
                });
                $cached = true;
            }
            
            return response()->json([
                'success' => true,
                'data' => $data,
                'timeFilter' => $timeFilter,
                'cached' => $cached
            ]);
        } catch (\Exception $e) {
            Log::error('Get top performers failed', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to get top performers'
            ], 500);
        }
    }

    /**
     * Get comprehensive dashboard summary with all key metrics
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function getDashboardSummary(Request $request): JsonResponse
    {
        try {
            // Validate time filter
            $timeFilter = $request->input('timeFilter', 'all');
            $validFilters = ['7days', '30days', '3months', 'all'];
            
            if (!in_array($timeFilter, $validFilters)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid time filter. Valid values: 7days, 30days, 3months, all'
                ], 400);
            }
            
            // Check if cache bypass is requested
            $bypassCache = $request->input('bypassCache', false);
            $cached = false;

            // Use cache or bypass if requested
            $cacheKey = "analytics:dashboard-summary:{$timeFilter}";
            if ($bypassCache) {
                $data = $this->analyticsService->getDashboardSummary($timeFilter);
            } else {
                $data = $this->cacheService->remember($cacheKey, function () use ($timeFilter) {
                    return $this->analyticsService->getDashboardSummary($timeFilter);
                });
                $cached = true;
            }
            
            return response()->json([
                'success' => true,
                'data' => $data,
                'timeFilter' => $timeFilter,
                'cached' => $cached
            ]);
        } catch (\Exception $e) {
            Log::error('Get dashboard summary failed', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to get dashboard summary'
            ], 500);
        }
    }

    /**
     * Export analytics data to CSV
     *
     * @param Request $request
     * @return JsonResponse|\Illuminate\Http\Response
     */
    public function exportData(Request $request)
    {
        try {
            // Validate export type
            $exportType = $request->input('type');
            $validTypes = ['exams', 'students', 'questions', 'trends'];
            
            if (!\in_array($exportType, $validTypes)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid export type. Valid values: exams, students, questions, trends'
                ], 400);
            }
            
            // Validate time filter
            $timeFilter = $request->input('timeFilter', 'all');
            $validFilters = ['7days', '30days', '3months', 'all'];
            
            if (!\in_array($timeFilter, $validFilters)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid time filter. Valid values: 7days, 30days, 3months, all'
                ], 400);
            }
            
            // Create CSV export service
            $csvService = new \App\Services\CsvExportService();
            
            // Generate data based on export type
            switch ($exportType) {
                case 'exams':
                    $data = $this->exportExamData($timeFilter, $request, $csvService);
                    break;
                case 'students':
                    $data = $this->exportStudentData($timeFilter, $request, $csvService);
                    break;
                case 'questions':
                    $data = $this->exportQuestionData($timeFilter, $request, $csvService);
                    break;
                case 'trends':
                    $data = $this->exportTrendData($timeFilter, $request, $csvService);
                    break;
                default:
                    return response()->json([
                        'success' => false,
                        'message' => 'Export type not implemented'
                    ], 400);
            }
            
            // Check if data limit exceeded (10,000 rows)
            if (count($data['data']) > 10000) {
                return response()->json([
                    'success' => false,
                    'message' => 'Export data exceeds 10,000 rows limit. Please use time filters to reduce data.'
                ], 413);
            }
            
            // Generate CSV content
            $csvContent = $csvService->generateCsv($data['data'], $data['headers']);
            
            // Create filename
            $timestamp = date('Y-m-d_H-i-s');
            $filename = "analytics_{$exportType}_{$timeFilter}_{$timestamp}.csv";
            
            // Return CSV download response
            return $csvService->createDownloadResponse($csvContent, $filename);
            
        } catch (\Exception $e) {
            Log::error('Export data failed', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to export data'
            ], 500);
        }
    }
    
    /**
     * Export exam performance data
     *
     * @param string $timeFilter
     * @param Request $request
     * @param \App\Services\CsvExportService $csvService
     * @return array
     */
    private function exportExamData(string $timeFilter, Request $request, \App\Services\CsvExportService $csvService): array
    {
        // Get all exam data (no pagination for export)
        $sortBy = $request->input('sortBy', 'attempts');
        $order = $request->input('order', 'desc');
        
        // Get large dataset by fetching multiple pages
        $allExams = [];
        $page = 1;
        $maxPages = 200; // Limit to prevent infinite loop (200 * 50 = 10,000 max)
        
        do {
            $examData = $this->analyticsService->getExamPerformanceList($timeFilter, $sortBy, $order, $page);
            $allExams = array_merge($allExams, $examData['exams']);
            $page++;
        } while ($page <= $examData['pagination']['totalPages'] && $page <= $maxPages && count($allExams) < 10000);
        
        return $csvService->formatExamPerformanceData($allExams, $timeFilter);
    }
    
    /**
     * Export student performance data
     *
     * @param string $timeFilter
     * @param Request $request
     * @param \App\Services\CsvExportService $csvService
     * @return array
     */
    private function exportStudentData(string $timeFilter, Request $request, \App\Services\CsvExportService $csvService): array
    {
        // Get all student data (no pagination for export)
        $level = $request->input('level', 'all');
        
        // Get large dataset by fetching multiple pages
        $allStudents = [];
        $page = 1;
        $maxPages = 200; // Limit to prevent infinite loop
        
        do {
            $studentData = $this->analyticsService->getStudentPerformanceList($timeFilter, $level, $page);
            $allStudents = array_merge($allStudents, $studentData['students']);
            $page++;
        } while ($page <= $studentData['pagination']['totalPages'] && $page <= $maxPages && count($allStudents) < 10000);
        
        return $csvService->formatStudentPerformanceData($allStudents, $timeFilter);
    }
    
    /**
     * Export question analysis data
     *
     * @param string $timeFilter
     * @param Request $request
     * @param \App\Services\CsvExportService $csvService
     * @return array
     */
    private function exportQuestionData(string $timeFilter, Request $request, \App\Services\CsvExportService $csvService): array
    {
        $examId = $request->input('examId');
        
        if (!$examId) {
            throw new \InvalidArgumentException('examId is required for question export');
        }
        
        $questionData = $this->analyticsService->getQuestionDifficultyAnalysis($examId, $timeFilter);
        
        return $csvService->formatQuestionAnalysisData(
            $questionData['questions'], 
            $questionData['examTitle'], 
            $timeFilter
        );
    }
    
    /**
     * Export trend analysis data
     *
     * @param string $timeFilter
     * @param Request $request
     * @param \App\Services\CsvExportService $csvService
     * @return array
     */
    private function exportTrendData(string $timeFilter, Request $request, \App\Services\CsvExportService $csvService): array
    {
        // Parse categories
        $categoriesInput = $request->input('categories', 'all');
        $categories = [];
        
        if (is_string($categoriesInput)) {
            if ($categoriesInput === 'all' || empty($categoriesInput)) {
                $categories = ['all'];
            } else {
                $categories = array_map('trim', explode(',', $categoriesInput));
            }
        } elseif (is_array($categoriesInput)) {
            $categories = $categoriesInput;
        } else {
            $categories = ['all'];
        }
        
        $trendData = $this->analyticsService->getTrendAnalysis($timeFilter, $categories);
        
        return $csvService->formatTrendAnalysisData($trendData['trendData'], $timeFilter);
    }
    
    /**
     * Get attempt review for admin (questions, answers, and results)
     * Admin can view any student's attempt review
     *
     * @param Request $request
     * @param int $attemptId
     * @return JsonResponse
     */
    public function getAttemptReview(Request $request, int $attemptId): JsonResponse
    {
        try {
            // Get the attempt (admin can view any attempt)
            $attempt = \App\Models\ExamAttempt::where('id', $attemptId)
                ->whereIn('status', ['completed', 'auto_submitted'])
                ->with([
                    'exam:id,title,description,randomize_questions,randomize_choices',
                    'reviewee:id,first_name,last_name,username'
                ])
                ->firstOrFail();
            
            // Combine first and last name
            $studentName = trim($attempt->reviewee->first_name . ' ' . $attempt->reviewee->last_name);
            
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
                    'student_name' => $studentName,
                    'student_username' => $attempt->reviewee->username,
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
            Log::error('Get attempt review failed', [
                'attempt_id' => $attemptId,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            
            return response()->json([
                'success' => false,
                'message' => 'Failed to load attempt review: ' . $e->getMessage()
            ], 400);
        }
    }
}

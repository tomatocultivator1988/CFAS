<?php

namespace App\Services;

use Illuminate\Support\Facades\Log;

class CacheInvalidationService
{
    private CacheService $cacheService;

    public function __construct(CacheService $cacheService)
    {
        $this->cacheService = $cacheService;
    }

    /**
     * Invalidate all cache keys affected by an exam completion
     *
     * @param int $examId
     * @param int $studentId
     * @param string $category
     * @return void
     */
    public function invalidateExamCompletion(int $examId, int $studentId, string $category): void
    {
        $startTime = microtime(true);
        
        // Get all affected cache keys
        $affectedKeys = $this->getAffectedCacheKeys($examId, $studentId, $category);
        
        // Invalidate all affected keys
        foreach ($affectedKeys as $key) {
            $this->cacheService->forget($key);
        }
        
        $duration = round((microtime(true) - $startTime) * 1000, 2);
        
        // Log the invalidation
        $this->logInvalidation($examId, $studentId, $category, $affectedKeys, $duration);
    }

    /**
     * Get all cache keys affected by an exam completion
     *
     * @param int $examId
     * @param int $studentId
     * @param string $category
     * @return array
     */
    private function getAffectedCacheKeys(int $examId, int $studentId, string $category): array
    {
        $keys = [];
        $timeFilters = ['7days', '30days', '3months', 'all'];
        
        // 1. Overview metrics - all time filters
        foreach ($timeFilters as $filter) {
            $keys[] = "analytics:overview:{$filter}";
        }
        
        // 2. Exam performance lists - all variations
        foreach ($timeFilters as $filter) {
            // We need to invalidate all pages and sort combinations
            // Pattern: analytics:exams:{timeFilter}:{page}:{sortBy}:{order}
            $sortFields = ['attempts', 'avgScore', 'passRate'];
            $orders = ['asc', 'desc'];
            
            for ($page = 1; $page <= 10; $page++) { // Assume max 10 pages
                foreach ($sortFields as $sortBy) {
                    foreach ($orders as $order) {
                        $keys[] = "analytics:exams:{$filter}:{$page}:{$sortBy}:{$order}";
                    }
                }
            }
        }
        
        // 3. Exam-specific details - this exam, all time filters
        foreach ($timeFilters as $filter) {
            $keys[] = "analytics:exam:{$examId}:{$filter}";
        }
        
        // 4. Student performance lists - all variations
        foreach ($timeFilters as $filter) {
            $levels = ['all', 'struggling', 'average', 'top'];
            for ($page = 1; $page <= 10; $page++) {
                foreach ($levels as $level) {
                    $keys[] = "analytics:students:{$filter}:{$level}:{$page}";
                }
            }
        }
        
        // 5. Student-specific trends - this student, all time filters
        foreach ($timeFilters as $filter) {
            $keys[] = "analytics:student:{$studentId}:{$filter}";
        }
        
        // 6. Question analysis - this exam, all time filters
        foreach ($timeFilters as $filter) {
            $difficulties = ['all', 'difficult', 'easy'];
            foreach ($difficulties as $difficulty) {
                $keys[] = "analytics:questions:{$examId}:{$filter}:{$difficulty}";
            }
        }
        
        // 7. Trend analysis - include this category and 'all'
        foreach ($timeFilters as $filter) {
            // Category-specific trends
            $keys[] = "analytics:trends:{$filter}:{$category}";
            // All categories trends
            $keys[] = "analytics:trends:{$filter}:all";
        }
        
        // 8. Dashboard summary - all time filters
        foreach ($timeFilters as $filter) {
            $keys[] = "analytics:dashboard-summary:{$filter}";
        }
        
        // 9. Top performers - all time filters
        foreach ($timeFilters as $filter) {
            $keys[] = "analytics:top-performers:{$filter}";
        }
        
        return $keys;
    }

    /**
     * Log cache invalidation for monitoring
     *
     * @param int $examId
     * @param int $studentId
     * @param string $category
     * @param array $keys
     * @param float $duration
     * @return void
     */
    private function logInvalidation(int $examId, int $studentId, string $category, array $keys, float $duration): void
    {
        Log::info('Analytics cache invalidated', [
            'event' => 'exam_completion',
            'exam_id' => $examId,
            'student_id' => $studentId,
            'category' => $category,
            'key_count' => count($keys),
            'duration_ms' => $duration,
            'timestamp' => now()->toDateTimeString()
        ]);
    }
}

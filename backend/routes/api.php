<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\ExamController;
use App\Http\Controllers\QuestionController;
use App\Http\Controllers\RevieweeExamController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\AnalyticsController;
use App\Http\Controllers\MlPredictiveController;
use App\Http\Controllers\AdminAttemptController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// Health check endpoint (no auth required)
Route::get('/health', function () {
    return response()->json([
        'status' => 'ok',
        'message' => 'CFAS Exam System API is running',
        'timestamp' => now()->toIso8601String(),
        'version' => '1.0.0'
    ]);
});

// Authentication routes (rate limited)
Route::middleware(['log.api', 'sanitize'])->group(function () {
    Route::post('/auth/login', [AuthController::class, 'login'])->middleware('throttle:login');
});

// Protected routes (require authentication)
Route::middleware(['auth.token', 'log.api', 'sanitize'])->group(function () {
    
    // Auth validation and logout
    Route::get('/auth/validate', [AuthController::class, 'validateSession']);
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::get('/auth/me', [AuthController::class, 'me']);
    Route::put('/auth/email', [AuthController::class, 'updateEmail']);
    Route::post('/auth/change-password', [AuthController::class, 'changePassword']);
    
    // Reviewee routes (with IP restriction for exam taking)
    Route::prefix('reviewee')->middleware('role:reviewee')->group(function () {
        Route::get('/exams', [RevieweeExamController::class, 'getAssignedExams']);
        Route::get('/exam-history', [RevieweeExamController::class, 'getExamHistory']);
        Route::get('/attempts/{id}/review', [RevieweeExamController::class, 'getAttemptReview']);
        
        // Exam taking routes
        Route::post('/exams/{id}/start', [RevieweeExamController::class, 'startExam'])->middleware('throttle:exam-actions');
        Route::get('/attempts/{id}', [RevieweeExamController::class, 'getAttempt']);
        Route::post('/attempts/{id}/answers', [RevieweeExamController::class, 'submitAnswer'])->middleware('throttle:exam-actions');
        Route::post('/attempts/{id}/submit', [RevieweeExamController::class, 'submitExam'])->middleware('throttle:exam-actions');
        Route::get('/attempts/{id}/time', [RevieweeExamController::class, 'getRemainingTime']);
        Route::post('/attempts/{id}/violations', [RevieweeExamController::class, 'reportViolation'])->middleware('throttle:exam-actions');
        Route::get('/attempts/{id}/violations', [RevieweeExamController::class, 'getViolationCount']);
    });
    
    // Admin routes
    Route::prefix('admin')->middleware('role:admin')->group(function () {
        
        // Exam management
        Route::get('/exams', [ExamController::class, 'index']);
        Route::get('/exams/{id}', [ExamController::class, 'show']);
        Route::post('/exams', [ExamController::class, 'store']);
        Route::put('/exams/{id}', [ExamController::class, 'update']);
        Route::delete('/exams/{id}', [ExamController::class, 'destroy']);
        Route::post('/exams/{id}/questions', [ExamController::class, 'attachQuestions']);
        Route::post('/exams/{id}/assign', [ExamController::class, 'assign']);
        Route::post('/exams/{id}/toggle-status', [ExamController::class, 'toggleStatus']);
        
        // Question management
        Route::get('/questions', [QuestionController::class, 'index']);
        Route::get('/questions/{id}', [QuestionController::class, 'show']);
        Route::post('/questions', [QuestionController::class, 'store']);
        Route::post('/questions/bulk', [QuestionController::class, 'bulkStore']);
        Route::put('/questions/{id}', [QuestionController::class, 'update']);
        Route::delete('/questions/{id}', [QuestionController::class, 'destroy']);
        Route::post('/questions/import-docx', [QuestionController::class, 'importFromDocx']);
        
        // User management
        Route::get('/users', [UserController::class, 'index']);
        Route::post('/users', [UserController::class, 'store']);
        Route::post('/users/send-score-summary-bulk', [UserController::class, 'sendScoreSummaryBulk']);
        Route::get('/users/{id}', [UserController::class, 'show']);
        Route::put('/users/{id}', [UserController::class, 'update']);
        Route::delete('/users/{id}', [UserController::class, 'destroy']);
        Route::delete('/users/{id}/permanent', [UserController::class, 'permanentlyDelete']);
        Route::post('/users/{id}/reset-password', [UserController::class, 'resetPassword']);
        Route::post('/users/{id}/send-score-summary', [UserController::class, 'sendScoreSummary']);
        Route::get('/users/{id}/audit-log', [UserController::class, 'auditLog']);
        
        // Export routes
        Route::get('/export/all-results', [\App\Http\Controllers\ExportController::class, 'exportAllResults']);
        Route::get('/export/all-attempts', [\App\Http\Controllers\ExportController::class, 'getAllAttempts']);
        Route::get('/export/user-performance', [\App\Http\Controllers\ExportController::class, 'exportUserPerformance']);
        Route::get('/export/exam-analytics', [\App\Http\Controllers\ExportController::class, 'exportExamAnalytics']);
        Route::get('/export/category-exam-data', [\App\Http\Controllers\ExportController::class, 'getCategoryExamData']);
        Route::get('/export/professional-results', [\App\Http\Controllers\ExportController::class, 'exportProfessionalResults']);
        Route::get('/export/xlsx', [\App\Http\Controllers\ExportController::class, 'exportXlsx']);
        
        // Dashboard stats
        Route::get('/dashboard/stats', function () {
            $examStats = DB::table('exams')
                ->selectRaw('
                    SUM(CASE WHEN is_deleted = 0 THEN 1 ELSE 0 END) as total_exams,
                    SUM(CASE WHEN is_deleted = 0 AND status = ? THEN 1 ELSE 0 END) as active_exams
                ', ['active'])
                ->first();

            $userStats = DB::table('users')
                ->selectRaw('
                    COUNT(*) as total_users,
                    SUM(CASE WHEN is_active = 1 AND role = ? THEN 1 ELSE 0 END) as active_users
                ', ['reviewee'])
                ->first();

            $attemptStats = DB::table('exam_attempts')
                ->selectRaw('
                    COUNT(*) as total_attempts,
                    SUM(CASE WHEN status = ? AND end_time >= ? THEN 1 ELSE 0 END) as recent_submissions
                ', ['completed', now()->subDay()])
                ->first();

            $totalQuestions = DB::table('questions')->count();

            return response()->json([
                'totalExams' => (int) ($examStats->total_exams ?? 0),
                'activeExams' => (int) ($examStats->active_exams ?? 0),
                'totalQuestions' => $totalQuestions,
                'totalUsers' => (int) ($userStats->total_users ?? 0),
                'activeUsers' => (int) ($userStats->active_users ?? 0),
                'totalAttempts' => (int) ($attemptStats->total_attempts ?? 0),
                'recentSubmissions' => (int) ($attemptStats->recent_submissions ?? 0),
            ]);
        });

        Route::get('/attempts/count', function () {
            $count = \App\Models\ExamAttempt::count();
            return response()->json(['count' => $count]);
        });

        // Maintenance: hard delete attempts for hidden/orphan exams
        Route::delete('/attempts/purge-hidden', [AdminAttemptController::class, 'purgeHiddenOrOrphanAttempts']);
        
        Route::get('/system/storage', function () {
            $storagePath = storage_path();
            $totalSpace = disk_total_space($storagePath);
            $freeSpace = disk_free_space($storagePath);
            $usedSpace = $totalSpace - $freeSpace;
            $usedPercentage = round(($usedSpace / $totalSpace) * 100, 1);
            
            return response()->json([
                'total' => $totalSpace,
                'used' => $usedSpace,
                'free' => $freeSpace,
                'percentage' => $usedPercentage,
                'formatted' => $usedPercentage . '% Used'
            ]);
        });
    });
    
    // Analytics routes (separate from admin prefix to avoid conflicts)
    Route::middleware('role:admin')->group(function () {
        // Analytics Dashboard (New)
        Route::get('/analytics/overview', [AnalyticsController::class, 'getOverviewMetrics']);
        Route::get('/analytics/exams', [AnalyticsController::class, 'getExamPerformance']);
        Route::get('/analytics/exams/{id}/details', [AnalyticsController::class, 'getExamDetails']);
        Route::get('/analytics/students', [AnalyticsController::class, 'getStudentPerformance']);
        Route::get('/analytics/students/{id}/trend', [AnalyticsController::class, 'getStudentTrend']);
        Route::get('/analytics/questions/{examId}', [AnalyticsController::class, 'getQuestionAnalysis']);
        Route::get('/analytics/trends', [AnalyticsController::class, 'getTrendData']);
        Route::get('/analytics/top-performers', [AnalyticsController::class, 'getTopPerformers']);
        Route::get('/analytics/dashboard-summary', [AnalyticsController::class, 'getDashboardSummary']);
        Route::get('/analytics/ml-predictions', [MlPredictiveController::class, 'getPredictions']);
        Route::post('/analytics/export', [AnalyticsController::class, 'exportData']);
        
        // Legacy Analytics (Old - kept for backward compatibility)
        Route::get('/analytics/reviewees/{id}/scores', [AnalyticsController::class, 'getRevieweeScores']);
        Route::get('/analytics/exams/{id}/average', [AnalyticsController::class, 'getExamAverage']);
        Route::get('/analytics/reviewees/{id}/trends', [AnalyticsController::class, 'getPerformanceTrends']);
        Route::get('/analytics/reviewees/{id}/topics', [AnalyticsController::class, 'getTopicPerformance']);
        Route::get('/analytics/exams/{id}/rankings', [AnalyticsController::class, 'getComparativeRankings']);
        Route::get('/analytics/attempts/{id}/review', [AnalyticsController::class, 'getAttemptReview']);
        Route::delete('/analytics/attempts/{id}', [AnalyticsController::class, 'deleteAttempt']);
    });
});

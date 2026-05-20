<?php

require_once 'backend/vendor/autoload.php';

// Load Laravel environment
$app = require_once 'backend/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Services\AnalyticsService;
use Illuminate\Support\Facades\DB;

echo "=== TESTING ANALYTICS PASSING SCORE FIX ===\n\n";

// 1. Check if we have the Aquaculture Reviewer exam
echo "1. Looking for Aquaculture Reviewer exam...\n";
$aquaExam = DB::table('exams')
    ->where('title', 'LIKE', '%Aquaculture%')
    ->where('is_deleted', 0)
    ->first();

if ($aquaExam) {
    echo "✓ Found exam: {$aquaExam->title}\n";
    echo "  ID: {$aquaExam->id}\n";
    echo "  Passing Score in DB: {$aquaExam->passing_score}\n";
} else {
    echo "✗ Aquaculture exam not found\n";
    exit(1);
}

// 2. Test Analytics Service
echo "\n2. Testing AnalyticsService...\n";
$analyticsService = new AnalyticsService();

// Test exam performance list
echo "  Testing getExamPerformanceList...\n";
$performanceData = $analyticsService->getExamPerformanceList('all', 'attempts', 'desc', 1);

$foundAquaExam = false;
foreach ($performanceData['exams'] as $exam) {
    if (strpos($exam['title'], 'Aquaculture') !== false) {
        echo "  ✓ Found Aquaculture exam in performance list:\n";
        echo "    Title: {$exam['title']}\n";
        echo "    Passing Score from Analytics: {$exam['passingScore']}\n";
        echo "    Total Attempts: {$exam['totalAttempts']}\n";
        echo "    Average Score: {$exam['averageScore']}\n";
        echo "    Pass Rate: {$exam['passRate']}%\n";
        
        if ($exam['passingScore'] == $aquaExam->passing_score) {
            echo "  ✓ Passing score matches database!\n";
        } else {
            echo "  ✗ Passing score mismatch! Expected: {$aquaExam->passing_score}, Got: {$exam['passingScore']}\n";
        }
        
        $foundAquaExam = true;
        break;
    }
}

if (!$foundAquaExam) {
    echo "  ✗ Aquaculture exam not found in performance list\n";
}

// 3. Test score distribution
echo "\n3. Testing getExamScoreDistribution...\n";
$distributionData = $analyticsService->getExamScoreDistribution($aquaExam->id, 'all');

echo "  Exam Title: {$distributionData['examTitle']}\n";
echo "  Passing Score from Distribution: {$distributionData['passingScore']}\n";

if ($distributionData['passingScore'] == $aquaExam->passing_score) {
    echo "  ✓ Distribution passing score matches database!\n";
} else {
    echo "  ✗ Distribution passing score mismatch! Expected: {$aquaExam->passing_score}, Got: {$distributionData['passingScore']}\n";
}

// 4. Test with direct API call simulation
echo "\n4. Testing direct database query...\n";
$directQuery = DB::table('exams as e')
    ->leftJoin('exam_attempts as ea', function($join) {
        $join->on('e.id', '=', 'ea.exam_id')
             ->where('ea.status', '=', 'completed');
    })
    ->select(
        'e.id',
        'e.title',
        'e.passing_score',
        DB::raw('COUNT(ea.id) as total_attempts'),
        DB::raw('COALESCE(AVG(ea.percentage), 0) as average_score'),
        DB::raw('COALESCE(
            SUM(CASE WHEN ea.percentage >= e.passing_score THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(ea.id), 0),
            0
        ) as pass_rate')
    )
    ->where('e.id', $aquaExam->id)
    ->groupBy('e.id', 'e.title', 'e.passing_score')
    ->first();

if ($directQuery) {
    echo "  ✓ Direct query results:\n";
    echo "    Title: {$directQuery->title}\n";
    echo "    Passing Score: {$directQuery->passing_score}\n";
    echo "    Total Attempts: {$directQuery->total_attempts}\n";
    echo "    Average Score: " . round($directQuery->average_score, 2) . "\n";
    echo "    Pass Rate: " . round($directQuery->pass_rate, 2) . "%\n";
}

echo "\n=== TEST COMPLETE ===\n";
echo "The analytics should now show the correct passing score from the database.\n";
echo "Refresh the analytics page at http://192.168.11.40/exam-frontend to see the fix.\n";
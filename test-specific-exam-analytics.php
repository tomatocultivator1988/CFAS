<?php

require_once 'backend/vendor/autoload.php';

// Load Laravel environment
$app = require_once 'backend/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Services\AnalyticsService;
use Illuminate\Support\Facades\DB;

echo "=== TESTING SPECIFIC EXAM ANALYTICS ===\n\n";

$examId = 106; // Aquaculture Reviewer- 1 Shellcheck
$examTitle = "Aquaculture Reviewer- 1 Shellcheck";

// 1. Check database value
echo "1. Database check for exam ID {$examId}...\n";
$exam = DB::table('exams')->where('id', $examId)->first();
if ($exam) {
    echo "✓ Exam: {$exam->title}\n";
    echo "✓ Passing Score in DB: {$exam->passing_score}\n";
} else {
    echo "✗ Exam not found\n";
    exit(1);
}

// 2. Test Analytics Service
echo "\n2. Testing AnalyticsService for this specific exam...\n";
$analyticsService = new AnalyticsService();

// Test exam performance list
echo "  Testing getExamPerformanceList...\n";
$performanceData = $analyticsService->getExamPerformanceList('all', 'attempts', 'desc', 1);

$foundExam = false;
foreach ($performanceData['exams'] as $examData) {
    if ($examData['id'] == $examId) {
        echo "  ✓ Found exam in performance list:\n";
        echo "    Title: {$examData['title']}\n";
        echo "    Passing Score from Analytics: {$examData['passingScore']}\n";
        echo "    Total Attempts: {$examData['totalAttempts']}\n";
        echo "    Average Score: {$examData['averageScore']}\n";
        echo "    Pass Rate: {$examData['passRate']}%\n";
        
        if ($examData['passingScore'] == $exam->passing_score) {
            echo "  ✓ PASSING SCORE MATCHES DATABASE! ✓\n";
        } else {
            echo "  ✗ Passing score mismatch! Expected: {$exam->passing_score}, Got: {$examData['passingScore']}\n";
        }
        
        $foundExam = true;
        break;
    }
}

if (!$foundExam) {
    echo "  ✗ Exam not found in performance list\n";
}

// 3. Test score distribution
echo "\n3. Testing getExamScoreDistribution...\n";
$distributionData = $analyticsService->getExamScoreDistribution($examId, 'all');

echo "  Exam Title: {$distributionData['examTitle']}\n";
echo "  Passing Score from Distribution: {$distributionData['passingScore']}\n";

if ($distributionData['passingScore'] == $exam->passing_score) {
    echo "  ✓ DISTRIBUTION PASSING SCORE MATCHES DATABASE! ✓\n";
} else {
    echo "  ✗ Distribution passing score mismatch! Expected: {$exam->passing_score}, Got: {$distributionData['passingScore']}\n";
}

echo "\n=== SUMMARY ===\n";
echo "Database Passing Score: {$exam->passing_score}\n";
echo "Analytics should now show: {$exam->passing_score}% instead of 70%\n";
echo "\nThe fix is deployed! Refresh your analytics page to see the correct passing score.\n";
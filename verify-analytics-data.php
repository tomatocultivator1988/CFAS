<?php

require __DIR__ . '/backend/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/backend/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "=== Verifying Analytics Data ===\n\n";

// Count attempts
$totalAttempts = DB::table('exam_attempts')->where('status', 'completed')->count();
echo "Total Completed Attempts: {$totalAttempts}\n";

// Count answers
$totalAnswers = DB::table('attempt_answers')->count();
echo "Total Answers: {$totalAnswers}\n";

// Average score
$avgScore = DB::table('exam_attempts')->where('status', 'completed')->avg('percentage');
echo "Average Score: " . round($avgScore, 2) . "%\n";

// Score distribution
echo "\nScore Distribution:\n";
$distribution = DB::table('exam_attempts')
    ->select(
        DB::raw("CASE 
            WHEN percentage BETWEEN 0 AND 50 THEN '0-50%'
            WHEN percentage BETWEEN 51 AND 70 THEN '51-70%'
            WHEN percentage BETWEEN 71 AND 85 THEN '71-85%'
            WHEN percentage BETWEEN 86 AND 100 THEN '86-100%'
        END as range"),
        DB::raw('COUNT(*) as count')
    )
    ->where('status', 'completed')
    ->groupBy('range')
    ->get();

foreach ($distribution as $item) {
    echo "  {$item->range}: {$item->count} attempts\n";
}

// Recent attempts
echo "\nRecent 5 Attempts:\n";
$recentAttempts = DB::table('exam_attempts as ea')
    ->join('users as u', 'ea.reviewee_id', '=', 'u.id')
    ->join('exams as e', 'ea.exam_id', '=', 'e.id')
    ->select('u.first_name', 'u.last_name', 'e.title', 'ea.percentage', 'ea.start_time')
    ->where('ea.status', 'completed')
    ->orderBy('ea.start_time', 'DESC')
    ->limit(5)
    ->get();

foreach ($recentAttempts as $attempt) {
    echo "  {$attempt->first_name} {$attempt->last_name} - {$attempt->title} - {$attempt->percentage}% - {$attempt->start_time}\n";
}

echo "\n✓ Analytics data is ready to view!\n";

<?php
// Test what's actually in the database
require __DIR__ . '/backend/vendor/autoload.php';

$app = require_once __DIR__ . '/backend/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

// Get some sample users
$users = DB::table('users')
    ->where('role', 'reviewee')
    ->limit(5)
    ->get();

echo "=== USERS IN DATABASE ===\n\n";
foreach ($users as $user) {
    echo "ID: {$user->id}\n";
    echo "Username: {$user->username}\n";
    echo "First Name: " . ($user->first_name ?? 'NULL') . "\n";
    echo "Last Name: " . ($user->last_name ?? 'NULL') . "\n";
    echo "Full Name: " . trim(($user->first_name ?? '') . ' ' . ($user->last_name ?? '')) . "\n";
    echo "---\n";
}

// Get some sample attempts
$attempts = DB::table('exam_attempts')
    ->join('users', 'exam_attempts.reviewee_id', '=', 'users.id')
    ->join('exams', 'exam_attempts.exam_id', '=', 'exams.id')
    ->where('exam_attempts.status', 'completed')
    ->select(
        'users.username',
        'users.first_name',
        'users.last_name',
        'exams.title',
        'exam_attempts.score',
        'exam_attempts.total_questions'
    )
    ->limit(5)
    ->get();

echo "\n=== SAMPLE ATTEMPTS ===\n\n";
foreach ($attempts as $attempt) {
    echo "Student: {$attempt->username} ({$attempt->first_name} {$attempt->last_name})\n";
    echo "Exam: {$attempt->title}\n";
    echo "Score: {$attempt->score}/{$attempt->total_questions}\n";
    echo "---\n";
}

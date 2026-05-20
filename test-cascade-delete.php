<?php
/**
 * Test cascade delete functionality when deleting a reviewee
 */

require __DIR__ . '/backend/vendor/autoload.php';

$app = require_once __DIR__ . '/backend/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "=== Testing Cascade Delete for Reviewee ===\n\n";

// Create a test reviewee
$testUser = DB::table('users')->insertGetId([
    'username' => 'test_cascade_' . time(),
    'password_hash' => password_hash('password123', PASSWORD_BCRYPT),
    'first_name' => 'Test',
    'last_name' => 'Cascade',
    'role' => 'reviewee',
    'is_active' => true,
    'require_password_change' => false,
    'created_at' => now(),
]);

echo "✓ Created test reviewee (ID: {$testUser})\n";

// Create an exam attempt for this reviewee
$examId = DB::table('exams')->where('status', 'active')->first()->id;
$attemptId = DB::table('exam_attempts')->insertGetId([
    'exam_id' => $examId,
    'reviewee_id' => $testUser,
    'attempt_number' => 1,
    'randomization_seed' => 12345,
    'start_time' => now(),
    'time_limit_seconds' => 3600,
    'status' => 'completed',
    'score' => 50,
    'total_questions' => 100,
    'percentage' => 50.0,
    'end_time' => now(),
]);

echo "✓ Created exam attempt (ID: {$attemptId})\n";

// Create some attempt answers
$questionId = DB::table('questions')->first()->id;
$choiceId = DB::table('answer_choices')->where('question_id', $questionId)->first()->id;

DB::table('attempt_answers')->insert([
    'attempt_id' => $attemptId,
    'question_id' => $questionId,
    'selected_choice_id' => $choiceId,
    'is_correct' => true,
    'answered_at' => now(),
]);

echo "✓ Created attempt answer\n";

// Create a security violation
DB::table('security_violations')->insert([
    'attempt_id' => $attemptId,
    'violation_type' => 'focus_loss',
    'detected_at' => now(),
]);

echo "✓ Created security violation\n";

// Create an ML prediction
DB::table('ml_predictions')->insert([
    'reviewee_id' => $testUser,
    'pass_probability' => 0.75,
    'fail_probability' => 0.25,
    'risk_level' => 'Low',
    'confidence' => 0.85,
    'features' => json_encode(['avg_score' => 75]),
    'predicted_at' => now(),
]);

echo "✓ Created ML prediction\n\n";

// Count related records before deletion
$attemptsCount = DB::table('exam_attempts')->where('reviewee_id', $testUser)->count();
$answersCount = DB::table('attempt_answers')->where('attempt_id', $attemptId)->count();
$violationsCount = DB::table('security_violations')->where('attempt_id', $attemptId)->count();
$predictionsCount = DB::table('ml_predictions')->where('reviewee_id', $testUser)->count();

echo "Before deletion:\n";
echo "  - Exam attempts: {$attemptsCount}\n";
echo "  - Attempt answers: {$answersCount}\n";
echo "  - Security violations: {$violationsCount}\n";
echo "  - ML predictions: {$predictionsCount}\n\n";

// Delete the reviewee
echo "Deleting reviewee...\n";
DB::table('users')->where('id', $testUser)->delete();
echo "✓ Reviewee deleted\n\n";

// Count related records after deletion
$attemptsCount = DB::table('exam_attempts')->where('reviewee_id', $testUser)->count();
$answersCount = DB::table('attempt_answers')->where('attempt_id', $attemptId)->count();
$violationsCount = DB::table('security_violations')->where('attempt_id', $attemptId)->count();
$predictionsCount = DB::table('ml_predictions')->where('reviewee_id', $testUser)->count();

echo "After deletion:\n";
echo "  - Exam attempts: {$attemptsCount}\n";
echo "  - Attempt answers: {$answersCount}\n";
echo "  - Security violations: {$violationsCount}\n";
echo "  - ML predictions: {$predictionsCount}\n\n";

// Verify all are deleted
if ($attemptsCount === 0 && $answersCount === 0 && $violationsCount === 0 && $predictionsCount === 0) {
    echo "✅ SUCCESS: All related data was cascade deleted!\n";
} else {
    echo "❌ FAILED: Some data was not deleted:\n";
    if ($attemptsCount > 0) echo "  - Exam attempts still exist\n";
    if ($answersCount > 0) echo "  - Attempt answers still exist\n";
    if ($violationsCount > 0) echo "  - Security violations still exist\n";
    if ($predictionsCount > 0) echo "  - ML predictions still exist\n";
}

echo "\n=== Test Complete ===\n";

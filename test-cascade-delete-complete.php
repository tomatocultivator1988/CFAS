<?php
/**
 * Complete test for cascade delete functionality when deleting a reviewee
 * Tests all related tables including audit logs
 */

require __DIR__ . '/backend/vendor/autoload.php';

$app = require_once __DIR__ . '/backend/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "=== Complete Cascade Delete Test ===\n\n";

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

// Create an exam attempt
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

// Create attempt answers
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

// Create security violation
DB::table('security_violations')->insert([
    'attempt_id' => $attemptId,
    'violation_type' => 'focus_loss',
    'detected_at' => now(),
]);

echo "✓ Created security violation\n";

// Create ML prediction
DB::table('ml_predictions')->insert([
    'reviewee_id' => $testUser,
    'pass_probability' => 0.75,
    'fail_probability' => 0.25,
    'risk_level' => 'Low',
    'confidence' => 0.85,
    'features' => json_encode(['avg_score' => 75]),
    'predicted_at' => now(),
]);

echo "✓ Created ML prediction\n";

// Create auth token
DB::table('auth_tokens')->insert([
    'user_id' => $testUser,
    'token' => 'test_token_' . uniqid(),
    'expires_at' => now()->addHours(24),
    'created_at' => now(),
]);

echo "✓ Created auth token\n";

// Create audit log
DB::table('audit_logs')->insert([
    'user_id' => $testUser,
    'action' => 'login',
    'entity_type' => 'user',
    'entity_id' => $testUser,
    'details' => 'Test login',
    'ip_address' => '127.0.0.1',
    'created_at' => now(),
]);

echo "✓ Created audit log\n\n";

// Count all records before deletion
$counts = [
    'attempts' => DB::table('exam_attempts')->where('reviewee_id', $testUser)->count(),
    'answers' => DB::table('attempt_answers')->where('attempt_id', $attemptId)->count(),
    'violations' => DB::table('security_violations')->where('attempt_id', $attemptId)->count(),
    'predictions' => DB::table('ml_predictions')->where('reviewee_id', $testUser)->count(),
    'tokens' => DB::table('auth_tokens')->where('user_id', $testUser)->count(),
    'audit_logs' => DB::table('audit_logs')->where('user_id', $testUser)->count(),
];

echo "Before deletion:\n";
echo "  - Exam attempts: {$counts['attempts']}\n";
echo "  - Attempt answers: {$counts['answers']}\n";
echo "  - Security violations: {$counts['violations']}\n";
echo "  - ML predictions: {$counts['predictions']}\n";
echo "  - Auth tokens: {$counts['tokens']}\n";
echo "  - Audit logs: {$counts['audit_logs']}\n\n";

// Delete the reviewee
echo "Deleting reviewee...\n";
DB::table('users')->where('id', $testUser)->delete();
echo "✓ Reviewee deleted\n\n";

// Count all records after deletion
$countsAfter = [
    'attempts' => DB::table('exam_attempts')->where('reviewee_id', $testUser)->count(),
    'answers' => DB::table('attempt_answers')->where('attempt_id', $attemptId)->count(),
    'violations' => DB::table('security_violations')->where('attempt_id', $attemptId)->count(),
    'predictions' => DB::table('ml_predictions')->where('reviewee_id', $testUser)->count(),
    'tokens' => DB::table('auth_tokens')->where('user_id', $testUser)->count(),
    'audit_logs_with_user' => DB::table('audit_logs')->where('user_id', $testUser)->count(),
    'audit_logs_null' => DB::table('audit_logs')->whereNull('user_id')->count(),
];

echo "After deletion:\n";
echo "  - Exam attempts: {$countsAfter['attempts']}\n";
echo "  - Attempt answers: {$countsAfter['answers']}\n";
echo "  - Security violations: {$countsAfter['violations']}\n";
echo "  - ML predictions: {$countsAfter['predictions']}\n";
echo "  - Auth tokens: {$countsAfter['tokens']}\n";
echo "  - Audit logs (with user_id): {$countsAfter['audit_logs_with_user']}\n";
echo "  - Audit logs (user_id = NULL): {$countsAfter['audit_logs_null']}\n\n";

// Verify results
$success = true;
$errors = [];

if ($countsAfter['attempts'] !== 0) {
    $success = false;
    $errors[] = "Exam attempts were not deleted";
}

if ($countsAfter['answers'] !== 0) {
    $success = false;
    $errors[] = "Attempt answers were not deleted";
}

if ($countsAfter['violations'] !== 0) {
    $success = false;
    $errors[] = "Security violations were not deleted";
}

if ($countsAfter['predictions'] !== 0) {
    $success = false;
    $errors[] = "ML predictions were not deleted";
}

if ($countsAfter['tokens'] !== 0) {
    $success = false;
    $errors[] = "Auth tokens were not deleted";
}

if ($countsAfter['audit_logs_with_user'] !== 0) {
    $success = false;
    $errors[] = "Audit logs still reference deleted user";
}

if ($countsAfter['audit_logs_null'] === 0) {
    $success = false;
    $errors[] = "Audit logs were deleted instead of setting user_id to NULL";
}

if ($success) {
    echo "✅ SUCCESS: All cascade deletes working correctly!\n";
    echo "   - Exam data (attempts, answers, violations) deleted\n";
    echo "   - ML predictions deleted\n";
    echo "   - Auth tokens deleted\n";
    echo "   - Audit logs preserved with user_id set to NULL\n";
} else {
    echo "❌ FAILED: Issues found:\n";
    foreach ($errors as $error) {
        echo "  - {$error}\n";
    }
}

echo "\n=== Test Complete ===\n";

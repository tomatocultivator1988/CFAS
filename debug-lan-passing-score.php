<?php

require_once 'backend/vendor/autoload.php';

// Load Laravel environment
$app = require_once 'backend/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use Illuminate\Support\Facades\DB;
use App\Models\Exam;
use App\Services\ExamManagementService;

echo "=== DEBUGGING PASSING SCORE ISSUE SA LAN ===\n\n";

// 1. Check if Exam model has passing_score in fillable
echo "1. Checking Exam model fillable array...\n";
$exam = new Exam();
$fillable = $exam->getFillable();
echo "Fillable fields: " . implode(', ', $fillable) . "\n";

if (in_array('passing_score', $fillable)) {
    echo "✓ passing_score is in fillable array\n";
} else {
    echo "✗ passing_score NOT in fillable array - PROBLEM FOUND!\n";
}

// 2. Check if database column exists
echo "\n2. Checking database column...\n";
try {
    $columnExists = DB::select("SHOW COLUMNS FROM exams LIKE 'passing_score'");
    if (!empty($columnExists)) {
        echo "✓ passing_score column exists in database\n";
        $columnInfo = $columnExists[0];
        echo "Column type: {$columnInfo->Type}\n";
        echo "Default: {$columnInfo->Default}\n";
    } else {
        echo "✗ passing_score column does NOT exist - PROBLEM FOUND!\n";
    }
} catch (Exception $e) {
    echo "✗ Error checking column: " . $e->getMessage() . "\n";
}

// 3. Test creating exam with passing_score
echo "\n3. Testing exam creation with passing_score...\n";
try {
    $examService = new ExamManagementService();
    
    $testData = [
        'title' => 'DEBUG Test Exam - ' . date('Y-m-d H:i:s'),
        'description' => 'Testing passing score functionality',
        'time_limit_minutes' => 60,
        'max_attempts' => 3,
        'passing_score' => 85,
        'randomize_questions' => true,
        'randomize_choices' => true,
        'violation_threshold' => 3
    ];
    
    echo "Attempting to create exam with passing_score: 85\n";
    $newExam = $examService->createExam($testData);
    
    echo "✓ Exam created successfully!\n";
    echo "Exam ID: {$newExam->id}\n";
    echo "Passing score returned: {$newExam->passing_score}\n";
    
    // Verify in database
    $dbExam = DB::table('exams')->where('id', $newExam->id)->first();
    echo "Passing score in database: {$dbExam->passing_score}\n";
    
    if ($newExam->passing_score == 85 && $dbExam->passing_score == 85) {
        echo "✓ Passing score saved correctly!\n";
    } else {
        echo "✗ Passing score NOT saved correctly!\n";
    }
    
    // Clean up
    DB::table('exams')->where('id', $newExam->id)->delete();
    echo "Test exam deleted\n";
    
} catch (Exception $e) {
    echo "✗ Error creating exam: " . $e->getMessage() . "\n";
    echo "Stack trace:\n" . $e->getTraceAsString() . "\n";
}

// 4. Check validation rules
echo "\n4. Checking validation rules...\n";
try {
    $examService = new ExamManagementService();
    
    // Try invalid passing_score
    $invalidData = [
        'title' => 'Invalid Test',
        'description' => 'Testing validation',
        'time_limit_minutes' => 60,
        'max_attempts' => 3,
        'passing_score' => 150, // Invalid
        'randomize_questions' => true,
        'randomize_choices' => true,
        'violation_threshold' => 3
    ];
    
    try {
        $examService->createExam($invalidData);
        echo "✗ Validation NOT working - accepted invalid passing_score 150\n";
    } catch (Exception $e) {
        echo "✓ Validation working - rejected invalid passing_score 150\n";
    }
    
} catch (Exception $e) {
    echo "✗ Error testing validation: " . $e->getMessage() . "\n";
}

echo "\n=== DIAGNOSIS COMPLETE ===\n";
echo "If you see any ✗ marks above, those are the issues that need to be fixed.\n";
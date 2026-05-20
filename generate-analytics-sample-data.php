<?php
/**
 * Generate Sample Analytics Data
 * Creates realistic exam attempts and scores for testing analytics dashboard
 */

require __DIR__ . '/backend/vendor/autoload.php';

$app = require_once __DIR__ . '/backend/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

echo "=== Generating Analytics Sample Data ===\n\n";

// Check if we have exams
$examCount = DB::table('exams')->where('status', 'active')->where('is_deleted', 0)->count();
if ($examCount === 0) {
    echo "❌ No exams found! Please create exams first.\n";
    exit(1);
}

// Check if we have users (reviewees)
$revieweeCount = DB::table('users')->where('role', 'reviewee')->count();
if ($revieweeCount === 0) {
    echo "❌ No reviewees found! Creating sample reviewees...\n";
    
    // Create 20 sample reviewees
    for ($i = 1; $i <= 20; $i++) {
        DB::table('users')->insert([
            'username' => "student{$i}",
            'password_hash' => password_hash('password', PASSWORD_DEFAULT),
            'first_name' => "Student",
            'last_name' => "User {$i}",
            'middle_initial' => chr(64 + ($i % 26)),
            'role' => 'reviewee',
            'is_active' => 1,
            'require_password_change' => 0,
            'created_at' => now(),
            'last_login_at' => null
        ]);
    }
    echo "✓ Created 20 sample reviewees\n\n";
}

// Get all exams and reviewees
$exams = DB::table('exams')->where('status', 'active')->where('is_deleted', 0)->get();
$reviewees = DB::table('users')->where('role', 'reviewee')->where('is_active', 1)->get();

echo "Found {$exams->count()} exams and {$reviewees->count()} reviewees\n\n";

$attemptsCreated = 0;
$now = Carbon::now();

// Generate attempts for the last 3 months
foreach ($exams as $exam) {
    echo "Generating attempts for exam: {$exam->title}\n";
    
    // Get questions for this exam via exam_questions pivot table
    $questionIds = DB::table('exam_questions')
        ->where('exam_id', $exam->id)
        ->pluck('question_id')
        ->toArray();
    
    if (empty($questionIds)) {
        echo "  ⚠ No questions found, skipping...\n";
        continue;
    }
    
    $totalQuestions = count($questionIds);
    
    // Each reviewee takes this exam 1-3 times
    foreach ($reviewees as $reviewee) {
        $numAttempts = rand(1, 3);
        
        // Get current attempt number for this reviewee
        $currentAttemptNumber = DB::table('exam_attempts')
            ->where('exam_id', $exam->id)
            ->where('reviewee_id', $reviewee->id)
            ->max('attempt_number') ?? 0;
        
        for ($attemptNum = 1; $attemptNum <= $numAttempts; $attemptNum++) {
            // Random date in the last 90 days
            $daysAgo = rand(0, 90);
            $attemptDate = $now->copy()->subDays($daysAgo);
            
            // Calculate score (realistic distribution)
            // 60% of students score between 60-85%
            // 20% score below 60%
            // 20% score above 85%
            $rand = rand(1, 100);
            if ($rand <= 20) {
                // Low performers
                $scorePercentage = rand(30, 59);
            } elseif ($rand <= 80) {
                // Average performers
                $scorePercentage = rand(60, 85);
            } else {
                // High performers
                $scorePercentage = rand(86, 100);
            }
            
            $correctAnswers = round(($scorePercentage / 100) * $totalQuestions);
            $score = $correctAnswers;
            
            // Random time taken (30-90 minutes)
            $timeTaken = rand(1800, 5400); // seconds
            $startTime = $attemptDate;
            $endTime = $attemptDate->copy()->addSeconds($timeTaken);
            
            // Create attempt
            $attemptId = DB::table('exam_attempts')->insertGetId([
                'exam_id' => $exam->id,
                'reviewee_id' => $reviewee->id,
                'attempt_number' => $currentAttemptNumber + $attemptNum,
                'randomization_seed' => rand(1000, 9999),
                'start_time' => $startTime,
                'end_time' => $endTime,
                'time_limit_seconds' => $exam->time_limit_minutes * 60,
                'violation_count' => 0,
                'status' => 'completed',
                'score' => $score,
                'total_questions' => $totalQuestions,
                'percentage' => $scorePercentage
            ]);
            
            // Create answers for each question
            $correctCount = 0;
            foreach ($questionIds as $index => $questionId) {
                // Get choices for this question
                $choices = DB::table('answer_choices')
                    ->where('question_id', $questionId)
                    ->get();
                
                if ($choices->isEmpty()) continue;
                
                // Determine if this answer should be correct based on target score
                $shouldBeCorrect = ($correctCount < $correctAnswers);
                
                // Select answer
                if ($shouldBeCorrect) {
                    // Select correct answer
                    $correctChoice = $choices->where('is_correct', 1)->first();
                    $selectedChoiceId = $correctChoice ? $correctChoice->id : $choices->random()->id;
                    $isCorrect = 1;
                    $correctCount++;
                } else {
                    // Select wrong answer
                    $wrongChoices = $choices->where('is_correct', 0);
                    if ($wrongChoices->isNotEmpty()) {
                        $selectedChoiceId = $wrongChoices->random()->id;
                        $isCorrect = 0;
                    } else {
                        // If no wrong choices, skip
                        continue;
                    }
                }
                
                // Random answer time within the attempt duration
                $answerTime = $startTime->copy()->addSeconds(rand(0, $timeTaken));
                
                DB::table('attempt_answers')->insert([
                    'attempt_id' => $attemptId,
                    'question_id' => $questionId,
                    'selected_choice_id' => $selectedChoiceId,
                    'is_correct' => $isCorrect,
                    'answered_at' => $answerTime
                ]);
            }
            
            $attemptsCreated++;
        }
    }
    
    echo "  ✓ Generated attempts for {$exam->title}\n";
}

echo "\n=== Summary ===\n";
echo "✓ Created {$attemptsCreated} exam attempts\n";
echo "✓ Analytics data is ready!\n";
echo "\nYou can now view the analytics dashboard with real data.\n";
echo "Login as admin and go to Analytics page.\n";

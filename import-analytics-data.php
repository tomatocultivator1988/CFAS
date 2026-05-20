<?php
/**
 * Import Analytics Data to LAN Server Database
 * Run this in XAMPP htdocs/Exam-Main directory
 */

require __DIR__ . '/backend/vendor/autoload.php';

$app = require_once __DIR__ . '/backend/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use Illuminate\Support\Facades\DB;

echo "=== Importing Analytics Data to LAN Server ===\n\n";

// Check if export file exists
if (!file_exists('analytics_export.json')) {
    echo "❌ Export file not found: analytics_export.json\n";
    echo "Please run EXPORT-ANALYTICS-DATA-TO-LAN.bat first\n";
    exit(1);
}

// Load the export data
echo "Loading export data...\n";
$data = json_decode(file_get_contents('analytics_export.json'), true);

if (!$data || !isset($data['attempts']) || !isset($data['answers'])) {
    echo "❌ Invalid export data format\n";
    exit(1);
}

$attempts = $data['attempts'];
$answers = $data['answers'];

echo "Found " . count($attempts) . " attempts and " . count($answers) . " answers\n\n";

// Clear existing data (optional - comment out if you want to keep existing data)
echo "Clearing existing analytics data...\n";
DB::table('attempt_answers')->delete();
DB::table('exam_attempts')->delete();
echo "✓ Cleared existing data\n\n";

// Import attempts
echo "Importing exam attempts...\n";
$importedAttempts = 0;
foreach ($attempts as $attempt) {
    try {
        DB::table('exam_attempts')->insert((array)$attempt);
        $importedAttempts++;
    } catch (\Exception $e) {
        echo "Warning: Failed to import attempt ID {$attempt['id']}: {$e->getMessage()}\n";
    }
}
echo "✓ Imported {$importedAttempts} exam attempts\n\n";

// Import answers
echo "Importing attempt answers...\n";
$importedAnswers = 0;
foreach ($answers as $answer) {
    try {
        DB::table('attempt_answers')->insert((array)$answer);
        $importedAnswers++;
    } catch (\Exception $e) {
        echo "Warning: Failed to import answer ID {$answer['id']}: {$e->getMessage()}\n";
    }
}
echo "✓ Imported {$importedAnswers} attempt answers\n\n";

// Verify import
$totalAttempts = DB::table('exam_attempts')->count();
$totalAnswers = DB::table('attempt_answers')->count();
$avgScore = DB::table('exam_attempts')->where('status', 'completed')->avg('percentage');

echo "=== Import Summary ===\n";
echo "✓ Total Attempts in Database: {$totalAttempts}\n";
echo "✓ Total Answers in Database: {$totalAnswers}\n";
echo "✓ Average Score: " . round($avgScore, 2) . "%\n";
echo "\n✓ Analytics data import complete!\n";
echo "You can now view the analytics dashboard with real data.\n";

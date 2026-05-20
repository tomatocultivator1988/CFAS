<?php

require_once 'backend/vendor/autoload.php';

// Load Laravel environment
$app = require_once 'backend/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use Illuminate\Support\Facades\DB;

echo "=== ALL EXAMS WITH PASSING SCORES ===\n\n";

$exams = DB::table('exams')
    ->select('id', 'title', 'passing_score')
    ->where('is_deleted', 0)
    ->orderBy('title')
    ->get();

foreach ($exams as $exam) {
    echo "ID: {$exam->id} | Title: {$exam->title} | Passing Score: {$exam->passing_score}\n";
}

echo "\n=== LOOKING FOR AQUACULTURE EXAMS ===\n\n";

$aquaExams = DB::table('exams')
    ->select('id', 'title', 'passing_score')
    ->where('title', 'LIKE', '%Aquaculture%')
    ->orWhere('title', 'LIKE', '%Shellcheck%')
    ->where('is_deleted', 0)
    ->get();

foreach ($aquaExams as $exam) {
    echo "ID: {$exam->id} | Title: {$exam->title} | Passing Score: {$exam->passing_score}\n";
}
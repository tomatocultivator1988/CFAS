<?php

require __DIR__ . '/backend/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/backend/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "=== Checking Exams ===\n\n";

$exams = DB::table('exams')->get();
echo "Total Exams: " . $exams->count() . "\n\n";

if ($exams->count() > 0) {
    foreach ($exams as $exam) {
        echo "ID: {$exam->id}\n";
        echo "Title: {$exam->title}\n";
        echo "Status: {$exam->status}\n";
        echo "Category: {$exam->category}\n";
        echo "---\n";
    }
} else {
    echo "No exams found in database.\n";
    echo "\nYou need to create exams first!\n";
    echo "Login as admin and create some exams.\n";
}

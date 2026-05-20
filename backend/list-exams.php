<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

$exams = \App\Models\Exam::select('id', 'title', 'category')->orderBy('id')->get();

echo "Available Exams:\n";
echo "================\n\n";

foreach ($exams as $exam) {
    echo "ID: {$exam->id}\n";
    echo "Title: {$exam->title}\n";
    echo "Category: {$exam->category}\n";
    echo "---\n";
}

echo "\nTotal exams: " . $exams->count() . "\n";

<?php

require 'C:/xampp/htdocs/exam-backend/vendor/autoload.php';

$app = require_once 'C:/xampp/htdocs/exam-backend/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "========================================\n";
echo "  QUESTIONS TABLE STRUCTURE\n";
echo "========================================\n\n";

$columns = DB::select('DESCRIBE questions');

foreach ($columns as $col) {
    echo "{$col->Field} ({$col->Type}) - {$col->Null} - {$col->Key}\n";
}

echo "\n========================================\n";
echo "  EXAM_QUESTIONS TABLE STRUCTURE\n";
echo "========================================\n\n";

$columns2 = DB::select('DESCRIBE exam_questions');

foreach ($columns2 as $col) {
    echo "{$col->Field} ({$col->Type}) - {$col->Null} - {$col->Key}\n";
}

echo "\n";

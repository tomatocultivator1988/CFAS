<?php

require __DIR__ . '/backend/vendor/autoload.php';

$app = require_once __DIR__ . '/backend/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

$deleted = DB::table('exam_questions')->where('exam_id', 91)->delete();
echo "Cleared $deleted questions from exam 91\n";

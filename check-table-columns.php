<?php

require __DIR__ . '/backend/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/backend/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "=== Checking Table Structures ===\n\n";

// Check exams table
echo "EXAMS TABLE:\n";
$examColumns = DB::select("DESCRIBE exams");
foreach ($examColumns as $col) {
    echo "  - {$col->Field} ({$col->Type})\n";
}

echo "\nUSERS TABLE:\n";
$userColumns = DB::select("DESCRIBE users");
foreach ($userColumns as $col) {
    echo "  - {$col->Field} ({$col->Type})\n";
}

echo "\nEXAM_ATTEMPTS TABLE:\n";
$attemptColumns = DB::select("DESCRIBE exam_attempts");
foreach ($attemptColumns as $col) {
    echo "  - {$col->Field} ({$col->Type})\n";
}

echo "\nQUESTIONS TABLE:\n";
$questionColumns = DB::select("DESCRIBE questions");
foreach ($questionColumns as $col) {
    echo "  - {$col->Field} ({$col->Type})\n";
}

echo "\nCHOICES TABLE:\n";
$choiceColumns = DB::select("DESCRIBE choices");
foreach ($choiceColumns as $col) {
    echo "  - {$col->Field} ({$col->Type})\n";
}

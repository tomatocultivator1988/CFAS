<?php

require __DIR__ . '/backend/vendor/autoload.php';

$app = require_once __DIR__ . '/backend/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "=== Testing Attempt Creation ===\n\n";

$examId = 5; // SET A
$revieweeId = 16; // testuser

try {
    $service = app(\App\Services\ExamDeliveryService::class);
    $attempt = $service->startExamAttempt($examId, $revieweeId);
    
    echo "✓ Attempt created successfully!\n";
    echo "Attempt ID: {$attempt->id}\n";
    echo "Status: {$attempt->status}\n";
    echo "Start Time: {$attempt->start_time}\n";
    
} catch (\Exception $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
}

<?php
// Test category-exam-data endpoint directly
require __DIR__ . '/backend/vendor/autoload.php';

$app = require_once __DIR__ . '/backend/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);

// Create a test request
$request = Illuminate\Http\Request::create(
    '/api/admin/export/category-exam-data',
    'GET',
    [],
    [],
    [],
    ['HTTP_ACCEPT' => 'application/json']
);

try {
    $response = $kernel->handle($request);
    
    echo "Status Code: " . $response->getStatusCode() . "\n";
    echo "Content:\n";
    echo $response->getContent() . "\n";
    
    $kernel->terminate($request, $response);
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
    echo "Trace: " . $e->getTraceAsString() . "\n";
}

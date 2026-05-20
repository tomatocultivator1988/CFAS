<?php
/**
 * Quick test to verify Python path resolution after Apache restart
 */

// Load Laravel
require __DIR__ . '/backend/vendor/autoload.php';
$app = require_once __DIR__ . '/backend/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

// Test PlatformService
$platformService = new \App\Services\PlatformService();

echo "=== Python Path Resolution Test ===\n\n";

// Clear cache first
$platformService->clearCache();
echo "✓ Cache cleared\n\n";

// Resolve Python path
echo "Resolving Python path...\n";
$pythonPath = $platformService->resolvePythonPath();
echo "Python Path: {$pythonPath}\n\n";

// Check if it's the full path or just 'python.exe'
if ($pythonPath === 'python.exe' || $pythonPath === 'python') {
    echo "❌ ISSUE: Python path is not fully resolved!\n";
    echo "Expected: C:\\Users\\Hi\\AppData\\Local\\Programs\\Python\\Python312\\python.exe\n";
    echo "Got: {$pythonPath}\n\n";
    
    // Try to find Python manually
    echo "Checking if Python exists at expected location...\n";
    $expectedPath = 'C:\\Users\\Hi\\AppData\\Local\\Programs\\Python\\Python312\\python.exe';
    if (file_exists($expectedPath)) {
        echo "✓ Python DOES exist at: {$expectedPath}\n";
        echo "The PlatformService is not finding it correctly.\n";
    } else {
        echo "❌ Python NOT found at: {$expectedPath}\n";
    }
} else {
    echo "✓ SUCCESS: Python path is fully resolved!\n";
    echo "Path: {$pythonPath}\n";
    
    // Test if it actually works
    echo "\nTesting Python execution...\n";
    $testCommand = $platformService->buildCommand('C:/xampp/htdocs/ml_model/predict_api.py', ['--health-check']);
    echo "Command: {$testCommand}\n\n";
    
    $result = $platformService->executeCommand($testCommand, 10);
    echo "Exit Code: {$result->exitCode}\n";
    echo "Execution Time: " . round($result->executionTime * 1000, 2) . " ms\n";
    
    if ($result->isSuccess()) {
        echo "✓ Python execution successful!\n";
        echo "\nOutput:\n";
        echo $result->stdout;
    } else {
        echo "❌ Python execution failed!\n";
        echo "\nError:\n";
        echo $result->stderr;
    }
}

echo "\n=== Test Complete ===\n";

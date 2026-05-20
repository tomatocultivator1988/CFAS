<?php
/**
 * Verify Python path resolution in XAMPP deployment
 * Run this from command line: php verify-xampp-python-path.php
 */

// Load from XAMPP deployment
require 'C:/xampp/htdocs/exam-backend/vendor/autoload.php';
$app = require_once 'C:/xampp/htdocs/exam-backend/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

echo "=== XAMPP Deployment - Python Path Verification ===\n\n";

// Create PlatformService instance (same as dashboard does)
$platformService = new \App\Services\PlatformService();

echo "1. Clearing cache...\n";
$platformService->clearCache();
echo "   ✓ Cache cleared\n\n";

echo "2. Resolving Python path...\n";
$pythonPath = $platformService->resolvePythonPath();
echo "   Python Path: {$pythonPath}\n\n";

if ($pythonPath === 'python.exe' || $pythonPath === 'python') {
    echo "   ❌ FAILED: Python path not fully resolved!\n";
    echo "   This is what the dashboard will show.\n\n";
    
    // Debug: Check if file exists
    $expectedPath = 'C:\\Users\\Hi\\AppData\\Local\\Programs\\Python\\Python312\\python.exe';
    echo "3. Checking expected path...\n";
    if (file_exists($expectedPath)) {
        echo "   ✓ Python EXISTS at: {$expectedPath}\n";
        echo "   Issue: PlatformService search logic not finding it\n";
    } else {
        echo "   ❌ Python NOT FOUND at: {$expectedPath}\n";
    }
} else {
    echo "   ✓ SUCCESS: Python path fully resolved!\n\n";
    
    echo "3. Testing Python execution...\n";
    $command = $platformService->buildCommand('C:/xampp/htdocs/ml_model/predict_api.py', ['--health-check']);
    echo "   Command: {$command}\n\n";
    
    $result = $platformService->executeCommand($command, 10);
    
    if ($result->isSuccess()) {
        echo "   ✓ Python execution successful!\n";
        echo "   Exit Code: {$result->exitCode}\n";
        echo "   Execution Time: " . round($result->executionTime * 1000, 2) . " ms\n\n";
        
        $output = json_decode($result->stdout, true);
        if ($output && isset($output['status'])) {
            echo "   ML System Status: {$output['status']}\n";
        }
    } else {
        echo "   ❌ Python execution failed!\n";
        echo "   Exit Code: {$result->exitCode}\n";
        echo "   Error: {$result->stderr}\n";
    }
}

echo "\n=== Verification Complete ===\n";

<?php
// Test extraction and splitting logic

require 'backend/vendor/autoload.php';
$app = require_once 'backend/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

$filePath = 'Aquaculture_Reviewer-1_Shellcheck-Full.docx';

echo "Extracting text from: $filePath\n\n";

// Run Python extraction
$pythonPath = 'C:\\Users\\Hi\\AppData\\Local\\Programs\\Python\\Python312\\python.exe';
$scriptPath = 'extract-with-formatting.py';
$tempFile = 'test-extracted-output.txt';

$command = sprintf(
    '"%s" "%s" "%s" "%s" 2>&1',
    $pythonPath,
    $scriptPath,
    $filePath,
    $tempFile
);

echo "Running: $command\n\n";
exec($command, $output, $returnCode);

echo "Return code: $returnCode\n";
echo "Output: " . implode("\n", $output) . "\n\n";

if (file_exists($tempFile)) {
    $text = file_get_contents($tempFile);
    echo "Extracted text length: " . strlen($text) . " characters\n";
    echo "Lines: " . substr_count($text, "\n") . "\n\n";
    
    // Show first 3000 characters
    echo "First 3000 characters:\n";
    echo "========================================\n";
    echo substr($text, 0, 3000) . "\n";
    echo "========================================\n\n";
    
    // Test splitting
    echo "Testing split logic...\n";
    $pattern = '/(?=^\s*\d+[\.\)]\s+)/m';
    $blocks = preg_split($pattern, $text, -1, PREG_SPLIT_NO_EMPTY);
    
    echo "Total blocks after split: " . count($blocks) . "\n\n";
    
    // Show first 5 blocks
    echo "First 5 blocks:\n";
    for ($i = 0; $i < min(5, count($blocks)); $i++) {
        $block = trim($blocks[$i]);
        echo "\n--- Block $i (length: " . strlen($block) . ") ---\n";
        echo substr($block, 0, 200) . "...\n";
    }
    
} else {
    echo "ERROR: Extraction file not created\n";
}

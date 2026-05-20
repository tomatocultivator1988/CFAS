<?php
/**
 * Test Script: Extract text from real DOCX and check for Q1-Q2
 */

require __DIR__ . '/backend/vendor/autoload.php';

$docxFile = __DIR__ . '/Aquaculture_set A.docx';

if (!file_exists($docxFile)) {
    die("❌ DOCX file not found: $docxFile\n");
}

echo "========================================\n";
echo "  REAL DOCX EXTRACTION TEST\n";
echo "========================================\n\n";

echo "Testing file: $docxFile\n\n";

// Test Python extraction
echo "[1] Testing Python extraction...\n";
$pythonPath = 'C:\\Users\\Hi\\AppData\\Local\\Programs\\Python\\Python312\\python.exe';
$scriptPath = __DIR__ . '/extract-with-formatting.py';
$tempFile = __DIR__ . '/test-extraction-output.txt';

$command = sprintf(
    '"%s" "%s" "%s" "%s" 2>&1',
    $pythonPath,
    $scriptPath,
    $docxFile,
    $tempFile
);

exec($command, $output, $returnCode);

if ($returnCode === 0 && file_exists($tempFile)) {
    $extractedText = file_get_contents($tempFile);
    echo "✓ Python extraction successful\n";
    echo "  Length: " . strlen($extractedText) . " chars\n";
    
    // Check for Q1 and Q2
    $lines = explode("\n", $extractedText);
    $foundQ1 = false;
    $foundQ2 = false;
    
    foreach ($lines as $lineNum => $line) {
        if (preg_match('/^\s*1[\.\)]\s+/', $line)) {
            $foundQ1 = true;
            echo "  ✓ Found Q1 at line $lineNum: " . substr($line, 0, 60) . "...\n";
        }
        if (preg_match('/^\s*2[\.\)]\s+/', $line)) {
            $foundQ2 = true;
            echo "  ✓ Found Q2 at line $lineNum: " . substr($line, 0, 60) . "...\n";
        }
        
        // Show first 10 lines
        if ($lineNum < 10) {
            echo "  Line $lineNum: " . substr($line, 0, 80) . "\n";
        }
    }
    
    if (!$foundQ1) {
        echo "  ❌ Question 1 NOT FOUND in extracted text!\n";
    }
    if (!$foundQ2) {
        echo "  ❌ Question 2 NOT FOUND in extracted text!\n";
    }
    
    // Count total questions
    preg_match_all('/^\s*(\d+)[\.\)]\s+/m', $extractedText, $matches);
    if (!empty($matches[1])) {
        $numbers = array_map('intval', $matches[1]);
        $minNum = min($numbers);
        $maxNum = max($numbers);
        echo "\n  Question range: Q$minNum to Q$maxNum\n";
        echo "  Total question markers found: " . count($numbers) . "\n";
        
        // Check if Q1 and Q2 are in the list
        if (!in_array(1, $numbers)) {
            echo "  ❌ Question 1 is MISSING from the list!\n";
        }
        if (!in_array(2, $numbers)) {
            echo "  ❌ Question 2 is MISSING from the list!\n";
        }
    }
    
    // Save first 2000 chars for inspection
    file_put_contents(__DIR__ . '/test-extraction-preview.txt', substr($extractedText, 0, 2000));
    echo "\n  Preview saved to: test-extraction-preview.txt\n";
    
} else {
    echo "❌ Python extraction failed\n";
    echo "  Return code: $returnCode\n";
    echo "  Output: " . implode("\n", $output) . "\n";
}

echo "\n========================================\n";
echo "  CONCLUSION\n";
echo "========================================\n\n";

if ($foundQ1 && $foundQ2) {
    echo "✅ Both Q1 and Q2 are present in extracted text\n";
    echo "   The problem might be in the AI parsing or splitting logic\n";
} else {
    echo "❌ Q1 and/or Q2 are missing from extracted text\n";
    echo "   The problem is in the DOCX extraction step\n";
    echo "   Check the DOCX file format - maybe Q1-Q2 are in a different format\n";
}

echo "\n";

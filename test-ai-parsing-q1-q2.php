<?php
/**
 * Test Script: Simulate AI parsing to see if Q1-Q2 are included
 */

require __DIR__ . '/backend/vendor/autoload.php';

// Load environment
$dotenv = Dotenv\Dotenv::createImmutable(__DIR__ . '/backend');
$dotenv->load();

// Bootstrap Laravel
$app = require_once __DIR__ . '/backend/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

echo "========================================\n";
echo "  AI PARSING Q1-Q2 TEST\n";
echo "========================================\n\n";

// Get the service
$service = app(\App\Services\AiDocxParserService::class);

// Extract text from DOCX
$docxFile = __DIR__ . '/Aquaculture_set A.docx';
echo "Extracting text from: $docxFile\n\n";

// Use reflection to call protected method
$reflection = new ReflectionClass($service);
$extractMethod = $reflection->getMethod('extractTextFromDocx');
$extractMethod->setAccessible(true);

$extractedText = $extractMethod->invoke($service, $docxFile);

echo "Extracted text length: " . strlen($extractedText) . " chars\n\n";

// Split into question blocks
$splitMethod = $reflection->getMethod('splitIntoQuestionBlocks');
$splitMethod->setAccessible(true);

$questionBlocks = $splitMethod->invoke($service, $extractedText);

echo "Total question blocks: " . count($questionBlocks) . "\n\n";

// Check first 5 blocks
echo "First 5 question blocks:\n";
echo "========================================\n";
for ($i = 0; $i < min(5, count($questionBlocks)); $i++) {
    $block = $questionBlocks[$i];
    
    // Extract question number
    if (preg_match('/^(\d+)[\.\)]\s+/', $block, $matches)) {
        $questionNum = $matches[1];
        $preview = substr($block, 0, 150);
        echo "\nBlock $i: Question #$questionNum\n";
        echo "Preview: $preview...\n";
    }
}

echo "\n========================================\n";
echo "  ANALYSIS\n";
echo "========================================\n\n";

// Check which question numbers are in the blocks
$questionNumbers = [];
foreach ($questionBlocks as $block) {
    if (preg_match('/^(\d+)[\.\)]/', $block, $matches)) {
        $questionNumbers[] = (int)$matches[1];
    }
}

sort($questionNumbers);
echo "Question numbers in blocks: " . implode(', ', array_slice($questionNumbers, 0, 10)) . "...\n";
echo "First question: Q" . min($questionNumbers) . "\n";
echo "Last question: Q" . max($questionNumbers) . "\n";
echo "Total questions: " . count($questionNumbers) . "\n\n";

if (in_array(1, $questionNumbers) && in_array(2, $questionNumbers)) {
    echo "✅ Q1 and Q2 are in the question blocks\n";
    echo "   The problem is in the AI parsing step\n\n";
    
    // Test with first batch (10 questions)
    echo "Testing AI parsing with first 10 questions...\n";
    $firstBatch = array_slice($questionBlocks, 0, 10);
    $batchText = implode("\n\n", $firstBatch);
    
    echo "Batch text length: " . strlen($batchText) . " chars\n";
    echo "Batch text preview:\n";
    echo substr($batchText, 0, 500) . "...\n\n";
    
    // Save to file for manual inspection
    file_put_contents(__DIR__ . '/test-first-batch.txt', $batchText);
    echo "Batch text saved to: test-first-batch.txt\n";
    echo "You can manually check if Q1 and Q2 are in this batch\n";
    
} else {
    echo "❌ Q1 and/or Q2 are NOT in the question blocks\n";
    if (!in_array(1, $questionNumbers)) {
        echo "   - Q1 is MISSING\n";
    }
    if (!in_array(2, $questionNumbers)) {
        echo "   - Q2 is MISSING\n";
    }
}

echo "\n";

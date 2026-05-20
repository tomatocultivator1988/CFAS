<?php
/**
 * Test Script: Test splitting with REAL extracted text
 */

$realText = file_get_contents(__DIR__ . '/test-extraction-preview.txt');

echo "========================================\n";
echo "  TESTING SPLIT WITH REAL TEXT\n";
echo "========================================\n\n";

echo "Text length: " . strlen($realText) . " chars\n\n";

// First, remove the answer key section if present
$text = preg_replace('/^(answer\s+key|answers?)\s*:?.*$/ims', '', $realText);

// Split by question numbers at the start of a line
$pattern = '/(?=^\s*\d+[\.\)]\s+)/m';
$blocks = preg_split($pattern, $text, -1, PREG_SPLIT_NO_EMPTY);

echo "Total blocks after split: " . count($blocks) . "\n\n";

// Filter and clean blocks
$questionBlocks = [];
$seenNumbers = [];

foreach ($blocks as $index => $block) {
    $block = trim($block);
    
    // Skip empty blocks
    if (empty($block)) {
        continue;
    }
    
    // Extract question number from the start
    if (preg_match('/^(\d+)[\.\)]\s+/', $block, $matches)) {
        $questionNum = (int)$matches[1];
        
        // Skip if we've already seen this question number (avoid duplicates)
        if (isset($seenNumbers[$questionNum])) {
            echo "⚠️  Duplicate question #$questionNum - SKIPPED\n";
            continue;
        }
        
        $seenNumbers[$questionNum] = true;
        $questionBlocks[] = $block;
        
        // Log first few questions to verify we're not skipping
        if ($questionNum <= 5) {
            $preview = substr($block, 0, 100);
            echo "✓ Found question #$questionNum at block index $index\n";
            echo "  Preview: $preview...\n\n";
        }
    } else {
        // Log blocks that don't start with a question number
        if ($index < 3) {
            echo "⚠️  Block $index doesn't start with question number: " . substr($block, 0, 100) . "\n";
        }
    }
}

// Sort by question number to ensure correct order
usort($questionBlocks, function($a, $b) {
    preg_match('/^(\d+)[\.\)]/', $a, $matchA);
    preg_match('/^(\d+)[\.\)]/', $b, $matchB);
    $numA = isset($matchA[1]) ? (int)$matchA[1] : 0;
    $numB = isset($matchB[1]) ? (int)$matchB[1] : 0;
    return $numA - $numB;
});

// Log question number range
if (!empty($questionBlocks)) {
    preg_match('/^(\d+)[\.\)]/', $questionBlocks[0], $firstMatch);
    preg_match('/^(\d+)[\.\)]/', end($questionBlocks), $lastMatch);
    $firstNum = isset($firstMatch[1]) ? $firstMatch[1] : '?';
    $lastNum = isset($lastMatch[1]) ? $lastMatch[1] : '?';
    echo "\n========================================\n";
    echo "Split into " . count($questionBlocks) . " unique question blocks (Q$firstNum to Q$lastNum)\n";
    echo "========================================\n\n";
} else {
    echo "❌ No question blocks found!\n";
}

// Check which questions were extracted
$extractedNumbers = [];
foreach ($questionBlocks as $block) {
    if (preg_match('/^(\d+)[\.\)]/', $block, $matches)) {
        $extractedNumbers[] = (int)$matches[1];
    }
}

sort($extractedNumbers);
echo "First 10 questions: " . implode(', ', array_slice($extractedNumbers, 0, 10)) . "\n";

if (in_array(1, $extractedNumbers) && in_array(2, $extractedNumbers)) {
    echo "\n✅ SUCCESS: Questions 1 and 2 are included!\n";
} else {
    echo "\n❌ PROBLEM: Questions 1 and/or 2 are missing!\n";
    if (!in_array(1, $extractedNumbers)) {
        echo "   - Question 1 is MISSING\n";
    }
    if (!in_array(2, $extractedNumbers)) {
        echo "   - Question 2 is MISSING\n";
    }
}

echo "\n";

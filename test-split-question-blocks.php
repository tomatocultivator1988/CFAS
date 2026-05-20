<?php
/**
 * Test Script: Debug splitIntoQuestionBlocks method
 * This tests why Q1 and Q2 are being skipped
 */

// Sample text with questions 1-5
$sampleText = <<<TEXT
1. What is aquaculture?
a. Fish farming
b. **Aquaculture**
c. Fish capture
d. Fish processing

2. What is the most common fish in aquaculture?
a. **Tilapia**
b. Tuna
c. Salmon
d. Mackerel

3. What does sustainable aquaculture mean?
a. Fast production
b. **Environmentally responsible farming**
c. Maximum profit
d. Large scale operations

4. What is the main challenge in aquaculture?
a. Marketing
b. **Water quality management**
c. Transportation
d. Packaging

5. What equipment is essential for aquaculture?
a. Boats
b. Nets
c. **Aeration systems**
d. Trucks
TEXT;

echo "========================================\n";
echo "  TESTING splitIntoQuestionBlocks\n";
echo "========================================\n\n";

echo "Sample text length: " . strlen($sampleText) . " chars\n\n";

// Test the regex pattern used in splitIntoQuestionBlocks
$pattern = '/(?=^\s*\d+[\.\)]\s+)/m';
$blocks = preg_split($pattern, $sampleText, -1, PREG_SPLIT_NO_EMPTY);

echo "Total blocks after split: " . count($blocks) . "\n\n";

foreach ($blocks as $index => $block) {
    $block = trim($block);
    
    if (empty($block)) {
        echo "Block $index: EMPTY (skipped)\n";
        continue;
    }
    
    // Extract question number
    if (preg_match('/^(\d+)[\.\)]\s+/', $block, $matches)) {
        $questionNum = (int)$matches[1];
        $preview = substr($block, 0, 50);
        echo "Block $index: Question #$questionNum - $preview...\n";
    } else {
        $preview = substr($block, 0, 50);
        echo "Block $index: NO QUESTION NUMBER - $preview...\n";
    }
}

echo "\n========================================\n";
echo "  ANALYSIS\n";
echo "========================================\n\n";

// Now test with the actual filtering logic from the method
$questionBlocks = [];
$seenNumbers = [];

foreach ($blocks as $index => $block) {
    $block = trim($block);
    
    if (empty($block)) {
        continue;
    }
    
    // Extract question number from the start
    if (preg_match('/^(\d+)[\.\)]\s+/', $block, $matches)) {
        $questionNum = (int)$matches[1];
        
        // Skip if we've already seen this question number
        if (isset($seenNumbers[$questionNum])) {
            echo "⚠️  Duplicate question #$questionNum - SKIPPED\n";
            continue;
        }
        
        $seenNumbers[$questionNum] = true;
        $questionBlocks[] = $block;
        
        if ($questionNum <= 5) {
            echo "✓ Found question #$questionNum at block index $index\n";
        }
    } else {
        if ($index < 3) {
            echo "⚠️  Block $index doesn't start with question number: " . substr($block, 0, 100) . "\n";
        }
    }
}

echo "\nTotal question blocks extracted: " . count($questionBlocks) . "\n";

// Check which questions were extracted
$extractedNumbers = [];
foreach ($questionBlocks as $block) {
    if (preg_match('/^(\d+)[\.\)]/', $block, $matches)) {
        $extractedNumbers[] = (int)$matches[1];
    }
}

sort($extractedNumbers);
echo "Question numbers extracted: " . implode(', ', $extractedNumbers) . "\n";

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

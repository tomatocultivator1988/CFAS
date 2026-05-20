<?php
/**
 * Test Script: Test improved choice splitting
 */

$sampleText = <<<TEXT
1. Republic Act 8550
a. Agriculture and Fisheries Modernization Act          b. Enabling Act of a University
**c. Fisheries Code of 1998**                           d. Presidential Decree 704

2. Republic Act 8435
a. Fisheries Code of 1998                               b. Modernization of Agriculture Act
c. Modernization of Fisheries Act                       **d. Agriculture and Fisheries Modernization Act**

3. The raising of two or more species of fish or crustaceans in a pond
a. monoculture                                          **b. polyculture**
c. monosex culture                                      d. integrated farming system
TEXT;

echo "========================================\n";
echo "  IMPROVED CHOICE SPLITTING TEST\n";
echo "========================================\n\n";

// Better approach: Split each line that has multiple choices
$lines = explode("\n", $sampleText);
$processedLines = [];

foreach ($lines as $line) {
    // Check if line has multiple choices (a. ... b. ... or c. ... d. ...)
    // Pattern: choice letter followed by text, then 2+ spaces, then another choice letter
    if (preg_match('/^([a-d]\.\s+.+?)\s{2,}([a-d]\.\s+.+)$/', $line, $matches)) {
        // Split into two lines
        $processedLines[] = trim($matches[1]);
        $processedLines[] = trim($matches[2]);
    } else {
        $processedLines[] = $line;
    }
}

$processedText = implode("\n", $processedLines);

echo "AFTER PREPROCESSING:\n";
echo "--------------------\n";
$lines = explode("\n", $processedText);
foreach ($lines as $i => $line) {
    if ($i < 20) {
        echo "Line $i: $line\n";
    }
}

echo "\n========================================\n";
echo "  ANALYSIS\n";
echo "========================================\n\n";

// Count choices per question
preg_match_all('/^([a-d])\.\s+/m', $processedText, $matches);
echo "Total choice markers found: " . count($matches[0]) . "\n";

// Check if Q1 has 4 choices
$q1Block = substr($processedText, 0, strpos($processedText, '2. Republic Act'));
preg_match_all('/^([a-d])\.\s+/m', $q1Block, $q1Choices);
echo "Q1 choices: " . count($q1Choices[0]) . " (should be 4)\n";

if (count($q1Choices[0]) == 4) {
    echo "✅ Q1 now has 4 separate choice lines\n";
} else {
    echo "❌ Q1 still has issues\n";
}

// Check Q2
$q2Start = strpos($processedText, '2. Republic Act');
$q2End = strpos($processedText, '3. The raising');
$q2Block = substr($processedText, $q2Start, $q2End - $q2Start);
preg_match_all('/^([a-d])\.\s+/m', $q2Block, $q2Choices);
echo "Q2 choices: " . count($q2Choices[0]) . " (should be 4)\n";

if (count($q2Choices[0]) == 4) {
    echo "✅ Q2 now has 4 separate choice lines\n";
} else {
    echo "❌ Q2 still has issues\n";
}

echo "\n";

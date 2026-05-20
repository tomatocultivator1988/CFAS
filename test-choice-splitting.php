<?php
/**
 * Test Script: Test choice splitting preprocessing
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
echo "  CHOICE SPLITTING TEST\n";
echo "========================================\n\n";

echo "BEFORE PREPROCESSING:\n";
echo "--------------------\n";
$lines = explode("\n", $sampleText);
foreach ($lines as $i => $line) {
    if ($i < 10) {
        echo "Line $i: $line\n";
    }
}

echo "\n\nAPPLYING PREPROCESSING...\n\n";

// Apply the preprocessing regex
// Pattern: matches "a. text" followed by whitespace and "b. text" on the same line
$processedText = preg_replace('/([a-d]\.\s+[^\n]+?)\s{2,}([a-d]\.\s+)/m', "$1\n$2", $sampleText);

echo "AFTER PREPROCESSING:\n";
echo "--------------------\n";
$lines = explode("\n", $processedText);
foreach ($lines as $i => $line) {
    if ($i < 15) {
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

echo "\n";

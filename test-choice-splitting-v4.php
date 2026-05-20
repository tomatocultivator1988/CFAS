<?php
/**
 * Test Script: Test choice splitting with proper marker handling
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
echo "  CHOICE SPLITTING V4\n";
echo "========================================\n\n";

function splitChoicesOnLine($text) {
    $lines = explode("\n", $text);
    $processedLines = [];
    
    foreach ($lines as $line) {
        // Skip empty lines
        if (trim($line) === '') {
            $processedLines[] = $line;
            continue;
        }
        
        // Check if line starts with a choice letter (with or without **)
        if (!preg_match('/^(\*\*)?[a-d]\.\s+/', $line)) {
            $processedLines[] = $line;
            continue;
        }
        
        // Try to split by multiple spaces (2 or more) before a choice letter
        // This handles: "a. text    b. text" or "**c. text**    d. text"
        // Pattern: 2+ spaces followed by optional ** and choice letter
        $parts = preg_split('/\s{2,}(?=(\*\*)?[a-d]\.\s+)/', $line);
        
        if (count($parts) > 1) {
            // Multiple choices on one line - split them
            foreach ($parts as $part) {
                $trimmed = trim($part);
                if ($trimmed !== '') {
                    $processedLines[] = $trimmed;
                }
            }
        } else {
            // Single choice on line
            $processedLines[] = $line;
        }
    }
    
    return implode("\n", $processedLines);
}

$processedText = splitChoicesOnLine($sampleText);

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

// Count choices per question (with or without **)
preg_match_all('/^(\*\*)?([a-d])\.\s+/m', $processedText, $matches);
echo "Total choice markers found: " . count($matches[0]) . "\n";

// Check if Q1 has 4 choices
$q1Block = substr($processedText, 0, strpos($processedText, '2. Republic Act'));
preg_match_all('/^(\*\*)?([a-d])\.\s+/m', $q1Block, $q1Choices);
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
preg_match_all('/^(\*\*)?([a-d])\.\s+/m', $q2Block, $q2Choices);
echo "Q2 choices: " . count($q2Choices[0]) . " (should be 4)\n";

if (count($q2Choices[0]) == 4) {
    echo "✅ Q2 now has 4 separate choice lines\n";
} else {
    echo "❌ Q2 still has issues\n";
}

echo "\n";

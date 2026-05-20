<?php
/**
 * Test script for Professional CSV Export
 * This tests the new exportProfessionalResults endpoint
 */

echo "Testing Professional CSV Export Endpoint\n";
echo "========================================\n\n";

// Test the endpoint URL
$url = "http://192.168.11.40/exam-backend/api/admin/export/professional-results";

echo "Testing endpoint: $url\n\n";

// Create a test request
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Accept: application/json',
    'Content-Type: application/json'
]);

// For testing, you might need to add authentication
// curl_setopt($ch, CURLOPT_HTTPHEADER, [
//     'Authorization: Bearer YOUR_TOKEN_HERE',
//     'Accept: application/json',
//     'Content-Type: application/json'
// ]);

echo "Sending request...\n";
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);

echo "HTTP Status Code: $httpCode\n\n";

if ($response === false) {
    echo "CURL Error: " . curl_error($ch) . "\n";
} else {
    $data = json_decode($response, true);
    
    if (json_last_error() !== JSON_ERROR_NONE) {
        echo "JSON Parse Error: " . json_last_error_msg() . "\n";
        echo "Raw Response:\n";
        echo substr($response, 0, 500) . "...\n";
    } else {
        echo "Response Structure:\n";
        echo "-------------------\n";
        
        if (isset($data['success'])) {
            echo "Success: " . ($data['success'] ? 'true' : 'false') . "\n";
        }
        
        if (isset($data['count'])) {
            echo "Row Count: " . $data['count'] . "\n";
        }
        
        if (isset($data['format'])) {
            echo "Format: " . $data['format'] . "\n";
        }
        
        if (isset($data['data']) && is_array($data['data'])) {
            echo "\nData Preview (first 10 rows):\n";
            echo "------------------------------\n";
            
            $sampleRows = array_slice($data['data'], 0, 10);
            foreach ($sampleRows as $index => $row) {
                echo "Row $index: ";
                if (is_array($row)) {
                    echo "Array with " . count($row) . " columns\n";
                    // Show first few columns
                    $sampleCols = array_slice($row, 0, 3);
                    echo "  Sample: " . implode(" | ", array_map(function($val) {
                        return substr(strval($val), 0, 30);
                    }, $sampleCols)) . "\n";
                } else {
                    echo gettype($row) . "\n";
                }
            }
            
            // Check structure
            echo "\nStructure Analysis:\n";
            echo "------------------\n";
            
            $hasMetadata = false;
            $hasStudentInfo = false;
            $hasCategorySections = false;
            $hasSummary = false;
            
            foreach ($data['data'] as $row) {
                if (is_array($row) && count($row) > 0) {
                    $firstCell = $row[0] ?? '';
                    if (strpos($firstCell, 'CFAS REVIEW CENTER') !== false) {
                        $hasMetadata = true;
                    }
                    if (strpos($firstCell, 'STUDENT INFORMATION') !== false) {
                        $hasStudentInfo = true;
                    }
                    if (strpos($firstCell, 'EXAM RESULTS') !== false) {
                        $hasCategorySections = true;
                    }
                    if (strpos($firstCell, 'OVERALL PERFORMANCE') !== false) {
                        $hasSummary = true;
                    }
                }
            }
            
            echo "✓ Metadata Section: " . ($hasMetadata ? 'Yes' : 'No') . "\n";
            echo "✓ Student Information: " . ($hasStudentInfo ? 'Yes' : 'No') . "\n";
            echo "✓ Category Sections: " . ($hasCategorySections ? 'Yes' : 'No') . "\n";
            echo "✓ Overall Summary: " . ($hasSummary ? 'Yes' : 'No') . "\n";
            
        } else {
            echo "No data array found in response\n";
        }
        
        if (isset($data['message'])) {
            echo "\nMessage: " . $data['message'] . "\n";
        }
    }
}

curl_close($ch);

echo "\n\nTest Complete!\n";
echo "=============\n";

// Also test CSV generation
echo "\nTesting CSV Generation:\n";
echo "----------------------\n";

if (isset($data['data']) && is_array($data['data'])) {
    $csvContent = "";
    foreach ($data['data'] as $row) {
        if (is_array($row)) {
            $escapedRow = array_map(function($cell) {
                $cell = strval($cell);
                $cell = str_replace('"', '""', $cell);
                return '"' . $cell . '"';
            }, $row);
            $csvContent .= implode(',', $escapedRow) . "\n";
        }
    }
    
    $lineCount = count($data['data']);
    $charCount = strlen($csvContent);
    
    echo "CSV would be $lineCount lines, $charCount characters\n";
    echo "First 3 lines of CSV:\n";
    echo "---------------------\n";
    
    $lines = explode("\n", $csvContent);
    for ($i = 0; $i < min(3, count($lines)); $i++) {
        echo substr($lines[$i], 0, 100) . "...\n";
    }
}

echo "\n\nRecommendations:\n";
echo "---------------\n";
echo "1. Deploy using DEPLOY-PROFESSIONAL-CSV.bat\n";
echo "2. Clear Laravel cache after deployment\n";
echo "3. Test the endpoint with proper authentication\n";
echo "4. Verify the CSV download works in the frontend\n";
?>
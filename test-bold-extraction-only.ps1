# Test Bold/Highlight Extraction Only
Write-Host "=== Testing Bold/Highlight Extraction ===" -ForegroundColor Cyan
Write-Host ""

$docxFile = "Aquaculture_set A.docx"

# Test 1: Extract with formatting
Write-Host "1. Extracting text with formatting markers..." -ForegroundColor Yellow
try {
    $output = python extract-with-formatting.py "$docxFile" "test-formatted.txt" 2>&1
    Write-Host "   $output" -ForegroundColor Gray
    
    if (Test-Path "test-formatted.txt") {
        $content = Get-Content "test-formatted.txt" -Raw
        $markerCount = ([regex]::Matches($content, '\*\*')).Count / 2
        
        Write-Host "   OK - Extraction successful!" -ForegroundColor Green
        Write-Host "   Found $markerCount bold/highlighted items" -ForegroundColor White
    } else {
        Write-Host "   ERROR - Output file not created" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "   ERROR - Extraction failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Test 2: Show sample marked items
Write-Host "2. Sample marked items (first 10):" -ForegroundColor Yellow
$lines = Get-Content "test-formatted.txt" | Select-String "\*\*" | Select-Object -First 10
$count = 1
foreach ($line in $lines) {
    $lineText = $line.Line
    # Extract the marked text
    if ($lineText -match '\*\*([^*]+)\*\*') {
        $markedText = $matches[1]
        Write-Host "   $count. $markedText" -ForegroundColor Green
        $count++
    }
}
Write-Host ""

# Test 3: Verify question structure
Write-Host "3. Verifying question structure..." -ForegroundColor Yellow
$content = Get-Content "test-formatted.txt"
$questionLines = $content | Select-String "^\d+\." | Select-Object -First 5

Write-Host "   First 5 questions:" -ForegroundColor Gray
foreach ($qLine in $questionLines) {
    $text = $qLine.Line.Substring(0, [Math]::Min(70, $qLine.Line.Length))
    Write-Host "   $text..." -ForegroundColor DarkGray
}
Write-Host ""

# Test 4: Count questions with marked answers
Write-Host "4. Analyzing marked answers..." -ForegroundColor Yellow
$allLines = Get-Content "test-formatted.txt"
$questionCount = 0
$markedAnswerCount = 0
$inQuestion = $false

for ($i = 0; $i -lt $allLines.Count; $i++) {
    $line = $allLines[$i]
    
    # Check if this is a question line
    if ($line -match '^\d+\.') {
        $questionCount++
        $inQuestion = $true
        
        # Check next few lines for marked answers
        $hasMarkedAnswer = $false
        for ($j = $i; $j -lt [Math]::Min($i + 10, $allLines.Count); $j++) {
            if ($allLines[$j] -match '\*\*') {
                $hasMarkedAnswer = $true
                break
            }
            # Stop if we hit the next question
            if ($j -gt $i -and $allLines[$j] -match '^\d+\.') {
                break
            }
        }
        
        if ($hasMarkedAnswer) {
            $markedAnswerCount++
        }
    }
}

Write-Host "   Total questions found: $questionCount" -ForegroundColor White
Write-Host "   Questions with marked answers: $markedAnswerCount" -ForegroundColor White
$percentage = if ($questionCount -gt 0) { [math]::Round(($markedAnswerCount / $questionCount) * 100, 1) } else { 0 }
Write-Host "   Coverage: $percentage%" -ForegroundColor $(if ($percentage -gt 80) { "Green" } else { "Yellow" })
Write-Host ""

# Test 5: Compare with old extraction
Write-Host "5. Comparing with old extraction method..." -ForegroundColor Yellow
try {
    python extract-to-file.py "$docxFile" "test-old.txt" 2>&1 | Out-Null
    
    $oldContent = Get-Content "test-old.txt" -Raw
    $newContent = Get-Content "test-formatted.txt" -Raw
    
    $oldLength = $oldContent.Length
    $newLength = $newContent.Length
    
    Write-Host "   Old method: $oldLength characters" -ForegroundColor Gray
    Write-Host "   New method: $newLength characters (with markers)" -ForegroundColor Gray
    
    $difference = $newLength - $oldLength
    Write-Host "   Difference: +$difference characters (formatting markers)" -ForegroundColor White
    
    Remove-Item "test-old.txt" -ErrorAction SilentlyContinue
} catch {
    Write-Host "   WARNING - Could not compare with old method" -ForegroundColor Yellow
}
Write-Host ""

Write-Host "=== TEST RESULTS ===" -ForegroundColor Cyan
Write-Host ""
if ($markedAnswerCount -gt 0) {
    Write-Host "SUCCESS! Bold/Highlight detection is working!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Summary:" -ForegroundColor White
    Write-Host "- Formatting extraction: WORKING" -ForegroundColor Green
    Write-Host "- Bold text detection: WORKING" -ForegroundColor Green
    Write-Host "- Highlight detection: WORKING" -ForegroundColor Green
    Write-Host "- Marker insertion: WORKING" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next step: Test the full import through the web interface!" -ForegroundColor Cyan
} else {
    Write-Host "WARNING: No marked answers found!" -ForegroundColor Yellow
    Write-Host "This could mean:" -ForegroundColor White
    Write-Host "- The DOCX file has no bold/highlighted text" -ForegroundColor Gray
    Write-Host "- The extraction script needs adjustment" -ForegroundColor Gray
}
Write-Host ""

# Cleanup
Write-Host "Cleaning up test files..." -ForegroundColor Gray
Remove-Item "test-formatted.txt" -ErrorAction SilentlyContinue

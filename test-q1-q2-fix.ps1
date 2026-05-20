# Test Script: Verify Q1-Q2 Skip Fix
# This script verifies that the fix for skipping questions 1-2 is working

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Q1-Q2 SKIP FIX VERIFICATION TEST" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Check Python script exists
Write-Host "[TEST 1] Python Script Deployment" -ForegroundColor Yellow
$pythonScript = "C:\xampp\htdocs\exam-backend\extract-with-formatting.py"
if (Test-Path $pythonScript) {
    Write-Host "  ✓ Python script exists at: $pythonScript" -ForegroundColor Green
    $scriptSize = (Get-Item $pythonScript).Length
    Write-Host "  ✓ File size: $scriptSize bytes" -ForegroundColor Green
} else {
    Write-Host "  ✗ Python script MISSING at: $pythonScript" -ForegroundColor Red
    Write-Host "  ACTION: Run deployment script to copy file" -ForegroundColor Yellow
}
Write-Host ""

# Test 2: Check service file has bold marker logic
Write-Host "[TEST 2] Service File Enhancement" -ForegroundColor Yellow
$serviceFile = "C:\xampp\htdocs\exam-backend\app\Services\AiDocxParserService.php"
if (Test-Path $serviceFile) {
    Write-Host "  ✓ Service file exists" -ForegroundColor Green
    
    $content = Get-Content $serviceFile -Raw
    
    # Check for bold marker logic
    if ($content -match 'WITH BOLD MARKERS') {
        Write-Host "  ✓ Contains 'WITH BOLD MARKERS' comment" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Missing 'WITH BOLD MARKERS' comment" -ForegroundColor Red
    }
    
    if ($content -match '\$isBold') {
        Write-Host "  ✓ Contains bold detection logic (\$isBold)" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Missing bold detection logic" -ForegroundColor Red
    }
    
    if ($content -match 'w:b') {
        Write-Host "  ✓ Contains XML bold element detection (w:b)" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Missing XML bold element detection" -ForegroundColor Red
    }
    
    if ($content -match '\*\*.*\*\*') {
        Write-Host "  ✓ Contains marker wrapping logic (**text**)" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Missing marker wrapping logic" -ForegroundColor Red
    }
} else {
    Write-Host "  ✗ Service file MISSING" -ForegroundColor Red
}
Write-Host ""

# Test 3: Check log file for recent imports
Write-Host "[TEST 3] Recent Import Logs" -ForegroundColor Yellow
$logFile = "C:\xampp\htdocs\exam-backend\storage\logs\laravel.log"
if (Test-Path $logFile) {
    Write-Host "  ✓ Log file exists" -ForegroundColor Green
    
    # Get last 200 lines and look for split info
    $recentLogs = Get-Content $logFile -Tail 200
    $splitLines = $recentLogs | Select-String "Split into.*question blocks"
    
    if ($splitLines) {
        Write-Host "  Recent import splits found:" -ForegroundColor Cyan
        foreach ($line in $splitLines | Select-Object -Last 3) {
            if ($line -match 'Q1 to Q') {
                Write-Host "    ✓ $line" -ForegroundColor Green
            } elseif ($line -match 'Q2 to Q|Q3 to Q') {
                Write-Host "    ✗ $line" -ForegroundColor Red
                Write-Host "      WARNING: Still skipping Q1!" -ForegroundColor Yellow
            } else {
                Write-Host "    ? $line" -ForegroundColor Gray
            }
        }
    } else {
        Write-Host "  No recent import splits found in logs" -ForegroundColor Gray
        Write-Host "  (This is OK if you haven't tested yet)" -ForegroundColor Gray
    }
} else {
    Write-Host "  ✗ Log file not found" -ForegroundColor Red
}
Write-Host ""

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "FIX COMPONENTS:" -ForegroundColor Yellow
Write-Host "  1. Python script with bold detection" -ForegroundColor White
Write-Host "  2. Enhanced ZIP/XML extraction with bold markers" -ForegroundColor White
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host "  1. Go to: http://localhost/exam-frontend" -ForegroundColor White
Write-Host "  2. Login as admin" -ForegroundColor White
Write-Host "  3. Create new exam" -ForegroundColor White
Write-Host "  4. Upload DOCX with 100 questions" -ForegroundColor White
Write-Host "  5. Verify all 100 questions imported (not 98)" -ForegroundColor White
Write-Host "  6. Check logs show 'Q1 to Q100' (not 'Q2 to Q100')" -ForegroundColor White
Write-Host ""
Write-Host "LOG CHECK COMMAND:" -ForegroundColor Yellow
Write-Host '  Get-Content "C:\xampp\htdocs\exam-backend\storage\logs\laravel.log" -Tail 100 | Select-String "Split into"' -ForegroundColor Gray
Write-Host ""

# Compare Development vs XAMPP Backend Files
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Development vs XAMPP Comparison" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$devRoot = "backend"
$xamppRoot = "C:\xampp\htdocs\exam-backend"

# Check if XAMPP backend exists
if (-not (Test-Path $xamppRoot)) {
    Write-Host "[ERROR] XAMPP backend not found at: $xamppRoot" -ForegroundColor Red
    pause
    exit 1
}

Write-Host "[INFO] Comparing key files...`n" -ForegroundColor Yellow

# Files to compare
$filesToCompare = @(
    "app\Http\Controllers\RevieweeExamController.php",
    "app\Http\Controllers\QuestionController.php",
    "app\Http\Controllers\ExamController.php",
    "app\Services\RandomizationService.php",
    "routes\api.php",
    ".env",
    "public\index.php"
)

$identical = 0
$different = 0
$missing = 0

foreach ($file in $filesToCompare) {
    $devFile = Join-Path $devRoot $file
    $xamppFile = Join-Path $xamppRoot $file
    
    Write-Host "Checking: $file" -ForegroundColor White
    
    if (-not (Test-Path $devFile)) {
        Write-Host "  [MISSING] Not in development folder" -ForegroundColor Red
        $missing++
        continue
    }
    
    if (-not (Test-Path $xamppFile)) {
        Write-Host "  [MISSING] Not in XAMPP" -ForegroundColor Red
        $missing++
        continue
    }
    
    $devHash = (Get-FileHash $devFile -Algorithm MD5).Hash
    $xamppHash = (Get-FileHash $xamppFile -Algorithm MD5).Hash
    
    $devTime = (Get-Item $devFile).LastWriteTime
    $xamppTime = (Get-Item $xamppFile).LastWriteTime
    
    if ($devHash -eq $xamppHash) {
        Write-Host "  [IDENTICAL] Same content" -ForegroundColor Green
        Write-Host "  Dev:  $devTime" -ForegroundColor Gray
        Write-Host "  XAMPP: $xamppTime" -ForegroundColor Gray
        $identical++
    } else {
        Write-Host "  [DIFFERENT] Content differs!" -ForegroundColor Red
        Write-Host "  Dev:  $devTime" -ForegroundColor Gray
        Write-Host "  XAMPP: $xamppTime" -ForegroundColor Gray
        $different++
    }
    
    Write-Host ""
}

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Identical: $identical" -ForegroundColor Green
Write-Host "Different: $different" -ForegroundColor $(if ($different -gt 0) { "Red" } else { "Green" })
Write-Host "Missing:   $missing" -ForegroundColor $(if ($missing -gt 0) { "Red" } else { "Green" })
Write-Host ""

if ($different -gt 0) {
    Write-Host "[WARNING] Some files are different!" -ForegroundColor Yellow
    Write-Host "You may need to redeploy: .\deploy-backend.bat" -ForegroundColor Yellow
} elseif ($missing -gt 0) {
    Write-Host "[WARNING] Some files are missing!" -ForegroundColor Yellow
    Write-Host "You may need to redeploy: .\deploy-backend.bat" -ForegroundColor Yellow
} else {
    Write-Host "[SUCCESS] All checked files are identical!" -ForegroundColor Green
}

Write-Host "========================================`n" -ForegroundColor Cyan
pause

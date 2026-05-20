#!/usr/bin/env pwsh

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "VERIFYING EXPORT SECTION REMOVAL" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if the built files exist
$analyticsJs = "C:\xampp\htdocs\exam-frontend\assets\AnalyticsDashboard-Ca31c0b7.js"
$analyticsCss = "C:\xampp\htdocs\exam-frontend\assets\AnalyticsDashboard-Bs3T7A7G.css"

Write-Host "[1/4] Checking deployed files..." -ForegroundColor Yellow
if (Test-Path $analyticsJs) {
    Write-Host "✓ Analytics JS file found: AnalyticsDashboard-Ca31c0b7.js" -ForegroundColor Green
} else {
    Write-Host "✗ Analytics JS file NOT found!" -ForegroundColor Red
    exit 1
}

if (Test-Path $analyticsCss) {
    Write-Host "✓ Analytics CSS file found: AnalyticsDashboard-Bs3T7A7G.css" -ForegroundColor Green
} else {
    Write-Host "✗ Analytics CSS file NOT found!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[2/4] Searching for export-related code in JS file..." -ForegroundColor Yellow
$jsContent = Get-Content $analyticsJs -Raw
$exportMatches = @(
    "Export & Print",
    "export-section",
    "ExportToolbar",
    "CSV Export",
    "export.*button",
    "download.*csv"
)

$foundExports = @()
foreach ($pattern in $exportMatches) {
    if ($jsContent -match $pattern) {
        $foundExports += $pattern
    }
}

if ($foundExports.Count -eq 0) {
    Write-Host "✓ No export-related code found in JS file!" -ForegroundColor Green
} else {
    Write-Host "✗ Found export-related code:" -ForegroundColor Red
    foreach ($match in $foundExports) {
        Write-Host "  - $match" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "[3/4] Searching for export-related styles in CSS file..." -ForegroundColor Yellow
$cssContent = Get-Content $analyticsCss -Raw
$cssExportMatches = @(
    "export-section",
    "export-toolbar",
    "export-button",
    "csv-export"
)

$foundCssExports = @()
foreach ($pattern in $cssExportMatches) {
    if ($cssContent -match $pattern) {
        $foundCssExports += $pattern
    }
}

if ($foundCssExports.Count -eq 0) {
    Write-Host "✓ No export-related styles found in CSS file!" -ForegroundColor Green
} else {
    Write-Host "✗ Found export-related styles:" -ForegroundColor Red
    foreach ($match in $foundCssExports) {
        Write-Host "  - $match" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "[4/4] Testing Analytics Dashboard URL..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://192.168.11.40/exam-frontend/admin/analytics" -TimeoutSec 10 -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "✓ Analytics Dashboard is accessible!" -ForegroundColor Green
        Write-Host "  Status: $($response.StatusCode)" -ForegroundColor Green
    } else {
        Write-Host "✗ Analytics Dashboard returned status: $($response.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ Failed to access Analytics Dashboard: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "VERIFICATION COMPLETE!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host "1. Clear your browser cache completely (Ctrl + Shift + Delete)" -ForegroundColor White
Write-Host "2. Select 'All time' and check all boxes" -ForegroundColor White
Write-Host "3. Clear data" -ForegroundColor White
Write-Host "4. Go to: http://192.168.11.40/exam-frontend/admin/analytics" -ForegroundColor White
Write-Host "5. The Export & Print section should be GONE!" -ForegroundColor Green
Write-Host ""
Write-Host "If you still see the export section, try:" -ForegroundColor Yellow
Write-Host "- Open in incognito/private mode" -ForegroundColor White
Write-Host "- Try a different browser" -ForegroundColor White
Write-Host "- Hard refresh with Ctrl + F5" -ForegroundColor White
Write-Host ""

Read-Host "Press Enter to continue"
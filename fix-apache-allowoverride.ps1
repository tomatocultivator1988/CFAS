# Fix Apache AllowOverride Setting
# Run as Administrator

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Fixing Apache AllowOverride Setting" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Check if running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    Write-Host "`nPress any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

$httpdConf = "C:\xampp\apache\conf\httpd.conf"

if (-not (Test-Path $httpdConf)) {
    Write-Host "ERROR: httpd.conf not found at $httpdConf" -ForegroundColor Red
    Write-Host "Is XAMPP installed?" -ForegroundColor Yellow
    Write-Host "`nPress any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-Host "Backing up httpd.conf..." -ForegroundColor Yellow
$backupPath = "$httpdConf.backup." + (Get-Date -Format "yyyyMMdd_HHmmss")
Copy-Item $httpdConf $backupPath
Write-Host "   Backup created: $backupPath" -ForegroundColor Green

Write-Host "`nUpdating AllowOverride settings..." -ForegroundColor Yellow

$content = Get-Content $httpdConf -Raw

# Replace AllowOverride None with AllowOverride All in the htdocs directory section
$pattern = '(<Directory\s+"C:/xampp/htdocs">[\s\S]*?)AllowOverride\s+None'
$replacement = '$1AllowOverride All'

if ($content -match $pattern) {
    $content = $content -replace $pattern, $replacement
    Set-Content $httpdConf -Value $content -NoNewline
    Write-Host "   AllowOverride changed to 'All' for htdocs directory" -ForegroundColor Green
} else {
    Write-Host "   Could not find the pattern to replace" -ForegroundColor Yellow
    Write-Host "   You may need to edit httpd.conf manually" -ForegroundColor Yellow
}

Write-Host "`nVerifying mod_rewrite is enabled..." -ForegroundColor Yellow
$content = Get-Content $httpdConf -Raw

if ($content -match "#LoadModule rewrite_module") {
    Write-Host "   Uncommenting mod_rewrite..." -ForegroundColor Yellow
    $content = $content -replace "#LoadModule rewrite_module", "LoadModule rewrite_module"
    Set-Content $httpdConf -Value $content -NoNewline
    Write-Host "   mod_rewrite enabled" -ForegroundColor Green
} elseif ($content -match "LoadModule rewrite_module") {
    Write-Host "   mod_rewrite already enabled" -ForegroundColor Green
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Apache Configuration Updated!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`nIMPORTANT: You MUST restart Apache now!" -ForegroundColor Yellow
Write-Host "`nSteps:" -ForegroundColor Yellow
Write-Host "1. Open XAMPP Control Panel" -ForegroundColor White
Write-Host "2. Click 'Stop' on Apache" -ForegroundColor White
Write-Host "3. Click 'Start' on Apache" -ForegroundColor White
Write-Host "4. Clear browser cache (Ctrl+Shift+Delete)" -ForegroundColor White
Write-Host "5. Test exam submission: http://192.168.11.40/exam-frontend/" -ForegroundColor White

Write-Host "`nIf you need to restore the backup:" -ForegroundColor Yellow
Write-Host "Copy-Item '$backupPath' '$httpdConf' -Force" -ForegroundColor Cyan

Write-Host "`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

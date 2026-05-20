# ============================================================================
# Deploy Fixed CFAS Launcher
# This script backs up old files and deploys the fixed versions
# ============================================================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CFAS Launcher Fix Deployment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Ask for confirmation
Write-Host "This script will:" -ForegroundColor Yellow
Write-Host "  1. Backup old launcher files to 'backup' folder" -ForegroundColor White
Write-Host "  2. Replace them with fixed versions" -ForegroundColor White
Write-Host "  3. Delete old desktop shortcut" -ForegroundColor White
Write-Host ""

$confirmation = Read-Host "Do you want to continue? (Y/N)"
if ($confirmation -ne "Y" -and $confirmation -ne "y") {
    Write-Host ""
    Write-Host "Deployment cancelled." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

Write-Host ""

# Create backup directory
Write-Host "Step 1: Creating backup directory..." -ForegroundColor Cyan

$backupDir = "backup"
if (-not (Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir | Out-Null
    Write-Host "  ✓ Backup directory created" -ForegroundColor Green
} else {
    Write-Host "  ✓ Backup directory already exists" -ForegroundColor Green
}

Write-Host ""

# Backup old files
Write-Host "Step 2: Backing up old files..." -ForegroundColor Cyan

$filesToBackup = @(
    "CFAS-System-Launcher.ps1",
    "Launch-CFAS.vbs",
    "LAUNCH-CFAS-GUI.bat",
    "Create-Desktop-Shortcut.ps1"
)

foreach ($file in $filesToBackup) {
    if (Test-Path $file) {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $backupFile = Join-Path $backupDir "$file.$timestamp.bak"
        Copy-Item $file $backupFile -Force
        Write-Host "  ✓ Backed up: $file" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ File not found: $file (skipping)" -ForegroundColor Yellow
    }
}

Write-Host ""

# Deploy fixed files
Write-Host "Step 3: Deploying fixed files..." -ForegroundColor Cyan

$deployments = @{
    "CFAS-System-Launcher-FIXED.ps1" = "CFAS-System-Launcher.ps1"
    "Launch-CFAS-FIXED.vbs" = "Launch-CFAS.vbs"
    "LAUNCH-CFAS-GUI-FIXED.bat" = "LAUNCH-CFAS-GUI.bat"
    "Create-Desktop-Shortcut-FIXED.ps1" = "Create-Desktop-Shortcut.ps1"
}

foreach ($source in $deployments.Keys) {
    $destination = $deployments[$source]
    
    if (Test-Path $source) {
        Copy-Item $source $destination -Force
        Write-Host "  ✓ Deployed: $source → $destination" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Source file not found: $source" -ForegroundColor Red
    }
}

Write-Host ""

# Delete old desktop shortcut
Write-Host "Step 4: Removing old desktop shortcut..." -ForegroundColor Cyan

$desktopPath = [Environment]::GetFolderPath("Desktop")
$oldShortcut = Join-Path $desktopPath "CFAS Exam System.lnk"

if (Test-Path $oldShortcut) {
    Remove-Item $oldShortcut -Force
    Write-Host "  ✓ Old shortcut removed" -ForegroundColor Green
} else {
    Write-Host "  ⚠ Old shortcut not found (skipping)" -ForegroundColor Yellow
}

Write-Host ""

# Summary
Write-Host "========================================" -ForegroundColor Green
Write-Host "Deployment Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "What was done:" -ForegroundColor Cyan
Write-Host "  ✓ Old files backed up to 'backup' folder" -ForegroundColor White
Write-Host "  ✓ Fixed files deployed" -ForegroundColor White
Write-Host "  ✓ Old desktop shortcut removed" -ForegroundColor White
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Run: .\Create-Desktop-Shortcut.ps1" -ForegroundColor White
Write-Host "     (This will create a new shortcut with the fixed launcher)" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Double-click the new desktop shortcut to test" -ForegroundColor White
Write-Host "     (Terminal should stay open and show all messages)" -ForegroundColor Gray
Write-Host ""
Write-Host "If you need to rollback:" -ForegroundColor Yellow
Write-Host "  - Restore files from 'backup' folder" -ForegroundColor Gray
Write-Host ""

Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Quick Git Installer - Downloads and starts installation
Write-Host "Downloading Git installer..." -ForegroundColor Cyan

$gitUrl = "https://github.com/git-for-windows/git/releases/download/v2.43.0.windows.1/Git-2.43.0-64-bit.exe"
$installerPath = "$env:TEMP\GitInstaller.exe"

# Check if already installed
try {
    git --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Git is already installed!" -ForegroundColor Green
        git --version
        exit 0
    }
} catch {}

# Download
Write-Host "Downloading from GitHub..." -ForegroundColor Yellow
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri $gitUrl -OutFile $installerPath -UseBasicParsing
$ProgressPreference = 'Continue'

Write-Host "Download complete! Starting installer..." -ForegroundColor Green
Write-Host "Follow the prompts (use default settings)" -ForegroundColor Yellow

# Start installer without waiting
Start-Process -FilePath $installerPath

Write-Host "`nInstaller started!" -ForegroundColor Green
Write-Host "After installation:" -ForegroundColor Cyan
Write-Host "1. Close and reopen PowerShell" -ForegroundColor White
Write-Host "2. Run: git --version" -ForegroundColor White
Write-Host "3. Then: git init" -ForegroundColor White

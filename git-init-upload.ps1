# Git Upload Script - Works even if PATH not updated
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Git Upload Helper" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Find Git executable
$gitPaths = @(
    "C:\Program Files\Git\bin\git.exe",
    "C:\Program Files (x86)\Git\bin\git.exe",
    "$env:LOCALAPPDATA\Programs\Git\bin\git.exe"
)

$gitExe = $null
foreach ($path in $gitPaths) {
    if (Test-Path $path) {
        $gitExe = $path
        break
    }
}

if ($null -eq $gitExe) {
    Write-Host "[ERROR] Git not found!" -ForegroundColor Red
    Write-Host "Please install Git first using: quick-install-git.ps1" -ForegroundColor Yellow
    Write-Host "Or download from: https://git-scm.com/download/win" -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host "[OK] Found Git at: $gitExe" -ForegroundColor Green
& $gitExe --version
Write-Host ""

# Check if already initialized
if (Test-Path ".git") {
    Write-Host "[INFO] Git repository already initialized" -ForegroundColor Yellow
    Write-Host ""
} else {
    Write-Host "Initializing Git repository..." -ForegroundColor Yellow
    & $gitExe init
    Write-Host "[OK] Repository initialized!" -ForegroundColor Green
    Write-Host ""
}

# Configure Git user (if not set)
Write-Host "Configuring Git user..." -ForegroundColor Yellow
$userName = Read-Host "Enter your name (for commits)"
$userEmail = Read-Host "Enter your email"

& $gitExe config user.name "$userName"
& $gitExe config user.email "$userEmail"
Write-Host "[OK] User configured!" -ForegroundColor Green
Write-Host ""

# Add files
Write-Host "Adding files to Git..." -ForegroundColor Yellow
& $gitExe add .
Write-Host "[OK] Files added!" -ForegroundColor Green
Write-Host ""

# Show status
Write-Host "Git Status:" -ForegroundColor Cyan
& $gitExe status --short
Write-Host ""

# Commit
Write-Host "Creating commit..." -ForegroundColor Yellow
& $gitExe commit -m "Initial commit: CFAS Review Center Exam System"
Write-Host "[OK] Commit created!" -ForegroundColor Green
Write-Host ""

# Instructions for GitHub
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "1. Go to: https://github.com/new" -ForegroundColor White
Write-Host "2. Create a new repository" -ForegroundColor White
Write-Host "3. Copy the repository URL" -ForegroundColor White
Write-Host "4. Come back here and paste it below" -ForegroundColor White
Write-Host ""

$repoUrl = Read-Host "Paste your GitHub repository URL (or press Enter to skip)"

if ($repoUrl) {
    Write-Host ""
    Write-Host "Adding remote repository..." -ForegroundColor Yellow
    & $gitExe remote add origin $repoUrl
    
    Write-Host "Pushing to GitHub..." -ForegroundColor Yellow
    & $gitExe branch -M main
    & $gitExe push -u origin main
    
    Write-Host ""
    Write-Host "[SUCCESS] Code uploaded to GitHub!" -ForegroundColor Green
    Write-Host "View at: $repoUrl" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "To upload later, run these commands:" -ForegroundColor Yellow
    Write-Host "git remote add origin YOUR_GITHUB_URL" -ForegroundColor White
    Write-Host "git branch -M main" -ForegroundColor White
    Write-Host "git push -u origin main" -ForegroundColor White
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
pause

# Auto-download and install Git for Windows
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Git Auto-Installer" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Check if Git is already installed
Write-Host "Checking if Git is already installed..." -ForegroundColor Yellow
try {
    $gitVersion = git --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n[SUCCESS] Git is already installed!" -ForegroundColor Green
        Write-Host $gitVersion -ForegroundColor Green
        Write-Host "`nYou can now use Git commands!" -ForegroundColor Cyan
        pause
        exit 0
    }
} catch {
    Write-Host "[INFO] Git not found. Proceeding with installation...`n" -ForegroundColor Yellow
}

# Download Git installer
Write-Host "Downloading Git for Windows..." -ForegroundColor Yellow
$gitUrl = "https://github.com/git-for-windows/git/releases/download/v2.43.0.windows.1/Git-2.43.0-64-bit.exe"
$installerPath = "$env:TEMP\GitInstaller.exe"

try {
    Write-Host "Download URL: $gitUrl" -ForegroundColor Gray
    Write-Host "Saving to: $installerPath`n" -ForegroundColor Gray
    
    # Download with progress
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $gitUrl -OutFile $installerPath -UseBasicParsing
    $ProgressPreference = 'Continue'
    
    Write-Host "[SUCCESS] Download complete!`n" -ForegroundColor Green
    
    # Verify file exists
    if (Test-Path $installerPath) {
        $fileSize = (Get-Item $installerPath).Length / 1MB
        Write-Host "File size: $([math]::Round($fileSize, 2)) MB`n" -ForegroundColor Gray
        
        # Run installer
        Write-Host "Starting Git installation..." -ForegroundColor Yellow
        Write-Host "Please follow the installer prompts:" -ForegroundColor Cyan
        Write-Host "- Use default settings (just click Next)" -ForegroundColor White
        Write-Host "- Wait for installation to complete`n" -ForegroundColor White
        
        Start-Process -FilePath $installerPath -Wait
        
        Write-Host "`n[INFO] Installation completed!" -ForegroundColor Green
        Write-Host "`nIMPORTANT: Close this PowerShell window and open a NEW one" -ForegroundColor Yellow
        Write-Host "Then run: git --version" -ForegroundColor Cyan
        Write-Host "`nAfter that, you can use Git commands!" -ForegroundColor Green
        
        # Clean up
        Write-Host "`nCleaning up installer..." -ForegroundColor Gray
        Remove-Item $installerPath -ErrorAction SilentlyContinue
        
    } else {
        Write-Host "[ERROR] Download failed - file not found" -ForegroundColor Red
        exit 1
    }
    
} catch {
    Write-Host "`n[ERROR] Failed to download or install Git" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`nPlease download manually from: https://git-scm.com/download/win" -ForegroundColor Yellow
    exit 1
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "1. Close this PowerShell window" -ForegroundColor White
Write-Host "2. Open a NEW PowerShell window" -ForegroundColor White
Write-Host "3. Run: git --version" -ForegroundColor White
Write-Host "4. Navigate to your project folder" -ForegroundColor White
Write-Host "5. Run: git init" -ForegroundColor White
Write-Host "========================================`n" -ForegroundColor Cyan

pause

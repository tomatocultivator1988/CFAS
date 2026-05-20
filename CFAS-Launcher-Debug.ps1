# CFAS Launcher - Debug Version
# This version shows console output for troubleshooting

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CFAS Exam System Launcher - Debug Mode" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[1/5] Checking PowerShell version..." -ForegroundColor Yellow
Write-Host "      Version: $($PSVersionTable.PSVersion)" -ForegroundColor Gray
Write-Host ""

Write-Host "[2/5] Checking paths..." -ForegroundColor Yellow
$backendPath = Join-Path $PSScriptRoot "backend"
$logoPath = Join-Path $PSScriptRoot "frontend\public\cfas-logo.jpg"

if (Test-Path $backendPath) {
    Write-Host "      ✓ Backend found: $backendPath" -ForegroundColor Green
} else {
    Write-Host "      ✗ Backend NOT found: $backendPath" -ForegroundColor Red
}

if (Test-Path $logoPath) {
    Write-Host "      ✓ Logo found: $logoPath" -ForegroundColor Green
} else {
    Write-Host "      ⚠ Logo not found (will use fallback)" -ForegroundColor Yellow
}
Write-Host ""

Write-Host "[3/5] Loading Windows Forms..." -ForegroundColor Yellow
try {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    Write-Host "      ✓ Windows Forms loaded successfully" -ForegroundColor Green
} catch {
    Write-Host "      ✗ ERROR loading Windows Forms: $_" -ForegroundColor Red
    pause
    exit 1
}
Write-Host ""

Write-Host "[4/5] Creating GUI window..." -ForegroundColor Yellow
try {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "CFAS Exam System Launcher - Debug"
    $form.Size = New-Object System.Drawing.Size(500, 300)
    $form.StartPosition = "CenterScreen"
    
    $label = New-Object System.Windows.Forms.Label
    $label.Text = "CFAS Launcher Debug Mode`n`nIf you see this window, the GUI works!`n`nClick OK to close."
    $label.Font = New-Object System.Drawing.Font("Segoe UI", 12)
    $label.Size = New-Object System.Drawing.Size(450, 150)
    $label.Location = New-Object System.Drawing.Point(25, 30)
    $label.TextAlign = "MiddleCenter"
    $form.Controls.Add($label)
    
    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Text = "OK - GUI Works!"
    $okButton.Size = New-Object System.Drawing.Size(200, 40)
    $okButton.Location = New-Object System.Drawing.Point(150, 200)
    $okButton.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
    $okButton.BackColor = [System.Drawing.Color]::FromArgb(39, 174, 96)
    $okButton.ForeColor = [System.Drawing.Color]::White
    $okButton.FlatStyle = "Flat"
    $okButton.Add_Click({ $form.Close() })
    $form.Controls.Add($okButton)
    
    Write-Host "      ✓ GUI window created" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "[5/5] Showing GUI..." -ForegroundColor Yellow
    Write-Host "      Look for the window on your screen!" -ForegroundColor Cyan
    Write-Host ""
    
    [void]$form.ShowDialog()
    
    Write-Host ""
    Write-Host "✓ GUI test successful!" -ForegroundColor Green
    Write-Host ""
    Write-Host "The launcher GUI works correctly." -ForegroundColor Green
    Write-Host "You can now use the desktop shortcut." -ForegroundColor Green
    
} catch {
    Write-Host "      ✗ ERROR creating GUI: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Error details:" -ForegroundColor Yellow
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Press any key to exit..." -ForegroundColor Gray
pause

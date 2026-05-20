# Restart Apache via XAMPP
Write-Host "Restarting Apache..." -ForegroundColor Yellow

# Stop Apache
$stopResult = & "C:\xampp\apache\bin\httpd.exe" -k stop 2>&1
Start-Sleep -Seconds 2

# Start Apache
$startResult = & "C:\xampp\apache\bin\httpd.exe" -k start 2>&1
Start-Sleep -Seconds 2

# Check if running
$apache = Get-Process -Name "httpd" -ErrorAction SilentlyContinue
if ($apache) {
    Write-Host "Apache restarted successfully!" -ForegroundColor Green
} else {
    Write-Host "Apache may not be running. Check XAMPP Control Panel." -ForegroundColor Yellow
}

Write-Host "`nPress any key..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

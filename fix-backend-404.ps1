# Fix Backend 404 Error - Redirect to public folder
# The issue is that Laravel's entry point is in the public/ folder

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Fixing Backend 404 Error" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$backendPath = "C:\xampp\htdocs\exam-backend"

if (-not (Test-Path $backendPath)) {
    Write-Host "ERROR: Backend not deployed to XAMPP!" -ForegroundColor Red
    Write-Host "Run deploy-for-lan.ps1 first" -ForegroundColor Yellow
    exit 1
}

Write-Host "Creating root .htaccess to redirect to public folder..." -ForegroundColor Yellow

$htaccessContent = @"
<IfModule mod_rewrite.c>
    RewriteEngine On
    
    # Redirect all requests to public folder
    RewriteRule ^(.*)$ public/$1 [L]
</IfModule>
"@

$htaccessPath = Join-Path $backendPath ".htaccess"
Set-Content -Path $htaccessPath -Value $htaccessContent -Encoding UTF8

Write-Host "   Root .htaccess updated" -ForegroundColor Green

Write-Host "`nTesting backend health endpoint..." -ForegroundColor Yellow

Start-Sleep -Seconds 2

try {
    $response = Invoke-WebRequest -Uri "http://192.168.11.40/exam-backend/api/health" -UseBasicParsing -TimeoutSec 5
    Write-Host "   Backend is accessible!" -ForegroundColor Green
    Write-Host "   Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "   Response: $($response.Content)" -ForegroundColor Cyan
} catch {
    Write-Host "   Still getting error. Checking further..." -ForegroundColor Yellow
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Fix Applied!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`nNext Steps:" -ForegroundColor Yellow
Write-Host "1. Test the backend: http://192.168.11.40/exam-backend/api/health" -ForegroundColor White
Write-Host "2. If still 404, restart Apache in XAMPP" -ForegroundColor White
Write-Host "3. Test exam submission again" -ForegroundColor White

Write-Host "`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

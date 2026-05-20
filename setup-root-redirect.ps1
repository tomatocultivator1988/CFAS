# Setup Root Redirect to Exam System
Write-Host "Setting up root redirect..." -ForegroundColor Yellow

$indexContent = @'
<?php
// Redirect to CFAS Exam System
header('Location: /exam-frontend/');
exit;
?>
'@

# Backup original
if (Test-Path "C:\xampp\htdocs\index.php") {
    Copy-Item "C:\xampp\htdocs\index.php" "C:\xampp\htdocs\index.php.backup" -Force
    Write-Host "Original index.php backed up" -ForegroundColor Green
}

# Create new redirect
Set-Content "C:\xampp\htdocs\index.php" -Value $indexContent
Write-Host "Root redirect created!" -ForegroundColor Green

Write-Host "`nNow accessing http://192.168.11.40 will redirect to exam system" -ForegroundColor Cyan
Write-Host "`nPress any key..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

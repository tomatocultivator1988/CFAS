# Cleanup Nested Public Folders
# This removes the duplicate Laravel installations inside backend/public/

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Cleanup Nested Public Folders" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$backendPublic = "backend\public"

# Check if nested public exists
if (Test-Path "$backendPublic\public") {
    Write-Host "[WARNING] Found nested public folders!" -ForegroundColor Yellow
    Write-Host "These are duplicates and NOT used by the system.`n" -ForegroundColor Yellow
    
    # Calculate size
    $size = (Get-ChildItem -Path "$backendPublic\public" -Recurse -ErrorAction SilentlyContinue | 
             Measure-Object -Property Length -Sum).Sum / 1MB
    
    Write-Host "Wasting approximately: $([math]::Round($size, 2)) MB`n" -ForegroundColor Red
    
    Write-Host "The system uses:" -ForegroundColor Green
    Write-Host "  backend/public/index.php  <- CORRECT entry point" -ForegroundColor White
    Write-Host "`nThe nested folders are:" -ForegroundColor Yellow
    Write-Host "  backend/public/public/... <- DUPLICATE (not used)" -ForegroundColor Red
    Write-Host "`n"
    
    $confirm = Read-Host "Delete nested public folders? (yes/no)"
    
    if ($confirm -eq "yes") {
        Write-Host "`nDeleting nested folders..." -ForegroundColor Yellow
        
        # List of folders/files to remove from backend/public/
        $toRemove = @(
            "public",
            "app",
            "bootstrap",
            "config",
            "database",
            "resources",
            "routes",
            "storage",
            "tests",
            "vendor",
            ".env",
            ".env.example",
            ".phpunit.result.cache",
            "activate-reviewees.php",
            "artisan",
            "composer.json",
            "composer.lock",
            "phpunit.xml",
            "reset-reviewee-password.php",
            "test-default-password.php",
            "test-password.php",
            "test-user-creation.php"
        )
        
        foreach ($item in $toRemove) {
            $path = Join-Path $backendPublic $item
            if (Test-Path $path) {
                Write-Host "  Removing: $item" -ForegroundColor Gray
                Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
        
        Write-Host "`n[SUCCESS] Cleanup complete!" -ForegroundColor Green
        Write-Host "`nYour backend/public/ folder now only contains:" -ForegroundColor Cyan
        Get-ChildItem -Path $backendPublic | Select-Object Name, Length
        
    } else {
        Write-Host "`nCleanup cancelled." -ForegroundColor Yellow
    }
    
} else {
    Write-Host "[OK] No nested public folders found!" -ForegroundColor Green
    Write-Host "Your structure is clean.`n" -ForegroundColor Green
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Current Structure:" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "backend/" -ForegroundColor White
Write-Host "├── app/              (Laravel application code)" -ForegroundColor Gray
Write-Host "├── public/           (Web root - XAMPP points here)" -ForegroundColor Green
Write-Host "│   ├── index.php     (Entry point)" -ForegroundColor Green
Write-Host "│   └── .htaccess     (Apache config)" -ForegroundColor Green
Write-Host "├── vendor/           (Dependencies)" -ForegroundColor Gray
Write-Host "└── ...               (Other Laravel folders)" -ForegroundColor Gray
Write-Host "========================================`n" -ForegroundColor Cyan

pause

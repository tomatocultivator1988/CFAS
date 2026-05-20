# Test Word Import Functionality
Write-Host "=== Testing Word Import System ===" -ForegroundColor Cyan

# Check if backend is running
Write-Host "`n1. Checking backend..." -ForegroundColor Yellow
$backendUrl = "http://192.168.11.40/exam-backend/public/api/admin/exams"
try {
    $response = Invoke-WebRequest -Uri $backendUrl -Method GET -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    Write-Host "   ✓ Backend is running" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Backend not accessible" -ForegroundColor Red
    Write-Host "   Please start XAMPP Apache first!" -ForegroundColor Yellow
    exit 1
}

# Check if Python is available
Write-Host "`n2. Checking Python..." -ForegroundColor Yellow
$pythonPath = "C:\Users\Hi\AppData\Local\Programs\Python\Python312\python.exe"
if (Test-Path $pythonPath) {
    Write-Host "   ✓ Python found at: $pythonPath" -ForegroundColor Green
    
    # Check Python version
    $pythonVersion = & $pythonPath --version 2>&1
    Write-Host "   Version: $pythonVersion" -ForegroundColor Cyan
} else {
    Write-Host "   ✗ Python not found at: $pythonPath" -ForegroundColor Red
    Write-Host "   Word import may use fallback method" -ForegroundColor Yellow
}

# Check if extract-with-formatting.py exists
Write-Host "`n3. Checking extraction script..." -ForegroundColor Yellow
$scriptPath = "Exam-Main\extract-with-formatting.py"
if (Test-Path $scriptPath) {
    Write-Host "   ✓ Extraction script found" -ForegroundColor Green
} else {
    Write-Host "   ✗ Extraction script not found" -ForegroundColor Red
    Write-Host "   Creating extraction script..." -ForegroundColor Yellow
    
    # The script will be created by the service when needed
    Write-Host "   Script will be auto-created on first import" -ForegroundColor Cyan
}

# Check Laravel cache
Write-Host "`n4. Checking Laravel cache..." -ForegroundColor Yellow
Set-Location "Exam-Main\backend"
php artisan config:clear | Out-Null
php artisan route:clear | Out-Null
php artisan cache:clear | Out-Null
Write-Host "   ✓ Cache cleared" -ForegroundColor Green

# Check import route
Write-Host "`n5. Checking import route..." -ForegroundColor Yellow
$routes = php artisan route:list | Select-String "import-docx"
if ($routes) {
    Write-Host "   ✓ Import route registered:" -ForegroundColor Green
    Write-Host "   $routes" -ForegroundColor Cyan
} else {
    Write-Host "   ✗ Import route not found!" -ForegroundColor Red
}

# Check if sample DOCX exists
Write-Host "`n6. Checking sample files..." -ForegroundColor Yellow
Set-Location ".."
$sampleFiles = @(
    "Sample_Questions.docx",
    "Aquaculture_set A.docx",
    "Aquaculture_set B.docx"
)

foreach ($file in $sampleFiles) {
    if (Test-Path $file) {
        $size = (Get-Item $file).Length / 1KB
        Write-Host "   ✓ Found: $file ($([math]::Round($size, 2)) KB)" -ForegroundColor Green
    }
}

# Check temp directory
Write-Host "`n7. Checking temp directory..." -ForegroundColor Yellow
$tempDir = "backend\storage\app\temp"
if (Test-Path $tempDir) {
    Write-Host "   ✓ Temp directory exists" -ForegroundColor Green
    
    # Clean old temp files
    $oldFiles = Get-ChildItem $tempDir -Filter "import_*" | Where-Object { $_.LastWriteTime -lt (Get-Date).AddHours(-1) }
    if ($oldFiles) {
        $oldFiles | Remove-Item -Force
        Write-Host "   Cleaned $($oldFiles.Count) old temp files" -ForegroundColor Cyan
    }
} else {
    Write-Host "   Creating temp directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    Write-Host "   ✓ Temp directory created" -ForegroundColor Green
}

# Check PHP extensions
Write-Host "`n8. Checking PHP extensions..." -ForegroundColor Yellow
Set-Location "backend"
$phpInfo = php -m
$requiredExtensions = @("zip", "xml", "mbstring", "fileinfo")
foreach ($ext in $requiredExtensions) {
    if ($phpInfo -contains $ext) {
        Write-Host "   ✓ $ext enabled" -ForegroundColor Green
    } else {
        Write-Host "   ✗ $ext not enabled" -ForegroundColor Red
    }
}

# Check Composer packages
Write-Host "`n9. Checking Composer packages..." -ForegroundColor Yellow
$composerLock = Get-Content "composer.lock" -Raw | ConvertFrom-Json
$packages = $composerLock.packages | Where-Object { $_.name -like "*pdf*" -or $_.name -like "*phpword*" }
if ($packages) {
    Write-Host "   ✓ PDF/Word packages installed:" -ForegroundColor Green
    foreach ($pkg in $packages) {
        Write-Host "     - $($pkg.name) ($($pkg.version))" -ForegroundColor Cyan
    }
} else {
    Write-Host "   ⚠ No PDF/Word packages found" -ForegroundColor Yellow
}

Write-Host "`n=== System Check Complete ===" -ForegroundColor Cyan
Write-Host "`nTo test Word import:" -ForegroundColor Yellow
Write-Host "1. Go to: http://192.168.11.40/exam-frontend" -ForegroundColor White
Write-Host "2. Login as admin" -ForegroundColor White
Write-Host "3. Click on an exam" -ForegroundColor White
Write-Host "4. Click 'Upload Word Document'" -ForegroundColor White
Write-Host "5. Select a .docx file" -ForegroundColor White
Write-Host "6. Watch the progress bar" -ForegroundColor White

Write-Host "`nIf import fails, check:" -ForegroundColor Yellow
Write-Host "- Browser console (F12) for errors" -ForegroundColor White
Write-Host "- Laravel logs: backend\storage\logs\laravel.log" -ForegroundColor White
Write-Host "- Network tab (F12) to see API response" -ForegroundColor White

Set-Location ".."

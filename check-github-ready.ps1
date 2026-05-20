# GitHub Upload Readiness Check
# This script checks if your project is safe to upload to GitHub

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "GitHub Upload Readiness Check" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$issues = @()
$warnings = @()
$passed = @()

# Check 1: .gitignore exists
Write-Host "Checking .gitignore file..." -ForegroundColor Yellow
if (Test-Path ".gitignore") {
    $passed += "✓ .gitignore file exists"
} else {
    $issues += "✗ .gitignore file missing!"
}

# Check 2: .env files should NOT be tracked
Write-Host "Checking for .env files..." -ForegroundColor Yellow
$envFiles = @(
    "backend\.env",
    "frontend\.env",
    ".env"
)

foreach ($file in $envFiles) {
    if (Test-Path $file) {
        # Check if it's in .gitignore
        $gitignoreContent = Get-Content ".gitignore" -Raw
        if ($gitignoreContent -match [regex]::Escape($file)) {
            $passed += "✓ $file exists but is ignored"
        } else {
            $issues += "✗ $file exists but NOT in .gitignore!"
        }
    }
}

# Check 3: .env.example files should exist
Write-Host "Checking for .env.example files..." -ForegroundColor Yellow
$exampleFiles = @(
    "backend\.env.example",
    "frontend\.env.example"
)

foreach ($file in $exampleFiles) {
    if (Test-Path $file) {
        $passed += "✓ $file exists"
    } else {
        $warnings += "⚠ $file missing (recommended to have)"
    }
}

# Check 4: Large directories should be ignored
Write-Host "Checking for large directories..." -ForegroundColor Yellow
$largeDirs = @(
    "backend\vendor",
    "frontend\node_modules",
    "frontend\dist",
    "ml_model\venv"
)

foreach ($dir in $largeDirs) {
    if (Test-Path $dir) {
        $gitignoreContent = Get-Content ".gitignore" -Raw
        $dirPattern = $dir -replace "\\", "/"
        if ($gitignoreContent -match [regex]::Escape($dirPattern)) {
            $passed += "✓ $dir is ignored"
        } else {
            $issues += "✗ $dir exists but NOT ignored (will upload huge files!)"
        }
    }
}

# Check 5: Search for potential secrets in code
Write-Host "Searching for potential secrets in code..." -ForegroundColor Yellow
$secretPatterns = @(
    "password\s*=\s*['\`"][^'\`"]+['\`"]",
    "api_key\s*=\s*['\`"][^'\`"]+['\`"]",
    "secret\s*=\s*['\`"][^'\`"]+['\`"]"
)

$codeFiles = Get-ChildItem -Path "backend\app", "frontend\src" -Recurse -Include "*.php", "*.js", "*.vue" -ErrorAction SilentlyContinue

foreach ($file in $codeFiles) {
    $content = Get-Content $file.FullName -Raw
    foreach ($pattern in $secretPatterns) {
        if ($content -match $pattern) {
            $warnings += "⚠ Potential secret found in: $($file.Name)"
            break
        }
    }
}

# Check 6: Database files
Write-Host "Checking for database files..." -ForegroundColor Yellow
$dbFiles = Get-ChildItem -Path "." -Include "*.sql", "*.sqlite", "*.db" -Recurse -ErrorAction SilentlyContinue

if ($dbFiles.Count -gt 0) {
    $gitignoreContent = Get-Content ".gitignore" -Raw
    if ($gitignoreContent -match "\*\.sql") {
        $passed += "✓ Database files are ignored"
    } else {
        $warnings += "⚠ Found $($dbFiles.Count) database file(s) - consider adding *.sql to .gitignore"
    }
}

# Display Results
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "RESULTS" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

if ($passed.Count -gt 0) {
    Write-Host "PASSED CHECKS:" -ForegroundColor Green
    foreach ($item in $passed) {
        Write-Host "  $item" -ForegroundColor Green
    }
    Write-Host ""
}

if ($warnings.Count -gt 0) {
    Write-Host "WARNINGS:" -ForegroundColor Yellow
    foreach ($item in $warnings) {
        Write-Host "  $item" -ForegroundColor Yellow
    }
    Write-Host ""
}

if ($issues.Count -gt 0) {
    Write-Host "ISSUES (MUST FIX):" -ForegroundColor Red
    foreach ($item in $issues) {
        Write-Host "  $item" -ForegroundColor Red
    }
    Write-Host ""
}

# Final verdict
Write-Host "========================================" -ForegroundColor Cyan
if ($issues.Count -eq 0) {
    Write-Host "✓ READY TO UPLOAD TO GITHUB!" -ForegroundColor Green
    Write-Host "`nNext steps:" -ForegroundColor Cyan
    Write-Host "1. git init" -ForegroundColor White
    Write-Host "2. git add ." -ForegroundColor White
    Write-Host "3. git commit -m 'Initial commit'" -ForegroundColor White
    Write-Host "4. git remote add origin YOUR_GITHUB_URL" -ForegroundColor White
    Write-Host "5. git push -u origin main" -ForegroundColor White
} else {
    Write-Host "✗ NOT READY - Fix issues above first!" -ForegroundColor Red
    Write-Host "`nRead GITHUB_UPLOAD_GUIDE.md for help" -ForegroundColor Yellow
}
Write-Host "========================================`n" -ForegroundColor Cyan

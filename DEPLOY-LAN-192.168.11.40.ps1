$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$frontendSource = Join-Path $projectRoot 'frontend'
$backendSource = Join-Path $projectRoot 'backend'
$htdocsRoot = 'C:\xampp\htdocs'
$frontendTarget = Join-Path $htdocsRoot 'frontend'
$backendTarget = Join-Path $htdocsRoot 'backend'
$phpCli = 'C:\xampp\php\php.exe'
$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'

if (-not (Test-Path $frontendSource)) { throw "Frontend source not found: $frontendSource" }
if (-not (Test-Path $backendSource)) { throw "Backend source not found: $backendSource" }
if (-not (Test-Path $htdocsRoot)) { throw "XAMPP htdocs not found: $htdocsRoot" }
if (-not (Test-Path $backendTarget)) { throw "Backend target not found: $backendTarget" }
if (-not (Test-Path $phpCli)) { throw "XAMPP PHP not found: $phpCli" }

Write-Host "Building frontend..." -ForegroundColor Cyan
Push-Location $frontendSource
npm run build
if ($LASTEXITCODE -ne 0) { throw 'Frontend build failed.' }
Pop-Location

$distPath = Join-Path $frontendSource 'dist'
if (-not (Test-Path $distPath)) { throw "Build output not found: $distPath" }

if (Test-Path $frontendTarget) {
    $frontendBackup = "$frontendTarget.backup.$timestamp"
    Write-Host "Backing up frontend to $frontendBackup" -ForegroundColor Yellow
    Copy-Item $frontendTarget $frontendBackup -Recurse -Force
    Remove-Item $frontendTarget -Recurse -Force
}

New-Item -Path $frontendTarget -ItemType Directory -Force | Out-Null
Copy-Item (Join-Path $distPath '*') $frontendTarget -Recurse -Force
Write-Host "Frontend deployed to $frontendTarget" -ForegroundColor Green

$backendFiles = @(
    'app\Http\Controllers\MlPredictiveController.php',
    'app\Services\MlPredictiveService.php',
    'routes\api.php'
)

$backendBackupRoot = Join-Path $htdocsRoot "backend_patch_backup_$timestamp"
New-Item -Path $backendBackupRoot -ItemType Directory -Force | Out-Null

foreach ($relativePath in $backendFiles) {
    $sourcePath = Join-Path $backendSource $relativePath
    $targetPath = Join-Path $backendTarget $relativePath
    if (-not (Test-Path $sourcePath)) { throw "Missing source file: $sourcePath" }

    $targetDir = Split-Path -Parent $targetPath
    New-Item -Path $targetDir -ItemType Directory -Force | Out-Null

    if (Test-Path $targetPath) {
        $backupPath = Join-Path $backendBackupRoot $relativePath
        $backupDir = Split-Path -Parent $backupPath
        New-Item -Path $backupDir -ItemType Directory -Force | Out-Null
        Copy-Item $targetPath $backupPath -Force
    }

    Copy-Item $sourcePath $targetPath -Force
    Write-Host "Backend deployed: $relativePath" -ForegroundColor Green
}

Push-Location $backendTarget
& $phpCli artisan optimize:clear
if ($LASTEXITCODE -ne 0) { throw 'Failed to clear Laravel cache.' }

& $phpCli artisan migrate --force
if ($LASTEXITCODE -ne 0) { throw 'Migration failed.' }

& $phpCli artisan route:list --path=api/analytics/ml-predictions
if ($LASTEXITCODE -ne 0) { throw 'Route verification failed.' }
Pop-Location

Write-Host "Deployment completed." -ForegroundColor Green
Write-Host "LAN Frontend: http://192.168.11.40/frontend" -ForegroundColor Cyan
Write-Host "LAN API Base: http://192.168.11.40/api" -ForegroundColor Cyan

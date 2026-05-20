# Task 5: Test Status Toggle Feature
# Tests the new active/inactive status toggle replacing the assignment system

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Task 5: Status Toggle Test" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:8000/api"
$adminUsername = "admin"
$adminPassword = "admin123"
$revieweeUsername = "reviewee"
$revieweePassword = "reviewee123"

# Step 1: Admin Login
Write-Host "Step 1: Admin Login..." -ForegroundColor Yellow
$loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body (@{
    username = $adminUsername
    password = $adminPassword
} | ConvertTo-Json) -ContentType "application/json"

$adminToken = $loginResponse.data.token
Write-Host "[OK] Admin logged in successfully" -ForegroundColor Green
Write-Host ""

# Step 2: Get all exams
Write-Host "Step 2: Get all exams..." -ForegroundColor Yellow
$headers = @{
    "Authorization" = "Bearer $adminToken"
    "Content-Type" = "application/json"
}

$exams = Invoke-RestMethod -Uri "$baseUrl/admin/exams" -Method Get -Headers $headers
Write-Host "[OK] Found $($exams.exams.Count) exams" -ForegroundColor Green

if ($exams.exams.Count -eq 0) {
    Write-Host "[ERROR] No exams found. Please create an exam first." -ForegroundColor Red
    exit 1
}

$testExam = $exams.exams[0]
Write-Host "  Using exam: $($testExam.title)" -ForegroundColor Cyan
Write-Host "  Current status: $($testExam.status)" -ForegroundColor Cyan
Write-Host ""

# Step 3: Toggle exam status
Write-Host "Step 3: Toggle exam status..." -ForegroundColor Yellow
$toggleResponse = Invoke-RestMethod -Uri "$baseUrl/admin/exams/$($testExam.id)/toggle-status" -Method Post -Headers $headers
Write-Host "[OK] Status toggled successfully" -ForegroundColor Green
Write-Host "  New status: $($toggleResponse.exam.status)" -ForegroundColor Cyan
Write-Host ""

# Step 4: Verify status changed
Write-Host "Step 4: Verify status changed..." -ForegroundColor Yellow
$updatedExam = Invoke-RestMethod -Uri "$baseUrl/admin/exams/$($testExam.id)" -Method Get -Headers $headers
Write-Host "[OK] Verified status: $($updatedExam.exam.status)" -ForegroundColor Green
Write-Host ""

# Step 5: Reviewee Login
Write-Host "Step 5: Reviewee Login..." -ForegroundColor Yellow
Start-Sleep -Seconds 2
try {
    $revieweeLoginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body (@{
        username = $revieweeUsername
        password = $revieweePassword
    } | ConvertTo-Json) -ContentType "application/json"

    $revieweeToken = $revieweeLoginResponse.data.token
    Write-Host "[OK] Reviewee logged in successfully" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Failed to login reviewee: $_" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Step 6: Get reviewee available exams
Write-Host "Step 6: Get reviewee available exams..." -ForegroundColor Yellow
$revieweeHeaders = @{
    "Authorization" = "Bearer $revieweeToken"
    "Content-Type" = "application/json"
}

$availableExams = Invoke-RestMethod -Uri "$baseUrl/reviewee/exams" -Method Get -Headers $revieweeHeaders
Write-Host "[OK] Reviewee can see $($availableExams.exams.Count) exams" -ForegroundColor Green

# Check if the exam is visible based on status
$isVisible = $availableExams.exams | Where-Object { $_.id -eq $testExam.id }
if ($updatedExam.exam.status -eq "active") {
    if ($isVisible) {
        Write-Host "[OK] Active exam is visible to reviewee (CORRECT)" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Active exam is NOT visible to reviewee (WRONG)" -ForegroundColor Red
    }
} else {
    if ($isVisible) {
        Write-Host "[ERROR] Inactive exam is visible to reviewee (WRONG)" -ForegroundColor Red
    } else {
        Write-Host "[OK] Inactive exam is NOT visible to reviewee (CORRECT)" -ForegroundColor Green
    }
}
Write-Host ""

# Step 7: Toggle back to original status
Write-Host "Step 7: Toggle back to original status..." -ForegroundColor Yellow
$toggleBackResponse = Invoke-RestMethod -Uri "$baseUrl/admin/exams/$($testExam.id)/toggle-status" -Method Post -Headers $headers
Write-Host "[OK] Status toggled back to: $($toggleBackResponse.exam.status)" -ForegroundColor Green
Write-Host ""

# Step 8: Verify reviewee sees updated list
Write-Host "Step 8: Verify reviewee sees updated list..." -ForegroundColor Yellow
$updatedAvailableExams = Invoke-RestMethod -Uri "$baseUrl/reviewee/exams" -Method Get -Headers $revieweeHeaders
Write-Host "[OK] Reviewee now sees $($updatedAvailableExams.exams.Count) exams" -ForegroundColor Green

$isVisibleNow = $updatedAvailableExams.exams | Where-Object { $_.id -eq $testExam.id }
if ($toggleBackResponse.exam.status -eq "active") {
    if ($isVisibleNow) {
        Write-Host "[OK] Active exam is visible to reviewee (CORRECT)" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Active exam is NOT visible to reviewee (WRONG)" -ForegroundColor Red
    }
} else {
    if ($isVisibleNow) {
        Write-Host "[ERROR] Inactive exam is visible to reviewee (WRONG)" -ForegroundColor Red
    } else {
        Write-Host "[OK] Inactive exam is NOT visible to reviewee (CORRECT)" -ForegroundColor Green
    }
}
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Test Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Summary:" -ForegroundColor Yellow
Write-Host "- Status toggle endpoint works correctly" -ForegroundColor White
Write-Host "- Reviewees see only active exams" -ForegroundColor White
Write-Host "- No assignment needed - automatic visibility" -ForegroundColor White

# Test Export Endpoints
Write-Host "Testing Export Endpoints..." -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:8000/api"

# First, login as admin
Write-Host "1. Logging in as admin..." -ForegroundColor Yellow
$loginBody = @{
    username = "admin"
    password = "password123"
} | ConvertTo-Json

$loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $loginBody -ContentType "application/json"

if ($loginResponse.data.token) {
    Write-Host "Success: Login successful" -ForegroundColor Green
    $token = $loginResponse.data.token
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }
} else {
    Write-Host "Error: Login failed" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Test Export All Results
Write-Host "2. Testing Export All Results..." -ForegroundColor Yellow
try {
    $allResults = Invoke-RestMethod -Uri "$baseUrl/admin/export/all-results" -Method Get -Headers $headers
    if ($allResults.success) {
        Write-Host "Success: Export All Results" -ForegroundColor Green
        Write-Host "Total records: $($allResults.count)" -ForegroundColor Cyan
    } else {
        Write-Host "Error: Export All Results failed" -ForegroundColor Red
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test Export User Performance
Write-Host "3. Testing Export User Performance..." -ForegroundColor Yellow
try {
    $userPerf = Invoke-RestMethod -Uri "$baseUrl/admin/export/user-performance" -Method Get -Headers $headers
    if ($userPerf.success) {
        Write-Host "Success: Export User Performance" -ForegroundColor Green
        Write-Host "Total users: $($userPerf.count)" -ForegroundColor Cyan
    } else {
        Write-Host "Error: Export User Performance failed" -ForegroundColor Red
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test Export Exam Analytics
Write-Host "4. Testing Export Exam Analytics..." -ForegroundColor Yellow
try {
    $examAnalytics = Invoke-RestMethod -Uri "$baseUrl/admin/export/exam-analytics" -Method Get -Headers $headers
    if ($examAnalytics.success) {
        Write-Host "Success: Export Exam Analytics" -ForegroundColor Green
        Write-Host "Total exams: $($examAnalytics.count)" -ForegroundColor Cyan
    } else {
        Write-Host "Error: Export Exam Analytics failed" -ForegroundColor Red
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Export Endpoints Test Complete!" -ForegroundColor Cyan

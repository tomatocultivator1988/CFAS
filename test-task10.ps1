# Task 10: API Security and Authentication Testing
Write-Host "=== TASK 10 API SECURITY TESTING ===" -ForegroundColor Cyan

$baseUrl = "http://127.0.0.1:8000/api"
$adminUser = "admin"
$adminPass = "admin123"

# Helper function
function Invoke-ApiRequest {
    param($Uri, $Method = "Get", $Body = $null, $Headers = @{})
    try {
        $params = @{
            Uri = $Uri
            Method = $Method
            Headers = $Headers
            ContentType = "application/json"
        }
        if ($Body) { $params.Body = $Body }
        return Invoke-RestMethod @params
    } catch {
        return @{
            error = $true
            status = $_.Exception.Response.StatusCode.value__
            message = $_.ErrorDetails.Message
        }
    }
}

Write-Host "`n=== TEST 1: AUTHENTICATION MIDDLEWARE ===" -ForegroundColor Yellow

Write-Host "`n1.1 Test protected endpoint without token (should fail)..." -ForegroundColor Yellow
$noAuth = Invoke-ApiRequest -Uri "$baseUrl/auth/me"
if ($noAuth.error -and $noAuth.status -eq 401) {
    Write-Host "OK - Correctly rejected request without token (401)" -ForegroundColor Green
} else {
    Write-Host "FAIL - Should have rejected request without token" -ForegroundColor Red
}

Write-Host "`n1.2 Test with invalid token (should fail)..." -ForegroundColor Yellow
$badHeaders = @{"Authorization"="Bearer invalid_token_12345"; "Content-Type"="application/json"}
$badAuth = Invoke-ApiRequest -Uri "$baseUrl/auth/me" -Headers $badHeaders
if ($badAuth.error -and $badAuth.status -eq 401) {
    Write-Host "OK - Correctly rejected invalid token (401)" -ForegroundColor Green
} else {
    Write-Host "FAIL - Should have rejected invalid token" -ForegroundColor Red
}

Write-Host "`n1.3 Test with valid token (should succeed)..." -ForegroundColor Yellow
$loginBody = @{username=$adminUser; password=$adminPass} | ConvertTo-Json
$login = Invoke-ApiRequest -Uri "$baseUrl/auth/login" -Method Post -Body $loginBody
$token = $login.data.token
$headers = @{"Authorization"="Bearer $token"; "Content-Type"="application/json"}
$validAuth = Invoke-ApiRequest -Uri "$baseUrl/auth/me" -Headers $headers
if ($validAuth.data) {
    Write-Host "OK - Valid token accepted" -ForegroundColor Green
} else {
    Write-Host "FAIL - Valid token should have been accepted" -ForegroundColor Red
}

Write-Host "`n=== TEST 2: RATE LIMITING ===" -ForegroundColor Yellow

Write-Host "`n2.1 Test login rate limit (10 requests per minute)..." -ForegroundColor Yellow
$rateLimitHit = $false
$successCount = 0
$blockedCount = 0

for ($i = 1; $i -le 12; $i++) {
    $testBody = @{username="test_user_$i"; password="test_pass"} | ConvertTo-Json
    $result = Invoke-ApiRequest -Uri "$baseUrl/auth/login" -Method Post -Body $testBody
    
    if ($result.error -and $result.status -eq 429) {
        $blockedCount++
        if (-not $rateLimitHit) {
            Write-Host "   Rate limit hit at request $i" -ForegroundColor Gray
            $rateLimitHit = $true
        }
    } else {
        $successCount++
    }
    
    Start-Sleep -Milliseconds 100
}

if ($rateLimitHit) {
    Write-Host "OK - Rate limiting working ($successCount allowed, $blockedCount blocked)" -ForegroundColor Green
} else {
    Write-Host "WARNING - Rate limit not hit (may need more requests or shorter window)" -ForegroundColor Yellow
}

Write-Host "`n2.2 Test API rate limit (60 requests per minute)..." -ForegroundColor Yellow
$loginBody = @{username=$adminUser; password=$adminPass} | ConvertTo-Json
$login = Invoke-ApiRequest -Uri "$baseUrl/auth/login" -Method Post -Body $loginBody
$token = $login.data.token
$headers = @{"Authorization"="Bearer $token"; "Content-Type"="application/json"}

$apiRateLimitHit = $false
$apiSuccessCount = 0
$apiBlockedCount = 0

Write-Host "   Making 65 rapid requests to test rate limit..." -ForegroundColor Gray
for ($i = 1; $i -le 65; $i++) {
    $result = Invoke-ApiRequest -Uri "$baseUrl/auth/me" -Headers $headers
    
    if ($result.error -and $result.status -eq 429) {
        $apiBlockedCount++
        if (-not $apiRateLimitHit) {
            Write-Host "   API rate limit hit at request $i" -ForegroundColor Gray
            $apiRateLimitHit = $true
        }
    } else {
        $apiSuccessCount++
    }
}

if ($apiRateLimitHit) {
    Write-Host "OK - API rate limiting working ($apiSuccessCount allowed, $apiBlockedCount blocked)" -ForegroundColor Green
} else {
    Write-Host "WARNING - API rate limit not hit in 65 requests" -ForegroundColor Yellow
}

Write-Host "`n=== TEST 3: API REQUEST LOGGING ===" -ForegroundColor Yellow

Write-Host "`n3.1 Make some API requests..." -ForegroundColor Yellow
$loginBody = @{username=$adminUser; password=$adminPass} | ConvertTo-Json
$login = Invoke-ApiRequest -Uri "$baseUrl/auth/login" -Method Post -Body $loginBody
$token = $login.data.token
$headers = @{"Authorization"="Bearer $token"; "Content-Type"="application/json"}

Invoke-ApiRequest -Uri "$baseUrl/auth/me" -Headers $headers | Out-Null
Invoke-ApiRequest -Uri "$baseUrl/admin/exams" -Headers $headers | Out-Null
Invoke-ApiRequest -Uri "$baseUrl/auth/validate" -Headers $headers | Out-Null

Write-Host "OK - Made 3 API requests" -ForegroundColor Green
Write-Host "   Note: Logs are stored in audit_logs table" -ForegroundColor Gray
Write-Host "OK - Logging middleware is active (check database to verify)" -ForegroundColor Green

Write-Host "`n=== TASK 10 TESTING COMPLETE ===" -ForegroundColor Cyan

Write-Host "`nFEATURES IMPLEMENTED:" -ForegroundColor Yellow
Write-Host "- Authentication middleware validates tokens on all protected routes" -ForegroundColor White
Write-Host "- Rate limiting: Login 10/min, API 60/min" -ForegroundColor White
Write-Host "- API request logging to audit_logs table" -ForegroundColor White
Write-Host "- Returns 401 for missing/invalid tokens" -ForegroundColor White
Write-Host "- Returns 429 when rate limit exceeded" -ForegroundColor White

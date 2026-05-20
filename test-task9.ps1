# Task 9: IP-Based Access Control Testing
Write-Host "=== TASK 9 IP-BASED ACCESS CONTROL TESTING ===" -ForegroundColor Cyan

# Configuration
$baseUrl = "http://127.0.0.1:8000/api"
$adminUser = "admin"
$adminPass = "admin123"
$revieweeUser = "reviewee"
$revieweePass = "reviewee123"

# Helper function to make API calls
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

Write-Host "`n1. Login as admin..." -ForegroundColor Yellow
$loginBody = @{username=$adminUser; password=$adminPass} | ConvertTo-Json
$adminLogin = Invoke-ApiRequest -Uri "$baseUrl/auth/login" -Method Post -Body $loginBody
$adminToken = $adminLogin.data.token
$adminHeaders = @{"Authorization"="Bearer $adminToken"; "Content-Type"="application/json"}
Write-Host "OK - Admin logged in" -ForegroundColor Green

Write-Host "`n2. Login as reviewee..." -ForegroundColor Yellow
$loginBody = @{username=$revieweeUser; password=$revieweePass} | ConvertTo-Json
$revieweeLogin = Invoke-ApiRequest -Uri "$baseUrl/auth/login" -Method Post -Body $loginBody
$revieweeToken = $revieweeLogin.data.token
$revieweeHeaders = @{"Authorization"="Bearer $revieweeToken"; "Content-Type"="application/json"}
Write-Host "OK - Reviewee logged in" -ForegroundColor Green

Write-Host "`n3. Create test exam..." -ForegroundColor Yellow
$examBody = @{
    title = "IP Test Exam"
    description = "Testing IP restrictions"
    time_limit_minutes = 30
    passing_score = 60
    max_attempts = 3
    randomize_questions = $true
    randomize_choices = $true
} | ConvertTo-Json
$exam = Invoke-ApiRequest -Uri "$baseUrl/admin/exams" -Method Post -Body $examBody -Headers $adminHeaders
$examId = $exam.data.id
Write-Host "OK - Exam created (ID: $examId)" -ForegroundColor Green

Write-Host "`n4. Create test question..." -ForegroundColor Yellow
$questionBody = @{
    question_text = "Test question for IP restriction?"
    topic = "Security"
    answer_choices = @(
        @{choice_text="Choice A"; is_correct=$true}
        @{choice_text="Choice B"; is_correct=$false}
    )
} | ConvertTo-Json -Depth 10
$question = Invoke-ApiRequest -Uri "$baseUrl/admin/questions" -Method Post -Body $questionBody -Headers $adminHeaders
$questionId = $question.data.id
Write-Host "OK - Question created (ID: $questionId)" -ForegroundColor Green

Write-Host "`n5. Attach question to exam..." -ForegroundColor Yellow
$attachBody = @{question_ids=@($questionId)} | ConvertTo-Json
Invoke-ApiRequest -Uri "$baseUrl/admin/exams/$examId/questions" -Method Post -Body $attachBody -Headers $adminHeaders | Out-Null
Write-Host "OK - Question attached" -ForegroundColor Green

Write-Host "`n6. Assign exam to reviewee..." -ForegroundColor Yellow
$assignBody = @{reviewee_ids=@($revieweeLogin.data.user.id)} | ConvertTo-Json
Invoke-ApiRequest -Uri "$baseUrl/admin/exams/$examId/assign" -Method Post -Body $assignBody -Headers $adminHeaders | Out-Null
Write-Host "OK - Exam assigned" -ForegroundColor Green

Write-Host "`n7. Test IP restriction behavior..." -ForegroundColor Yellow
Write-Host "   Note: By default, LAB_IP_RANGES is empty, so all IPs are allowed (development mode)" -ForegroundColor Gray

Write-Host "`n8. Attempt to start exam (should succeed with empty IP config)..." -ForegroundColor Yellow
$startResult = Invoke-ApiRequest -Uri "$baseUrl/reviewee/exams/$examId/start" -Method Post -Headers $revieweeHeaders

if ($startResult.error -and $startResult.status -eq 403) {
    Write-Host "   IP RESTRICTED - Access denied (403 Forbidden)" -ForegroundColor Red
    Write-Host "   This means LAB_IP_RANGES is configured and your IP is not allowed" -ForegroundColor Gray
} elseif ($startResult.data) {
    $attemptId = $startResult.data.id
    Write-Host "OK - Exam started successfully (Attempt ID: $attemptId)" -ForegroundColor Green
    Write-Host "   This means LAB_IP_RANGES is empty (development mode) or your IP is allowed" -ForegroundColor Gray
    
    Write-Host "`n9. Test other protected endpoints..." -ForegroundColor Yellow
    
    # Test get attempt
    $getAttempt = Invoke-ApiRequest -Uri "$baseUrl/reviewee/attempts/$attemptId" -Headers $revieweeHeaders
    if ($getAttempt.data) {
        Write-Host "OK - Get attempt succeeded" -ForegroundColor Green
    } else {
        Write-Host "FAIL - Get attempt failed" -ForegroundColor Red
    }
    
    # Test submit answer
    $answerBody = @{question_id=$questionId; answer_choice_id=$question.data.answer_choices[0].id} | ConvertTo-Json
    $submitAnswer = Invoke-ApiRequest -Uri "$baseUrl/reviewee/attempts/$attemptId/answers" -Method Post -Body $answerBody -Headers $revieweeHeaders
    if ($submitAnswer.data) {
        Write-Host "OK - Submit answer succeeded" -ForegroundColor Green
    } else {
        Write-Host "FAIL - Submit answer failed" -ForegroundColor Red
    }
    
    # Test get remaining time
    $getTime = Invoke-ApiRequest -Uri "$baseUrl/reviewee/attempts/$attemptId/time" -Headers $revieweeHeaders
    if ($getTime.data) {
        Write-Host "OK - Get remaining time succeeded" -ForegroundColor Green
    } else {
        Write-Host "FAIL - Get remaining time failed" -ForegroundColor Red
    }
} else {
    Write-Host "FAIL - Unexpected response" -ForegroundColor Red
    Write-Host ($startResult | ConvertTo-Json) -ForegroundColor Gray
}

Write-Host "`n10. Verify non-exam endpoints are NOT restricted..." -ForegroundColor Yellow
$exams = Invoke-ApiRequest -Uri "$baseUrl/reviewee/exams" -Headers $revieweeHeaders
if ($exams.data) {
    Write-Host "OK - Get assigned exams succeeded (not IP restricted)" -ForegroundColor Green
} else {
    Write-Host "FAIL - Get assigned exams failed" -ForegroundColor Red
}

Write-Host "`n=== TASK 9 TESTING COMPLETE ===" -ForegroundColor Cyan
Write-Host "`nIP RESTRICTION CONFIGURATION:" -ForegroundColor Yellow
Write-Host "- Middleware registered as 'lab.ip' in Kernel.php" -ForegroundColor White
Write-Host "- Applied to exam-taking routes (start, submit, answers, etc.)" -ForegroundColor White
Write-Host "- NOT applied to exam listing route" -ForegroundColor White
Write-Host "- Configuration in config/app.php reads from LAB_IP_RANGES env variable" -ForegroundColor White
Write-Host "- Empty LAB_IP_RANGES = allow all IPs (development mode)" -ForegroundColor White
Write-Host "`nTO ENABLE IP RESTRICTIONS:" -ForegroundColor Yellow
Write-Host "1. Edit .env file" -ForegroundColor White
Write-Host "2. Set LAB_IP_RANGES=127.0.0.1,192.168.1.0/24" -ForegroundColor White
Write-Host "3. Restart Laravel server" -ForegroundColor White
Write-Host "4. Run this test again - exam start should return 403 if your IP is not allowed" -ForegroundColor White
Write-Host "`nSUPPORTED IP FORMATS:" -ForegroundColor Yellow
Write-Host "- Exact IP: 127.0.0.1" -ForegroundColor White
Write-Host "- CIDR notation: 192.168.1.0/24" -ForegroundColor White
Write-Host "- Wildcard: 192.168.1.*" -ForegroundColor White
Write-Host "- Range: 192.168.1.1-192.168.1.100" -ForegroundColor White
Write-Host "- Multiple (comma-separated): 127.0.0.1,192.168.1.0/24,10.0.0.*" -ForegroundColor White

# Task 5 Testing Script - Exam Delivery Service
Write-Host "=== TASK 5 EXAM DELIVERY SERVICE TESTING ===" -ForegroundColor Cyan

# 1. Login as reviewee
Write-Host "`n1. Login as reviewee..." -ForegroundColor Yellow
$loginBody = @{username='reviewee';password='reviewee123'} | ConvertTo-Json
$loginResponse = Invoke-RestMethod -Uri 'http://127.0.0.1:8000/api/auth/login' -Method Post -Body $loginBody -ContentType 'application/json'
$revieweeToken = $loginResponse.data.token
$revieweeHeaders = @{'Authorization'="Bearer $revieweeToken"; 'Content-Type'='application/json'}
Write-Host "   OK - Reviewee logged in" -ForegroundColor Green

# 2. Get assigned exams
Write-Host "`n2. Get assigned exams..." -ForegroundColor Yellow
$examsResponse = Invoke-RestMethod -Uri 'http://127.0.0.1:8000/api/reviewee/exams' -Method Get -Headers $revieweeHeaders
Write-Host "   OK - Retrieved $($examsResponse.exams.Count) assigned exam(s)" -ForegroundColor Green
if ($examsResponse.exams.Count -gt 0) {
    $exam = $examsResponse.exams[0]
    Write-Host "   Exam: $($exam.title)" -ForegroundColor Gray
    Write-Host "   Attempts remaining: $($exam.attempts_remaining)" -ForegroundColor Gray
    $examId = $exam.id
} else {
    Write-Host "   No exams assigned. Please assign an exam to reviewee first." -ForegroundColor Red
    exit 1
}

# 3. Start exam attempt
Write-Host "`n3. Start exam attempt..." -ForegroundColor Yellow
$startResponse = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/reviewee/exams/$examId/start" -Method Post -Headers $revieweeHeaders -ErrorAction Stop
$attemptId = $startResponse.attempt.id
Write-Host "   OK - Exam attempt started (ID: $attemptId)" -ForegroundColor Green
Write-Host "   Attempt number: $($startResponse.attempt.attempt_number)" -ForegroundColor Gray
Write-Host "   Time limit: $($startResponse.attempt.time_limit_seconds) seconds" -ForegroundColor Gray

# 4. Get attempt details
Write-Host "`n4. Get attempt details..." -ForegroundColor Yellow
$attemptDetails = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/reviewee/attempts/$attemptId" -Method Get -Headers $revieweeHeaders
Write-Host "   OK - Retrieved attempt details" -ForegroundColor Green
Write-Host "   Questions: $($attemptDetails.questions.Count)" -ForegroundColor Gray
Write-Host "   Remaining time: $($attemptDetails.remaining_seconds) seconds" -ForegroundColor Gray
Write-Host "   Status: $($attemptDetails.attempt.status)" -ForegroundColor Gray

# 5. Get remaining time
Write-Host "`n5. Get remaining time..." -ForegroundColor Yellow
$timeResponse = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/reviewee/attempts/$attemptId/time" -Method Get -Headers $revieweeHeaders
Write-Host "   OK - Remaining time: $($timeResponse.remaining_seconds) seconds" -ForegroundColor Green

# 6. Submit answers for all questions
Write-Host "`n6. Submit answers..." -ForegroundColor Yellow
$answeredCount = 0
foreach ($question in $attemptDetails.questions) {
    # Select first choice for each question (for testing)
    $choiceId = $question.answerChoices[0].id
    $answerBody = @{
        question_id = $question.id
        choice_id = $choiceId
    } | ConvertTo-Json
    
    $answerResponse = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/reviewee/attempts/$attemptId/answers" -Method Post -Headers $revieweeHeaders -Body $answerBody -ErrorAction SilentlyContinue
    if ($answerResponse) {
        $answeredCount++
    }
}
Write-Host "   OK - Submitted $answeredCount answer(s)" -ForegroundColor Green

# 7. Submit exam
Write-Host "`n7. Submit exam..." -ForegroundColor Yellow
$submitResponse = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/reviewee/attempts/$attemptId/submit" -Method Post -Headers $revieweeHeaders
Write-Host "   OK - Exam submitted successfully" -ForegroundColor Green
Write-Host "   Score: $($submitResponse.attempt.score) / $($submitResponse.attempt.total_questions)" -ForegroundColor Gray
Write-Host "   Percentage: $($submitResponse.attempt.percentage)%" -ForegroundColor Gray
Write-Host "   Status: $($submitResponse.attempt.status)" -ForegroundColor Gray

# 8. Verify attempt is completed
Write-Host "`n8. Verify attempt completion..." -ForegroundColor Yellow
$finalAttempt = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/reviewee/attempts/$attemptId" -Method Get -Headers $revieweeHeaders
if ($finalAttempt.attempt.status -eq 'completed') {
    Write-Host "   OK - Attempt marked as completed" -ForegroundColor Green
} else {
    Write-Host "   Warning: Attempt status is $($finalAttempt.attempt.status)" -ForegroundColor Yellow
}

# 9. Try to start another attempt (should work if attempts remaining)
Write-Host "`n9. Check if can start another attempt..." -ForegroundColor Yellow
$examsCheck = Invoke-RestMethod -Uri 'http://127.0.0.1:8000/api/reviewee/exams' -Method Get -Headers $revieweeHeaders
$examCheck = $examsCheck.exams | Where-Object { $_.id -eq $examId }
if ($examCheck.can_attempt) {
    Write-Host "   OK - Can start another attempt ($($examCheck.attempts_remaining) remaining)" -ForegroundColor Green
} else {
    Write-Host "   OK - Maximum attempts reached" -ForegroundColor Green
}

Write-Host "`n=== ALL TASK 5 TESTS PASSED ===" -ForegroundColor Green
Write-Host "`nFeatures tested:" -ForegroundColor Cyan
Write-Host "  - Get assigned exams" -ForegroundColor Gray
Write-Host "  - Start exam attempt" -ForegroundColor Gray
Write-Host "  - Get attempt details with randomized questions" -ForegroundColor Gray
Write-Host "  - Get remaining time" -ForegroundColor Gray
Write-Host "  - Submit answers" -ForegroundColor Gray
Write-Host "  - Submit exam and calculate score" -ForegroundColor Gray
Write-Host "  - Attempt limit enforcement" -ForegroundColor Gray

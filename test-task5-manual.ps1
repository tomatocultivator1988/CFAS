# Manual Task 5 Test
Write-Host "=== MANUAL TASK 5 TEST ===" -ForegroundColor Cyan

# Login as reviewee
$loginBody = @{username='reviewee';password='reviewee123'} | ConvertTo-Json
$loginResponse = Invoke-RestMethod -Uri 'http://127.0.0.1:8000/api/auth/login' -Method Post -Body $loginBody -ContentType 'application/json'
$token = $loginResponse.data.token
$headers = @{'Authorization'="Bearer $token"; 'Content-Type'='application/json'}
Write-Host "Logged in as reviewee" -ForegroundColor Green

# Get exams
$exams = Invoke-RestMethod -Uri 'http://127.0.0.1:8000/api/reviewee/exams' -Method Get -Headers $headers
Write-Host "`nAssigned exams: $($exams.exams.Count)" -ForegroundColor Yellow
$exam = $exams.exams[0]
Write-Host "Exam: $($exam.title)" -ForegroundColor Gray
Write-Host "Attempts remaining: $($exam.attempts_remaining)" -ForegroundColor Gray

# Start attempt
Write-Host "`nStarting new attempt..." -ForegroundColor Yellow
$start = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/reviewee/exams/$($exam.id)/start" -Method Post -Headers $headers
Write-Host "Attempt ID: $($start.attempt.id)" -ForegroundColor Green
Write-Host "Status: $($start.attempt.status)" -ForegroundColor Gray
$attemptId = $start.attempt.id

# Get attempt details
Write-Host "`nGetting attempt details..." -ForegroundColor Yellow
$details = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/reviewee/attempts/$attemptId" -Method Get -Headers $headers
Write-Host "Questions: $($details.questions.Count)" -ForegroundColor Green
Write-Host "Remaining time: $($details.remaining_seconds) seconds" -ForegroundColor Gray

# Submit answers
Write-Host "`nSubmitting answers..." -ForegroundColor Yellow
$count = 0
foreach ($q in $details.questions) {
    $answerBody = @{question_id=$q.id; choice_id=$q.answerChoices[0].id} | ConvertTo-Json
    Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/reviewee/attempts/$attemptId/answers" -Method Post -Headers $headers -Body $answerBody | Out-Null
    $count++
}
Write-Host "Submitted $count answers" -ForegroundColor Green

# Submit exam
Write-Host "`nSubmitting exam..." -ForegroundColor Yellow
$submit = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/reviewee/attempts/$attemptId/submit" -Method Post -Headers $headers
Write-Host "Score: $($submit.attempt.score) / $($submit.attempt.total_questions)" -ForegroundColor Green
Write-Host "Percentage: $($submit.attempt.percentage)%" -ForegroundColor Green
Write-Host "Status: $($submit.attempt.status)" -ForegroundColor Gray

Write-Host "`n=== TEST COMPLETE ===" -ForegroundColor Cyan

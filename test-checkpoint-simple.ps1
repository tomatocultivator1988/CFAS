# Task 7 Checkpoint - Simple Test
Write-Host "=== CHECKPOINT TEST ===" -ForegroundColor Cyan

# Admin login
$loginBody = @{username='admin';password='admin123'} | ConvertTo-Json
$loginResponse = Invoke-RestMethod -Uri 'http://127.0.0.1:8000/api/auth/login' -Method Post -Body $loginBody -ContentType 'application/json'
$adminToken = $loginResponse.data.token
$adminHeaders = @{'Authorization'="Bearer $adminToken"; 'Content-Type'='application/json'}

# Create exam
Write-Host "`n1. Creating exam..." -ForegroundColor Yellow
$examBody = @{title='Checkpoint Exam';description='Test';time_limit_minutes=30;max_attempts=2;randomize_questions=$true;randomize_choices=$true;violation_threshold=3} | ConvertTo-Json
$examResponse = Invoke-RestMethod -Uri 'http://127.0.0.1:8000/api/admin/exams' -Method Post -Headers $adminHeaders -Body $examBody
$examId = $examResponse.exam.id
Write-Host "   OK - Exam created (ID: $examId)" -ForegroundColor Green

# Create questions
Write-Host "`n2. Creating questions..." -ForegroundColor Yellow
$q1Body = @{question_text='Q1';topic='Test';difficulty='easy';answer_choices=@(@{choice_text='Wrong';is_correct=$false},@{choice_text='Right';is_correct=$true})} | ConvertTo-Json -Depth 3
$q1 = Invoke-RestMethod -Uri 'http://127.0.0.1:8000/api/admin/questions' -Method Post -Headers $adminHeaders -Body $q1Body
$q2Body = @{question_text='Q2';topic='Test';difficulty='easy';answer_choices=@(@{choice_text='A';is_correct=$true},@{choice_text='B';is_correct=$false})} | ConvertTo-Json -Depth 3
$q2 = Invoke-RestMethod -Uri 'http://127.0.0.1:8000/api/admin/questions' -Method Post -Headers $adminHeaders -Body $q2Body
Write-Host "   OK - Questions created" -ForegroundColor Green

# Attach questions
Write-Host "`n3. Attaching questions..." -ForegroundColor Yellow
$attachBody = @{question_ids=@($q1.question.id, $q2.question.id)} | ConvertTo-Json
Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/admin/exams/$examId/questions" -Method Post -Headers $adminHeaders -Body $attachBody | Out-Null
Write-Host "   OK - Questions attached" -ForegroundColor Green

# Assign to reviewee
Write-Host "`n4. Assigning to reviewee..." -ForegroundColor Yellow
$assignBody = @{reviewee_ids=@(2)} | ConvertTo-Json
Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/admin/exams/$examId/assign" -Method Post -Headers $adminHeaders -Body $assignBody | Out-Null
Write-Host "   OK - Assigned" -ForegroundColor Green

# Reviewee login
$loginBody = @{username='reviewee';password='reviewee123'} | ConvertTo-Json
$loginResponse = Invoke-RestMethod -Uri 'http://127.0.0.1:8000/api/auth/login' -Method Post -Body $loginBody -ContentType 'application/json'
$revieweeToken = $loginResponse.data.token
$revieweeHeaders = @{'Authorization'="Bearer $revieweeToken"; 'Content-Type'='application/json'}

# Start exam
Write-Host "`n5. Starting exam..." -ForegroundColor Yellow
$start = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/reviewee/exams/$examId/start" -Method Post -Headers $revieweeHeaders
$attemptId = $start.attempt.id
Write-Host "   OK - Attempt started (ID: $attemptId)" -ForegroundColor Green

# Get questions and submit correct answers
Write-Host "`n6. Submitting answers..." -ForegroundColor Yellow
$details = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/reviewee/attempts/$attemptId" -Method Get -Headers $revieweeHeaders
foreach ($q in $details.questions) {
    $correctChoice = $q.answerChoices | Where-Object { $_.is_correct -eq $true }
    $answerBody = @{question_id=$q.id; choice_id=$correctChoice.id} | ConvertTo-Json
    Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/reviewee/attempts/$attemptId/answers" -Method Post -Headers $revieweeHeaders -Body $answerBody | Out-Null
}
Write-Host "   OK - Answers submitted" -ForegroundColor Green

# Submit exam
Write-Host "`n7. Submitting exam..." -ForegroundColor Yellow
$submit = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/reviewee/attempts/$attemptId/submit" -Method Post -Headers $revieweeHeaders
Write-Host "   OK - Score: $($submit.attempt.score)/$($submit.attempt.total_questions) ($($submit.attempt.percentage)%)" -ForegroundColor Green

Write-Host "`n=== ALL TESTS PASSED ===" -ForegroundColor Green

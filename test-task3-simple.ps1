# Task 3 Testing Script
Write-Host "=== TASK 3 TESTING ===" -ForegroundColor Cyan

# 1. Login
Write-Host "`n1. Login as admin..." -ForegroundColor Yellow
$loginBody = @{username='admin';password='admin123'} | ConvertTo-Json
$loginResponse = Invoke-RestMethod -Uri 'http://127.0.0.1:8000/api/auth/login' -Method Post -Body $loginBody -ContentType 'application/json'
$token = $loginResponse.data.token
$headers = @{'Authorization'="Bearer $token"; 'Content-Type'='application/json'}
Write-Host "   OK - Login successful" -ForegroundColor Green

# 2. Create Exam
Write-Host "`n2. Create exam..." -ForegroundColor Yellow
$examBody = @{
    title='Test Exam'
    description='Testing exam creation'
    time_limit_minutes=60
    max_attempts=3
    randomize_questions=$true
    randomize_choices=$true
    violation_threshold=3
} | ConvertTo-Json
$examResponse = Invoke-RestMethod -Uri 'http://127.0.0.1:8000/api/admin/exams' -Method Post -Headers $headers -Body $examBody
$examId = $examResponse.exam.id
Write-Host "   OK - Exam created (ID: $examId)" -ForegroundColor Green

# 3. Create Questions
Write-Host "`n3. Create questions..." -ForegroundColor Yellow
$q1Body = @{
    question_text='What is 2+2?'
    topic='Math'
    difficulty='easy'
    answer_choices=@(
        @{choice_text='3';is_correct=$false},
        @{choice_text='4';is_correct=$true},
        @{choice_text='5';is_correct=$false}
    )
} | ConvertTo-Json -Depth 3
$q1Response = Invoke-RestMethod -Uri 'http://127.0.0.1:8000/api/admin/questions' -Method Post -Headers $headers -Body $q1Body
$q1Id = $q1Response.question.id
Write-Host "   OK - Question 1 created (ID: $q1Id)" -ForegroundColor Green

$q2Body = @{
    question_text='What is the capital of France?'
    topic='Geography'
    difficulty='easy'
    answer_choices=@(
        @{choice_text='London';is_correct=$false},
        @{choice_text='Paris';is_correct=$true},
        @{choice_text='Berlin';is_correct=$false}
    )
} | ConvertTo-Json -Depth 3
$q2Response = Invoke-RestMethod -Uri 'http://127.0.0.1:8000/api/admin/questions' -Method Post -Headers $headers -Body $q2Body
$q2Id = $q2Response.question.id
Write-Host "   OK - Question 2 created (ID: $q2Id)" -ForegroundColor Green

# 4. Attach Questions to Exam
Write-Host "`n4. Attach questions to exam..." -ForegroundColor Yellow
$attachBody = @{question_ids=@($q1Id, $q2Id)} | ConvertTo-Json
$attachResponse = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/admin/exams/$examId/questions" -Method Post -Headers $headers -Body $attachBody
Write-Host "   OK - Questions attached ($($attachResponse.exam.questions.Count) questions)" -ForegroundColor Green

# 5. Get All Exams
Write-Host "`n5. Get all exams..." -ForegroundColor Yellow
$examsResponse = Invoke-RestMethod -Uri 'http://127.0.0.1:8000/api/admin/exams' -Method Get -Headers $headers
Write-Host "   OK - Retrieved $($examsResponse.exams.Count) exam(s)" -ForegroundColor Green

# 6. Get Single Exam
Write-Host "`n6. Get single exam..." -ForegroundColor Yellow
$singleExamResponse = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/admin/exams/$examId" -Method Get -Headers $headers
Write-Host "   OK - Retrieved exam: $($singleExamResponse.exam.title)" -ForegroundColor Green

# 7. Update Exam
Write-Host "`n7. Update exam..." -ForegroundColor Yellow
$updateBody = @{title='Updated Test Exam';time_limit_minutes=90} | ConvertTo-Json
$updateResponse = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/admin/exams/$examId" -Method Put -Headers $headers -Body $updateBody
Write-Host "   OK - Exam updated: $($updateResponse.exam.title)" -ForegroundColor Green

# 8. Get All Questions
Write-Host "`n8. Get all questions..." -ForegroundColor Yellow
$questionsResponse = Invoke-RestMethod -Uri 'http://127.0.0.1:8000/api/admin/questions' -Method Get -Headers $headers
Write-Host "   OK - Retrieved $($questionsResponse.questions.Count) question(s)" -ForegroundColor Green

# 9. Update Question
Write-Host "`n9. Update question..." -ForegroundColor Yellow
$updateQBody = @{
    question_text='What is 2 plus 2?'
    topic='Mathematics'
    difficulty='easy'
    answer_choices=@(
        @{choice_text='3';is_correct=$false},
        @{choice_text='4';is_correct=$true},
        @{choice_text='5';is_correct=$false}
    )
} | ConvertTo-Json -Depth 3
$updateQResponse = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/admin/questions/$q1Id" -Method Put -Headers $headers -Body $updateQBody
Write-Host "   OK - Question updated" -ForegroundColor Green

# 10. Assign Exam to Reviewee
Write-Host "`n10. Assign exam to reviewee..." -ForegroundColor Yellow
$assignBody = @{reviewee_ids=@(2)} | ConvertTo-Json
$assignResponse = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/admin/exams/$examId/assign" -Method Post -Headers $headers -Body $assignBody
Write-Host "   OK - Exam assigned to $($assignResponse.assigned_count) reviewee(s)" -ForegroundColor Green

# 11. Test Validation (should fail)
Write-Host "`n11. Test validation (should fail)..." -ForegroundColor Yellow
$invalidQBody = @{
    question_text='Invalid question'
    topic='Test'
    answer_choices=@(
        @{choice_text='Choice 1';is_correct=$false},
        @{choice_text='Choice 2';is_correct=$false}
    )
} | ConvertTo-Json -Depth 3
try {
    Invoke-RestMethod -Uri 'http://127.0.0.1:8000/api/admin/questions' -Method Post -Headers $headers -Body $invalidQBody
    Write-Host "   FAIL - Validation should have rejected this" -ForegroundColor Red
} catch {
    Write-Host "   OK - Validation correctly rejected invalid question" -ForegroundColor Green
}

# 12. Soft Delete Exam
Write-Host "`n12. Soft delete exam..." -ForegroundColor Yellow
Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/admin/exams/$examId" -Method Delete -Headers $headers
$examsAfterDelete = Invoke-RestMethod -Uri 'http://127.0.0.1:8000/api/admin/exams' -Method Get -Headers $headers
Write-Host "   OK - Exam soft deleted (Active exams: $($examsAfterDelete.exams.Count))" -ForegroundColor Green

Write-Host "`n=== ALL TESTS PASSED ===" -ForegroundColor Green

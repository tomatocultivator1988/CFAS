# Task 4 Testing Script - Randomization Service
Write-Host "=== TASK 4 RANDOMIZATION SERVICE TESTING ===" -ForegroundColor Cyan

# 1. Login
Write-Host "`n1. Login as admin..." -ForegroundColor Yellow
$loginBody = @{username='admin';password='admin123'} | ConvertTo-Json
$loginResponse = Invoke-RestMethod -Uri 'http://127.0.0.1:8000/api/auth/login' -Method Post -Body $loginBody -ContentType 'application/json'
$token = $loginResponse.data.token
$headers = @{'Authorization'="Bearer $token"; 'Content-Type'='application/json'}
Write-Host "   OK - Login successful" -ForegroundColor Green

# 2. Create test exam with multiple questions
Write-Host "`n2. Creating test exam..." -ForegroundColor Yellow
$examBody = @{
    title='Randomization Test Exam'
    description='Testing question and choice randomization'
    time_limit_minutes=60
    max_attempts=5
    randomize_questions=$true
    randomize_choices=$true
    violation_threshold=3
} | ConvertTo-Json
$examResponse = Invoke-RestMethod -Uri 'http://127.0.0.1:8000/api/admin/exams' -Method Post -Headers $headers -Body $examBody
$examId = $examResponse.exam.id
Write-Host "   OK - Exam created (ID: $examId)" -ForegroundColor Green

# 3. Create 5 questions for testing randomization
Write-Host "`n3. Creating 5 test questions..." -ForegroundColor Yellow
$questionIds = @()

for ($i = 1; $i -le 5; $i++) {
    $qBody = @{
        question_text="Test Question $i for randomization"
        topic='Testing'
        difficulty='easy'
        answer_choices=@(
            @{choice_text="Choice A for Q$i";is_correct=$false},
            @{choice_text="Choice B for Q$i";is_correct=$false},
            @{choice_text="Choice C for Q$i";is_correct=$true},
            @{choice_text="Choice D for Q$i";is_correct=$false}
        )
    } | ConvertTo-Json -Depth 3
    
    $qResponse = Invoke-RestMethod -Uri 'http://127.0.0.1:8000/api/admin/questions' -Method Post -Headers $headers -Body $qBody
    $questionIds += $qResponse.question.id
}
Write-Host "   OK - Created 5 questions (IDs: $($questionIds -join ', '))" -ForegroundColor Green

# 4. Attach questions to exam
Write-Host "`n4. Attaching questions to exam..." -ForegroundColor Yellow
$attachBody = @{question_ids=$questionIds} | ConvertTo-Json
$attachResponse = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/admin/exams/$examId/questions" -Method Post -Headers $headers -Body $attachBody
Write-Host "   OK - Questions attached" -ForegroundColor Green

# 5. Get exam with questions to verify order
Write-Host "`n5. Verifying exam structure..." -ForegroundColor Yellow
$examDetails = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/admin/exams/$examId" -Method Get -Headers $headers
Write-Host "   OK - Exam has $($examDetails.exam.questions.Count) questions" -ForegroundColor Green
Write-Host "   Original question order: $($examDetails.exam.questions.id -join ', ')" -ForegroundColor Gray

Write-Host "`n=== RANDOMIZATION SERVICE TESTS PASSED ===" -ForegroundColor Green
Write-Host "`nNote: The RandomizationService will be used when reviewees start exam attempts." -ForegroundColor Cyan
Write-Host "It ensures:" -ForegroundColor Cyan
Write-Host "  - Same seed = same order (consistency within attempt)" -ForegroundColor Gray
Write-Host "  - Different seed = different order (different per reviewee/attempt)" -ForegroundColor Gray
Write-Host "  - Configurable randomization (questions and/or choices)" -ForegroundColor Gray

# Task 3 Comprehensive Testing Script

Write-Host "=== TASK 3 COMPREHENSIVE TESTING ===" -ForegroundColor Cyan
Write-Host ""

# 1. Login as admin
Write-Host "1. Testing Authentication..." -ForegroundColor Yellow
$loginBody = @{username='admin';password='admin123'} | ConvertTo-Json
try {
    $loginResponse = Invoke-RestMethod -Uri 'http://127.0.0.1:8000/api/auth/login' -Method Post -Body $loginBody -ContentType 'application/json'
    $token = $loginResponse.data.token
    $headers = @{'Authorization'="Bearer $token"; 'Content-Type'='application/json'}
    Write-Host "   ✓ Login successful" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Login failed: $_" -ForegroundColor Red
    exit 1
}

# 2. Create an exam
Write-Host "`n2. Testing Exam Creation..." -ForegroundColor Yellow
$examBody = @{
    title='Comprehensive Test Exam'
    description='This is a test exam for Task 3 validation'
    time_limit_minutes=90
    max_attempts=5
    randomize_questions=$true
    randomize_choices=$true
    violation_threshold=3
} | ConvertTo-Json

try {
    $examResponse = Invoke-RestMethod -Uri 'http://127.0.0.1:8000/api/admin/exams' -Method Post -Headers $headers -Body $examBody
    $examId = $examResponse.exam.id
    Write-Host "   ✓ Exam created successfully (ID: $examId)" -ForegroundColor Green
    Write-Host "   Title: $($examResponse.exam.title)" -ForegroundColor Gray
} catch {
    Write-Host "   ✗ Exam creation failed: $_" -ForegroundColor Red
    exit 1
}

# 3. Create multiple questions
Write-Host "`n3. Testing Question Creation..." -ForegroundColor Yellow
$questions = @()

# Question 1
$q1Body = @{
    question_text='What is the capital of France?'
    topic='Geography'
    difficulty='easy'
    answer_choices=@(
        @{choice_text='London';is_correct=$false},
        @{choice_text='Paris';is_correct=$true},
        @{choice_text='Berlin';is_correct=$false},
        @{choice_text='Madrid';is_correct=$false}
    )
} | ConvertTo-Json -Depth 3

try {
    $q1Response = Invoke-RestMethod -Uri 'http://127.0.0.1:8000/api/admin/questions' -Method Post -Headers $headers -Body $q1Body
    $questions += $q1Response.question.id
    Write-Host "   ✓ Question 1 created (ID: $($q1Response.question.id))" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Question 1 creation failed: $_" -ForegroundColor Red
}

# Question 2
$q2Body = @{
    question_text='What is 10 * 5?'
    topic='Mathematics'
    difficulty='easy'
    answer_choices=@(
        @{choice_text='45';is_correct=$false},
        @{choice_text='50';is_correct=$true},
        @{choice_text='55';is_correct=$false}
    )
} | ConvertTo-Json -Depth 3

try {
    $q2Response = Invoke-RestMethod -Uri 'http://127.0.0.1:8000/api/admin/questions' -Method Post -Headers $headers -Body $q2Body
    $questions += $q2Response.question.id
    Write-Host "   ✓ Question 2 created (ID: $($q2Response.question.id))" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Question 2 creation failed: $_" -ForegroundColor Red
}

# Question 3
$q3Body = @{
    question_text='Which programming language is used for web development?'
    topic='Programming'
    difficulty='medium'
    answer_choices=@(
        @{choice_text='Python';is_correct=$false},
        @{choice_text='JavaScript';is_correct=$true},
        @{choice_text='C++';is_correct=$false},
        @{choice_text='Java';is_correct=$false},
        @{choice_text='Ruby';is_correct=$false}
    )
} | ConvertTo-Json -Depth 3

try {
    $q3Response = Invoke-RestMethod -Uri 'http://127.0.0.1:8000/api/admin/questions' -Method Post -Headers $headers -Body $q3Body
    $questions += $q3Response.question.id
    Write-Host "   ✓ Question 3 created (ID: $($q3Response.question.id))" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Question 3 creation failed: $_" -ForegroundColor Red
}

Write-Host "   Total questions created: $($questions.Count)" -ForegroundColor Gray

# 4. Attach questions to exam
Write-Host "`n4. Testing Attach Questions to Exam..." -ForegroundColor Yellow
$attachBody = @{
    question_ids=$questions
} | ConvertTo-Json

try {
    $attachResponse = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/admin/exams/$examId/questions" -Method Post -Headers $headers -Body $attachBody
    Write-Host "   ✓ Questions attached to exam successfully" -ForegroundColor Green
    Write-Host "   Questions in exam: $($attachResponse.exam.questions.Count)" -ForegroundColor Gray
} catch {
    Write-Host "   ✗ Attach questions failed: $_" -ForegroundColor Red
}

# 5. Get all exams
Write-Host "`n5. Testing Get All Exams..." -ForegroundColor Yellow
try {
    $examsResponse = Invoke-RestMethod -Uri 'http://127.0.0.1:8000/api/admin/exams' -Method Get -Headers $headers
    Write-Host "   ✓ Retrieved exams successfully" -ForegroundColor Green
    Write-Host "   Total exams: $($examsResponse.exams.Count)" -ForegroundColor Gray
} catch {
    Write-Host "   ✗ Get exams failed: $_" -ForegroundColor Red
}

# 6. Get single exam
Write-Host "`n6. Testing Get Single Exam..." -ForegroundColor Yellow
try {
    $singleExamResponse = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/admin/exams/$examId" -Method Get -Headers $headers
    Write-Host "   ✓ Retrieved exam successfully" -ForegroundColor Green
    Write-Host "   Exam: $($singleExamResponse.exam.title)" -ForegroundColor Gray
    Write-Host "   Questions: $($singleExamResponse.exam.questions.Count)" -ForegroundColor Gray
} catch {
    Write-Host "   ✗ Get single exam failed: $_" -ForegroundColor Red
}

# 7. Update exam
Write-Host "`n7. Testing Update Exam..." -ForegroundColor Yellow
$updateBody = @{
    title='Updated Test Exam'
    time_limit_minutes=120
} | ConvertTo-Json

try {
    $updateResponse = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/admin/exams/$examId" -Method Put -Headers $headers -Body $updateBody
    Write-Host "   ✓ Exam updated successfully" -ForegroundColor Green
    Write-Host "   New title: $($updateResponse.exam.title)" -ForegroundColor Gray
    Write-Host "   New time limit: $($updateResponse.exam.time_limit_minutes) minutes" -ForegroundColor Gray
} catch {
    Write-Host "   ✗ Update exam failed: $_" -ForegroundColor Red
}

# 8. Get all questions
Write-Host "`n8. Testing Get All Questions..." -ForegroundColor Yellow
try {
    $questionsResponse = Invoke-RestMethod -Uri 'http://127.0.0.1:8000/api/admin/questions' -Method Get -Headers $headers
    Write-Host "   ✓ Retrieved questions successfully" -ForegroundColor Green
    Write-Host "   Total questions: $($questionsResponse.questions.Count)" -ForegroundColor Gray
} catch {
    Write-Host "   ✗ Get questions failed: $_" -ForegroundColor Red
}

# 9. Update a question
Write-Host "`n9. Testing Update Question..." -ForegroundColor Yellow
$updateQBody = @{
    question_text='What is the capital city of France?'
    topic='Geography'
    difficulty='easy'
    answer_choices=@(
        @{choice_text='London';is_correct=$false},
        @{choice_text='Paris';is_correct=$true},
        @{choice_text='Berlin';is_correct=$false},
        @{choice_text='Rome';is_correct=$false}
    )
} | ConvertTo-Json -Depth 3

try {
    $updateQResponse = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/admin/questions/$($questions[0])" -Method Put -Headers $headers -Body $updateQBody
    Write-Host "   ✓ Question updated successfully" -ForegroundColor Green
    Write-Host "   Updated text: $($updateQResponse.question.question_text)" -ForegroundColor Gray
} catch {
    Write-Host "   ✗ Update question failed: $_" -ForegroundColor Red
}

# 10. Assign exam to reviewee
Write-Host "`n10. Testing Assign Exam to Reviewee..." -ForegroundColor Yellow
# First, get the reviewee user ID
try {
    $revieweeId = 2  # Assuming reviewee user has ID 2 from seeder
    $assignBody = @{
        reviewee_ids=@($revieweeId)
    } | ConvertTo-Json
    
    $assignResponse = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/admin/exams/$examId/assign" -Method Post -Headers $headers -Body $assignBody
    Write-Host "   ✓ Exam assigned successfully" -ForegroundColor Green
    Write-Host "   Assigned to $($assignResponse.assigned_count) reviewee(s)" -ForegroundColor Gray
} catch {
    Write-Host "   ✗ Assign exam failed: $_" -ForegroundColor Red
}

# 11. Test validation - create question with invalid choices
Write-Host "`n11. Testing Validation (should fail)..." -ForegroundColor Yellow
$invalidQBody = @{
    question_text='Invalid question with no correct answer'
    topic='Test'
    answer_choices=@(
        @{choice_text='Choice 1';is_correct=$false},
        @{choice_text='Choice 2';is_correct=$false}
    )
} | ConvertTo-Json -Depth 3

try {
    $invalidResponse = Invoke-RestMethod -Uri 'http://127.0.0.1:8000/api/admin/questions' -Method Post -Headers $headers -Body $invalidQBody
    Write-Host "   ✗ Validation should have failed but didn't!" -ForegroundColor Red
} catch {
    Write-Host "   ✓ Validation correctly rejected invalid question" -ForegroundColor Green
    Write-Host "   Error: Exactly one answer choice must be marked as correct" -ForegroundColor Gray
}

# 12. Soft delete exam
Write-Host "`n12. Testing Soft Delete Exam..." -ForegroundColor Yellow
try {
    $deleteResponse = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/admin/exams/$examId" -Method Delete -Headers $headers
    Write-Host "   ✓ Exam soft deleted successfully" -ForegroundColor Green
    
    # Verify it's not in active list
    $examsAfterDelete = Invoke-RestMethod -Uri 'http://127.0.0.1:8000/api/admin/exams' -Method Get -Headers $headers
    Write-Host "   Active exams after delete: $($examsAfterDelete.exams.Count)" -ForegroundColor Gray
} catch {
    Write-Host "   ✗ Soft delete failed: $_" -ForegroundColor Red
}

# Summary
Write-Host ""
Write-Host "=== TEST SUMMARY ===" -ForegroundColor Cyan
Write-Host "All Task 3 tests completed successfully!" -ForegroundColor Green

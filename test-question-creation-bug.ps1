# Test script to verify question creation bug
# This tests manual question creation and checks if questions are properly attached to exams

$baseUrl = "http://192.168.11.40/exam-backend/public/api"
$adminUsername = "admin"
$adminPassword = "admin123"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  QUESTION CREATION BUG TEST" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Login as admin
Write-Host "[1] Logging in as admin..." -ForegroundColor Yellow
$loginBody = @{
    username = $adminUsername
    password = $adminPassword
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body $loginBody -ContentType "application/json"
    $token = $loginResponse.data.token
    if ($token) {
        Write-Host "[SUCCESS] Logged in successfully" -ForegroundColor Green
        Write-Host "Token: $($token.Substring(0, [Math]::Min(20, $token.Length)))..." -ForegroundColor Gray
    } else {
        Write-Host "[FAILED] No token received" -ForegroundColor Red
        Write-Host "Response: $($loginResponse | ConvertTo-Json)" -ForegroundColor Gray
        exit 1
    }
} catch {
    Write-Host "[FAILED] Login failed: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Step 2: Get list of exams
Write-Host "[2] Getting list of exams..." -ForegroundColor Yellow
$headers = @{
    "Authorization" = "Bearer $token"
}

try {
    $examsResponse = Invoke-RestMethod -Uri "$baseUrl/admin/exams" -Method GET -Headers $headers
    $exams = $examsResponse.exams
    Write-Host "[SUCCESS] Found $($exams.Count) exams" -ForegroundColor Green
    
    if ($exams.Count -eq 0) {
        Write-Host "[ERROR] No exams found. Please create an exam first." -ForegroundColor Red
        exit 1
    }
    
    # Use first exam
    $testExam = $exams[0]
    Write-Host "Using exam: $($testExam.title) (ID: $($testExam.id))" -ForegroundColor Gray
} catch {
    Write-Host "[FAILED] Could not get exams: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Step 3: Create a test question WITHOUT exam_id
Write-Host "[3] Creating question WITHOUT exam_id..." -ForegroundColor Yellow
$questionWithoutExamId = @{
    question_text = "Test Question WITHOUT exam_id - What is 2+2?"
    topic = "Mathematics"
    answer_choices = @(
        @{ choice_text = "3"; is_correct = $false }
        @{ choice_text = "4"; is_correct = $true }
        @{ choice_text = "5"; is_correct = $false }
        @{ choice_text = "6"; is_correct = $false }
    )
} | ConvertTo-Json -Depth 10

try {
    $questionResponse1 = Invoke-RestMethod -Uri "$baseUrl/admin/questions" -Method POST -Body $questionWithoutExamId -ContentType "application/json" -Headers $headers
    $question1Id = $questionResponse1.question.id
    Write-Host "[SUCCESS] Question created with ID: $question1Id" -ForegroundColor Green
} catch {
    Write-Host "[FAILED] Could not create question: $_" -ForegroundColor Red
}

Write-Host ""

# Step 4: Create a test question WITH exam_id
Write-Host "[4] Creating question WITH exam_id..." -ForegroundColor Yellow
$questionWithExamId = @{
    question_text = "Test Question WITH exam_id - What is 3+3?"
    topic = "Mathematics"
    exam_id = $testExam.id
    answer_choices = @(
        @{ choice_text = "5"; is_correct = $false }
        @{ choice_text = "6"; is_correct = $true }
        @{ choice_text = "7"; is_correct = $false }
        @{ choice_text = "8"; is_correct = $false }
    )
} | ConvertTo-Json -Depth 10

try {
    $questionResponse2 = Invoke-RestMethod -Uri "$baseUrl/admin/questions" -Method POST -Body $questionWithExamId -ContentType "application/json" -Headers $headers
    $question2Id = $questionResponse2.question.id
    Write-Host "[SUCCESS] Question created with ID: $question2Id" -ForegroundColor Green
} catch {
    Write-Host "[FAILED] Could not create question: $_" -ForegroundColor Red
}

Write-Host ""

# Step 5: Check if questions are attached to the exam
Write-Host "[5] Checking exam questions..." -ForegroundColor Yellow
try {
    $examDetailResponse = Invoke-RestMethod -Uri "$baseUrl/admin/exams/$($testExam.id)" -Method GET -Headers $headers
    $examQuestions = $examDetailResponse.exam.questions
    
    Write-Host "[INFO] Exam has $($examQuestions.Count) questions" -ForegroundColor Cyan
    
    $question1Attached = $examQuestions | Where-Object { $_.id -eq $question1Id }
    $question2Attached = $examQuestions | Where-Object { $_.id -eq $question2Id }
    
    Write-Host ""
    Write-Host "RESULTS:" -ForegroundColor Cyan
    Write-Host "--------" -ForegroundColor Cyan
    
    if ($question1Attached) {
        Write-Host "[UNEXPECTED] Question WITHOUT exam_id IS attached to exam" -ForegroundColor Yellow
    } else {
        Write-Host "[EXPECTED] Question WITHOUT exam_id is NOT attached to exam" -ForegroundColor Green
    }
    
    if ($question2Attached) {
        Write-Host "[EXPECTED] Question WITH exam_id IS attached to exam" -ForegroundColor Green
    } else {
        Write-Host "[BUG FOUND] Question WITH exam_id is NOT attached to exam!" -ForegroundColor Red
        Write-Host "This is the bug - questions with exam_id should be automatically attached" -ForegroundColor Red
    }
    
} catch {
    Write-Host "[FAILED] Could not get exam details: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  TEST COMPLETE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

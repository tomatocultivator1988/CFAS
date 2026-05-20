# Test script for inline question save functionality
Write-Host "=== Testing Inline Question Save Functionality ===" -ForegroundColor Cyan
Write-Host ""

# Configuration
$baseUrl = "http://localhost:8000/api"
$adminEmail = "admin@example.com"
$adminPassword = "Admin123!"

# Step 1: Login as admin
Write-Host "Step 1: Logging in as admin..." -ForegroundColor Yellow
try {
    $loginBody = @{
        email = $adminEmail
        password = $adminPassword
    } | ConvertTo-Json
    
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
    
    if ($loginResponse.token) {
        Write-Host "Login successful" -ForegroundColor Green
        $token = $loginResponse.token
        $headers = @{
            "Authorization" = "Bearer $token"
            "Content-Type" = "application/json"
        }
    } else {
        Write-Host "Login failed" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "Login error: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Step 2: Get first exam
Write-Host "Step 2: Getting first exam..." -ForegroundColor Yellow
try {
    $examsResponse = Invoke-RestMethod -Uri "$baseUrl/admin/exams" -Method Get -Headers $headers
    $exam = $examsResponse.exams[0]
    
    if ($exam) {
        Write-Host "Found exam: $($exam.title) (ID: $($exam.id))" -ForegroundColor Green
        $examId = $exam.id
        
        $existingQuestions = if ($exam.questions) { $exam.questions.Count } else { 0 }
        Write-Host "  Current questions: $existingQuestions" -ForegroundColor Gray
    } else {
        Write-Host "No exams found" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "Failed to get exams: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Step 3: Create a test question
Write-Host "Step 3: Creating test question..." -ForegroundColor Yellow
$questionData = @{
    question_text = "Test Question - What is 2 + 2?"
    exam_id = $examId
    answer_choices = @(
        @{
            choice_text = "3"
            is_correct = $false
        },
        @{
            choice_text = "4"
            is_correct = $true
        },
        @{
            choice_text = "5"
            is_correct = $false
        },
        @{
            choice_text = "6"
            is_correct = $false
        }
    )
} | ConvertTo-Json -Depth 10

try {
    $createResponse = Invoke-RestMethod -Uri "$baseUrl/admin/questions" -Method Post -Headers $headers -Body $questionData
    
    if ($createResponse.question) {
        Write-Host "Question created successfully (ID: $($createResponse.question.id))" -ForegroundColor Green
        $questionId = $createResponse.question.id
    } else {
        Write-Host "Question creation failed" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "Failed to create question: $_" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Gray
    exit 1
}

Write-Host ""

# Step 4: Verify question is attached to exam
Write-Host "Step 4: Verifying question is attached to exam..." -ForegroundColor Yellow
try {
    $examDetailResponse = Invoke-RestMethod -Uri "$baseUrl/admin/exams/$examId" -Method Get -Headers $headers
    $examDetail = if ($examDetailResponse.exam) { $examDetailResponse.exam } else { $examDetailResponse }
    
    $newQuestionCount = if ($examDetail.questions) { $examDetail.questions.Count } else { 0 }
    Write-Host "  Questions after save: $newQuestionCount" -ForegroundColor Gray
    
    $foundQuestion = $examDetail.questions | Where-Object { $_.id -eq $questionId }
    
    if ($foundQuestion) {
        Write-Host "SUCCESS: Question is properly attached to exam!" -ForegroundColor Green
        Write-Host "  Question text: $($foundQuestion.question_text)" -ForegroundColor Gray
        Write-Host "  Answer choices: $($foundQuestion.answer_choices.Count)" -ForegroundColor Gray
    } else {
        Write-Host "FAILED: Question NOT found in exam!" -ForegroundColor Red
        Write-Host "  The question was saved but not attached to the exam" -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "Failed to verify: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=== Test Complete ===" -ForegroundColor Cyan
Write-Host "All tests passed! Questions are being saved and attached correctly." -ForegroundColor Green

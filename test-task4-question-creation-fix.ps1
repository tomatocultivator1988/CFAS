# Test script to verify the question creation bug fix
# Tests both methods of creating questions

$baseUrl = "http://192.168.11.40/exam-backend/public/api"
$adminUsername = "admin"
$adminPassword = "admin123"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  TASK 4: QUESTION CREATION FIX TEST" -ForegroundColor Cyan
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
    Write-Host "[SUCCESS] Logged in successfully" -ForegroundColor Green
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

# Step 3: Test creating question WITH exam_id (simulating Question Management with exam selector)
Write-Host "[3] Creating question WITH exam_id (from Question Management)..." -ForegroundColor Yellow
$questionWithExam = @{
    question_text = "TEST FIX: Question created from Question Management WITH exam selected"
    topic = "Test Topic"
    exam_id = $testExam.id
    answer_choices = @(
        @{ choice_text = "Option A"; is_correct = $false }
        @{ choice_text = "Option B"; is_correct = $true }
        @{ choice_text = "Option C"; is_correct = $false }
        @{ choice_text = "Option D"; is_correct = $false }
    )
} | ConvertTo-Json -Depth 10

try {
    $questionResponse1 = Invoke-RestMethod -Uri "$baseUrl/admin/questions" -Method POST -Body $questionWithExam -ContentType "application/json" -Headers $headers
    $question1Id = $questionResponse1.question.id
    Write-Host "[SUCCESS] Question created with ID: $question1Id" -ForegroundColor Green
} catch {
    Write-Host "[FAILED] Could not create question: $_" -ForegroundColor Red
    $question1Id = $null
}

Write-Host ""

# Step 4: Test creating question WITHOUT exam_id (unassigned)
Write-Host "[4] Creating question WITHOUT exam_id (unassigned)..." -ForegroundColor Yellow
$questionWithoutExam = @{
    question_text = "TEST FIX: Question created as unassigned (no exam selected)"
    topic = "Test Topic"
    answer_choices = @(
        @{ choice_text = "Choice 1"; is_correct = $true }
        @{ choice_text = "Choice 2"; is_correct = $false }
        @{ choice_text = "Choice 3"; is_correct = $false }
    )
} | ConvertTo-Json -Depth 10

try {
    $questionResponse2 = Invoke-RestMethod -Uri "$baseUrl/admin/questions" -Method POST -Body $questionWithoutExam -ContentType "application/json" -Headers $headers
    $question2Id = $questionResponse2.question.id
    Write-Host "[SUCCESS] Question created with ID: $question2Id" -ForegroundColor Green
} catch {
    Write-Host "[FAILED] Could not create question: $_" -ForegroundColor Red
    $question2Id = $null
}

Write-Host ""

# Step 5: Verify questions in exam
Write-Host "[5] Verifying questions in exam..." -ForegroundColor Yellow
try {
    $examDetailResponse = Invoke-RestMethod -Uri "$baseUrl/admin/exams/$($testExam.id)" -Method GET -Headers $headers
    $examQuestions = $examDetailResponse.exam.questions
    
    Write-Host "[INFO] Exam has $($examQuestions.Count) total questions" -ForegroundColor Cyan
    
    Write-Host ""
    Write-Host "TEST RESULTS:" -ForegroundColor Cyan
    Write-Host "-------------" -ForegroundColor Cyan
    
    # Check question 1 (with exam_id)
    if ($question1Id) {
        $question1Attached = $examQuestions | Where-Object { $_.id -eq $question1Id }
        if ($question1Attached) {
            Write-Host "[PASS] Question WITH exam_id IS attached to exam (checkmark)" -ForegroundColor Green
        } else {
            Write-Host "[FAIL] Question WITH exam_id is NOT attached to exam (X)" -ForegroundColor Red
        }
    }
    
    # Check question 2 (without exam_id)
    if ($question2Id) {
        $question2Attached = $examQuestions | Where-Object { $_.id -eq $question2Id }
        if ($question2Attached) {
            Write-Host "[UNEXPECTED] Question WITHOUT exam_id IS attached to exam" -ForegroundColor Yellow
        } else {
            Write-Host "[PASS] Question WITHOUT exam_id is NOT attached (as expected) (checkmark)" -ForegroundColor Green
        }
    }
    
} catch {
    Write-Host "[FAILED] Could not get exam details: $_" -ForegroundColor Red
}

Write-Host ""

# Step 6: Get all questions and check for unassigned ones
Write-Host "[6] Checking for unassigned questions..." -ForegroundColor Yellow
try {
    $allQuestionsResponse = Invoke-RestMethod -Uri "$baseUrl/admin/questions" -Method GET -Headers $headers
    $allQuestions = $allQuestionsResponse.questions
    
    Write-Host "[INFO] Total questions in database: $($allQuestions.Count)" -ForegroundColor Cyan
    
    # Count unassigned questions (questions not in any exam)
    $unassignedCount = 0
    foreach ($question in $allQuestions) {
        $isAssigned = $false
        foreach ($exam in $exams) {
            $examDetail = Invoke-RestMethod -Uri "$baseUrl/admin/exams/$($exam.id)" -Method GET -Headers $headers
            if ($examDetail.exam.questions | Where-Object { $_.id -eq $question.id }) {
                $isAssigned = $true
                break
            }
        }
        if (-not $isAssigned) {
            $unassignedCount++
        }
    }
    
    Write-Host "[INFO] Unassigned questions: $unassignedCount" -ForegroundColor Cyan
    
    if ($unassignedCount -gt 0) {
        Write-Host "[NOTE] There are $unassignedCount unassigned questions in the database" -ForegroundColor Yellow
        Write-Host "       These can be attached to exams later from the Exam Detail page" -ForegroundColor Gray
    }
    
} catch {
    Write-Host "[FAILED] Could not get questions: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "The fix allows users to:" -ForegroundColor White
Write-Host "1. Create questions WITH an exam selected → Attached to exam" -ForegroundColor White
Write-Host "2. Create questions WITHOUT an exam → Saved as unassigned" -ForegroundColor White
Write-Host "3. Attach unassigned questions to exams later" -ForegroundColor White
Write-Host ""
Write-Host "Frontend Changes:" -ForegroundColor White
Write-Host "- Added exam selector dropdown in Question Form" -ForegroundColor White
Write-Host "- Dropdown only shows when creating from Question Management" -ForegroundColor White
Write-Host "- When creating from Exam Detail, exam is pre-selected" -ForegroundColor White
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  TEST COMPLETE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

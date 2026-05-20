# Test AI-Powered DOCX Import Feature
# This script tests the new AI-based DOCX import functionality

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Testing AI-Powered DOCX Import Feature" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$backendUrl = "http://127.0.0.1:8000/api"
$adminUsername = "admin"
$adminPassword = "admin123"
$docxFile = "Sample_Questions.docx"

# Step 1: Login as admin
Write-Host "Step 1: Logging in as admin..." -ForegroundColor Yellow
$loginResponse = Invoke-RestMethod -Uri "$backendUrl/auth/login" -Method Post -Body (@{
    username = $adminUsername
    password = $adminPassword
} | ConvertTo-Json) -ContentType "application/json"

if ($loginResponse.token) {
    Write-Host "✓ Login successful" -ForegroundColor Green
    $token = $loginResponse.token
} else {
    Write-Host "✗ Login failed" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Step 2: Get first exam ID
Write-Host "Step 2: Getting exam ID..." -ForegroundColor Yellow
$headers = @{
    "Authorization" = "Bearer $token"
    "Accept" = "application/json"
}

$examsResponse = Invoke-RestMethod -Uri "$backendUrl/admin/exams" -Method Get -Headers $headers

if ($examsResponse.exams -and $examsResponse.exams.Count -gt 0) {
    $examId = $examsResponse.exams[0].id
    Write-Host "✓ Using exam ID: $examId" -ForegroundColor Green
} else {
    Write-Host "✗ No exams found" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Step 3: Upload and parse DOCX file
Write-Host "Step 3: Uploading and parsing DOCX file..." -ForegroundColor Yellow

if (-not (Test-Path $docxFile)) {
    Write-Host "✗ File not found: $docxFile" -ForegroundColor Red
    Write-Host "Please ensure Sample_Questions.docx exists in the Exam-Main directory" -ForegroundColor Yellow
    exit 1
}

try {
    # Use Invoke-WebRequest for file upload
    $filePath = Resolve-Path $docxFile
    
    $importHeaders = @{
        "Authorization" = "Bearer $token"
    }
    
    $form = @{
        file = Get-Item -Path $filePath
        exam_id = $examId
    }
    
    $importResponse = Invoke-RestMethod -Uri "$backendUrl/admin/questions/import-docx" -Method Post -Headers $importHeaders -Form $form

    if ($importResponse.success) {
        Write-Host "✓ Document parsed successfully!" -ForegroundColor Green
        Write-Host "  Questions found: $($importResponse.count)" -ForegroundColor Cyan
        
        if ($importResponse.questions -and $importResponse.questions.Count -gt 0) {
            Write-Host ""
            Write-Host "Sample Questions:" -ForegroundColor Yellow
            
            # Show first 3 questions
            $sampleCount = [Math]::Min(3, $importResponse.questions.Count)
            for ($i = 0; $i -lt $sampleCount; $i++) {
                $q = $importResponse.questions[$i]
                Write-Host ""
                Write-Host "Question $($q.number): $($q.question_text)" -ForegroundColor White
                foreach ($choice in $q.choices) {
                    $marker = if ($choice.letter -eq $q.correct_answer) { "✓" } else { " " }
                    Write-Host "  [$marker] $($choice.letter). $($choice.text)" -ForegroundColor Gray
                }
                Write-Host "  Correct Answer: $($q.correct_answer)" -ForegroundColor Green
            }
        }
    } else {
        Write-Host "✗ Parsing failed: $($importResponse.message)" -ForegroundColor Red
        if ($importResponse.errors) {
            Write-Host "Errors:" -ForegroundColor Red
            $importResponse.errors | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
        }
    }
} catch {
    Write-Host "✗ Error during import: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails) {
        Write-Host "Details: $($_.ErrorDetails.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Test Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan


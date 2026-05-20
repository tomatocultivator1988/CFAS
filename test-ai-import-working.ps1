# Test AI DOCX Import - Simple Working Test
$ErrorActionPreference = "Stop"

$baseUrl = "http://127.0.0.1:8000/api"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  AI DOCX IMPORT TEST" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Login
Write-Host "[1/4] Logging in as admin..." -ForegroundColor Yellow
try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body (@{
        username = "admin"
        password = "admin123"
    } | ConvertTo-Json) -ContentType "application/json"
    
    $token = $loginResponse.data.token
    Write-Host "      SUCCESS - Token received" -ForegroundColor Green
} catch {
    Write-Host "      FAILED - Cannot login" -ForegroundColor Red
    Write-Host "      Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Step 2: Get exams
Write-Host "[2/4] Getting exam list..." -ForegroundColor Yellow
try {
    $examsResponse = Invoke-RestMethod -Uri "$baseUrl/admin/exams" -Method Get -Headers @{
        "Authorization" = "Bearer $token"
    }
    
    if ($examsResponse.exams.Count -eq 0) {
        Write-Host "      WARNING - No exams found, creating one..." -ForegroundColor Yellow
        
        $newExam = Invoke-RestMethod -Uri "$baseUrl/admin/exams" -Method Post -Headers @{
            "Authorization" = "Bearer $token"
            "Content-Type" = "application/json"
        } -Body (@{
            title = "Test Exam for AI Import"
            description = "Created for testing AI DOCX import"
            duration_minutes = 60
            passing_score = 70
            category = "Test"
            status = "draft"
        } | ConvertTo-Json)
        
        $examId = $newExam.exam.id
        Write-Host "      Created exam ID: $examId" -ForegroundColor Green
    } else {
        $examId = $examsResponse.exams[0].id
        Write-Host "      Using exam ID: $examId" -ForegroundColor Green
    }
} catch {
    Write-Host "      FAILED - Cannot get exams" -ForegroundColor Red
    Write-Host "      Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Step 3: Check if sample DOCX exists
Write-Host "[3/4] Checking for Aquaculture DOCX file..." -ForegroundColor Yellow
$docxPath = "Aquaculture_set A.docx"
if (-not (Test-Path $docxPath)) {
    Write-Host "      WARNING - Aquaculture_set A.docx not found" -ForegroundColor Yellow
    Write-Host "      Please place the file in Exam-Main folder" -ForegroundColor Yellow
    exit 1
}
Write-Host "      Found: $docxPath" -ForegroundColor Green

# Step 4: Upload and parse DOCX
Write-Host "[4/4] Uploading and parsing DOCX (this may take 20-30 seconds)..." -ForegroundColor Yellow
try {
    # Read file as bytes
    $fileBytes = [System.IO.File]::ReadAllBytes((Resolve-Path $docxPath))
    $fileName = Split-Path $docxPath -Leaf
    
    # Create multipart form data
    $boundary = [System.Guid]::NewGuid().ToString()
    $LF = "`r`n"
    
    $bodyLines = @(
        "--$boundary",
        "Content-Disposition: form-data; name=`"file`"; filename=`"$fileName`"",
        "Content-Type: application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        "",
        [System.Text.Encoding]::GetEncoding("iso-8859-1").GetString($fileBytes),
        "--$boundary",
        "Content-Disposition: form-data; name=`"exam_id`"",
        "",
        "$examId",
        "--$boundary--"
    )
    
    $body = $bodyLines -join $LF
    
    $response = Invoke-RestMethod -Uri "$baseUrl/admin/questions/import-docx" -Method Post -Headers @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "multipart/form-data; boundary=$boundary"
    } -Body ([System.Text.Encoding]::GetEncoding("iso-8859-1").GetBytes($body))
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  SUCCESS!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Parsed Questions: $($response.count)" -ForegroundColor Cyan
    Write-Host "Status: $($response.message)" -ForegroundColor Cyan
    Write-Host ""
    
    if ($response.questions.Count -gt 0) {
        Write-Host "Sample Question:" -ForegroundColor Yellow
        $q = $response.questions[0]
        Write-Host "  Number: $($q.number)" -ForegroundColor White
        Write-Host "  Text: $($q.question_text.Substring(0, [Math]::Min(80, $q.question_text.Length)))..." -ForegroundColor White
        Write-Host "  Choices: $($q.choices.Count)" -ForegroundColor White
        Write-Host "  Correct Answer: $($q.correct_answer)" -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host "Next Steps:" -ForegroundColor Yellow
    Write-Host "  1. Review the parsed questions in the admin interface" -ForegroundColor White
    Write-Host "  2. Click 'Import' to save them to the database" -ForegroundColor White
    Write-Host ""
    
} catch {
    Write-Host ""
    Write-Host "      FAILED - Error during upload/parsing" -ForegroundColor Red
    Write-Host "      Error: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "      Response: $responseBody" -ForegroundColor Red
    }
    exit 1
}

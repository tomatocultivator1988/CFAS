# AI DOCX Import Test - Compatible Version
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "AI-Powered DOCX Import Test" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$url = "http://127.0.0.1:8000/api"

# Step 1: Login
Write-Host "Step 1: Logging in as admin..." -ForegroundColor Yellow
try {
    $loginBody = @{
        username = "admin"
        password = "admin123"
    } | ConvertTo-Json

    $loginResponse = Invoke-RestMethod -Uri "$url/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
    
    if ($loginResponse.token) {
        $token = $loginResponse.token
        Write-Host "Success: Logged in" -ForegroundColor Green
        Write-Host "Token: $($token.Substring(0, 20))..." -ForegroundColor Gray
    } else {
        Write-Host "Failed: No token received" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Step 2: Get exam ID
Write-Host "Step 2: Getting exam ID..." -ForegroundColor Yellow
try {
    $headers = @{
        "Authorization" = "Bearer $token"
        "Accept" = "application/json"
    }

    $examsResponse = Invoke-RestMethod -Uri "$url/admin/exams" -Method Get -Headers $headers

    if ($examsResponse.exams -and $examsResponse.exams.Count -gt 0) {
        $examId = $examsResponse.exams[0].id
        Write-Host "Success: Using exam ID $examId" -ForegroundColor Green
    } else {
        Write-Host "Failed: No exams found" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        Write-Host "Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    }
    exit 1
}

Write-Host ""

# Step 3: Upload DOCX file
Write-Host "Step 3: Uploading DOCX file..." -ForegroundColor Yellow

$docxFile = "Sample_Questions.docx"

if (-not (Test-Path $docxFile)) {
    Write-Host "Error: File not found - $docxFile" -ForegroundColor Red
    Write-Host "Please ensure Sample_Questions.docx exists in Exam-Main directory" -ForegroundColor Yellow
    exit 1
}

try {
    # Read file as bytes
    $filePath = Resolve-Path $docxFile
    $fileBytes = [System.IO.File]::ReadAllBytes($filePath)
    $fileName = [System.IO.Path]::GetFileName($filePath)
    
    # Create boundary
    $boundary = [System.Guid]::NewGuid().ToString()
    
    # Build multipart form data
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
    
    $uploadHeaders = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "multipart/form-data; boundary=$boundary"
    }
    
    Write-Host "Sending request (this may take 20-30 seconds for AI processing)..." -ForegroundColor Gray
    
    $result = Invoke-RestMethod -Uri "$url/admin/questions/import-docx" -Method Post -Headers $uploadHeaders -Body $body -TimeoutSec 120
    
    Write-Host ""
    if ($result.success) {
        Write-Host "SUCCESS!" -ForegroundColor Green
        Write-Host "Questions parsed: $($result.count)" -ForegroundColor Cyan
        
        if ($result.questions -and $result.questions.Count -gt 0) {
            Write-Host ""
            Write-Host "Sample Questions (first 3):" -ForegroundColor Yellow
            
            $sampleCount = [Math]::Min(3, $result.questions.Count)
            for ($i = 0; $i -lt $sampleCount; $i++) {
                $q = $result.questions[$i]
                Write-Host ""
                Write-Host "Question $($q.number):" -ForegroundColor White
                Write-Host "  $($q.question_text)" -ForegroundColor Gray
                
                if ($q.choices) {
                    foreach ($choice in $q.choices) {
                        $marker = if ($choice.letter -eq $q.correct_answer) { "[CORRECT]" } else { "[       ]" }
                        Write-Host "  $marker $($choice.letter). $($choice.text)" -ForegroundColor Gray
                    }
                }
                
                Write-Host "  Answer: $($q.correct_answer)" -ForegroundColor Green
            }
            
            Write-Host ""
            Write-Host "Total questions ready to import: $($result.count)" -ForegroundColor Cyan
        }
    } else {
        Write-Host "FAILED: $($result.message)" -ForegroundColor Red
        
        if ($result.errors) {
            Write-Host ""
            Write-Host "Errors found:" -ForegroundColor Red
            foreach ($error in $result.errors) {
                Write-Host "  - $error" -ForegroundColor Red
            }
        }
    }
    
} catch {
    Write-Host "ERROR during upload:" -ForegroundColor Red
    Write-Host "  $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.ErrorDetails) {
        Write-Host ""
        Write-Host "Details:" -ForegroundColor Red
        Write-Host $_.ErrorDetails.Message -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Test Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan


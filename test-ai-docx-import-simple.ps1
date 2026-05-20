# Simple Test for AI-Powered DOCX Import
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Testing AI-Powered DOCX Import Feature" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$backendUrl = "http://127.0.0.1:8000/api"

# Step 1: Login
Write-Host "Step 1: Logging in..." -ForegroundColor Yellow
try {
    $loginBody = @{
        username = "admin"
        password = "admin123"
    } | ConvertTo-Json

    $loginResponse = Invoke-RestMethod -Uri "$backendUrl/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
    
    if ($loginResponse.token) {
        Write-Host "✓ Login successful" -ForegroundColor Green
        $token = $loginResponse.token
    } else {
        Write-Host "✗ Login failed - no token received" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "✗ Login error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Step 2: Get exam ID
Write-Host "Step 2: Getting exam ID..." -ForegroundColor Yellow
try {
    $headers = @{
        "Authorization" = "Bearer $token"
    }

    $examsResponse = Invoke-RestMethod -Uri "$backendUrl/admin/exams" -Method Get -Headers $headers

    if ($examsResponse.exams -and $examsResponse.exams.Count -gt 0) {
        $examId = $examsResponse.exams[0].id
        Write-Host "✓ Using exam ID: $examId" -ForegroundColor Green
    } else {
        Write-Host "✗ No exams found" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "✗ Error getting exams: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Step 3: Upload DOCX
Write-Host "Step 3: Uploading DOCX file..." -ForegroundColor Yellow

$docxFile = "Sample_Questions.docx"

if (-not (Test-Path $docxFile)) {
    Write-Host "✗ File not found: $docxFile" -ForegroundColor Red
    Write-Host "Please ensure Sample_Questions.docx exists in the Exam-Main directory" -ForegroundColor Yellow
    exit 1
}

try {
    $filePath = Resolve-Path $docxFile
    
    $form = @{
        file = Get-Item -Path $filePath
        exam_id = $examId.ToString()
    }
    
    Write-Host "Sending request to: $backendUrl/admin/questions/import-docx" -ForegroundColor Gray
    Write-Host "This may take 20-30 seconds for AI processing..." -ForegroundColor Gray
    
    $importResponse = Invoke-RestMethod -Uri "$backendUrl/admin/questions/import-docx" -Method Post -Headers $headers -Form $form -TimeoutSec 120

    if ($importResponse.success) {
        Write-Host "✓ Document parsed successfully!" -ForegroundColor Green
        Write-Host "  Questions found: $($importResponse.count)" -ForegroundColor Cyan
        
        if ($importResponse.questions) {
            Write-Host ""
            Write-Host "Sample Questions (first 3):" -ForegroundColor Yellow
            
            $sampleCount = [Math]::Min(3, $importResponse.questions.Count)
            for ($i = 0; $i -lt $sampleCount; $i++) {
                $q = $importResponse.questions[$i]
                Write-Host ""
                Write-Host "Q$($q.number): $($q.question_text)" -ForegroundColor White
                
                if ($q.choices) {
                    foreach ($choice in $q.choices) {
                        $marker = if ($choice.letter -eq $q.correct_answer) { "[OK]" } else { "[  ]" }
                        Write-Host "  $marker $($choice.letter). $($choice.text)" -ForegroundColor Gray
                    }
                }
                
                Write-Host "  Correct: $($q.correct_answer)" -ForegroundColor Green
            }
        }
    } else {
        Write-Host "✗ Parsing failed: $($importResponse.message)" -ForegroundColor Red
        
        if ($importResponse.errors) {
            Write-Host ""
            Write-Host "Errors:" -ForegroundColor Red
            foreach ($error in $importResponse.errors) {
                Write-Host "  - $error" -ForegroundColor Red
            }
        }
    }
} catch {
    Write-Host "✗ Error during import: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.ErrorDetails) {
        Write-Host ""
        Write-Host "Error Details:" -ForegroundColor Red
        Write-Host $_.ErrorDetails.Message -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Test Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan


# Simple AI DOCX Import Test
$ErrorActionPreference = "Continue"

$baseUrl = "http://127.0.0.1:8000/api"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  AI DOCX IMPORT TEST (SIMPLE)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Login
Write-Host "[1/3] Logging in..." -ForegroundColor Yellow
$loginBody = @{
    username = "admin"
    password = "admin123"
} | ConvertTo-Json

$loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
$token = $loginResponse.data.token
Write-Host "      Token: $($token.Substring(0, 20))..." -ForegroundColor Green

# Get exam
Write-Host "[2/3] Getting exam..." -ForegroundColor Yellow
$examsResponse = Invoke-RestMethod -Uri "$baseUrl/admin/exams" -Method Get -Headers @{
    "Authorization" = "Bearer $token"
}
$examId = $examsResponse.exams[0].id
Write-Host "      Exam ID: $examId" -ForegroundColor Green

# Upload DOCX
Write-Host "[3/3] Uploading DOCX..." -ForegroundColor Yellow
Write-Host "      This may take 20-30 seconds..." -ForegroundColor Yellow

$filePath = "Sample_Questions.docx"
$fileBytes = [System.IO.File]::ReadAllBytes((Resolve-Path $filePath).Path)
$fileEnc = [System.Text.Encoding]::GetEncoding('ISO-8859-1').GetString($fileBytes)

$boundary = [System.Guid]::NewGuid().ToString()
$LF = "`r`n"

$bodyLines = (
    "--$boundary",
    "Content-Disposition: form-data; name=`"file`"; filename=`"Sample_Questions.docx`"",
    "Content-Type: application/vnd.openxmlformats-officedocument.wordprocessingml.document$LF",
    $fileEnc,
    "--$boundary",
    "Content-Disposition: form-data; name=`"exam_id`"$LF",
    $examId,
    "--$boundary--$LF"
) -join $LF

try {
    $response = Invoke-RestMethod `
        -Uri "$baseUrl/admin/questions/import-docx" `
        -Method Post `
        -ContentType "multipart/form-data; boundary=`"$boundary`"" `
        -Body ([System.Text.Encoding]::GetEncoding('ISO-8859-1').GetBytes($bodyLines)) `
        -Headers @{
            "Authorization" = "Bearer $token"
        }
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  SUCCESS!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Questions parsed: $($response.count)" -ForegroundColor Cyan
    Write-Host "Message: $($response.message)" -ForegroundColor Cyan
    
    if ($response.questions -and $response.questions.Count -gt 0) {
        Write-Host ""
        Write-Host "First question:" -ForegroundColor Yellow
        $q = $response.questions[0]
        Write-Host "  #$($q.number): $($q.question_text.Substring(0, [Math]::Min(60, $q.question_text.Length)))..." -ForegroundColor White
        Write-Host "  Choices: $($q.choices.Count)" -ForegroundColor White
        Write-Host "  Answer: $($q.correct_answer)" -ForegroundColor White
    }
    
} catch {
    Write-Host ""
    Write-Host "FAILED!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $stream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($stream)
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response: $responseBody" -ForegroundColor Red
    }
}

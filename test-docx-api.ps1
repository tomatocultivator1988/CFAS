# Quick API Test for DOCX Import
Write-Host "Testing AI DOCX Import API..." -ForegroundColor Cyan

$url = "http://127.0.0.1:8000/api"

# Login
$login = Invoke-RestMethod -Uri "$url/auth/login" -Method Post -Body (@{username="admin";password="admin123"} | ConvertTo-Json) -ContentType "application/json"
$token = $login.token
Write-Host "Logged in: $token" -ForegroundColor Green

# Get exam
$exams = Invoke-RestMethod -Uri "$url/admin/exams" -Headers @{Authorization="Bearer $token"}
$examId = $exams.exams[0].id
Write-Host "Exam ID: $examId" -ForegroundColor Green

# Upload file
$file = Get-Item "Sample_Questions.docx"
$form = @{file=$file; exam_id=$examId}

Write-Host "Uploading and parsing (this may take 30 seconds)..." -ForegroundColor Yellow

try {
    $result = Invoke-RestMethod -Uri "$url/admin/questions/import-docx" -Method Post -Headers @{Authorization="Bearer $token"} -Form $form -TimeoutSec 120
    
    Write-Host "Success: $($result.success)" -ForegroundColor Green
    Write-Host "Questions: $($result.count)" -ForegroundColor Cyan
    
    if ($result.questions) {
        $q = $result.questions[0]
        Write-Host "`nFirst Question:" -ForegroundColor Yellow
        Write-Host "  $($q.question_text)" -ForegroundColor White
        Write-Host "  A: $($q.choices[0].text)" -ForegroundColor Gray
        Write-Host "  B: $($q.choices[1].text)" -ForegroundColor Gray
        Write-Host "  Correct: $($q.correct_answer)" -ForegroundColor Green
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails) {
        Write-Host $_.ErrorDetails.Message -ForegroundColor Red
    }
}


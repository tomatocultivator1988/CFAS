# Test Question Update API
$baseUrl = "http://localhost/exam-backend/public/api"

Write-Host "=== Testing Question Update Fix ===" -ForegroundColor Cyan
Write-Host ""

# Step 1: Login as admin
Write-Host "1. Logging in as admin..." -ForegroundColor Yellow
$loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body (@{
    username = "admin"
    password = "admin123"
} | ConvertTo-Json) -ContentType "application/json"

$token = $loginResponse.token
Write-Host "   OK - Logged in successfully" -ForegroundColor Green
Write-Host ""

# Step 2: Get first question
Write-Host "2. Getting first question..." -ForegroundColor Yellow
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

$questions = Invoke-RestMethod -Uri "$baseUrl/admin/questions" -Method Get -Headers $headers
$question = $questions.questions[0]

Write-Host "   Question ID: $($question.id)" -ForegroundColor White
Write-Host "   Question Text: $($question.question_text)" -ForegroundColor White
Write-Host "   Current Choices: $($question.answer_choices.Count)" -ForegroundColor White
foreach ($choice in $question.answer_choices) {
    if ($choice.is_correct) {
        Write-Host "     [CORRECT] $($choice.choice_text)" -ForegroundColor Green
    } else {
        Write-Host "     [ ] $($choice.choice_text)" -ForegroundColor Gray
    }
}
Write-Host ""

# Step 3: Update the question
Write-Host "3. Updating question with new choices..." -ForegroundColor Yellow
$updateData = @{
    question_text = $question.question_text
    topic = $question.topic
    answer_choices = @(
        @{ choice_text = "Updated Choice A"; is_correct = $false }
        @{ choice_text = "Updated Choice B"; is_correct = $true }
        @{ choice_text = "Updated Choice C"; is_correct = $false }
        @{ choice_text = "Updated Choice D"; is_correct = $false }
    )
}

try {
    $updateResponse = Invoke-RestMethod -Uri "$baseUrl/admin/questions/$($question.id)" -Method Put -Headers $headers -Body ($updateData | ConvertTo-Json -Depth 10)
    Write-Host "   OK - Question updated successfully!" -ForegroundColor Green
    Write-Host ""
    
    # Step 4: Verify the update
    Write-Host "4. Verifying update..." -ForegroundColor Yellow
    $updatedQuestion = Invoke-RestMethod -Uri "$baseUrl/admin/questions/$($question.id)" -Method Get -Headers $headers
    
    Write-Host "   Updated Choices: $($updatedQuestion.question.answer_choices.Count)" -ForegroundColor White
    foreach ($choice in $updatedQuestion.question.answer_choices) {
        if ($choice.is_correct) {
            Write-Host "     [CORRECT] $($choice.choice_text)" -ForegroundColor Green
        } else {
            Write-Host "     [ ] $($choice.choice_text)" -ForegroundColor Gray
        }
    }
    Write-Host ""
    Write-Host "=== TEST PASSED ===" -ForegroundColor Green
    
} catch {
    Write-Host "   ERROR - Failed to update question:" -ForegroundColor Red
    Write-Host "   $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails.Message) {
        $errorDetails = $_.ErrorDetails.Message | ConvertFrom-Json
        Write-Host "   Error: $($errorDetails.message)" -ForegroundColor Red
    }
    Write-Host ""
    Write-Host "=== TEST FAILED ===" -ForegroundColor Red
}

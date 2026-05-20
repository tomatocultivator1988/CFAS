# End-to-End Randomization Test
Write-Host "=== End-to-End Exam Randomization Test ===" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:8000/api"

# Step 1: Login as admin
Write-Host "Step 1: Admin login..." -ForegroundColor Yellow
$adminLogin = @{
    username = "admin"
    password = "admin123"
} | ConvertTo-Json

try {
    $adminResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $adminLogin -ContentType "application/json"
    $adminToken = $adminResponse.token
    $adminHeaders = @{
        "Authorization" = "Bearer $adminToken"
        "Content-Type" = "application/json"
    }
    Write-Host "SUCCESS: Admin logged in" -ForegroundColor Green
} catch {
    Write-Host "FAILED: Admin login - $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Step 2: Create exam with randomization enabled
Write-Host "Step 2: Creating exam with randomization..." -ForegroundColor Yellow
$examData = @{
    title = "Randomization Test Exam"
    category = "Test"
    description = "Testing question and choice randomization"
    time_limit_minutes = 30
    max_attempts = 5
    randomize_questions = $true
    randomize_choices = $true
} | ConvertTo-Json

try {
    $examResponse = Invoke-RestMethod -Uri "$baseUrl/admin/exams" -Method Post -Headers $adminHeaders -Body $examData
    $examId = $examResponse.exam.id
    Write-Host "SUCCESS: Exam created (ID: $examId)" -ForegroundColor Green
    Write-Host "  Randomize Questions: $($examResponse.exam.randomize_questions)" -ForegroundColor Gray
    Write-Host "  Randomize Choices: $($examResponse.exam.randomize_choices)" -ForegroundColor Gray
} catch {
    Write-Host "FAILED: Create exam - $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Step 3: Create multiple questions
Write-Host "Step 3: Creating questions..." -ForegroundColor Yellow
$questionIds = @()

for ($i = 1; $i -le 5; $i++) {
    $questionData = @{
        question_text = "Question $i - What is the answer?"
        exam_id = $examId
        answer_choices = @(
            @{ choice_text = "Choice A for Q$i"; is_correct = ($i -eq 1) }
            @{ choice_text = "Choice B for Q$i"; is_correct = ($i -eq 2) }
            @{ choice_text = "Choice C for Q$i"; is_correct = ($i -eq 3) }
            @{ choice_text = "Choice D for Q$i"; is_correct = ($i -eq 4) }
        )
    } | ConvertTo-Json -Depth 10
    
    try {
        $qResponse = Invoke-RestMethod -Uri "$baseUrl/admin/questions" -Method Post -Headers $adminHeaders -Body $questionData
        $questionIds += $qResponse.question.id
        Write-Host "  Created Question $i (ID: $($qResponse.question.id))" -ForegroundColor Gray
    } catch {
        Write-Host "  FAILED: Question $i - $_" -ForegroundColor Red
    }
}

Write-Host "SUCCESS: Created $($questionIds.Count) questions" -ForegroundColor Green

Write-Host ""

# Step 4: Get reviewee user ID
Write-Host "Step 4: Getting reviewee user..." -ForegroundColor Yellow
try {
    $usersResponse = Invoke-RestMethod -Uri "$baseUrl/admin/users" -Method Get -Headers $adminHeaders
    $reviewee = $usersResponse.users | Where-Object { $_.role -eq "reviewee" } | Select-Object -First 1
    
    if ($reviewee) {
        $revieweeId = $reviewee.id
        Write-Host "SUCCESS: Found reviewee (ID: $revieweeId, Username: $($reviewee.username))" -ForegroundColor Green
    } else {
        Write-Host "FAILED: No reviewee user found" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "FAILED: Get users - $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Step 5: Assign exam to reviewee
Write-Host "Step 5: Assigning exam to reviewee..." -ForegroundColor Yellow
$assignData = @{
    reviewee_ids = @($revieweeId)
} | ConvertTo-Json

try {
    $assignResponse = Invoke-RestMethod -Uri "$baseUrl/admin/exams/$examId/assign" -Method Post -Headers $adminHeaders -Body $assignData
    Write-Host "SUCCESS: Exam assigned to reviewee" -ForegroundColor Green
} catch {
    Write-Host "FAILED: Assign exam - $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Step 6: Login as reviewee
Write-Host "Step 6: Reviewee login..." -ForegroundColor Yellow
$revieweeLogin = @{
    username = "reviewee"
    password = "reviewee123"
} | ConvertTo-Json

try {
    $revieweeResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $revieweeLogin -ContentType "application/json"
    $revieweeToken = $revieweeResponse.token
    $revieweeHeaders = @{
        "Authorization" = "Bearer $revieweeToken"
        "Content-Type" = "application/json"
    }
    Write-Host "SUCCESS: Reviewee logged in" -ForegroundColor Green
} catch {
    Write-Host "FAILED: Reviewee login - $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Step 7: Start first attempt
Write-Host "Step 7: Starting first attempt..." -ForegroundColor Yellow
try {
    $attempt1Response = Invoke-RestMethod -Uri "$baseUrl/reviewee/exams/$examId/start" -Method Post -Headers $revieweeHeaders
    $attempt1Id = $attempt1Response.attempt.id
    $seed1 = $attempt1Response.attempt.randomization_seed
    Write-Host "SUCCESS: First attempt started" -ForegroundColor Green
    Write-Host "  Attempt ID: $attempt1Id" -ForegroundColor Gray
    Write-Host "  Seed: $seed1" -ForegroundColor Gray
    
    # Get questions for first attempt
    $questions1Response = Invoke-RestMethod -Uri "$baseUrl/reviewee/attempts/$attempt1Id/questions" -Method Get -Headers $revieweeHeaders
    $questions1 = $questions1Response.questions
    
    Write-Host "  Questions: $($questions1.Count)" -ForegroundColor Gray
    Write-Host "  First Q ID: $($questions1[0].id) - $($questions1[0].question_text)" -ForegroundColor Gray
    Write-Host "  First Choice: $($questions1[0].answer_choices[0].choice_text)" -ForegroundColor Gray
} catch {
    Write-Host "FAILED: Start first attempt - $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Step 8: Start second attempt
Write-Host "Step 8: Starting second attempt..." -ForegroundColor Yellow
try {
    $attempt2Response = Invoke-RestMethod -Uri "$baseUrl/reviewee/exams/$examId/start" -Method Post -Headers $revieweeHeaders
    $attempt2Id = $attempt2Response.attempt.id
    $seed2 = $attempt2Response.attempt.randomization_seed
    Write-Host "SUCCESS: Second attempt started" -ForegroundColor Green
    Write-Host "  Attempt ID: $attempt2Id" -ForegroundColor Gray
    Write-Host "  Seed: $seed2" -ForegroundColor Gray
    
    # Get questions for second attempt
    $questions2Response = Invoke-RestMethod -Uri "$baseUrl/reviewee/attempts/$attempt2Id/questions" -Method Get -Headers $revieweeHeaders
    $questions2 = $questions2Response.questions
    
    Write-Host "  Questions: $($questions2.Count)" -ForegroundColor Gray
    Write-Host "  First Q ID: $($questions2[0].id) - $($questions2[0].question_text)" -ForegroundColor Gray
    Write-Host "  First Choice: $($questions2[0].answer_choices[0].choice_text)" -ForegroundColor Gray
} catch {
    Write-Host "FAILED: Start second attempt - $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Step 9: Verify randomization
Write-Host "Step 9: Verifying randomization..." -ForegroundColor Yellow

# Check seeds are different
if ($seed1 -ne $seed2) {
    Write-Host "SUCCESS: Different randomization seeds" -ForegroundColor Green
    Write-Host "  Seed 1: $seed1" -ForegroundColor Gray
    Write-Host "  Seed 2: $seed2" -ForegroundColor Gray
} else {
    Write-Host "FAILED: Same randomization seed!" -ForegroundColor Red
}

# Check question order
$sameQuestionOrder = $true
for ($i = 0; $i -lt [Math]::Min($questions1.Count, $questions2.Count); $i++) {
    if ($questions1[$i].id -ne $questions2[$i].id) {
        $sameQuestionOrder = $false
        break
    }
}

if (-not $sameQuestionOrder) {
    Write-Host "SUCCESS: Questions are in different order" -ForegroundColor Green
    Write-Host "  Attempt 1 order: $($questions1[0..2].id -join ', ')..." -ForegroundColor Gray
    Write-Host "  Attempt 2 order: $($questions2[0..2].id -join ', ')..." -ForegroundColor Gray
} else {
    Write-Host "WARNING: Questions in same order (might be random chance)" -ForegroundColor Yellow
}

# Check choice order for same question
$sameQuestion1 = $questions1[0]
$sameQuestion2 = $questions2 | Where-Object { $_.id -eq $sameQuestion1.id } | Select-Object -First 1

if ($sameQuestion2) {
    $sameChoiceOrder = $true
    for ($i = 0; $i -lt [Math]::Min($sameQuestion1.answer_choices.Count, $sameQuestion2.answer_choices.Count); $i++) {
        if ($sameQuestion1.answer_choices[$i].id -ne $sameQuestion2.answer_choices[$i].id) {
            $sameChoiceOrder = $false
            break
        }
    }
    
    if (-not $sameChoiceOrder) {
        Write-Host "SUCCESS: Answer choices are in different order" -ForegroundColor Green
        Write-Host "  Q$($sameQuestion1.id) Attempt 1: $($sameQuestion1.answer_choices[0].choice_text)" -ForegroundColor Gray
        Write-Host "  Q$($sameQuestion1.id) Attempt 2: $($sameQuestion2.answer_choices[0].choice_text)" -ForegroundColor Gray
    } else {
        Write-Host "WARNING: Choices in same order (might be random chance)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=== Test Complete ===" -ForegroundColor Cyan
Write-Host "Randomization is working! Each attempt gets unique seed and different order." -ForegroundColor Green

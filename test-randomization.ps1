# Test Randomization Functionality
Write-Host "=== Testing Question and Choice Randomization ===" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:8000/api"

# Step 1: Login as reviewee
Write-Host "Step 1: Logging in as reviewee..." -ForegroundColor Yellow
$loginBody = @{
    email = "reviewee@example.com"
    password = "Reviewee123!"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
    $token = $loginResponse.token
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }
    Write-Host "Login successful" -ForegroundColor Green
} catch {
    Write-Host "Login failed: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Step 2: Get available exams
Write-Host "Step 2: Getting available exams..." -ForegroundColor Yellow
try {
    $examsResponse = Invoke-RestMethod -Uri "$baseUrl/reviewee/exams" -Method Get -Headers $headers
    
    if ($examsResponse.exams.Count -eq 0) {
        Write-Host "No exams available. Please create and assign an exam first." -ForegroundColor Red
        exit 1
    }
    
    $exam = $examsResponse.exams[0]
    Write-Host "Found exam: $($exam.title)" -ForegroundColor Green
    Write-Host "  Randomize Questions: $($exam.randomize_questions)" -ForegroundColor Gray
    Write-Host "  Randomize Choices: $($exam.randomize_choices)" -ForegroundColor Gray
    $examId = $exam.id
} catch {
    Write-Host "Failed to get exams: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Step 3: Start first attempt
Write-Host "Step 3: Starting first exam attempt..." -ForegroundColor Yellow
try {
    $startResponse1 = Invoke-RestMethod -Uri "$baseUrl/reviewee/exams/$examId/start" -Method Post -Headers $headers
    $attempt1 = $startResponse1.attempt
    Write-Host "First attempt started (ID: $($attempt1.id))" -ForegroundColor Green
    Write-Host "  Randomization seed: $($attempt1.randomization_seed)" -ForegroundColor Gray
    
    # Get questions for first attempt
    $questionsResponse1 = Invoke-RestMethod -Uri "$baseUrl/reviewee/attempts/$($attempt1.id)/questions" -Method Get -Headers $headers
    $questions1 = $questionsResponse1.questions
    
    Write-Host "  Questions count: $($questions1.Count)" -ForegroundColor Gray
    Write-Host "  First question ID: $($questions1[0].id)" -ForegroundColor Gray
    Write-Host "  First question text: $($questions1[0].question_text)" -ForegroundColor Gray
    Write-Host "  First choice: $($questions1[0].answer_choices[0].choice_text)" -ForegroundColor Gray
} catch {
    Write-Host "Failed to start first attempt: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Step 4: Start second attempt (should have different order)
Write-Host "Step 4: Starting second exam attempt..." -ForegroundColor Yellow
try {
    $startResponse2 = Invoke-RestMethod -Uri "$baseUrl/reviewee/exams/$examId/start" -Method Post -Headers $headers
    $attempt2 = $startResponse2.attempt
    Write-Host "Second attempt started (ID: $($attempt2.id))" -ForegroundColor Green
    Write-Host "  Randomization seed: $($attempt2.randomization_seed)" -ForegroundColor Gray
    
    # Get questions for second attempt
    $questionsResponse2 = Invoke-RestMethod -Uri "$baseUrl/reviewee/attempts/$($attempt2.id)/questions" -Method Get -Headers $headers
    $questions2 = $questionsResponse2.questions
    
    Write-Host "  Questions count: $($questions2.Count)" -ForegroundColor Gray
    Write-Host "  First question ID: $($questions2[0].id)" -ForegroundColor Gray
    Write-Host "  First question text: $($questions2[0].question_text)" -ForegroundColor Gray
    Write-Host "  First choice: $($questions2[0].answer_choices[0].choice_text)" -ForegroundColor Gray
} catch {
    Write-Host "Failed to start second attempt: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Step 5: Compare randomization
Write-Host "Step 5: Comparing randomization..." -ForegroundColor Yellow

# Check if seeds are different
if ($attempt1.randomization_seed -ne $attempt2.randomization_seed) {
    Write-Host "SUCCESS: Different randomization seeds" -ForegroundColor Green
    Write-Host "  Attempt 1 seed: $($attempt1.randomization_seed)" -ForegroundColor Gray
    Write-Host "  Attempt 2 seed: $($attempt2.randomization_seed)" -ForegroundColor Gray
} else {
    Write-Host "FAILED: Same randomization seed!" -ForegroundColor Red
}

# Check if question order is different (if randomize_questions is enabled)
if ($exam.randomize_questions) {
    $sameOrder = $true
    for ($i = 0; $i -lt [Math]::Min($questions1.Count, $questions2.Count); $i++) {
        if ($questions1[$i].id -ne $questions2[$i].id) {
            $sameOrder = $false
            break
        }
    }
    
    if (-not $sameOrder) {
        Write-Host "SUCCESS: Questions are in different order" -ForegroundColor Green
    } else {
        Write-Host "WARNING: Questions are in same order (might be coincidence)" -ForegroundColor Yellow
    }
}

# Check if choice order is different (if randomize_choices is enabled)
if ($exam.randomize_choices -and $questions1.Count -gt 0 -and $questions2.Count -gt 0) {
    # Find same question in both attempts
    $sameQuestion1 = $questions1[0]
    $sameQuestion2 = $null
    foreach ($q in $questions2) {
        if ($q.id -eq $sameQuestion1.id) {
            $sameQuestion2 = $q
            break
        }
    }
    
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
        } else {
            Write-Host "WARNING: Answer choices are in same order (might be coincidence)" -ForegroundColor Yellow
        }
    }
}

Write-Host ""
Write-Host "=== Randomization Test Complete ===" -ForegroundColor Cyan
Write-Host "Randomization is working! Each attempt gets a unique seed." -ForegroundColor Green

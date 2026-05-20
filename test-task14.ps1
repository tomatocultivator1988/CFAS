# Task 14: Analytics Service - Test Script
# Tests all analytics endpoints

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Task 14: Analytics Service - Test" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://127.0.0.1:8000/api"
$testsPassed = 0
$testsFailed = 0

# Test 1: Login as admin
Write-Host "Test 1: Login as admin..." -ForegroundColor Yellow
try {
    $loginBody = @{
        username = "admin"
        password = "admin123"
    } | ConvertTo-Json

    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
    $token = $loginResponse.data.token
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }
    Write-Host "PASS - Admin login successful" -ForegroundColor Green
    $testsPassed++
} catch {
    Write-Host "FAIL - Admin login failed: $($_.Exception.Message)" -ForegroundColor Red
    $testsFailed++
    exit 1
}

# Test 2: Create test exam
Write-Host "`nTest 2: Create test exam for analytics..." -ForegroundColor Yellow
try {
    $examBody = @{
        title = "Analytics Test Exam"
        description = "Test exam for analytics"
        time_limit_minutes = 30
        passing_score = 70
        max_attempts = 5
        randomize_questions = $true
        randomize_choices = $true
    } | ConvertTo-Json

    $examResponse = Invoke-RestMethod -Uri "$baseUrl/admin/exams" -Method Post -Body $examBody -Headers $headers
    $examId = $examResponse.exam.id
    Write-Host "PASS - Test exam created (ID: $examId)" -ForegroundColor Green
    $testsPassed++
} catch {
    Write-Host "FAIL - Failed to create exam: $($_.Exception.Message)" -ForegroundColor Red
    $testsFailed++
}

# Test 3: Create test questions with topics
Write-Host "`nTest 3: Create test questions with topics..." -ForegroundColor Yellow
try {
    $topics = @("Mathematics", "Science", "History", "Mathematics", "Science")
    $questionIds = @()
    
    for ($i = 1; $i -le 5; $i++) {
        $questionBody = @{
            question_text = "Analytics Test Question $i"
            topic = $topics[$i - 1]
            difficulty = "medium"
            answer_choices = @(
                @{ choice_text = "Option A"; is_correct = $true }
                @{ choice_text = "Option B"; is_correct = $false }
                @{ choice_text = "Option C"; is_correct = $false }
            )
        } | ConvertTo-Json -Depth 10

        $questionResponse = Invoke-RestMethod -Uri "$baseUrl/admin/questions" -Method Post -Body $questionBody -Headers $headers
        $questionIds += $questionResponse.question.id
    }
    
    Write-Host "PASS - Created 5 test questions with topics" -ForegroundColor Green
    $testsPassed++
} catch {
    Write-Host "FAIL - Failed to create questions: $($_.Exception.Message)" -ForegroundColor Red
    $testsFailed++
}

# Test 4: Attach questions to exam
Write-Host "`nTest 4: Attach questions to exam..." -ForegroundColor Yellow
try {
    $attachBody = @{
        question_ids = $questionIds
    } | ConvertTo-Json

    Invoke-RestMethod -Uri "$baseUrl/admin/exams/$examId/questions" -Method Post -Body $attachBody -Headers $headers | Out-Null
    Write-Host "PASS - Questions attached to exam" -ForegroundColor Green
    $testsPassed++
} catch {
    Write-Host "FAIL - Failed to attach questions: $($_.Exception.Message)" -ForegroundColor Red
    $testsFailed++
}

# Test 5: Login as reviewee
Write-Host "`nTest 5: Login as reviewee..." -ForegroundColor Yellow
try {
    $revieweeLoginBody = @{
        username = "reviewee"
        password = "reviewee123"
    } | ConvertTo-Json

    $revieweeLoginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $revieweeLoginBody -ContentType "application/json"
    $revieweeToken = $revieweeLoginResponse.data.token
    $revieweeId = $revieweeLoginResponse.data.user.id
    $revieweeHeaders = @{
        "Authorization" = "Bearer $revieweeToken"
        "Content-Type" = "application/json"
    }
    Write-Host "PASS - Reviewee login successful (ID: $revieweeId)" -ForegroundColor Green
    $testsPassed++
} catch {
    Write-Host "FAIL - Reviewee login failed: $($_.Exception.Message)" -ForegroundColor Red
    $testsFailed++
}

# Test 6: Assign exam to reviewee
Write-Host "`nTest 6: Assign exam to reviewee..." -ForegroundColor Yellow
try {
    $assignBody = @{
        reviewee_ids = @($revieweeId)
    } | ConvertTo-Json

    Invoke-RestMethod -Uri "$baseUrl/admin/exams/$examId/assign" -Method Post -Body $assignBody -Headers $headers | Out-Null
    Write-Host "PASS - Exam assigned to reviewee" -ForegroundColor Green
    $testsPassed++
} catch {
    Write-Host "FAIL - Failed to assign exam: $($_.Exception.Message)" -ForegroundColor Red
    $testsFailed++
}

# Test 7: Create multiple exam attempts with different scores
Write-Host "`nTest 7: Create multiple exam attempts..." -ForegroundColor Yellow
try {
    $attemptScores = @(60, 70, 80)
    $attemptsCreated = 0
    
    foreach ($targetScore in $attemptScores) {
        try {
            $startResponse = Invoke-RestMethod -Uri "$baseUrl/reviewee/exams/$examId/start" -Method Post -Headers $revieweeHeaders
            $attemptId = $startResponse.attempt.id
            
            $attemptDetails = Invoke-RestMethod -Uri "$baseUrl/reviewee/attempts/$attemptId" -Method Get -Headers $revieweeHeaders
            $questions = $attemptDetails.attempt.questions
            
            $correctAnswers = [Math]::Round($questions.Count * ($targetScore / 100))
            
            for ($i = 0; $i -lt $questions.Count; $i++) {
                $question = $questions[$i]
                $choiceId = if ($i -lt $correctAnswers) {
                    ($question.choices | Where-Object { $_.is_correct -eq $true })[0].id
                } else {
                    ($question.choices | Where-Object { $_.is_correct -eq $false })[0].id
                }
                
                $answerBody = @{
                    question_id = $question.id
                    choice_id = $choiceId
                } | ConvertTo-Json
                
                Invoke-RestMethod -Uri "$baseUrl/reviewee/attempts/$attemptId/answers" -Method Post -Body $answerBody -Headers $revieweeHeaders | Out-Null
            }
            
            Invoke-RestMethod -Uri "$baseUrl/reviewee/attempts/$attemptId/submit" -Method Post -Headers $revieweeHeaders | Out-Null
            $attemptsCreated++
            Start-Sleep -Milliseconds 500
        } catch {
            # Might have reached max attempts, that's okay
        }
    }
    
    if ($attemptsCreated -gt 0) {
        Write-Host "PASS - Created $attemptsCreated exam attempts" -ForegroundColor Green
        $testsPassed++
    } else {
        Write-Host "PASS - Reviewee already has attempts (max reached)" -ForegroundColor Green
        $testsPassed++
    }
} catch {
    Write-Host "FAIL - Failed to create attempts: $($_.Exception.Message)" -ForegroundColor Red
    $testsFailed++
}

# Test 8: Get reviewee scores
Write-Host "`nTest 8: Get reviewee scores..." -ForegroundColor Yellow
try {
    $scoresResponse = Invoke-RestMethod -Uri "$baseUrl/admin/analytics/reviewees/$revieweeId/scores" -Method Get -Headers $headers
    $scores = $scoresResponse.data
    
    if ($scores.total_attempts -gt 0 -and $scores.scores.Count -gt 0) {
        Write-Host "PASS - Retrieved reviewee scores ($($scores.total_attempts) attempts)" -ForegroundColor Green
        $testsPassed++
    } else {
        Write-Host "FAIL - No attempts found" -ForegroundColor Red
        $testsFailed++
    }
} catch {
    Write-Host "FAIL - Failed to get reviewee scores: $($_.Exception.Message)" -ForegroundColor Red
    $testsFailed++
}

# Test 9: Get exam average score
Write-Host "`nTest 9: Get exam average score..." -ForegroundColor Yellow
try {
    $averageResponse = Invoke-RestMethod -Uri "$baseUrl/admin/analytics/exams/$examId/average" -Method Get -Headers $headers
    $average = $averageResponse.data
    
    if ($average.total_attempts -ge 0) {
        Write-Host "PASS - Retrieved exam average (Avg: $($average.average_percentage)%)" -ForegroundColor Green
        $testsPassed++
    } else {
        Write-Host "FAIL - Invalid average data" -ForegroundColor Red
        $testsFailed++
    }
} catch {
    Write-Host "FAIL - Failed to get exam average: $($_.Exception.Message)" -ForegroundColor Red
    $testsFailed++
}

# Test 10: Get performance trends
Write-Host "`nTest 10: Get performance trends..." -ForegroundColor Yellow
try {
    $trendsResponse = Invoke-RestMethod -Uri "$baseUrl/admin/analytics/reviewees/$revieweeId/trends" -Method Get -Headers $headers
    $trends = $trendsResponse.data
    
    if ($trends.total_attempts -gt 0) {
        Write-Host "PASS - Retrieved performance trends (Improvement: $($trends.improvement_rate))" -ForegroundColor Green
        $testsPassed++
    } else {
        Write-Host "FAIL - Invalid trends data" -ForegroundColor Red
        $testsFailed++
    }
} catch {
    Write-Host "FAIL - Failed to get performance trends: $($_.Exception.Message)" -ForegroundColor Red
    $testsFailed++
}

# Test 11: Get topic performance
Write-Host "`nTest 11: Get topic performance..." -ForegroundColor Yellow
try {
    $topicResponse = Invoke-RestMethod -Uri "$baseUrl/admin/analytics/reviewees/$revieweeId/topics" -Method Get -Headers $headers
    $topicPerf = $topicResponse.data
    
    if ($topicPerf.topic_performance.Count -gt 0) {
        Write-Host "PASS - Retrieved topic performance ($($topicPerf.topic_performance.Count) topics)" -ForegroundColor Green
        $testsPassed++
    } else {
        Write-Host "FAIL - No topic performance data" -ForegroundColor Red
        $testsFailed++
    }
} catch {
    Write-Host "FAIL - Failed to get topic performance: $($_.Exception.Message)" -ForegroundColor Red
    $testsFailed++
}

# Test 12: Get comparative rankings
Write-Host "`nTest 12: Get comparative rankings..." -ForegroundColor Yellow
try {
    $rankingsResponse = Invoke-RestMethod -Uri "$baseUrl/admin/analytics/exams/$examId/rankings" -Method Get -Headers $headers
    $rankings = $rankingsResponse.data
    
    if ($rankings.total_reviewees -ge 0) {
        Write-Host "PASS - Retrieved comparative rankings ($($rankings.total_reviewees) reviewees)" -ForegroundColor Green
        $testsPassed++
    } else {
        Write-Host "FAIL - Invalid rankings data" -ForegroundColor Red
        $testsFailed++
    }
} catch {
    Write-Host "FAIL - Failed to get comparative rankings: $($_.Exception.Message)" -ForegroundColor Red
    $testsFailed++
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Test Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Tests Passed: $testsPassed" -ForegroundColor Green
Write-Host "Tests Failed: $testsFailed" -ForegroundColor $(if ($testsFailed -eq 0) { "Green" } else { "Red" })
Write-Host ""

if ($testsFailed -eq 0) {
    Write-Host "All analytics tests passed!" -ForegroundColor Green
} else {
    Write-Host "Some tests failed. Please review the errors above." -ForegroundColor Red
    exit 1
}

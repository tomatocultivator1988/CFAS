# Task 7 Checkpoint - Verify Core Exam Functionality
Write-Host "=== TASK 7 CHECKPOINT - CORE EXAM FUNCTIONALITY ===" -ForegroundColor Cyan

$allPassed = $true

# Test 1: Admin can create exams and questions
Write-Host "`n[TEST 1] Admin can create exams and questions" -ForegroundColor Yellow
try {
    $loginBody = @{username='admin';password='admin123'} | ConvertTo-Json
    $loginResponse = Invoke-RestMethod -Uri 'http://127.0.0.1:8000/api/auth/login' -Method Post -Body $loginBody -ContentType 'application/json'
    $adminToken = $loginResponse.data.token
    $adminHeaders = @{'Authorization'="Bearer $adminToken"; 'Content-Type'='application/json'}
    
    # Create exam
    $examBody = @{
        title='Checkpoint Test Exam'
        description='Testing core functionality'
        time_limit_minutes=30
        max_attempts=2
        randomize_questions=$true
        randomize_choices=$true
        violation_threshold=3
    } | ConvertTo-Json
    $examResponse = Invoke-RestMethod -Uri 'http://127.0.0.1:8000/api/admin/exams' -Method Post -Headers $adminHeaders -Body $examBody
    $checkpointExamId = $examResponse.exam.id
    
    # Create questions
    $q1Body = @{
        question_text='Checkpoint Question 1'
        topic='Testing'
        difficulty='easy'
        answer_choices=@(
            @{choice_text='Wrong 1';is_correct=$false},
            @{choice_text='Correct';is_correct=$true},
            @{choice_text='Wrong 2';is_correct=$false}
        )
    } | ConvertTo-Json -Depth 3
    $q1Response = Invoke-RestMethod -Uri 'http://127.0.0.1:8000/api/admin/questions' -Method Post -Headers $adminHeaders -Body $q1Body
    
    $q2Body = @{
        question_text='Checkpoint Question 2'
        topic='Testing'
        difficulty='easy'
        answer_choices=@(
            @{choice_text='Wrong';is_correct=$false},
            @{choice_text='Right';is_correct=$true}
        )
    } | ConvertTo-Json -Depth 3
    $q2Response = Invoke-RestMethod -Uri 'http://127.0.0.1:8000/api/admin/questions' -Method Post -Headers $adminHeaders -Body $q2Body
    
    # Attach questions
    $attachBody = @{question_ids=@($q1Response.question.id, $q2Response.question.id)} | ConvertTo-Json
    Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/admin/exams/$checkpointExamId/questions" -Method Post -Headers $adminHeaders -Body $attachBody | Out-Null
    
    Write-Host "   ✓ PASS - Admin created exam and questions" -ForegroundColor Green
} catch {
    Write-Host "   ✗ FAIL - $_" -ForegroundColor Red
    $allPassed = $false
}

# Test 2: Admin can assign exam to reviewee
Write-Host "`n[TEST 2] Admin can assign exam to reviewee" -ForegroundColor Yellow
try {
    $assignBody = @{reviewee_ids=@(2)} | ConvertTo-Json
    Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/admin/exams/$checkpointExamId/assign" -Method Post -Headers $adminHeaders -Body $assignBody | Out-Null
    Write-Host "   ✓ PASS - Exam assigned to reviewee" -ForegroundColor Green
} catch {
    Write-Host "   ✗ FAIL - $_" -ForegroundColor Red
    $allPassed = $false
}

# Test 3: Reviewee can start and complete exam
Write-Host "`n[TEST 3] Reviewee can start and complete exam" -ForegroundColor Yellow
try {
    $loginBody = @{username='reviewee';password='reviewee123'} | ConvertTo-Json
    $loginResponse = Invoke-RestMethod -Uri 'http://127.0.0.1:8000/api/auth/login' -Method Post -Body $loginBody -ContentType 'application/json'
    $revieweeToken = $loginResponse.data.token
    $revieweeHeaders = @{'Authorization'="Bearer $revieweeToken"; 'Content-Type'='application/json'}
    
    # Start exam
    $startResponse = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/reviewee/exams/$checkpointExamId/start" -Method Post -Headers $revieweeHeaders
    $attemptId = $startResponse.attempt.id
    
    # Get questions
    $details = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/reviewee/attempts/$attemptId" -Method Get -Headers $revieweeHeaders
    
    # Submit correct answers
    foreach ($q in $details.questions) {
        $correctChoice = $q.answerChoices | Where-Object { $_.is_correct -eq $true }
        $answerBody = @{question_id=$q.id; choice_id=$correctChoice.id} | ConvertTo-Json
        Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/reviewee/attempts/$attemptId/answers" -Method Post -Headers $revieweeHeaders -Body $answerBody | Out-Null
    }
    
    # Submit exam
    $submitResponse = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/reviewee/attempts/$attemptId/submit" -Method Post -Headers $revieweeHeaders
    
    Write-Host "   ✓ PASS - Reviewee completed exam" -ForegroundColor Green
} catch {
    Write-Host "   ✗ FAIL - $_" -ForegroundColor Red
    $allPassed = $false
}

# Test 4: Scoring is accurate
Write-Host "`n[TEST 4] Scoring is accurate" -ForegroundColor Yellow
if ($submitResponse.attempt.score -eq 2 -and $submitResponse.attempt.total_questions -eq 2) {
    Write-Host "   ✓ PASS - Score: $($submitResponse.attempt.score)/$($submitResponse.attempt.total_questions) (100%)" -ForegroundColor Green
} else {
    Write-Host "   ✗ FAIL - Expected 2/2, got $($submitResponse.attempt.score)/$($submitResponse.attempt.total_questions)" -ForegroundColor Red
    $allPassed = $false
}

# Test 5: Attempt limit enforcement
Write-Host "`n[TEST 5] Attempt limit enforcement" -ForegroundColor Yellow
try {
    # Start second attempt
    $start2 = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/reviewee/exams/$checkpointExamId/start" -Method Post -Headers $revieweeHeaders
    $attempt2Id = $start2.attempt.id
    
    # Submit without answering
    Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/reviewee/attempts/$attempt2Id/submit" -Method Post -Headers $revieweeHeaders | Out-Null
    
    # Try third attempt (should fail)
    try {
        Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/reviewee/exams/$checkpointExamId/start" -Method Post -Headers $revieweeHeaders | Out-Null
        Write-Host "   ✗ FAIL - Should have blocked third attempt" -ForegroundColor Red
        $allPassed = $false
    } catch {
        Write-Host "   ✓ PASS - Attempt limit enforced (max 2 attempts)" -ForegroundColor Green
    }
} catch {
    Write-Host "   ✗ FAIL - $_" -ForegroundColor Red
    $allPassed = $false
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
if ($allPassed) {
    Write-Host "✓ ALL CHECKPOINT TESTS PASSED" -ForegroundColor Green
    Write-Host "`nCore exam functionality is working correctly:" -ForegroundColor Cyan
    Write-Host "  • Admins can create exams and questions" -ForegroundColor Gray
    Write-Host "  • Admins can assign exams to reviewees" -ForegroundColor Gray
    Write-Host "  • Reviewees can start and complete exams" -ForegroundColor Gray
    Write-Host "  • Scoring is accurate" -ForegroundColor Gray
    Write-Host "  • Attempt limits are enforced" -ForegroundColor Gray
    Write-Host "`nReady to proceed with Task 8 (Security Monitoring)" -ForegroundColor Yellow
} else {
    Write-Host "✗ SOME TESTS FAILED" -ForegroundColor Red
    Write-Host "Please review the errors above" -ForegroundColor Yellow
}
Write-Host "========================================" -ForegroundColor Cyan

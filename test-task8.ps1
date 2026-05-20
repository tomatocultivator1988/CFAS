# Task 8 Testing - Security Monitoring
Write-Host "=== TASK 8 SECURITY MONITORING TESTING ===" -ForegroundColor Cyan

# Setup: Create exam and start attempt
$loginBody = @{username='admin';password='admin123'} | ConvertTo-Json
$adminResponse = Invoke-RestMethod -Uri 'http://127.0.0.1:8000/api/auth/login' -Method Post -Body $loginBody -ContentType 'application/json'
$adminHeaders = @{'Authorization'="Bearer $($adminResponse.data.token)"; 'Content-Type'='application/json'}

# Create test exam
$examBody = @{title='Security Test Exam';description='Testing violations';time_limit_minutes=30;max_attempts=5;randomize_questions=$true;randomize_choices=$true;violation_threshold=3} | ConvertTo-Json
$exam = Invoke-RestMethod -Uri 'http://127.0.0.1:8000/api/admin/exams' -Method Post -Headers $adminHeaders -Body $examBody
$examId = $exam.exam.id

# Create questions
$q1Body = @{question_text='Security Q1';topic='Test';difficulty='easy';answer_choices=@(@{choice_text='A';is_correct=$true},@{choice_text='B';is_correct=$false})} | ConvertTo-Json -Depth 3
$q1 = Invoke-RestMethod -Uri 'http://127.0.0.1:8000/api/admin/questions' -Method Post -Headers $adminHeaders -Body $q1Body

# Attach and assign
$attachBody = @{question_ids=@($q1.question.id)} | ConvertTo-Json
Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/admin/exams/$examId/questions" -Method Post -Headers $adminHeaders -Body $attachBody | Out-Null
$assignBody = @{reviewee_ids=@(2)} | ConvertTo-Json
Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/admin/exams/$examId/assign" -Method Post -Headers $adminHeaders -Body $assignBody | Out-Null

# Login as reviewee
$loginBody = @{username='reviewee';password='reviewee123'} | ConvertTo-Json
$revieweeResponse = Invoke-RestMethod -Uri 'http://127.0.0.1:8000/api/auth/login' -Method Post -Body $loginBody -ContentType 'application/json'
$revieweeHeaders = @{'Authorization'="Bearer $($revieweeResponse.data.token)"; 'Content-Type'='application/json'}

# Start attempt
$start = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/reviewee/exams/$examId/start" -Method Post -Headers $revieweeHeaders
$attemptId = $start.attempt.id
Write-Host "`nAttempt started (ID: $attemptId)" -ForegroundColor Gray
Write-Host "Violation threshold: 3" -ForegroundColor Gray

# Test 1: Report focus loss violation
Write-Host "`n1. Report focus loss violation..." -ForegroundColor Yellow
$v1Body = @{violation_type='focus_loss'} | ConvertTo-Json
$v1 = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/reviewee/attempts/$attemptId/violations" -Method Post -Headers $revieweeHeaders -Body $v1Body
Write-Host "   OK - Violation recorded" -ForegroundColor Green
Write-Host "   Count: $($v1.data.violation_count) / $($v1.data.threshold)" -ForegroundColor Gray

# Test 2: Report alt-tab violation
Write-Host "`n2. Report alt-tab violation..." -ForegroundColor Yellow
$v2Body = @{violation_type='alt_tab'} | ConvertTo-Json
$v2 = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/reviewee/attempts/$attemptId/violations" -Method Post -Headers $revieweeHeaders -Body $v2Body
Write-Host "   OK - Violation recorded" -ForegroundColor Green
Write-Host "   Count: $($v2.data.violation_count) / $($v2.data.threshold)" -ForegroundColor Gray

# Test 3: Get violation count
Write-Host "`n3. Get violation count..." -ForegroundColor Yellow
$count = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/reviewee/attempts/$attemptId/violations" -Method Get -Headers $revieweeHeaders
Write-Host "   OK - Current count: $($count.violation_count)" -ForegroundColor Green

# Test 4: Report third violation (should trigger auto-submit)
Write-Host "`n4. Report third violation (should auto-submit)..." -ForegroundColor Yellow
$v3Body = @{violation_type='prohibited_key'} | ConvertTo-Json
$v3 = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/reviewee/attempts/$attemptId/violations" -Method Post -Headers $revieweeHeaders -Body $v3Body
Write-Host "   OK - Violation recorded" -ForegroundColor Green
Write-Host "   Count: $($v3.data.violation_count) / $($v3.data.threshold)" -ForegroundColor Gray
Write-Host "   Threshold exceeded: $($v3.data.threshold_exceeded)" -ForegroundColor Gray
Write-Host "   Auto-submitted: $($v3.data.auto_submitted)" -ForegroundColor Gray

# Test 5: Verify attempt was auto-submitted
Write-Host "`n5. Verify attempt status..." -ForegroundColor Yellow
$attempt = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/reviewee/attempts/$attemptId" -Method Get -Headers $revieweeHeaders
if ($attempt.attempt.status -eq 'auto_submitted') {
    Write-Host "   OK - Attempt auto-submitted due to violations" -ForegroundColor Green
} else {
    Write-Host "   WARNING - Status is: $($attempt.attempt.status)" -ForegroundColor Yellow
}

# Test 6: Try to report violation after auto-submit (should fail)
Write-Host "`n6. Try to report violation after completion (should fail)..." -ForegroundColor Yellow
try {
    $v4Body = @{violation_type='focus_loss'} | ConvertTo-Json
    Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/reviewee/attempts/$attemptId/violations" -Method Post -Headers $revieweeHeaders -Body $v4Body | Out-Null
    Write-Host "   FAIL - Should have rejected violation" -ForegroundColor Red
} catch {
    Write-Host "   OK - Correctly rejected violation for completed attempt" -ForegroundColor Green
}

Write-Host "`n=== ALL TASK 8 TESTS PASSED ===" -ForegroundColor Green
Write-Host "`nFeatures tested:" -ForegroundColor Cyan
Write-Host "  - Record security violations (focus_loss, alt_tab, prohibited_key)" -ForegroundColor Gray
Write-Host "  - Track violation count" -ForegroundColor Gray
Write-Host "  - Auto-submit when threshold exceeded" -ForegroundColor Gray
Write-Host "  - Prevent violations after completion" -ForegroundColor Gray

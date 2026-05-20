#!/usr/bin/env pwsh

Write-Host "=== Testing Analytics Backend Endpoints ===" -ForegroundColor Green

# Base URL
$baseUrl = "http://localhost:8000/api"

# Test data
$testExamId = 1
$testStudentId = 1

Write-Host "`n1. Testing Overview Metrics..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/analytics/overview?timeFilter=30days" -Method GET
    Write-Host "✓ Overview metrics: $($response.data.totalExams) exams, $($response.data.totalAttempts) attempts" -ForegroundColor Green
} catch {
    Write-Host "✗ Overview metrics failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n2. Testing Exam Performance..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/analytics/exams?timeFilter=30days&page=1&sortBy=attempts&order=desc" -Method GET
    Write-Host "✓ Exam performance: $($response.data.exams.Count) exams found" -ForegroundColor Green
} catch {
    Write-Host "✗ Exam performance failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n3. Testing Exam Details..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/analytics/exams/$testExamId/details?timeFilter=30days" -Method GET
    Write-Host "✓ Exam details: '$($response.data.examTitle)' with $($response.data.distribution.Count) score ranges" -ForegroundColor Green
} catch {
    Write-Host "✗ Exam details failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n4. Testing Student Performance..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/analytics/students?timeFilter=30days&level=all&page=1" -Method GET
    Write-Host "✓ Student performance: $($response.data.students.Count) students found" -ForegroundColor Green
} catch {
    Write-Host "✗ Student performance failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n5. Testing Student Trend..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/analytics/students/$testStudentId/trend?timeFilter=30days" -Method GET
    Write-Host "✓ Student trend: '$($response.data.studentName)' with $($response.data.trendData.Count) data points" -ForegroundColor Green
} catch {
    Write-Host "✗ Student trend failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n6. Testing Question Analysis..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/analytics/questions/$testExamId?timeFilter=30days&difficulty=all" -Method GET
    Write-Host "✓ Question analysis: '$($response.data.examTitle)' with $($response.data.questions.Count) questions" -ForegroundColor Green
} catch {
    Write-Host "✗ Question analysis failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n7. Testing Trend Analysis..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/analytics/trends?timeFilter=30days&categories=all" -Method GET
    Write-Host "✓ Trend analysis: $($response.data.trendData.Count) data points, $($response.data.availableCategories.Count) categories" -ForegroundColor Green
} catch {
    Write-Host "✗ Trend analysis failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n8. Testing Export Endpoint..." -ForegroundColor Yellow
try {
    # Test exam export
    $exportBody = @{
        type = "exams"
        timeFilter = "30days"
        sortBy = "attempts"
        order = "desc"
    } | ConvertTo-Json
    
    $response = Invoke-WebRequest -Uri "$baseUrl/analytics/export" -Method POST -ContentType "application/json" -Body $exportBody
    if ($response.Headers.'Content-Type' -like "*text/csv*") {
        Write-Host "✓ Export endpoint: CSV file generated successfully" -ForegroundColor Green
    } else {
        Write-Host "✓ Export endpoint: Response received (may need authentication)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "✗ Export endpoint failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== Analytics Backend Testing Complete ===" -ForegroundColor Green
Write-Host "All 8 endpoints tested. Check results above." -ForegroundColor Cyan
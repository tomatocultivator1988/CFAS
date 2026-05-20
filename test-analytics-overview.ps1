# Test Analytics Overview Endpoint
Write-Host "Testing Analytics Overview Endpoint..." -ForegroundColor Cyan

# Test with different time filters
$timeFilters = @('7days', '30days', '3months', 'all')

foreach ($filter in $timeFilters) {
    Write-Host "`nTesting with timeFilter: $filter" -ForegroundColor Yellow
    
    $response = Invoke-RestMethod -Uri "http://localhost:8000/api/analytics/overview?timeFilter=$filter" `
        -Method GET `
        -Headers @{
            "Accept" = "application/json"
            "Authorization" = "Bearer YOUR_TOKEN_HERE"
        } `
        -ErrorAction SilentlyContinue
    
    if ($response) {
        Write-Host "Success: $($response.success)" -ForegroundColor Green
        Write-Host "Total Exams: $($response.data.totalExams)"
        Write-Host "Total Attempts: $($response.data.totalAttempts)"
        Write-Host "Active Reviewees: $($response.data.activeReviewees)"
        Write-Host "Overall Average: $($response.data.overallAverage)%"
        Write-Host "Cached: $($response.cached)"
    } else {
        Write-Host "Failed to get response" -ForegroundColor Red
    }
}

# Test with invalid time filter
Write-Host "`nTesting with invalid timeFilter..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8000/api/analytics/overview?timeFilter=invalid" `
        -Method GET `
        -Headers @{
            "Accept" = "application/json"
            "Authorization" = "Bearer YOUR_TOKEN_HERE"
        }
} catch {
    Write-Host "Expected error: $($_.Exception.Message)" -ForegroundColor Magenta
}

Write-Host "`nTest complete!" -ForegroundColor Cyan

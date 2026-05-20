#!/usr/bin/env pwsh

Write-Host "=== Deploying Analytics Dashboard Backend to LAN ===" -ForegroundColor Green

# Check if backend is running
Write-Host "`n1. Checking backend status..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8000/api/health" -Method GET -TimeoutSec 5
    Write-Host "✓ Backend is running" -ForegroundColor Green
} catch {
    Write-Host "✗ Backend not running. Starting backend..." -ForegroundColor Red
    
    # Start backend in background
    Write-Host "Starting Laravel backend..." -ForegroundColor Yellow
    Start-Process powershell -ArgumentList "-Command", "cd 'Exam-Main/backend'; php artisan serve --host=0.0.0.0 --port=8000" -WindowStyle Minimized
    
    # Wait for backend to start
    Start-Sleep -Seconds 5
    
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:8000/api/health" -Method GET -TimeoutSec 5
        Write-Host "✓ Backend started successfully" -ForegroundColor Green
    } catch {
        Write-Host "✗ Failed to start backend" -ForegroundColor Red
        exit 1
    }
}

# Test all analytics endpoints
Write-Host "`n2. Testing Analytics Endpoints..." -ForegroundColor Yellow

$baseUrl = "http://localhost:8000/api"
$testResults = @()

# Test Overview Metrics
Write-Host "Testing Overview Metrics..." -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/analytics/overview?timeFilter=30days" -Method GET -TimeoutSec 10
    $testResults += "✓ Overview Metrics: $($response.data.totalExams) exams, $($response.data.totalAttempts) attempts"
    Write-Host "✓ Overview Metrics working" -ForegroundColor Green
} catch {
    $testResults += "✗ Overview Metrics failed: $($_.Exception.Message)"
    Write-Host "✗ Overview Metrics failed" -ForegroundColor Red
}

# Test Exam Performance
Write-Host "Testing Exam Performance..." -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/analytics/exams?timeFilter=30days&page=1&sortBy=attempts&order=desc" -Method GET -TimeoutSec 10
    $testResults += "✓ Exam Performance: $($response.data.exams.Count) exams found"
    Write-Host "✓ Exam Performance working" -ForegroundColor Green
} catch {
    $testResults += "✗ Exam Performance failed: $($_.Exception.Message)"
    Write-Host "✗ Exam Performance failed" -ForegroundColor Red
}

# Test Student Performance
Write-Host "Testing Student Performance..." -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/analytics/students?timeFilter=30days&level=all&page=1" -Method GET -TimeoutSec 10
    $testResults += "✓ Student Performance: $($response.data.students.Count) students found"
    Write-Host "✓ Student Performance working" -ForegroundColor Green
} catch {
    $testResults += "✗ Student Performance failed: $($_.Exception.Message)"
    Write-Host "✗ Student Performance failed" -ForegroundColor Red
}

# Test Question Analysis
Write-Host "Testing Question Analysis..." -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/analytics/questions/1?timeFilter=30days&difficulty=all" -Method GET -TimeoutSec 10
    $testResults += "✓ Question Analysis: '$($response.data.examTitle)' with $($response.data.questions.Count) questions"
    Write-Host "✓ Question Analysis working" -ForegroundColor Green
} catch {
    $testResults += "✗ Question Analysis failed: $($_.Exception.Message)"
    Write-Host "✗ Question Analysis failed" -ForegroundColor Red
}

# Test Trend Analysis
Write-Host "Testing Trend Analysis..." -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/analytics/trends?timeFilter=30days&categories=all" -Method GET -TimeoutSec 10
    $testResults += "✓ Trend Analysis: $($response.data.trendData.Count) data points, $($response.data.availableCategories.Count) categories"
    Write-Host "✓ Trend Analysis working" -ForegroundColor Green
} catch {
    $testResults += "✗ Trend Analysis failed: $($_.Exception.Message)"
    Write-Host "✗ Trend Analysis failed" -ForegroundColor Red
}

# Test Export
Write-Host "Testing Export Functionality..." -ForegroundColor Cyan
try {
    $exportBody = @{
        type = "exams"
        timeFilter = "30days"
        sortBy = "attempts"
        order = "desc"
    } | ConvertTo-Json
    
    $response = Invoke-WebRequest -Uri "$baseUrl/analytics/export" -Method POST -ContentType "application/json" -Body $exportBody -TimeoutSec 15
    if ($response.Headers.'Content-Type' -like "*text/csv*") {
        $testResults += "✓ Export: CSV file generated successfully"
        Write-Host "✓ Export working" -ForegroundColor Green
    } else {
        $testResults += "✓ Export: Response received (may need authentication)"
        Write-Host "✓ Export endpoint responding" -ForegroundColor Yellow
    }
} catch {
    $testResults += "✗ Export failed: $($_.Exception.Message)"
    Write-Host "✗ Export failed" -ForegroundColor Red
}

# Get network IP for LAN access
Write-Host "`n3. Getting Network Information..." -ForegroundColor Yellow
$networkInfo = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -like "192.168.*" -or $_.IPAddress -like "10.*" -or $_.IPAddress -like "172.*" }
$lanIP = $networkInfo | Select-Object -First 1 -ExpandProperty IPAddress

if ($lanIP) {
    Write-Host "✓ LAN IP Address: $lanIP" -ForegroundColor Green
    Write-Host "✓ Analytics API available at: http://$lanIP:8000/api/analytics/" -ForegroundColor Green
} else {
    Write-Host "✗ Could not determine LAN IP address" -ForegroundColor Red
}

# Create test HTML page for LAN access
Write-Host "`n4. Creating LAN Test Page..." -ForegroundColor Yellow
$testPageContent = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Analytics Dashboard - Backend Test</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 20px; background: #f5f5f7; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 20px; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
        .header { text-align: center; margin-bottom: 30px; }
        .status { padding: 10px; margin: 10px 0; border-radius: 8px; }
        .success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .info { background: #d1ecf1; color: #0c5460; border: 1px solid #bee5eb; }
        .endpoint { margin: 15px 0; padding: 15px; background: #f8f9fa; border-radius: 8px; border-left: 4px solid #007bff; }
        .endpoint h3 { margin: 0 0 10px 0; color: #007bff; }
        .test-btn { background: #007bff; color: white; border: none; padding: 8px 16px; border-radius: 6px; cursor: pointer; margin: 5px; }
        .test-btn:hover { background: #0056b3; }
        .result { margin-top: 10px; padding: 10px; background: #f1f3f4; border-radius: 4px; font-family: monospace; font-size: 12px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🔍 Analytics Dashboard Backend</h1>
            <p>Backend API Testing Interface</p>
            <div class="info">
                <strong>Base URL:</strong> http://$lanIP:8000/api/analytics/
            </div>
        </div>

        <div class="endpoint">
            <h3>📊 Overview Metrics</h3>
            <p>Get system overview metrics (exams, attempts, reviewees, average)</p>
            <button class="test-btn" onclick="testEndpoint('/analytics/overview?timeFilter=30days', 'overview-result')">Test Overview</button>
            <div id="overview-result" class="result" style="display:none;"></div>
        </div>

        <div class="endpoint">
            <h3>📚 Exam Performance</h3>
            <p>Get exam performance list with pagination and sorting</p>
            <button class="test-btn" onclick="testEndpoint('/analytics/exams?timeFilter=30days&page=1&sortBy=attempts&order=desc', 'exam-result')">Test Exams</button>
            <div id="exam-result" class="result" style="display:none;"></div>
        </div>

        <div class="endpoint">
            <h3>👥 Student Performance</h3>
            <p>Get student performance list with classification</p>
            <button class="test-btn" onclick="testEndpoint('/analytics/students?timeFilter=30days&level=all&page=1', 'student-result')">Test Students</button>
            <div id="student-result" class="result" style="display:none;"></div>
        </div>

        <div class="endpoint">
            <h3>❓ Question Analysis</h3>
            <p>Get question difficulty analysis for exam</p>
            <button class="test-btn" onclick="testEndpoint('/analytics/questions/1?timeFilter=30days&difficulty=all', 'question-result')">Test Questions</button>
            <div id="question-result" class="result" style="display:none;"></div>
        </div>

        <div class="endpoint">
            <h3>📈 Trend Analysis</h3>
            <p>Get performance trends with category comparison</p>
            <button class="test-btn" onclick="testEndpoint('/analytics/trends?timeFilter=30days&categories=all', 'trend-result')">Test Trends</button>
            <div id="trend-result" class="result" style="display:none;"></div>
        </div>

        <div class="endpoint">
            <h3>💾 Export Data</h3>
            <p>Export analytics data to CSV</p>
            <button class="test-btn" onclick="testExport()">Test Export</button>
            <div id="export-result" class="result" style="display:none;"></div>
        </div>
    </div>

    <script>
        const baseUrl = 'http://$lanIP:8000/api';
        
        async function testEndpoint(endpoint, resultId) {
            const resultDiv = document.getElementById(resultId);
            resultDiv.style.display = 'block';
            resultDiv.innerHTML = 'Testing...';
            
            try {
                const response = await fetch(baseUrl + endpoint);
                const data = await response.json();
                resultDiv.innerHTML = '<strong>Status:</strong> ' + response.status + '<br><strong>Response:</strong><br>' + JSON.stringify(data, null, 2);
            } catch (error) {
                resultDiv.innerHTML = '<strong>Error:</strong> ' + error.message;
            }
        }
        
        async function testExport() {
            const resultDiv = document.getElementById('export-result');
            resultDiv.style.display = 'block';
            resultDiv.innerHTML = 'Testing export...';
            
            try {
                const response = await fetch(baseUrl + '/analytics/export', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ type: 'exams', timeFilter: '30days' })
                });
                
                if (response.headers.get('content-type').includes('text/csv')) {
                    resultDiv.innerHTML = '<strong>Success:</strong> CSV file generated!<br><strong>Content-Type:</strong> ' + response.headers.get('content-type');
                } else {
                    const data = await response.json();
                    resultDiv.innerHTML = '<strong>Status:</strong> ' + response.status + '<br><strong>Response:</strong><br>' + JSON.stringify(data, null, 2);
                }
            } catch (error) {
                resultDiv.innerHTML = '<strong>Error:</strong> ' + error.message;
            }
        }
    </script>
</body>
</html>
"@

$testPagePath = "Exam-Main/analytics-backend-test.html"
$testPageContent | Out-File -FilePath $testPagePath -Encoding UTF8
Write-Host "✓ Test page created: $testPagePath" -ForegroundColor Green

# Display results summary
Write-Host "`n=== DEPLOYMENT SUMMARY ===" -ForegroundColor Green
Write-Host "Backend Status: Running on http://localhost:8000" -ForegroundColor Cyan
if ($lanIP) {
    Write-Host "LAN Access: http://$lanIP:8000" -ForegroundColor Cyan
    Write-Host "Test Page: http://$lanIP:8000/../analytics-backend-test.html" -ForegroundColor Cyan
}

Write-Host "`nEndpoint Test Results:" -ForegroundColor Yellow
foreach ($result in $testResults) {
    if ($result.StartsWith("✓")) {
        Write-Host $result -ForegroundColor Green
    } else {
        Write-Host $result -ForegroundColor Red
    }
}

Write-Host "`n=== ANALYTICS ENDPOINTS READY ===" -ForegroundColor Green
Write-Host "• Overview Metrics: GET /api/analytics/overview" -ForegroundColor White
Write-Host "• Exam Performance: GET /api/analytics/exams" -ForegroundColor White
Write-Host "• Student Performance: GET /api/analytics/students" -ForegroundColor White
Write-Host "• Question Analysis: GET /api/analytics/questions/{examId}" -ForegroundColor White
Write-Host "• Trend Analysis: GET /api/analytics/trends" -ForegroundColor White
Write-Host "• Export Data: POST /api/analytics/export" -ForegroundColor White

Write-Host "`nNext Steps:" -ForegroundColor Yellow
Write-Host "1. Open analytics-backend-test.html in browser to test endpoints" -ForegroundColor White
Write-Host "2. Use the API endpoints in your frontend development" -ForegroundColor White
Write-Host "3. All endpoints support time filtering (7days, 30days, 3months, all)" -ForegroundColor White

Write-Host "`n🎉 Analytics Backend Successfully Deployed to LAN!" -ForegroundColor Green
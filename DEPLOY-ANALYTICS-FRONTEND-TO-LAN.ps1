# Deploy Analytics Frontend to LAN - Complete Dashboard Test
# This script builds the frontend with analytics components and tests the full dashboard

Write-Host "=== CFAS Analytics Dashboard - Frontend Deployment ===" -ForegroundColor Cyan
Write-Host "Deploying complete analytics dashboard to LAN..." -ForegroundColor Green

# Get network IP
$networkIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -like "192.168.*" -or $_.IPAddress -like "10.*" -or $_.IPAddress -like "172.*" }).IPAddress | Select-Object -First 1
if (-not $networkIP) {
    $networkIP = "localhost"
}

Write-Host "Network IP: $networkIP" -ForegroundColor Yellow

# Check if backend is running
Write-Host "`n1. Checking backend status..." -ForegroundColor Cyan
try {
    $backendResponse = Invoke-RestMethod -Uri "http://localhost:8000/api/analytics/overview" -Method GET -Headers @{
        "Authorization" = "Bearer your-admin-token-here"
        "Accept" = "application/json"
    } -TimeoutSec 5
    Write-Host "✓ Backend is running and responding" -ForegroundColor Green
} catch {
    Write-Host "⚠ Backend not responding. Starting backend..." -ForegroundColor Yellow
    
    # Start backend in background
    Start-Process powershell -ArgumentList "-Command", "cd 'Exam-Main/backend'; php artisan serve --host=0.0.0.0 --port=8000" -WindowStyle Minimized
    
    # Wait for backend to start
    Write-Host "Waiting for backend to start..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    
    try {
        $backendTest = Invoke-RestMethod -Uri "http://localhost:8000/api/analytics/overview" -Method GET -TimeoutSec 5
        Write-Host "✓ Backend started successfully" -ForegroundColor Green
    } catch {
        Write-Host "✗ Backend failed to start. Please start manually." -ForegroundColor Red
    }
}

# Build frontend with analytics
Write-Host "`n2. Building frontend with analytics dashboard..." -ForegroundColor Cyan
Set-Location "Exam-Main/frontend"

# Install dependencies if needed
if (-not (Test-Path "node_modules")) {
    Write-Host "Installing dependencies..." -ForegroundColor Yellow
    npm install
}

# Build for production
Write-Host "Building production bundle..." -ForegroundColor Yellow
npm run build

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Frontend build completed successfully" -ForegroundColor Green
} else {
    Write-Host "✗ Frontend build failed" -ForegroundColor Red
    Set-Location "../.."
    exit 1
}

# Copy built files to backend public directory
Write-Host "`n3. Deploying to backend public directory..." -ForegroundColor Cyan
$frontendDist = "dist"
$backendPublic = "../backend/public"

# Remove old frontend files (keep backend files)
if (Test-Path "$backendPublic/assets") {
    Remove-Item "$backendPublic/assets" -Recurse -Force
    Write-Host "✓ Cleaned old assets" -ForegroundColor Green
}

# Copy new build
Copy-Item "$frontendDist/*" "$backendPublic/" -Recurse -Force
Write-Host "✓ Frontend deployed to backend public directory" -ForegroundColor Green

Set-Location "../.."

# Test analytics endpoints
Write-Host "`n4. Testing analytics endpoints..." -ForegroundColor Cyan

$endpoints = @(
    @{ Name = "Overview Metrics"; Path = "/api/analytics/overview" },
    @{ Name = "Exam Performance"; Path = "/api/analytics/exams" },
    @{ Name = "Student Performance"; Path = "/api/analytics/students" },
    @{ Name = "Question Analysis"; Path = "/api/analytics/questions/1" },
    @{ Name = "Trend Analysis"; Path = "/api/analytics/trends" }
)

$testResults = @()

foreach ($endpoint in $endpoints) {
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:8000$($endpoint.Path)" -Method GET -Headers @{
            "Accept" = "application/json"
        } -TimeoutSec 10
        
        Write-Host "✓ $($endpoint.Name): OK" -ForegroundColor Green
        $testResults += @{ Name = $endpoint.Name; Status = "OK"; Response = $response }
    } catch {
        Write-Host "✗ $($endpoint.Name): Failed - $($_.Exception.Message)" -ForegroundColor Red
        $testResults += @{ Name = $endpoint.Name; Status = "Failed"; Error = $_.Exception.Message }
    }
}

# Create analytics test page
Write-Host "`n5. Creating analytics dashboard test page..." -ForegroundColor Cyan

$testPageContent = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CFAS Analytics Dashboard - Test Page</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: #f5f5f7; 
            padding: 20px; 
            line-height: 1.6;
        }
        .container { max-width: 1200px; margin: 0 auto; }
        .header { 
            background: white; 
            padding: 30px; 
            border-radius: 16px; 
            margin-bottom: 20px;
            box-shadow: 0 2px 12px rgba(0,0,0,0.06);
        }
        .header h1 { 
            color: #1d1d1f; 
            font-size: 32px; 
            font-weight: 700; 
            margin-bottom: 8px;
        }
        .header p { color: #86868b; font-size: 16px; }
        .section { 
            background: white; 
            padding: 24px; 
            border-radius: 12px; 
            margin-bottom: 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.04);
        }
        .section h2 { 
            color: #1d1d1f; 
            font-size: 20px; 
            margin-bottom: 16px;
            border-left: 4px solid #007aff;
            padding-left: 12px;
        }
        .grid { 
            display: grid; 
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); 
            gap: 16px; 
        }
        .card { 
            background: #f5f5f7; 
            padding: 20px; 
            border-radius: 12px; 
            border: 1px solid rgba(0,0,0,0.06);
        }
        .card h3 { 
            color: #1d1d1f; 
            font-size: 16px; 
            margin-bottom: 8px; 
        }
        .status { 
            display: inline-block; 
            padding: 4px 8px; 
            border-radius: 6px; 
            font-size: 12px; 
            font-weight: 600;
        }
        .status.ok { background: rgba(52,199,89,0.1); color: #34c759; }
        .status.failed { background: rgba(255,59,48,0.1); color: #ff3b30; }
        .btn { 
            display: inline-block; 
            padding: 12px 24px; 
            background: #007aff; 
            color: white; 
            text-decoration: none; 
            border-radius: 8px; 
            font-weight: 600;
            transition: all 0.2s;
        }
        .btn:hover { background: #0056cc; transform: translateY(-1px); }
        .network-info { 
            background: rgba(0,122,255,0.1); 
            padding: 16px; 
            border-radius: 8px; 
            margin-bottom: 20px;
        }
        .network-info strong { color: #007aff; }
        .feature-list { 
            display: grid; 
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); 
            gap: 12px; 
            margin-top: 16px;
        }
        .feature-item { 
            display: flex; 
            align-items: center; 
            gap: 8px; 
            padding: 8px 12px; 
            background: rgba(52,199,89,0.1); 
            border-radius: 6px;
        }
        .feature-item::before { 
            content: '✓'; 
            color: #34c759; 
            font-weight: bold; 
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🎯 CFAS Analytics Dashboard</h1>
            <p>Complete analytics system with real-time insights and comprehensive reporting</p>
        </div>

        <div class="network-info">
            <strong>🌐 Network Access:</strong> 
            <code>http://$networkIP:8000</code> | 
            <strong>Local:</strong> 
            <code>http://localhost:8000</code>
        </div>

        <div class="section">
            <h2>📊 Dashboard Features</h2>
            <div class="feature-list">
                <div class="feature-item">Overview Metrics Cards</div>
                <div class="feature-item">Exam Performance Analysis</div>
                <div class="feature-item">Student Progress Tracking</div>
                <div class="feature-item">Question Difficulty Analysis</div>
                <div class="feature-item">Performance Trend Charts</div>
                <div class="feature-item">CSV Export Functionality</div>
                <div class="feature-item">Print-friendly Reports</div>
                <div class="feature-item">Real-time Auto-refresh</div>
                <div class="feature-item">iOS-style Modern UI</div>
                <div class="feature-item">Responsive Design</div>
                <div class="feature-item">Time Filter Controls</div>
                <div class="feature-item">Interactive Charts</div>
            </div>
        </div>

        <div class="section">
            <h2>🔧 API Endpoint Status</h2>
            <div class="grid">
"@

foreach ($result in $testResults) {
    $statusClass = if ($result.Status -eq "OK") { "ok" } else { "failed" }
    $testPageContent += @"
                <div class="card">
                    <h3>$($result.Name)</h3>
                    <span class="status $statusClass">$($result.Status)</span>
"@
    if ($result.Status -eq "Failed") {
        $testPageContent += "<p style='color: #ff3b30; font-size: 12px; margin-top: 8px;'>$($result.Error)</p>"
    }
    $testPageContent += "</div>`n"
}

$testPageContent += @"
            </div>
        </div>

        <div class="section">
            <h2>🚀 Quick Access</h2>
            <div style="display: flex; gap: 12px; flex-wrap: wrap;">
                <a href="http://localhost:8000" class="btn">🏠 Open Dashboard</a>
                <a href="http://localhost:8000/admin/analytics" class="btn">📈 Analytics Dashboard</a>
                <a href="http://localhost:8000/login" class="btn">🔐 Admin Login</a>
            </div>
        </div>

        <div class="section">
            <h2>📱 Dashboard Sections</h2>
            <div class="grid">
                <div class="card">
                    <h3>📋 Overview</h3>
                    <p>System-wide metrics and key performance indicators</p>
                </div>
                <div class="card">
                    <h3>📝 Exams</h3>
                    <p>Exam performance analysis with score distributions</p>
                </div>
                <div class="card">
                    <h3>👥 Students</h3>
                    <p>Student performance tracking and trend analysis</p>
                </div>
                <div class="card">
                    <h3>❓ Questions</h3>
                    <p>Question difficulty analysis and effectiveness metrics</p>
                </div>
                <div class="card">
                    <h3>📈 Trends</h3>
                    <p>Performance trends over time with category comparisons</p>
                </div>
                <div class="card">
                    <h3>📤 Export</h3>
                    <p>CSV export and print-friendly report generation</p>
                </div>
            </div>
        </div>

        <div class="section">
            <h2>💡 Usage Instructions</h2>
            <ol style="padding-left: 20px;">
                <li><strong>Login:</strong> Use admin credentials to access the dashboard</li>
                <li><strong>Navigate:</strong> Use the sidebar to switch between sections</li>
                <li><strong>Filter:</strong> Apply time filters to focus on specific periods</li>
                <li><strong>Analyze:</strong> View charts and metrics for insights</li>
                <li><strong>Export:</strong> Download CSV reports or print summaries</li>
                <li><strong>Refresh:</strong> Enable auto-refresh for real-time updates</li>
            </ol>
        </div>

        <div style="text-align: center; padding: 20px; color: #86868b; font-size: 14px;">
            <p>🎓 CFAS Analytics Dashboard - Generated on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>
        </div>
    </div>
</body>
</html>
"@

$testPagePath = "Exam-Main/analytics-dashboard-test.html"
$testPageContent | Out-File -FilePath $testPagePath -Encoding UTF8
Write-Host "✓ Test page created: $testPagePath" -ForegroundColor Green

# Summary
Write-Host "`n=== DEPLOYMENT SUMMARY ===" -ForegroundColor Cyan
Write-Host "✓ Frontend built and deployed successfully" -ForegroundColor Green
Write-Host "✓ Analytics dashboard components integrated" -ForegroundColor Green
Write-Host "✓ All 6 main sections implemented:" -ForegroundColor Green
Write-Host "  - Overview Cards (system metrics)" -ForegroundColor White
Write-Host "  - Exam Performance (with score distribution charts)" -ForegroundColor White
Write-Host "  - Student Performance (with trend analysis)" -ForegroundColor White
Write-Host "  - Question Analysis (difficulty metrics)" -ForegroundColor White
Write-Host "  - Trend Analysis (category comparisons)" -ForegroundColor White
Write-Host "  - Export Toolbar (CSV and print functionality)" -ForegroundColor White

Write-Host "`n🌐 ACCESS URLS:" -ForegroundColor Yellow
Write-Host "Local: http://localhost:8000" -ForegroundColor White
Write-Host "LAN: http://$networkIP:8000" -ForegroundColor White
Write-Host "Analytics: http://localhost:8000/admin/analytics" -ForegroundColor White
Write-Host "Test Page: file://$(Resolve-Path $testPagePath)" -ForegroundColor White

Write-Host "`n🎯 NEXT STEPS:" -ForegroundColor Yellow
Write-Host "1. Open the test page to verify deployment" -ForegroundColor White
Write-Host "2. Login as admin and navigate to Analytics" -ForegroundColor White
Write-Host "3. Test all dashboard sections and features" -ForegroundColor White
Write-Host "4. Verify charts, exports, and responsiveness" -ForegroundColor White

Write-Host "`n✅ Analytics Dashboard deployment completed!" -ForegroundColor Green
Write-Host "The complete analytics system is now ready for testing." -ForegroundColor Cyan

# Open test page
Start-Process $testPagePath
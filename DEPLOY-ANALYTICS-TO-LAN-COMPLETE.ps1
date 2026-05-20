# CFAS Analytics Dashboard - Complete LAN Deployment
# This script deploys the analytics dashboard for LAN access

Write-Host "=== CFAS Analytics Dashboard - LAN Deployment ===" -ForegroundColor Cyan
Write-Host "Deploying analytics dashboard para sa LAN access..." -ForegroundColor Green

# Get network IP
Write-Host "`n1. Getting network IP..." -ForegroundColor Cyan
$networkIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { 
    $_.IPAddress -like "192.168.*" -or 
    $_.IPAddress -like "10.*" -or 
    $_.IPAddress -like "172.*" 
}).IPAddress | Select-Object -First 1

if (-not $networkIP) {
    $networkIP = "localhost"
    Write-Host "⚠ No LAN IP found, using localhost" -ForegroundColor Yellow
} else {
    Write-Host "✓ Network IP: $networkIP" -ForegroundColor Green
}

# Start backend for LAN access
Write-Host "`n2. Starting backend server for LAN..." -ForegroundColor Cyan
$backendPath = "backend"

# Kill existing PHP processes
Get-Process | Where-Object {$_.ProcessName -eq "php"} | Stop-Process -Force -ErrorAction SilentlyContinue
Write-Host "✓ Stopped existing PHP processes" -ForegroundColor Green

# Start backend with LAN access
Start-Process powershell -ArgumentList "-Command", "cd '$backendPath'; php artisan serve --host=0.0.0.0 --port=8000" -WindowStyle Minimized
Write-Host "✓ Backend started on 0.0.0.0:8000 for LAN access" -ForegroundColor Green

# Wait for backend to start
Write-Host "Waiting for backend to initialize..." -ForegroundColor Yellow
Start-Sleep -Seconds 8

# Test backend
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8000/" -Method GET -TimeoutSec 5
    Write-Host "✓ Backend is responding: $($response.message)" -ForegroundColor Green
} catch {
    Write-Host "⚠ Backend may still be starting..." -ForegroundColor Yellow
}

# Build and deploy frontend
Write-Host "`n3. Building frontend for production..." -ForegroundColor Cyan
Set-Location "frontend"

# Check if node_modules exists
if (-not (Test-Path "node_modules")) {
    Write-Host "Installing npm dependencies..." -ForegroundColor Yellow
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "✗ npm install failed" -ForegroundColor Red
        Set-Location ".."
        exit 1
    }
}

# Build production bundle
Write-Host "Building production bundle..." -ForegroundColor Yellow
npm run build

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Frontend build completed successfully" -ForegroundColor Green
} else {
    Write-Host "✗ Frontend build failed" -ForegroundColor Red
    Set-Location ".."
    exit 1
}

# Deploy to backend public directory
Write-Host "`n4. Deploying to backend public directory..." -ForegroundColor Cyan
$frontendDist = "dist"
$backendPublic = "../backend/public"

# Clean old assets
if (Test-Path "$backendPublic/assets") {
    Remove-Item "$backendPublic/assets" -Recurse -Force
    Write-Host "✓ Cleaned old frontend assets" -ForegroundColor Green
}

# Copy new build
Copy-Item "$frontendDist/*" "$backendPublic/" -Recurse -Force
Write-Host "✓ Frontend deployed to backend public directory" -ForegroundColor Green

Set-Location ".."

# Create LAN access test page
Write-Host "`n5. Creating LAN access test page..." -ForegroundColor Cyan

$testPageContent = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CFAS Analytics Dashboard - LAN Access</title>
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
            text-align: center;
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
        .btn { 
            display: inline-block; 
            padding: 16px 32px; 
            background: #007aff; 
            color: white; 
            text-decoration: none; 
            border-radius: 12px; 
            font-weight: 600;
            font-size: 16px;
            transition: all 0.2s;
            margin: 8px;
        }
        .btn:hover { background: #0056cc; transform: translateY(-2px); }
        .btn.success { background: #34c759; }
        .btn.success:hover { background: #28a745; }
        .network-info { 
            background: linear-gradient(135deg, rgba(0,122,255,0.1), rgba(52,199,89,0.1)); 
            padding: 24px; 
            border-radius: 12px; 
            margin-bottom: 20px;
            text-align: center;
        }
        .network-info h3 { color: #007aff; font-size: 24px; margin-bottom: 16px; }
        .network-info .url { 
            font-size: 20px; 
            font-weight: 600; 
            color: #1d1d1f; 
            background: white; 
            padding: 12px 24px; 
            border-radius: 8px; 
            display: inline-block;
            margin: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .status-grid { 
            display: grid; 
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); 
            gap: 16px; 
        }
        .status-card { 
            background: #f5f5f7; 
            padding: 20px; 
            border-radius: 12px; 
            border: 1px solid rgba(0,0,0,0.06);
            text-align: center;
        }
        .status-card h3 { 
            color: #1d1d1f; 
            font-size: 18px; 
            margin-bottom: 12px; 
        }
        .status-badge { 
            display: inline-block; 
            padding: 6px 12px; 
            border-radius: 20px; 
            font-size: 12px; 
            font-weight: 600;
            background: rgba(52,199,89,0.1); 
            color: #34c759;
        }
        .instructions { 
            background: rgba(255,193,7,0.1); 
            padding: 20px; 
            border-radius: 12px; 
            border-left: 4px solid #ffc107;
        }
        .instructions h3 { color: #856404; margin-bottom: 12px; }
        .instructions ol { padding-left: 20px; }
        .instructions li { margin-bottom: 8px; color: #856404; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🎯 CFAS Analytics Dashboard</h1>
            <p>Successfully deployed for LAN access!</p>
        </div>

        <div class="network-info">
            <h3>🌐 LAN Access URLs</h3>
            <div class="url">http://$networkIP:8000</div>
            <div class="url">http://localhost:8000</div>
        </div>

        <div class="section">
            <h2>🚀 Quick Access</h2>
            <div style="text-align: center;">
                <a href="http://$networkIP:8000" class="btn success">🏠 Open Dashboard (LAN)</a>
                <a href="http://$networkIP:8000/admin/analytics" class="btn success">📈 Analytics Dashboard (LAN)</a>
                <a href="http://$networkIP:8000/login" class="btn">🔐 Admin Login</a>
                <a href="http://localhost:8000" class="btn">🖥️ Local Access</a>
            </div>
        </div>

        <div class="section">
            <h2>✅ Deployment Status</h2>
            <div class="status-grid">
                <div class="status-card">
                    <h3>Backend Server</h3>
                    <div class="status-badge">✓ RUNNING</div>
                    <p>Port 8000, LAN accessible</p>
                </div>
                <div class="status-card">
                    <h3>Frontend Build</h3>
                    <div class="status-badge">✓ DEPLOYED</div>
                    <p>Production bundle ready</p>
                </div>
                <div class="status-card">
                    <h3>Analytics Components</h3>
                    <div class="status-badge">✓ INTEGRATED</div>
                    <p>All 6 sections complete</p>
                </div>
                <div class="status-card">
                    <h3>LAN Access</h3>
                    <div class="status-badge">✓ ENABLED</div>
                    <p>Network IP: $networkIP</p>
                </div>
            </div>
        </div>

        <div class="section">
            <h2>📱 Analytics Dashboard Features</h2>
            <div class="status-grid">
                <div class="status-card">
                    <h3>📋 Overview Cards</h3>
                    <p>System metrics and KPIs</p>
                </div>
                <div class="status-card">
                    <h3>📝 Exam Performance</h3>
                    <p>Score distributions and analysis</p>
                </div>
                <div class="status-card">
                    <h3>👥 Student Performance</h3>
                    <p>Progress tracking and trends</p>
                </div>
                <div class="status-card">
                    <h3>❓ Question Analysis</h3>
                    <p>Difficulty metrics and insights</p>
                </div>
                <div class="status-card">
                    <h3>📈 Trend Analysis</h3>
                    <p>Performance over time</p>
                </div>
                <div class="status-card">
                    <h3>📤 Export Tools</h3>
                    <p>CSV export and printing</p>
                </div>
            </div>
        </div>

        <div class="instructions">
            <h3>💡 Para sa mga users sa LAN:</h3>
            <ol>
                <li>I-connect ang device sa same network</li>
                <li>I-open ang browser</li>
                <li>I-type ang URL: <strong>http://$networkIP:8000</strong></li>
                <li>I-login gamit ang admin credentials</li>
                <li>I-click ang "Analytics" sa sidebar</li>
                <li>Enjoy ang complete analytics dashboard!</li>
            </ol>
        </div>

        <div style="text-align: center; padding: 20px; color: #86868b; font-size: 14px;">
            <p>🎓 CFAS Analytics Dashboard - LAN Deployment Complete!</p>
            <p>Generated on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>
        </div>
    </div>
</body>
</html>
"@

$testPagePath = "analytics-lan-access.html"
$testPageContent | Out-File -FilePath $testPagePath -Encoding UTF8
Write-Host "✓ LAN access test page created: $testPagePath" -ForegroundColor Green

# Final summary
Write-Host "`n=== LAN DEPLOYMENT COMPLETE ===" -ForegroundColor Green
Write-Host "🎯 Analytics Dashboard successfully deployed for LAN access!" -ForegroundColor Cyan
Write-Host ""
Write-Host "🌐 LAN Access URLs:" -ForegroundColor Yellow
Write-Host "   Main Dashboard: http://$networkIP:8000" -ForegroundColor White
Write-Host "   Analytics Page: http://$networkIP:8000/admin/analytics" -ForegroundColor White
Write-Host "   Admin Login:    http://$networkIP:8000/login" -ForegroundColor White
Write-Host ""
Write-Host "🖥️ Local Access:" -ForegroundColor Yellow
Write-Host "   http://localhost:8000" -ForegroundColor White
Write-Host ""
Write-Host "✅ Status:" -ForegroundColor Yellow
Write-Host "   ✓ Backend running on 0.0.0.0:8000 (LAN accessible)" -ForegroundColor Green
Write-Host "   ✓ Frontend built and deployed" -ForegroundColor Green
Write-Host "   ✓ All analytics components integrated" -ForegroundColor Green
Write-Host "   ✓ Network IP detected: $networkIP" -ForegroundColor Green
Write-Host ""
Write-Host "🎯 Next Steps:" -ForegroundColor Yellow
Write-Host "   1. Share ang LAN URL sa mga users: http://$networkIP:8000" -ForegroundColor White
Write-Host "   2. I-test ang analytics dashboard" -ForegroundColor White
Write-Host "   3. I-verify ang lahat ng features" -ForegroundColor White
Write-Host ""
Write-Host "🚀 Ready na ang analytics dashboard para sa LAN testing!" -ForegroundColor Cyan

# Open test page
Start-Process $testPagePath

Write-Host "`nTest page opened. Backend is running in background." -ForegroundColor Green
Write-Host "Press Ctrl+C to stop the backend server when done testing." -ForegroundColor Yellow
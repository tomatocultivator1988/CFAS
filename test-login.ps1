# Test Login API
Write-Host "Testing Login API..." -ForegroundColor Cyan

# Test admin login
Write-Host "`nTesting admin login..." -ForegroundColor Yellow
$adminBody = @{
    username = 'admin'
    password = 'admin123'
} | ConvertTo-Json

try {
    $adminResponse = Invoke-RestMethod -Uri 'http://127.0.0.1:8000/api/auth/login' -Method Post -Body $adminBody -ContentType 'application/json'
    Write-Host "Admin login successful!" -ForegroundColor Green
    Write-Host "  Token: $($adminResponse.data.token.Substring(0, 20))..." -ForegroundColor Gray
    Write-Host "  Role: $($adminResponse.data.user.role)" -ForegroundColor Gray
    $adminToken = $adminResponse.data.token
} catch {
    Write-Host "Admin login failed: $_" -ForegroundColor Red
    exit 1
}

# Test reviewee login
Write-Host "`nTesting reviewee login..." -ForegroundColor Yellow
$revieweeBody = @{
    username = 'reviewee'
    password = 'reviewee123'
} | ConvertTo-Json

try {
    $revieweeResponse = Invoke-RestMethod -Uri 'http://127.0.0.1:8000/api/auth/login' -Method Post -Body $revieweeBody -ContentType 'application/json'
    Write-Host "Reviewee login successful!" -ForegroundColor Green
    Write-Host "  Token: $($revieweeResponse.data.token.Substring(0, 20))..." -ForegroundColor Gray
    Write-Host "  Role: $($revieweeResponse.data.user.role)" -ForegroundColor Gray
} catch {
    Write-Host "Reviewee login failed: $_" -ForegroundColor Red
    exit 1
}

# Test token validation
Write-Host "`nTesting token validation..." -ForegroundColor Yellow
$headers = @{
    'Authorization' = "Bearer $adminToken"
    'Content-Type' = 'application/json'
}

try {
    $validateResponse = Invoke-RestMethod -Uri 'http://127.0.0.1:8000/api/auth/validate' -Method Get -Headers $headers
    Write-Host "Token validation successful!" -ForegroundColor Green
    Write-Host "  User: $($validateResponse.user.username)" -ForegroundColor Gray
} catch {
    Write-Host "Token validation failed: $_" -ForegroundColor Red
    exit 1
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "All authentication tests passed!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "`nYou can now login with:" -ForegroundColor White
Write-Host "  Admin: username=admin, password=admin123" -ForegroundColor Yellow
Write-Host "  Reviewee: username=reviewee, password=reviewee123" -ForegroundColor Yellow

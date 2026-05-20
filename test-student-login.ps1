# Test Student Login
Write-Host "Testing Student Login..." -ForegroundColor Cyan

# Test reviewee account
$body = @{
    username = "reviewee"
    password = "password"
} | ConvertTo-Json

Write-Host "`nTesting reviewee account..." -ForegroundColor Yellow
$response = Invoke-WebRequest -Uri "http://localhost/exam-backend/api/auth/login" `
    -Method POST `
    -Body $body `
    -ContentType "application/json" `
    -UseBasicParsing

Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
$data = $response.Content | ConvertFrom-Json
Write-Host "Response:" -ForegroundColor Green
$data | ConvertTo-Json -Depth 5

if ($data.data.token) {
    Write-Host "`n✅ Login successful!" -ForegroundColor Green
    Write-Host "Token: $($data.data.token.Substring(0, 20))..." -ForegroundColor Cyan
    Write-Host "User: $($data.data.user.username)" -ForegroundColor Cyan
    Write-Host "Role: $($data.data.user.role)" -ForegroundColor Cyan
} else {
    Write-Host "`n❌ Login failed!" -ForegroundColor Red
}

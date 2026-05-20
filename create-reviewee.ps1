# Create a new reviewee user
Write-Host "=== Creating New Reviewee User ===" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:8000/api"

# Step 1: Login as admin
Write-Host "Step 1: Logging in as admin..." -ForegroundColor Yellow
$loginBody = @{
    email = "admin@example.com"
    password = "Admin123!"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
    $token = $loginResponse.token
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }
    Write-Host "Admin login successful" -ForegroundColor Green
} catch {
    Write-Host "Admin login failed: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Step 2: Create reviewee user
Write-Host "Step 2: Creating reviewee user..." -ForegroundColor Yellow
$revieweeData = @{
    name = "Test Reviewee"
    email = "reviewee@example.com"
    password = "Reviewee123!"
    role = "reviewee"
} | ConvertTo-Json

try {
    $createResponse = Invoke-RestMethod -Uri "$baseUrl/admin/users" -Method Post -Headers $headers -Body $revieweeData
    Write-Host "Reviewee created successfully!" -ForegroundColor Green
    Write-Host "  Name: $($createResponse.user.name)" -ForegroundColor Gray
    Write-Host "  Email: $($createResponse.user.email)" -ForegroundColor Gray
    Write-Host "  Role: $($createResponse.user.role)" -ForegroundColor Gray
    Write-Host "  Password: Reviewee123!" -ForegroundColor Gray
} catch {
    Write-Host "Failed to create reviewee: $_" -ForegroundColor Red
    Write-Host "The user might already exist." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== Done ===" -ForegroundColor Cyan
Write-Host "You can now login with:" -ForegroundColor Green
Write-Host "  Email: reviewee@example.com" -ForegroundColor Gray
Write-Host "  Password: Reviewee123!" -ForegroundColor Gray

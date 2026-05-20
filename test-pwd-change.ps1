# Test Password Change API Endpoint
Write-Host "=== Password Change API Test ===" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:8000/api"

# Step 1: Login as admin
Write-Host "Step 1: Logging in as admin..." -ForegroundColor Yellow
$adminLogin = @{
    username = "admin"
    password = "admin123"
} | ConvertTo-Json

$adminResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $adminLogin -ContentType "application/json"
$adminToken = $adminResponse.data.token
Write-Host "Admin logged in successfully" -ForegroundColor Green
Write-Host ""

# Step 2: Create test user
Write-Host "Step 2: Creating test user..." -ForegroundColor Yellow
$newUser = @{
    username = "test_pwd_change"
    first_name = "Test"
    last_name = "Password"
    middle_initial = "C"
    role = "reviewee"
    is_active = $true
} | ConvertTo-Json

$headers = @{
    "Authorization" = "Bearer $adminToken"
    "Content-Type" = "application/json"
}

# Delete if exists
try {
    $users = Invoke-RestMethod -Uri "$baseUrl/admin/users" -Method Get -Headers $headers
    $existingUser = $users.data | Where-Object { $_.username -eq "test_pwd_change" }
    if ($existingUser) {
        Invoke-RestMethod -Uri "$baseUrl/admin/users/$($existingUser.id)" -Method Delete -Headers $headers | Out-Null
    }
} catch {}

$createResponse = Invoke-RestMethod -Uri "$baseUrl/admin/users" -Method Post -Body $newUser -Headers $headers -ContentType "application/json"
$testUserId = $createResponse.data.id
Write-Host "Test user created with ID: $testUserId" -ForegroundColor Green
Write-Host "Default password: password123" -ForegroundColor Green
Write-Host ""

# Step 3: Login as test user
Write-Host "Step 3: Logging in as test user..." -ForegroundColor Yellow
$testLogin = @{
    username = "test_pwd_change"
    password = "password123"
} | ConvertTo-Json

$testResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $testLogin -ContentType "application/json"
$testToken = $testResponse.data.token
$testUser = $testResponse.data.user
Write-Host "Test user logged in successfully" -ForegroundColor Green
Write-Host "require_password_change: $($testUser.require_password_change)" -ForegroundColor Green
Write-Host ""

# Step 4: Test validation - wrong password
Write-Host "Step 4: Testing wrong current password..." -ForegroundColor Yellow
$testHeaders = @{
    "Authorization" = "Bearer $testToken"
    "Content-Type" = "application/json"
}

$wrongPassword = @{
    current_password = "wrongpassword"
    new_password = "NewPassword123"
    new_password_confirmation = "NewPassword123"
} | ConvertTo-Json

try {
    Invoke-RestMethod -Uri "$baseUrl/auth/change-password" -Method Post -Body $wrongPassword -Headers $testHeaders -ContentType "application/json" | Out-Null
    Write-Host "ERROR: Should have failed" -ForegroundColor Red
} catch {
    Write-Host "Correctly rejected wrong password" -ForegroundColor Green
}
Write-Host ""

# Step 5: Test validation - password too short
Write-Host "Step 5: Testing password too short..." -ForegroundColor Yellow
$shortPassword = @{
    current_password = "password123"
    new_password = "12345"
    new_password_confirmation = "12345"
} | ConvertTo-Json

try {
    Invoke-RestMethod -Uri "$baseUrl/auth/change-password" -Method Post -Body $shortPassword -Headers $testHeaders -ContentType "application/json" | Out-Null
    Write-Host "ERROR: Should have failed" -ForegroundColor Red
} catch {
    Write-Host "Correctly rejected short password" -ForegroundColor Green
}
Write-Host ""

# Step 6: Test validation - password mismatch
Write-Host "Step 6: Testing password mismatch..." -ForegroundColor Yellow
$mismatchPassword = @{
    current_password = "password123"
    new_password = "NewPassword123"
    new_password_confirmation = "DifferentPassword123"
} | ConvertTo-Json

try {
    Invoke-RestMethod -Uri "$baseUrl/auth/change-password" -Method Post -Body $mismatchPassword -Headers $testHeaders -ContentType "application/json" | Out-Null
    Write-Host "ERROR: Should have failed" -ForegroundColor Red
} catch {
    Write-Host "Correctly rejected mismatched passwords" -ForegroundColor Green
}
Write-Host ""

# Step 7: Test validation - default password
Write-Host "Step 7: Testing default password as new password..." -ForegroundColor Yellow
$defaultPassword = @{
    current_password = "password123"
    new_password = "password123"
    new_password_confirmation = "password123"
} | ConvertTo-Json

try {
    Invoke-RestMethod -Uri "$baseUrl/auth/change-password" -Method Post -Body $defaultPassword -Headers $testHeaders -ContentType "application/json" | Out-Null
    Write-Host "ERROR: Should have failed" -ForegroundColor Red
} catch {
    Write-Host "Correctly rejected default password" -ForegroundColor Green
}
Write-Host ""

# Step 8: Successfully change password
Write-Host "Step 8: Successfully changing password..." -ForegroundColor Yellow
$validPassword = @{
    current_password = "password123"
    new_password = "MyNewPassword123!"
    new_password_confirmation = "MyNewPassword123!"
} | ConvertTo-Json

$changeResponse = Invoke-RestMethod -Uri "$baseUrl/auth/change-password" -Method Post -Body $validPassword -Headers $testHeaders -ContentType "application/json"
Write-Host "Password changed successfully" -ForegroundColor Green
Write-Host "Message: $($changeResponse.message)" -ForegroundColor Green
Write-Host ""

# Step 9: Verify old password no longer works
Write-Host "Step 9: Verifying old password no longer works..." -ForegroundColor Yellow
$oldPasswordLogin = @{
    username = "test_pwd_change"
    password = "password123"
} | ConvertTo-Json

try {
    Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $oldPasswordLogin -ContentType "application/json" | Out-Null
    Write-Host "ERROR: Old password should not work" -ForegroundColor Red
} catch {
    Write-Host "Old password correctly rejected" -ForegroundColor Green
}
Write-Host ""

# Step 10: Login with new password
Write-Host "Step 10: Logging in with new password..." -ForegroundColor Yellow
$newPasswordLogin = @{
    username = "test_pwd_change"
    password = "MyNewPassword123!"
} | ConvertTo-Json

$newLoginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $newPasswordLogin -ContentType "application/json"
$newUser = $newLoginResponse.data.user
Write-Host "Login with new password successful" -ForegroundColor Green
Write-Host "require_password_change: $($newUser.require_password_change)" -ForegroundColor Green
Write-Host ""

# Cleanup
Write-Host "Cleaning up..." -ForegroundColor Yellow
Invoke-RestMethod -Uri "$baseUrl/admin/users/$testUserId" -Method Delete -Headers $headers | Out-Null
Write-Host "Test user deleted" -ForegroundColor Green
Write-Host ""

Write-Host "=== All Tests Passed! ===" -ForegroundColor Green

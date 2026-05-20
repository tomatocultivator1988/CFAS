# Test Password Change API Endpoint
# This script tests the complete password change flow

Write-Host "=== Password Change API Test ===" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:8000/api"

# Step 1: Create a test user with default password
Write-Host "Step 1: Creating test user with default password..." -ForegroundColor Yellow

# First, login as admin
$adminLogin = @{
    username = "admin"
    password = "admin123"
} | ConvertTo-Json

try {
    $adminResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $adminLogin -ContentType "application/json"
    $adminToken = $adminResponse.data.token
    Write-Host "✓ Admin logged in successfully" -ForegroundColor Green
}
catch {
    Write-Host "✗ Admin login failed: $_" -ForegroundColor Red
    exit 1
}

# Create test user
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
        Write-Host "✓ Deleted existing test user" -ForegroundColor Green
    }
}
catch {
    # Ignore errors
}

try {
    $createResponse = Invoke-RestMethod -Uri "$baseUrl/admin/users" -Method Post -Body $newUser -Headers $headers -ContentType "application/json"
    $testUserId = $createResponse.data.id
    Write-Host "✓ Test user created with ID: $testUserId" -ForegroundColor Green
    Write-Host "✓ Default password: password123" -ForegroundColor Green
    Write-Host "✓ require_password_change: true" -ForegroundColor Green
}
catch {
    Write-Host "✗ Failed to create test user: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Step 2: Login as test user with default password
Write-Host "Step 2: Logging in as test user with default password..." -ForegroundColor Yellow

$testLogin = @{
    username = "test_pwd_change"
    password = "password123"
} | ConvertTo-Json

try {
    $testResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $testLogin -ContentType "application/json"
    $testToken = $testResponse.data.token
    $testUser = $testResponse.data.user
    Write-Host "✓ Test user logged in successfully" -ForegroundColor Green
    Write-Host "✓ require_password_change: $($testUser.require_password_change)" -ForegroundColor Green
    
    if ($testUser.require_password_change -ne $true) {
        Write-Host "✗ require_password_change should be true" -ForegroundColor Red
        exit 1
    }
}
catch {
    Write-Host "✗ Test user login failed: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Step 3: Test password change validation errors
Write-Host "Step 3: Testing validation errors..." -ForegroundColor Yellow

$testHeaders = @{
    "Authorization" = "Bearer $testToken"
    "Content-Type" = "application/json"
}

# Test 3a: Wrong current password
Write-Host "  3a: Testing wrong current password..." -ForegroundColor Gray
$wrongPassword = @{
    current_password = "wrongpassword"
    new_password = "NewPassword123"
    new_password_confirmation = "NewPassword123"
} | ConvertTo-Json

try {
    Invoke-RestMethod -Uri "$baseUrl/auth/change-password" -Method Post -Body $wrongPassword -Headers $testHeaders -ContentType "application/json" | Out-Null
    Write-Host "  ✗ Should have failed with wrong password" -ForegroundColor Red
    exit 1
}
catch {
    if ($_.Exception.Response.StatusCode -eq 401) {
        Write-Host "  ✓ Correctly rejected wrong current password" -ForegroundColor Green
    }
    else {
        Write-Host "  ✗ Unexpected error: $_" -ForegroundColor Red
        exit 1
    }
}

# Test 3b: Password too short
Write-Host "  3b: Testing password too short..." -ForegroundColor Gray
$shortPassword = @{
    current_password = "password123"
    new_password = "12345"
    new_password_confirmation = "12345"
} | ConvertTo-Json

try {
    Invoke-RestMethod -Uri "$baseUrl/auth/change-password" -Method Post -Body $shortPassword -Headers $testHeaders -ContentType "application/json" | Out-Null
    Write-Host "  ✗ Should have failed with short password" -ForegroundColor Red
    exit 1
}
catch {
    if ($_.Exception.Response.StatusCode -eq 422) {
        Write-Host "  ✓ Correctly rejected short password" -ForegroundColor Green
    }
    else {
        Write-Host "  ✗ Unexpected error: $_" -ForegroundColor Red
        exit 1
    }
}

# Test 3c: Password confirmation mismatch
Write-Host "  3c: Testing password confirmation mismatch..." -ForegroundColor Gray
$mismatchPassword = @{
    current_password = "password123"
    new_password = "NewPassword123"
    new_password_confirmation = "DifferentPassword123"
} | ConvertTo-Json

try {
    Invoke-RestMethod -Uri "$baseUrl/auth/change-password" -Method Post -Body $mismatchPassword -Headers $testHeaders -ContentType "application/json" | Out-Null
    Write-Host "  ✗ Should have failed with mismatched passwords" -ForegroundColor Red
    exit 1
}
catch {
    if ($_.Exception.Response.StatusCode -eq 422) {
        Write-Host "  ✓ Correctly rejected mismatched passwords" -ForegroundColor Green
    }
    else {
        Write-Host "  ✗ Unexpected error: $_" -ForegroundColor Red
        exit 1
    }
}

# Test 3d: Using default password as new password
Write-Host "  3d: Testing default password as new password..." -ForegroundColor Gray
$defaultPassword = @{
    current_password = "password123"
    new_password = "password123"
    new_password_confirmation = "password123"
} | ConvertTo-Json

try {
    Invoke-RestMethod -Uri "$baseUrl/auth/change-password" -Method Post -Body $defaultPassword -Headers $testHeaders -ContentType "application/json" | Out-Null
    Write-Host "  ✗ Should have failed with default password" -ForegroundColor Red
    exit 1
}
catch {
    if ($_.Exception.Response.StatusCode -eq 422) {
        Write-Host "  ✓ Correctly rejected default password" -ForegroundColor Green
    }
    else {
        Write-Host "  ✗ Unexpected error: $_" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""

# Step 4: Successfully change password
Write-Host "Step 4: Successfully changing password..." -ForegroundColor Yellow

$validPassword = @{
    current_password = "password123"
    new_password = "MyNewPassword123!"
    new_password_confirmation = "MyNewPassword123!"
} | ConvertTo-Json

try {
    $changeResponse = Invoke-RestMethod -Uri "$baseUrl/auth/change-password" -Method Post -Body $validPassword -Headers $testHeaders -ContentType "application/json"
    Write-Host "✓ Password changed successfully" -ForegroundColor Green
    Write-Host "✓ Message: $($changeResponse.message)" -ForegroundColor Green
}
catch {
    Write-Host "✗ Password change failed: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Step 5: Verify old password no longer works
Write-Host "Step 5: Verifying old password no longer works..." -ForegroundColor Yellow

$oldPasswordLogin = @{
    username = "test_pwd_change"
    password = "password123"
} | ConvertTo-Json

try {
    Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $oldPasswordLogin -ContentType "application/json" | Out-Null
    Write-Host "✗ Old password should not work" -ForegroundColor Red
    exit 1
}
catch {
    Write-Host "✓ Old password correctly rejected" -ForegroundColor Green
}

Write-Host ""

# Step 6: Login with new password
Write-Host "Step 6: Logging in with new password..." -ForegroundColor Yellow

$newPasswordLogin = @{
    username = "test_pwd_change"
    password = "MyNewPassword123!"
} | ConvertTo-Json

try {
    $newLoginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $newPasswordLogin -ContentType "application/json"
    $newUser = $newLoginResponse.data.user
    Write-Host "✓ Login with new password successful" -ForegroundColor Green
    Write-Host "✓ require_password_change: $($newUser.require_password_change)" -ForegroundColor Green
    
    if ($newUser.require_password_change -ne $false) {
        Write-Host "✗ require_password_change should be false" -ForegroundColor Red
        exit 1
    }
}
catch {
    Write-Host "✗ Login with new password failed: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Cleanup
Write-Host "Cleaning up..." -ForegroundColor Yellow
try {
    Invoke-RestMethod -Uri "$baseUrl/admin/users/$testUserId" -Method Delete -Headers $headers | Out-Null
    Write-Host "✓ Test user deleted" -ForegroundColor Green
}
catch {
    Write-Host "✗ Failed to delete test user: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== All Tests Passed! ===" -ForegroundColor Green
Write-Host ""
Write-Host "Password change functionality is working correctly:" -ForegroundColor Cyan
Write-Host "- Users can change from default password" -ForegroundColor White
Write-Host "- Validation prevents weak passwords" -ForegroundColor White
Write-Host "- Cannot reuse default password" -ForegroundColor White
Write-Host "- require_password_change flag updates correctly" -ForegroundColor White
Write-Host "- Old password no longer works after change" -ForegroundColor White
Write-Host "- New password works for login" -ForegroundColor White

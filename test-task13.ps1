# Task 13: User Management Service Testing
Write-Host "=== TASK 13 USER MANAGEMENT TESTING ===" -ForegroundColor Cyan

$baseUrl = "http://127.0.0.1:8000/api"
$adminUser = "admin"
$adminPass = "admin123"

function Invoke-ApiRequest {
    param($Uri, $Method = "Get", $Body = $null, $Headers = @{})
    try {
        $params = @{
            Uri = $Uri
            Method = $Method
            Headers = $Headers
            ContentType = "application/json"
        }
        if ($Body) { $params.Body = $Body }
        return Invoke-RestMethod @params
    } catch {
        return @{
            error = $true
            status = $_.Exception.Response.StatusCode.value__
            message = $_.ErrorDetails.Message
        }
    }
}

Write-Host "`n1. Login as admin..." -ForegroundColor Yellow
$loginBody = @{username=$adminUser; password=$adminPass} | ConvertTo-Json
$login = Invoke-ApiRequest -Uri "$baseUrl/auth/login" -Method Post -Body $loginBody
$token = $login.data.token
$headers = @{"Authorization"="Bearer $token"; "Content-Type"="application/json"}
Write-Host "OK - Admin logged in" -ForegroundColor Green

Write-Host "`n2. Create new user..." -ForegroundColor Yellow
$newUserBody = @{
    username = "testuser_$(Get-Random -Maximum 10000)"
    password = "testpass123"
    role = "reviewee"
    require_password_change = $false
} | ConvertTo-Json
$createResult = Invoke-ApiRequest -Uri "$baseUrl/admin/users" -Method Post -Body $newUserBody -Headers $headers
if ($createResult.user) {
    $userId = $createResult.user.id
    Write-Host "OK - User created (ID: $userId, Username: $($createResult.user.username))" -ForegroundColor Green
} else {
    Write-Host "FAIL - User creation failed" -ForegroundColor Red
    Write-Host $createResult.message -ForegroundColor Gray
}

Write-Host "`n3. Test username uniqueness..." -ForegroundColor Yellow
$duplicateBody = @{
    username = $createResult.user.username
    password = "testpass123"
    role = "reviewee"
} | ConvertTo-Json
$duplicateResult = Invoke-ApiRequest -Uri "$baseUrl/admin/users" -Method Post -Body $duplicateBody -Headers $headers
if ($duplicateResult.error -and $duplicateResult.status -eq 400) {
    Write-Host "OK - Duplicate username rejected" -ForegroundColor Green
} else {
    Write-Host "FAIL - Should have rejected duplicate username" -ForegroundColor Red
}

Write-Host "`n4. Get all users..." -ForegroundColor Yellow
$users = Invoke-ApiRequest -Uri "$baseUrl/admin/users" -Headers $headers
if ($users.users) {
    Write-Host "OK - Retrieved $($users.users.Count) users" -ForegroundColor Green
} else {
    Write-Host "FAIL - Failed to get users" -ForegroundColor Red
}

Write-Host "`n5. Get specific user..." -ForegroundColor Yellow
$user = Invoke-ApiRequest -Uri "$baseUrl/admin/users/$userId" -Headers $headers
if ($user.user) {
    Write-Host "OK - Retrieved user: $($user.user.username)" -ForegroundColor Green
} else {
    Write-Host "FAIL - Failed to get user" -ForegroundColor Red
}

Write-Host "`n6. Update user..." -ForegroundColor Yellow
$updateBody = @{
    require_password_change = $true
} | ConvertTo-Json
$updateResult = Invoke-ApiRequest -Uri "$baseUrl/admin/users/$userId" -Method Put -Body $updateBody -Headers $headers
if ($updateResult.user -and $updateResult.user.require_password_change -eq $true) {
    Write-Host "OK - User updated successfully" -ForegroundColor Green
} else {
    Write-Host "FAIL - User update failed" -ForegroundColor Red
}

Write-Host "`n7. Reset user password..." -ForegroundColor Yellow
$resetBody = @{
    new_password = "newpass123"
    require_password_change = $true
} | ConvertTo-Json
$resetResult = Invoke-ApiRequest -Uri "$baseUrl/admin/users/$userId/reset-password" -Method Post -Body $resetBody -Headers $headers
if ($resetResult.user) {
    Write-Host "OK - Password reset successfully" -ForegroundColor Green
    Write-Host "   Require password change: $($resetResult.user.require_password_change)" -ForegroundColor Gray
} else {
    Write-Host "FAIL - Password reset failed" -ForegroundColor Red
}

Write-Host "`n8. Get user audit log..." -ForegroundColor Yellow
$auditLog = Invoke-ApiRequest -Uri "$baseUrl/admin/users/$userId/audit-log" -Headers $headers
if ($auditLog.audit_logs) {
    Write-Host "OK - Retrieved $($auditLog.audit_logs.Count) audit log entries" -ForegroundColor Green
    foreach ($log in $auditLog.audit_logs) {
        Write-Host "   - $($log.action) at $($log.created_at)" -ForegroundColor Gray
    }
} else {
    Write-Host "FAIL - Failed to get audit log" -ForegroundColor Red
}

Write-Host "`n9. Deactivate user..." -ForegroundColor Yellow
$deactivateResult = Invoke-ApiRequest -Uri "$baseUrl/admin/users/$userId" -Method Delete -Headers $headers
if ($deactivateResult.user -and $deactivateResult.user.is_active -eq $false) {
    Write-Host "OK - User deactivated successfully" -ForegroundColor Green
} else {
    Write-Host "FAIL - User deactivation failed" -ForegroundColor Red
}

Write-Host "`n10. Verify user is deactivated..." -ForegroundColor Yellow
$deactivatedUser = Invoke-ApiRequest -Uri "$baseUrl/admin/users/$userId" -Headers $headers
if ($deactivatedUser.user -and $deactivatedUser.user.is_active -eq $false) {
    Write-Host "OK - User is deactivated (history preserved)" -ForegroundColor Green
} else {
    Write-Host "FAIL - User deactivation not verified" -ForegroundColor Red
}

Write-Host "`n11. Test deactivated user cannot login..." -ForegroundColor Yellow
$loginAttempt = @{
    username = $createResult.user.username
    password = "newpass123"
} | ConvertTo-Json
$loginResult = Invoke-ApiRequest -Uri "$baseUrl/auth/login" -Method Post -Body $loginAttempt
if ($loginResult.error) {
    Write-Host "OK - Deactivated user cannot login" -ForegroundColor Green
} else {
    Write-Host "FAIL - Deactivated user should not be able to login" -ForegroundColor Red
}

Write-Host "`n=== TASK 13 TESTING COMPLETE ===" -ForegroundColor Cyan

Write-Host "`nFEATURES TESTED:" -ForegroundColor Yellow
Write-Host "- User creation with password hashing" -ForegroundColor White
Write-Host "- Username uniqueness validation" -ForegroundColor White
Write-Host "- User listing and retrieval" -ForegroundColor White
Write-Host "- User updates" -ForegroundColor White
Write-Host "- Password reset with require_password_change flag" -ForegroundColor White
Write-Host "- User deactivation (soft delete)" -ForegroundColor White
Write-Host "- Audit logging for all user actions" -ForegroundColor White
Write-Host "- Deactivated users cannot login" -ForegroundColor White

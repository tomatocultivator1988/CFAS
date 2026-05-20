# Test Reviewee Password Change - Step by Step

## Prerequisites
- Backend running on `http://localhost:8000`
- Frontend running on `http://localhost:5173`
- Test user created

## Step 1: Create Test User

Run this command:
```bash
php create-test-reviewee.php
```

This creates:
- Username: `testuser`
- Password: `password123`
- Role: `reviewee`
- `require_password_change`: `true`

## Step 2: Login as Reviewee

1. Open browser: `http://localhost:5173`
2. Enter credentials:
   - Username: `testuser`
   - Password: `password123`
3. Click "Sign In"

## Step 3: Force Password Change Modal Appears

You should see:
- **Modal that cannot be closed** (no X button, no click outside)
- **Lock icon** with animations
- **Title**: "🔐 Secure Your Account"
- **Three input fields**:
  - Current Password
  - New Password (with strength indicator)
  - Confirm New Password
- **Requirements checklist**
- **Change Password button**

## Step 4: Test Validation

### Test 1: Wrong Current Password
- Current: `wrongpassword`
- New: `MyNewPass123`
- Confirm: `MyNewPass123`
- **Expected**: Error message "Current password is incorrect"

### Test 2: Password Too Short
- Current: `password123`
- New: `12345`
- Confirm: `12345`
- **Expected**: Error message "Password must be at least 6 characters"

### Test 3: Passwords Don't Match
- Current: `password123`
- New: `MyNewPass123`
- Confirm: `DifferentPass123`
- **Expected**: Error message "Passwords do not match"

### Test 4: Using Default Password
- Current: `password123`
- New: `password123`
- Confirm: `password123`
- **Expected**: Error message "You cannot use the default password"

### Test 5: Successful Change
- Current: `password123`
- New: `MyNewPass123`
- Confirm: `MyNewPass123`
- **Expected**: 
  - Success! Modal closes
  - Exam list loads
  - No more password change required

## Step 5: Verify Password Changed

1. Logout (if logout button available)
2. Try to login with old password: `password123`
   - **Expected**: Login fails
3. Login with new password: `MyNewPass123`
   - **Expected**: Login succeeds, no password change modal

## Visual Features to Check

### Password Strength Indicator
As you type the new password, watch for:
- **Weak** (red) - Less than 6 chars or simple
- **Fair** (orange) - 6+ chars
- **Good** (blue) - 8+ chars with uppercase/numbers
- **Strong** (green) - 8+ chars with uppercase, numbers, symbols

### Requirements Checklist
- ○ → ✓ when requirement is met
- Gray → Green color change
- Animated checkmark pop

### Password Visibility Toggle
- Click eye icon (👁️) to show/hide password
- Works for all three fields

### Animations
- Modal slides up on entrance
- Lock icon pulses
- Particles float in background
- Smooth transitions

## Troubleshooting

### Modal Doesn't Appear
**Check:**
1. User has `require_password_change = true` in database
2. Browser console for errors
3. Network tab - check `/api/auth/validate` response

### Password Change Fails
**Check:**
1. Backend is running
2. Network tab - check `/api/auth/change-password` request
3. Response error message
4. Browser console for errors

### Modal Won't Close After Success
**Check:**
1. `handlePasswordChanged` function is called
2. `showPasswordChangeModal` is set to false
3. Browser console for errors

## Database Verification

Check user in database:
```sql
SELECT username, require_password_change FROM users WHERE username = 'testuser';
```

**Before password change:**
```
username: testuser
require_password_change: 1
```

**After password change:**
```
username: testuser
require_password_change: 0
```

## Clean Up

Delete test user:
```bash
php -r "require 'backend/vendor/autoload.php'; \$app = require 'backend/bootstrap/app.php'; \$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap(); Illuminate\Support\Facades\DB::table('users')->where('username', 'testuser')->delete(); echo 'Test user deleted\n';"
```

## Success Criteria

✅ Modal appears on first login
✅ Cannot close modal without changing password
✅ All validation rules work correctly
✅ Password strength indicator updates in real-time
✅ Requirements checklist updates as you type
✅ Password visibility toggle works
✅ Successful password change closes modal
✅ Exam list loads after password change
✅ Old password no longer works
✅ New password works for login
✅ No password change modal on subsequent logins

## Notes

- The modal is designed to be **impossible to dismiss** until password is changed
- This ensures security by forcing users to change default passwords
- The design is clean and user-friendly with helpful feedback
- All animations are smooth and not distracting

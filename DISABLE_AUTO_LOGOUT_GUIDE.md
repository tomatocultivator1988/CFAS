# Disable Auto-Logout Guide

## Problem

Users are being automatically logged out after 30 minutes, even if they're still taking an exam or using the system.

## Solution

Change `SESSION_TIMEOUT_MINUTES` from 30 minutes to 43200 minutes (30 days).

This means:
- Users will stay logged in for up to 30 days
- They will ONLY logout when they click the "Logout" button
- No more automatic logout during exams!

---

## Quick Fix (Automatic)

Run this script:
```
.\DISABLE-AUTO-LOGOUT.bat
```

This will:
1. Update XAMPP .env file (30 → 43200 minutes)
2. Update development .env file (120 → 43200 minutes)
3. Clear Laravel cache
4. Prompt you to restart Apache

---

## Manual Fix (If needed)

### Step 1: Edit XAMPP .env file

Open: `C:\xampp\htdocs\exam-backend\.env`

Find this line:
```
SESSION_TIMEOUT_MINUTES=30
```

Change to:
```
SESSION_TIMEOUT_MINUTES=43200
```

### Step 2: Edit Development .env file

Open: `Exam-Main/backend/.env`

Find this line:
```
SESSION_TIMEOUT_MINUTES=120
```

Change to:
```
SESSION_TIMEOUT_MINUTES=43200
```

### Step 3: Clear Laravel cache

```
cd C:\xampp\htdocs\exam-backend
php artisan config:clear
php artisan cache:clear
```

### Step 4: Restart Apache

1. Open XAMPP Control Panel
2. Stop Apache
3. Start Apache

---

## What Changed?

| Setting | Before | After |
|---------|--------|-------|
| XAMPP Session Timeout | 30 minutes | 43200 minutes (30 days) |
| Development Session Timeout | 120 minutes | 43200 minutes (30 days) |

---

## Why 30 Days?

- Long enough that users won't be auto-logged out
- Still has an expiration (for security)
- Users must manually logout by clicking "Logout" button
- If browser is closed, session is preserved (can continue later)

---

## Testing

After applying the fix:

1. Login as a student
2. Wait 30+ minutes without clicking anything
3. Try to take an exam or navigate
4. You should still be logged in! ✅

---

## Security Note

This is safe because:
- Users still need to login with username/password
- Sessions are stored securely on the server
- Users can still manually logout
- 30 days is reasonable for an exam system
- Most users will logout manually anyway

---

## Reverting (If needed)

To go back to 30 minute timeout:

1. Change `SESSION_TIMEOUT_MINUTES=43200` back to `SESSION_TIMEOUT_MINUTES=30`
2. Run `php artisan config:clear`
3. Restart Apache

---

## Summary

✅ No more auto-logout after 30 minutes
✅ Users stay logged in until they click "Logout"
✅ Sessions last up to 30 days
✅ Safe and secure
✅ Better user experience during exams

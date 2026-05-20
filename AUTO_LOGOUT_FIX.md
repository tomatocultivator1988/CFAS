# Auto-Logout Bug Fix

## Problem
Users were experiencing automatic logout without notice and being redirected to the wrong URL:
- Expected: `http://192.168.11.40/exam-frontend/login`
- Actual: `http://192.168.11.40/login` (404 error)

## Root Causes

### 1. Incorrect Redirect URL
**Location**: `frontend/src/services/api.js` (line 33)

**Issue**: The 401 error interceptor used `window.location.href = '/login'` which ignored the base path configuration (`/exam-frontend/`).

**Fix**: Changed to use the Vite base URL:
```javascript
const basePath = import.meta.env.BASE_URL || '/'
window.location.href = `${basePath}login`
```

### 2. Token Expiration Too Short
**Location**: `backend/.env`

**Issue**: Tokens expired after 30 minutes (`SESSION_TIMEOUT_MINUTES=30`), causing frequent automatic logouts.

**Fix**: Increased to 120 minutes to match session lifetime:
```env
SESSION_TIMEOUT_MINUTES=120
```

### 3. No Token Refresh Mechanism
**Location**: `frontend/src/services/api.js`

**Issue**: No automatic token validation or refresh, so tokens would expire silently.

**Fix**: Added automatic token validation:
- Tracks user activity (mouse, keyboard, scroll, touch)
- Validates token every 5 minutes if user is active
- Only validates if activity detected within last 25 minutes
- Prevents token expiration during active usage

## Changes Made

### Frontend (`frontend/src/services/api.js`)
1. Added activity tracking system
2. Added periodic token validation (every 5 minutes)
3. Fixed redirect URL to respect base path
4. Activity timeout set to 25 minutes (before 30 min expiry)

### Backend (`backend/.env`)
1. Increased `SESSION_TIMEOUT_MINUTES` from 30 to 120 minutes

## How It Works Now

1. **User Activity Tracking**: System monitors mouse, keyboard, scroll, and touch events
2. **Automatic Validation**: Every 5 minutes, if user was active in last 25 minutes, token is validated
3. **Extended Session**: Tokens now last 120 minutes instead of 30
4. **Correct Redirect**: If logout occurs, redirects to `http://192.168.11.40/exam-frontend/login`

## Deployment

Run the deployment script:
```bash
FIX-AUTO-LOGOUT.bat
```

Or manually:
```bash
cd frontend
npm run build
xcopy /E /I /Y dist\* C:\xampp\htdocs\exam-frontend\
net stop Apache2.4
net start Apache2.4
```

## Testing

1. Login at `http://192.168.11.40/exam-frontend`
2. Use the system normally for 30+ minutes
3. Verify you stay logged in
4. If automatic logout occurs, verify redirect goes to correct URL

## Configuration

To adjust token lifetime, edit `backend/.env`:
```env
SESSION_TIMEOUT_MINUTES=120  # Change this value (in minutes)
```

To adjust validation frequency, edit `frontend/src/services/api.js`:
```javascript
const TOKEN_CHECK_INTERVAL = 5 * 60 * 1000 // Check every 5 minutes
const ACTIVITY_TIMEOUT = 25 * 60 * 1000 // 25 minutes
```

## Notes

- Token validation only happens when user is actively using the system
- Inactive users will still be logged out after token expiry
- The validation endpoint (`/auth/validate`) doesn't extend token lifetime, it just checks validity
- For production, consider implementing token refresh mechanism that extends token lifetime on validation

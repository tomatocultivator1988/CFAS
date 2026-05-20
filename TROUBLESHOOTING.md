# Troubleshooting Guide

## System is Not Working?

### Quick Checks:

1. **Are both servers running?**
   - Backend: http://127.0.0.1:8000
   - Frontend: https://localhost:5173

2. **Check browser console** (F12)
   - Look for CORS errors
   - Look for network errors
   - Look for JavaScript errors

3. **Common Issues:**

#### Issue: "Cannot connect to backend"
**Solution**: 
- Make sure backend is running: `cd backend && php artisan serve`
- Check that backend is on http://127.0.0.1:8000 (not https)

#### Issue: "CORS error"
**Solution**:
- Backend CORS is configured in `backend/config/cors.php`
- Make sure frontend URL is in allowed origins

#### Issue: "Login button does nothing"
**Solution**:
- Open browser console (F12)
- Check Network tab for failed requests
- Check Console tab for JavaScript errors

#### Issue: "404 Not Found"
**Solution**:
- Make sure you're accessing https://localhost:5173 (not http)
- Clear browser cache
- Hard refresh (Ctrl+Shift+R)

#### Issue: "Certificate error" (HTTPS warning)
**Solution**:
- This is normal for local development
- Click "Advanced" → "Proceed to localhost"
- Or use http://localhost:5173 instead

#### Issue: "Token expired" or "Unauthorized"
**Solution**:
- Clear localStorage: Open console and run `localStorage.clear()`
- Refresh page and login again

## Testing the System

### 1. Test Backend API Directly

Open PowerShell and run:
```powershell
$body = '{"username":"admin","password":"admin123"}'
Invoke-RestMethod -Uri 'http://127.0.0.1:8000/api/auth/login' -Method POST -Body $body -ContentType 'application/json'
```

You should see:
```json
{
  "message": "Login successful.",
  "data": {
    "token": "...",
    "user": { ... }
  }
}
```

### 2. Test Frontend

1. Open: https://localhost:5173
2. You should see the login page with purple gradient
3. Enter: admin / admin123
4. Click "Sign In"
5. Should redirect to admin dashboard

### 3. Check Browser Console

Press F12 and check:
- **Console tab**: No red errors
- **Network tab**: Login request should return 200 OK
- **Application tab** → Local Storage: Should have `auth_token`

## Server Status

### Check if servers are running:

**Backend:**
```powershell
curl http://127.0.0.1:8000
```

**Frontend:**
```powershell
curl https://localhost:5173
```

### Start servers:

**Backend:**
```powershell
cd Exam-Main/backend
php artisan serve
```

**Frontend:**
```powershell
cd Exam-Main/frontend
npm run dev
```

## Database Issues

### Check if database exists:
```powershell
mysql -u root -e "SHOW DATABASES LIKE 'review_center_exam';"
```

### Check if users exist:
```powershell
mysql -u root review_center_exam -e "SELECT id, username, role FROM users;"
```

Should show:
```
+----+----------+----------+
| id | username | role     |
+----+----------+----------+
|  1 | admin    | admin    |
|  2 | reviewee | reviewee |
+----+----------+----------+
```

### Re-seed users if needed:
```powershell
cd Exam-Main/backend
php artisan db:seed --class=UserSeeder
```

## Still Not Working?

1. **Restart everything:**
   ```powershell
   # Stop servers (Ctrl+C in each terminal)
   # Then restart:
   cd Exam-Main/backend
   php artisan serve
   
   # New terminal:
   cd Exam-Main/frontend
   npm run dev
   ```

2. **Clear all caches:**
   ```powershell
   # Backend
   cd Exam-Main/backend
   php artisan cache:clear
   php artisan config:clear
   
   # Frontend - delete node_modules and reinstall
   cd Exam-Main/frontend
   rm -r node_modules
   npm install
   ```

3. **Check logs:**
   ```powershell
   # Backend logs
   Get-Content Exam-Main/backend/storage/logs/laravel.log -Tail 50
   ```

## Contact Information

If you're still having issues:
1. Check what error message you're seeing
2. Check browser console (F12)
3. Check backend logs
4. Provide the specific error message

## Quick Reference

**Test Credentials:**
- Admin: `admin` / `admin123`
- Reviewee: `reviewee` / `reviewee123`

**URLs:**
- Frontend: https://localhost:5173
- Backend API: http://127.0.0.1:8000/api
- phpMyAdmin: http://localhost/phpmyadmin

**Ports:**
- Frontend: 5173
- Backend: 8000
- MySQL: 3306

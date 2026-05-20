# Quick Fix: Indi Ka Maka-Login After Deployment

## Problema
Pagkatapos mag-deploy, indi ka na maka-login or ang analytics page wala mag-load.

## Mga Posible nga Dahilan
1. **Browser cache** - Ang old files pa ang naka-load sa browser
2. **Token expired** - Ang authentication token nag-expire na
3. **localStorage cleared** - Ang saved login data na-delete
4. **API connection issue** - Ang frontend wala maka-connect sa backend

## Quick Fix (Pinakadali)

### Option 1: Clear Browser Cache
1. Press `Ctrl + Shift + Delete`
2. Select:
   - ✅ Cached images and files
   - ✅ Cookies and other site data
3. Click "Clear data"
4. Reload page (`Ctrl + F5`)
5. Login ulit

### Option 2: Use Incognito Mode
1. Press `Ctrl + Shift + N` (Chrome) or `Ctrl + Shift + P` (Firefox)
2. Go to `http://localhost/cfas`
3. Login
4. Kung nag-work, ang problema kay browser cache lang

### Option 3: Run Fix Script
```powershell
cd Exam-Main
.\FIX-LOGIN-AFTER-DEPLOY.ps1
```

Ini nga script:
- ✅ Clears Laravel cache
- ✅ Rebuilds frontend
- ✅ Redeploys to Apache
- ✅ Adds cache-busting headers
- ✅ Restarts Apache

## Diagnostic Script

Kung gusto mo ma-check kung ano exactly ang problema:

```powershell
cd Exam-Main
.\DIAGNOSE-LOGIN-ANALYTICS.ps1
```

Ini nga script mag-check sang:
- Backend server status
- Frontend build status
- Apache deployment
- Login endpoint
- Analytics endpoint
- CORS configuration

## Manual Fix Steps

Kung ang scripts wala mag-work, try ini:

### 1. Clear Laravel Cache
```bash
cd Exam-Main/backend
php artisan config:clear
php artisan cache:clear
php artisan route:clear
```

### 2. Rebuild Frontend
```bash
cd Exam-Main/frontend
npm run build
```

### 3. Redeploy to Apache
```powershell
# Copy new build
Copy-Item -Path "Exam-Main/frontend/dist/*" -Destination "C:\Apache24\htdocs\cfas" -Recurse -Force

# Restart Apache
Restart-Service -Name "Apache2.4" -Force
```

### 4. Clear Browser Data
1. Open DevTools (`F12`)
2. Go to Application tab
3. Clear Storage:
   - Local Storage
   - Session Storage
   - Cookies
4. Reload page

## Common Errors & Solutions

### Error: "401 Unauthorized"
**Cause:** Token expired or invalid

**Solution:**
1. Logout
2. Clear localStorage
3. Login again

### Error: "Network Error" or "ERR_CONNECTION_REFUSED"
**Cause:** Backend not running

**Solution:**
```bash
cd Exam-Main/backend
php artisan serve
```

### Error: "CORS Error"
**Cause:** Frontend URL not allowed in backend

**Solution:**
1. Edit `backend/.env`
2. Add/update:
   ```
   FRONTEND_URL=http://localhost
   ```
3. Restart backend

### Error: Analytics page blank/not loading
**Cause:** JavaScript errors or API connection issues

**Solution:**
1. Open browser console (`F12`)
2. Check for errors
3. Look for:
   - "Failed to fetch"
   - "401 Unauthorized"
   - "Network Error"
4. If token error: Logout and login again
5. If network error: Check backend is running

## Prevention Tips

Para indi na mag-occur ini nga problema sa future:

### 1. Add Cache Busting to .htaccess
```apache
<IfModule mod_headers.c>
  <FilesMatch "\.(html|htm)$">
    Header set Cache-Control "no-cache, no-store, must-revalidate"
    Header set Pragma "no-cache"
    Header set Expires 0
  </FilesMatch>
</IfModule>
```

### 2. Use Build Timestamps
Sa `vite.config.js`:
```javascript
export default defineConfig({
  build: {
    rollupOptions: {
      output: {
        entryFileNames: `assets/[name].[hash].js`,
        chunkFileNames: `assets/[name].[hash].js`,
        assetFileNames: `assets/[name].[hash].[ext]`
      }
    }
  }
})
```

### 3. Implement Token Refresh
Add automatic token refresh sa auth store para indi mag-expire ang session.

### 4. Add Session Validation
Check token validity before loading analytics page.

## Testing After Fix

1. **Test Login:**
   ```
   http://localhost/cfas
   Username: admin
   Password: admin123
   ```

2. **Test Analytics:**
   - Login as admin
   - Click "Analytics" sa sidebar
   - Check kung nag-load ang data

3. **Check Browser Console:**
   - Press `F12`
   - Look for errors
   - Should see no red errors

4. **Check Network Tab:**
   - Press `F12` > Network
   - Reload page
   - Check if API calls successful (200 status)

## Still Not Working?

Kung wala pa gid mag-work after all these steps:

1. **Check Backend Logs:**
   ```bash
   cd Exam-Main/backend
   tail -f storage/logs/laravel.log
   ```

2. **Check Apache Logs:**
   ```
   C:\Apache24\logs\error.log
   ```

3. **Verify Database:**
   ```bash
   cd Exam-Main/backend
   php artisan migrate:status
   ```

4. **Test API Directly:**
   ```bash
   curl http://localhost:8000/api/health
   ```

5. **Contact Support:**
   - Provide error messages from browser console
   - Provide backend logs
   - Describe exact steps that cause the error

## Quick Reference

| Problem | Quick Fix |
|---------|-----------|
| Can't login | Clear browser cache + reload |
| Analytics blank | Logout + login again |
| Token expired | Clear localStorage + login |
| Network error | Check backend is running |
| CORS error | Update FRONTEND_URL in .env |
| Old files loading | Hard reload (Ctrl+F5) |

## Scripts Summary

```powershell
# Diagnose issues
.\DIAGNOSE-LOGIN-ANALYTICS.ps1

# Fix login issues
.\FIX-LOGIN-AFTER-DEPLOY.ps1

# Deploy to Apache
.\DEPLOY-TO-LAN.ps1

# Clear all caches
.\FORCE-CLEAR-ALL-CACHE.ps1
```

---

**Note:** Ang pinaka-common solution kay mag-clear lang sang browser cache ug mag-login ulit. Try ini first before running ang complex scripts.

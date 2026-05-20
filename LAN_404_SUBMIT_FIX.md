# Fix: 404 Error After Exam Submission on LAN

## Problem
After submitting an exam on LAN (http://192.168.11.40), users see:
```
The requested URL was not found on this server.
Apache/2.4.58 (Win64) OpenSSL/3.1.3 PHP/8.2.12 Server at 192.168.11.40 Port 80
```

## Root Cause
The application is deployed at `http://192.168.11.40/exam-frontend/` but when the exam is submitted, Vue Router tries to navigate to `/exams`, which Apache interprets as `http://192.168.11.40/exams` (missing the `/exam-frontend/` base path).

This is a **Single Page Application (SPA) routing issue**. Apache needs to be configured to redirect all requests to `index.html` so Vue Router can handle the routing.

## Solution

### Quick Fix (Run This Script)
```powershell
.\fix-lan-404-after-submit.ps1
```

This script will:
1. Create proper `.htaccess` file in `C:\xampp\htdocs\exam-frontend\`
2. Verify Apache `mod_rewrite` is enabled
3. Check `AllowOverride` settings

### Manual Fix

#### Step 1: Update .htaccess
Create/update `C:\xampp\htdocs\exam-frontend\.htaccess`:

```apache
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteBase /exam-frontend/
  
  # Don't rewrite files or directories
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  
  # Rewrite everything else to index.html
  RewriteRule ^ index.html [L]
</IfModule>

Options -Indexes
AddDefaultCharset UTF-8
```

#### Step 2: Enable mod_rewrite in Apache
1. Open `C:\xampp\apache\conf\httpd.conf`
2. Find this line:
   ```apache
   #LoadModule rewrite_module modules/mod_rewrite.so
   ```
3. Remove the `#` to uncomment it:
   ```apache
   LoadModule rewrite_module modules/mod_rewrite.so
   ```

#### Step 3: Enable .htaccess Files
In the same `httpd.conf` file:

1. Find the `<Directory>` section for your htdocs:
   ```apache
   <Directory "C:/xampp/htdocs">
       AllowOverride None
       ...
   </Directory>
   ```

2. Change `AllowOverride None` to `AllowOverride All`:
   ```apache
   <Directory "C:/xampp/htdocs">
       AllowOverride All
       ...
   </Directory>
   ```

#### Step 4: Restart Apache
1. Open XAMPP Control Panel
2. Stop Apache
3. Start Apache

#### Step 5: Clear Browser Cache
- Press `Ctrl + Shift + Delete`
- Clear cached images and files
- Or use Incognito/Private mode

## Testing

1. Access: `http://192.168.11.40/exam-frontend/`
2. Login as a reviewee
3. Start an exam
4. Submit the exam
5. Should redirect to exam list without 404 error

## How It Works

### Before Fix:
```
User submits exam
  ↓
Vue Router: router.push('/exams')
  ↓
Browser requests: http://192.168.11.40/exams
  ↓
Apache: "No file at /exams" → 404 Error
```

### After Fix:
```
User submits exam
  ↓
Vue Router: router.push('/exams')
  ↓
Browser requests: http://192.168.11.40/exam-frontend/exams
  ↓
Apache: "No file, but .htaccess says redirect to index.html"
  ↓
Serves: index.html
  ↓
Vue Router: Handles /exams route → Shows exam list
```

## Verification

Check if .htaccess is working:
```powershell
# Test direct route access
Start-Process "http://192.168.11.40/exam-frontend/exams"
```

If it loads the app (not 404), .htaccess is working!

## Troubleshooting

### Still Getting 404?

1. **Check .htaccess exists:**
   ```powershell
   Test-Path "C:\xampp\htdocs\exam-frontend\.htaccess"
   ```

2. **Check mod_rewrite:**
   ```powershell
   Select-String -Path "C:\xampp\apache\conf\httpd.conf" -Pattern "LoadModule rewrite_module"
   ```
   Should NOT have `#` at the start.

3. **Check AllowOverride:**
   ```powershell
   Select-String -Path "C:\xampp\apache\conf\httpd.conf" -Pattern "AllowOverride"
   ```
   Should be `AllowOverride All` for htdocs directory.

4. **Check Apache error log:**
   ```
   C:\xampp\apache\logs\error.log
   ```

### Alternative: Use Hash Mode Router

If .htaccess doesn't work, you can use hash mode routing (URLs will have `#`):

In `frontend/src/router/index.js`:
```javascript
import { createRouter, createWebHashHistory } from 'vue-router'

const router = createRouter({
  history: createWebHashHistory(),
  routes: [...]
})
```

URLs will look like: `http://192.168.11.40/exam-frontend/#/exams`

## Summary

The 404 error after exam submission is fixed by:
1. ✅ Proper `.htaccess` configuration for SPA routing
2. ✅ Enabling Apache `mod_rewrite` module
3. ✅ Setting `AllowOverride All` in Apache config
4. ✅ Restarting Apache

Run `.\fix-lan-404-after-submit.ps1` to apply all fixes automatically!

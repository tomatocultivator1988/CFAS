# 🔧 MIME Type Error Fix Guide

## Problem
You're seeing this error in the browser console:
```
Failed to load module script: Expected a JavaScript module script 
but the server responded with a MIME type of "text/html"
```

## What This Means
The browser is trying to load JavaScript files (like `vue-vendor-BWkVCMxr.js`) but Apache is returning HTML (the index.html page) instead. This happens when the `.htaccess` file incorrectly rewrites requests for actual files.

## Quick Fix (Recommended)

### Option 1: Rebuild Everything
1. Double-click: `REBUILD-FRONTEND-FIX-MIME.bat`
2. Wait for the build to complete
3. Clear your browser cache (Ctrl + Shift + Delete)
4. Close all browser tabs
5. Open a new browser window
6. Go to: `http://192.168.11.40/exam-frontend`

### Option 2: Just Fix Apache Configuration
1. Double-click: `FIX-MIME-TYPE-ERROR.bat`
2. Clear your browser cache (Ctrl + Shift + Delete)
3. Close all browser tabs
4. Open a new browser window
5. Go to: `http://192.168.11.40/exam-frontend`

## Manual Fix (If Scripts Don't Work)

### Step 1: Update .htaccess
Edit `C:\xampp\htdocs\exam-frontend\.htaccess` and replace the content with:

```apache
# CRITICAL: Set MIME types BEFORE any rewrite rules
<IfModule mod_mime.c>
  AddType application/javascript .js
  AddType application/javascript .mjs
  AddType text/css .css
  AddType application/json .json
  AddType image/svg+xml .svg
  AddType image/png .png
  AddType image/jpeg .jpg .jpeg
  AddType image/webp .webp
  AddType font/woff .woff
  AddType font/woff2 .woff2
  AddType font/ttf .ttf
  AddType font/eot .eot
</IfModule>

<IfModule mod_rewrite.c>
  RewriteEngine On
  
  # CRITICAL: Don't rewrite actual files - serve them directly
  RewriteCond %{REQUEST_FILENAME} -f
  RewriteRule ^ - [L]
  
  # Don't rewrite directories
  RewriteCond %{REQUEST_FILENAME} -d
  RewriteRule ^ - [L]
  
  # Only rewrite non-existent files to index.html for Vue Router
  RewriteRule ^ index.html [L]
</IfModule>

# Disable directory browsing
Options -Indexes +FollowSymLinks

# Enable CORS for assets
<IfModule mod_headers.c>
  <FilesMatch "\.(js|mjs|css|json|svg|png|jpg|jpeg|webp|woff|woff2|ttf|eot)$">
    Header set Access-Control-Allow-Origin "*"
    Header set Cache-Control "public, max-age=31536000"
  </FilesMatch>
  
  # Ensure correct Content-Type headers
  <FilesMatch "\.js$">
    Header set Content-Type "application/javascript"
  </FilesMatch>
  
  <FilesMatch "\.mjs$">
    Header set Content-Type "application/javascript"
  </FilesMatch>
  
  <FilesMatch "\.css$">
    Header set Content-Type "text/css"
  </FilesMatch>
</IfModule>

# Set default charset
AddDefaultCharset UTF-8
```

### Step 2: Restart Apache
1. Open XAMPP Control Panel
2. Click "Stop" on Apache
3. Wait 2 seconds
4. Click "Start" on Apache

### Step 3: Clear Browser Cache
1. Press `Ctrl + Shift + Delete`
2. Select "Cached images and files"
3. Click "Clear data"
4. Close ALL browser tabs with the exam system
5. Open a new browser window

### Step 4: Test
Go to: `http://192.168.11.40/exam-frontend`

## Why This Happens

The issue occurs when:
1. **Wrong RewriteBase**: Using `RewriteBase /exam-frontend/` can cause issues
2. **Incorrect RewriteCond**: Using `[OR]` between file and directory checks
3. **Missing MIME types**: Apache doesn't know how to serve .js files correctly
4. **Browser cache**: Old cached files interfere with new ones

## The Fix Explained

### What We Changed:
1. **Removed RewriteBase**: Not needed when serving from a subdirectory
2. **Fixed RewriteCond**: Separate conditions for files and directories
3. **Added explicit MIME types**: Tell Apache exactly how to serve .js files
4. **Added Content-Type headers**: Force correct headers for JavaScript files

### Key Changes:
```apache
# OLD (WRONG):
RewriteCond %{REQUEST_FILENAME} -f [OR]
RewriteCond %{REQUEST_FILENAME} -d
RewriteRule ^ - [L]

# NEW (CORRECT):
RewriteCond %{REQUEST_FILENAME} -f
RewriteRule ^ - [L]

RewriteCond %{REQUEST_FILENAME} -d
RewriteRule ^ - [L]
```

## Verification

After applying the fix, check:

1. **Browser Console**: Should have NO errors
2. **Network Tab**: JavaScript files should load with `200 OK` status
3. **Content-Type**: Should be `application/javascript` for .js files
4. **Page Loads**: Application should load normally

## Still Not Working?

### Check Apache Modules
Make sure these modules are enabled in `C:\xampp\apache\conf\httpd.conf`:
- `mod_rewrite`
- `mod_mime`
- `mod_headers`

Look for these lines (should NOT have `#` at the start):
```apache
LoadModule rewrite_module modules/mod_rewrite.so
LoadModule mime_module modules/mod_mime.so
LoadModule headers_module modules/mod_headers.so
```

### Check File Permissions
Make sure Apache can read the files:
1. Right-click `C:\xampp\htdocs\exam-frontend`
2. Properties → Security
3. Make sure "Users" has "Read" permission

### Check Apache Error Log
Look at: `C:\xampp\apache\logs\error.log`
Check for any errors related to .htaccess or rewrite rules

## Prevention

To avoid this in the future:
1. Always use the provided deployment scripts
2. Don't manually edit .htaccess without testing
3. Clear browser cache after any deployment
4. Test in a fresh browser window/incognito mode

## Summary

The MIME type error is fixed by:
1. ✅ Correcting the .htaccess rewrite rules
2. ✅ Adding explicit MIME type declarations
3. ✅ Ensuring files are served directly (not rewritten)
4. ✅ Clearing browser cache
5. ✅ Restarting Apache

**Use the automated scripts for the easiest fix!**

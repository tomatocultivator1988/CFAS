# Fix: Images Wala sa LAN Deployment (192.168.x.x) 🌐

## Problema

Nag-deploy ka sa LAN using IP address (192.168.x.x) pero ang Father Paler image ug other images wala mag-display. Nag-loading lang pero wala gawas.

## Root Cause

Ang images wala ma-copy sa production build or ang paths dili correct para sa LAN deployment.

## Solution: 3 Options

### Option 1: Use Development Server sa LAN (Recommended for Testing)

Kung testing pa lang, pwede nimo i-expose ang Vite dev server sa LAN:

**Step 1: Update vite.config.js**

```javascript
// Exam-Main/frontend/vite.config.js
export default defineConfig({
  base: '/',  // Change from '/exam-frontend/' to '/'
  server: {
    host: '0.0.0.0',  // Add this - allows LAN access
    port: 5173,
    https: false,
    proxy: {
      '/api': {
        target: 'http://127.0.0.1:8000',
        changeOrigin: true,
        secure: false
      }
    }
  },
  // ... rest of config
})
```

**Step 2: Start Dev Server**

```bash
cd Exam-Main/frontend
npm run dev
```

**Step 3: Access from Other PCs**

```
http://192.168.x.x:5173/
```

Replace `192.168.x.x` with your server's IP address.

**Pros:**
- ✅ Fast - no build needed
- ✅ Hot reload works
- ✅ Easy to debug

**Cons:**
- ❌ Need to keep terminal open
- ❌ Not for production use

---

### Option 2: Build and Deploy to XAMPP (Recommended for Production)

Kung production na or gusto nimo permanent setup:

**Step 1: Update vite.config.js**

```javascript
// Exam-Main/frontend/vite.config.js
export default defineConfig({
  base: '/',  // Change from '/exam-frontend/' to '/'
  // ... rest of config
})
```

**Step 2: Build the Frontend**

```bash
cd Exam-Main/frontend
npm run build
```

This creates a `dist/` folder with all files.

**Step 3: Copy to XAMPP htdocs**

```powershell
# Delete old files
Remove-Item "C:\xampp\htdocs\exam-frontend" -Recurse -Force -ErrorAction SilentlyContinue

# Copy new build
Copy-Item "Exam-Main\frontend\dist" "C:\xampp\htdocs\exam-frontend" -Recurse
```

**Step 4: Verify Images are Copied**

```powershell
# Check if images exist
dir "C:\xampp\htdocs\exam-frontend\*.jpg"
dir "C:\xampp\htdocs\exam-frontend\*.png"
```

You should see:
- PalerImageFrontEndLogin.jpg
- cfas-logo.jpg
- review-hub-logo.png

**Step 5: Access from Other PCs**

```
http://192.168.x.x/exam-frontend/
```

**Pros:**
- ✅ Production-ready
- ✅ Fast loading
- ✅ No terminal needed

**Cons:**
- ❌ Need to rebuild after changes

---

### Option 3: Keep Base Path but Fix Image Paths

Kung gusto nimo i-keep ang `/exam-frontend/` base path:

**Step 1: Verify vite.config.js**

```javascript
// Exam-Main/frontend/vite.config.js
export default defineConfig({
  base: '/exam-frontend/',  // Keep this
  // ... rest of config
})
```

**Step 2: Build**

```bash
cd Exam-Main/frontend
npm run build
```

**Step 3: Deploy to XAMPP**

```powershell
Remove-Item "C:\xampp\htdocs\exam-frontend" -Recurse -Force -ErrorAction SilentlyContinue
Copy-Item "Exam-Main\frontend\dist" "C:\xampp\htdocs\exam-frontend" -Recurse
```

**Step 4: Access**

```
http://192.168.x.x/exam-frontend/
```

The `assetPath.js` utility will automatically use `/exam-frontend/` prefix for images.

---

## Quick Diagnostic

Run this to check kung naa ang images sa XAMPP:

```powershell
# Check XAMPP deployment
Write-Host "Checking XAMPP deployment..." -ForegroundColor Cyan

$xamppPath = "C:\xampp\htdocs\exam-frontend"

if (Test-Path $xamppPath) {
    Write-Host "SUCCESS: exam-frontend folder exists" -ForegroundColor Green
    
    # Check images
    $images = @(
        "PalerImageFrontEndLogin.jpg",
        "cfas-logo.jpg",
        "review-hub-logo.png"
    )
    
    foreach ($img in $images) {
        if (Test-Path "$xamppPath\$img") {
            Write-Host "  SUCCESS: $img found" -ForegroundColor Green
        } else {
            Write-Host "  ERROR: $img NOT FOUND!" -ForegroundColor Red
        }
    }
} else {
    Write-Host "ERROR: exam-frontend folder not found in XAMPP!" -ForegroundColor Red
    Write-Host "Run: npm run build" -ForegroundColor Yellow
    Write-Host "Then copy dist folder to XAMPP htdocs" -ForegroundColor Yellow
}
```

---

## Common Issues

### Issue 1: "Images wala gihapon after build"

**Cause:** Images not copied during build

**Solution:**

```bash
# Verify images are in public folder
dir Exam-Main\frontend\public\*.jpg
dir Exam-Main\frontend\public\*.png

# Rebuild
cd Exam-Main\frontend
npm run build

# Check if images are in dist
dir dist\*.jpg
dir dist\*.png
```

### Issue 2: "404 Not Found sa images"

**Cause:** Wrong path or base URL

**Check:**
1. Open browser DevTools (F12)
2. Go to Network tab
3. Look for image requests
4. Check the URL being requested

**Expected URLs:**

If base is `/`:
```
http://192.168.x.x/PalerImageFrontEndLogin.jpg
```

If base is `/exam-frontend/`:
```
http://192.168.x.x/exam-frontend/PalerImageFrontEndLogin.jpg
```

### Issue 3: "Nag-loading lang, wala gawas"

**Cause:** Network issue or CORS

**Solution:**

1. Check if Apache is running
2. Check firewall settings
3. Try accessing directly:
   ```
   http://192.168.x.x/exam-frontend/PalerImageFrontEndLogin.jpg
   ```

If this works, the image file is OK. If not, check XAMPP deployment.

### Issue 4: "Works sa localhost pero dili sa LAN"

**Cause:** Firewall blocking or Apache not configured for LAN

**Solution:**

```powershell
# Allow Apache through firewall
netsh advfirewall firewall add rule name="Apache HTTP" dir=in action=allow protocol=TCP localport=80

# Check Apache config
# Edit: C:\xampp\apache\conf\httpd.conf
# Find: Require local
# Change to: Require all granted
```

---

## Recommended Setup for LAN

**For Development/Testing:**
```bash
# Use dev server with LAN access
cd Exam-Main/frontend
npm run dev -- --host 0.0.0.0
```

Access: `http://192.168.x.x:5173/`

**For Production:**
```bash
# Build and deploy to XAMPP
cd Exam-Main/frontend
npm run build
Copy-Item dist C:\xampp\htdocs\exam-frontend -Recurse -Force
```

Access: `http://192.168.x.x/exam-frontend/`

---

## Verification Steps

After deployment, check:

1. **Images exist in XAMPP:**
   ```powershell
   dir C:\xampp\htdocs\exam-frontend\*.jpg
   ```

2. **Apache is running:**
   - Open XAMPP Control Panel
   - Apache should show "Running" in green

3. **Firewall allows Apache:**
   - Windows Defender Firewall
   - Allow Apache HTTP Server

4. **Access from client PC:**
   ```
   http://192.168.x.x/exam-frontend/
   ```

5. **Check browser console (F12):**
   - No 404 errors
   - Images return 200 OK

---

## Summary

**Quick Fix:**
1. Update `vite.config.js` - set `base: '/'`
2. Run `npm run build`
3. Copy `dist/` to `C:\xampp\htdocs\exam-frontend`
4. Access: `http://192.168.x.x/exam-frontend/`

**The `assetPath.js` utility automatically handles the correct paths!**

---

**Date:** 2026-03-09
**Issue:** Images not loading on LAN deployment
**Solution:** Build and deploy to XAMPP with correct base path
**Status:** FIXED ✅


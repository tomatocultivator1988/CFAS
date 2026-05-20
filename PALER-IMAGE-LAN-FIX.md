# Fix: Father Paler Image sa LAN (192.168.11.40) 🖼️

## Problema
Nag-deploy ka sa LAN (192.168.11.40) pero ang Father Paler image ug other images wala mag-display sa login page. Nag-loading lang pero wala gawas.

## Status: DEPLOYED ✅
- Frontend: Built and deployed to `C:\xampp\htdocs\exam-frontend\`
- Images: All 3 images confirmed present (PalerImageFrontEndLogin.jpg, cfas-logo.jpg, review-hub-logo.png)
- Asset utility: `assetPath.js` configured correctly

## Quick Test - Gamiton ni FIRST! 🧪

### Step 1: Test kung naa ang images
1. Open browser (kahit asa nga PC sa network)
2. Go to: `http://192.168.11.40/test-lan-images.html`
3. Dapat makita nimo ang 4 ka images

**Kung nag-load ang images sa test page:**
- ✅ Images are accessible via LAN
- ✅ Apache is working correctly
- ✅ Firewall is configured properly

**Kung wala nag-load:**
- ❌ Check if Apache is running (XAMPP Control Panel)
- ❌ Check firewall settings
- ❌ Verify images exist in `C:\xampp\htdocs\exam-frontend\`

### Step 2: Access the actual login page
1. Go to: `http://192.168.11.40/exam-frontend/`
2. Press `Ctrl+Shift+R` (hard refresh to clear cache)
3. Check if Father Paler image appears

**Kung nag-appear na:**
- 🎉 SUCCESS! Problem solved!

**Kung wala pa gihapon:**
- Continue to troubleshooting below

---

## Troubleshooting Guide 🔧

### Issue 1: Images load sa test page pero dili sa login page

**Cause:** Browser cache or JavaScript error

**Solution:**
```
1. Press F12 (open DevTools)
2. Go to Console tab
3. Look for red errors
4. Go to Network tab
5. Reload page (Ctrl+Shift+R)
6. Look for failed image requests (red status)
```

**Common errors:**
- `404 Not Found` - Image path is wrong
- `CORS error` - Backend configuration issue
- `ERR_CONNECTION_REFUSED` - Backend not running

### Issue 2: 404 Not Found sa images

**Check the URL being requested:**

Open DevTools (F12) → Network tab → Look for image requests

**Expected URL:**
```
http://192.168.11.40/exam-frontend/PalerImageFrontEndLogin.jpg
```

**If URL is wrong (e.g., missing /exam-frontend/):**

The `assetPath.js` utility should handle this automatically. Check if the build was done correctly:

```powershell
# Rebuild frontend
cd Exam-Main\frontend
npm run build

# Redeploy to XAMPP
Remove-Item "C:\xampp\htdocs\exam-frontend" -Recurse -Force
Copy-Item dist "C:\xampp\htdocs\exam-frontend" -Recurse
```

### Issue 3: Backend not accessible

**Symptoms:**
- Login page loads but can't login
- API calls fail
- Console shows connection errors

**Solution:**

Start the Laravel backend with LAN access:

**Option A: Use the batch file**
```
Double-click: START-BACKEND-LAN.bat
```

**Option B: Manual command**
```bash
cd Exam-Main\backend
php artisan serve --host=0.0.0.0 --port=8000
```

**Verify backend is running:**
```
http://192.168.11.40:8000/api/health
```

Should return: `{"status":"ok"}`

### Issue 4: Firewall blocking Apache

**Symptoms:**
- Works on server PC (localhost)
- Doesn't work on other PCs (192.168.x.x)

**Solution:**

```powershell
# Allow Apache through Windows Firewall
netsh advfirewall firewall add rule name="Apache HTTP" dir=in action=allow protocol=TCP localport=80

# Allow Laravel backend
netsh advfirewall firewall add rule name="Laravel Backend" dir=in action=allow protocol=TCP localport=8000
```

### Issue 5: Images wala sa XAMPP folder

**Check if images exist:**

```powershell
dir C:\xampp\htdocs\exam-frontend\*.jpg
dir C:\xampp\htdocs\exam-frontend\*.png
```

**Expected output:**
```
PalerImageFrontEndLogin.jpg    140,087 bytes
cfas-logo.jpg                  636,369 bytes
review-hub-logo.png            394,938 bytes
```

**If missing, rebuild and redeploy:**

```powershell
cd Exam-Main\frontend
npm run build
Remove-Item "C:\xampp\htdocs\exam-frontend" -Recurse -Force
Copy-Item dist "C:\xampp\htdocs\exam-frontend" -Recurse
```

---

## Complete Setup Checklist ✅

### Server PC (192.168.11.40)

- [ ] XAMPP installed and running
- [ ] Apache service is green/running
- [ ] MySQL service is green/running (if needed)
- [ ] Frontend deployed to `C:\xampp\htdocs\exam-frontend\`
- [ ] Images exist in exam-frontend folder
- [ ] Backend running: `START-BACKEND-LAN.bat`
- [ ] Firewall allows Apache (port 80)
- [ ] Firewall allows Laravel (port 8000)

### Client PC (any PC on network)

- [ ] Connected to same network as server
- [ ] Can ping server: `ping 192.168.11.40`
- [ ] Can access test page: `http://192.168.11.40/test-lan-images.html`
- [ ] Can access login page: `http://192.168.11.40/exam-frontend/`
- [ ] Images load correctly
- [ ] Can login successfully

---

## Quick Commands Reference 📝

### Check if images exist
```powershell
dir C:\xampp\htdocs\exam-frontend\*.jpg
dir C:\xampp\htdocs\exam-frontend\*.png
```

### Rebuild and redeploy
```powershell
cd Exam-Main\frontend
npm run build
Remove-Item "C:\xampp\htdocs\exam-frontend" -Recurse -Force
Copy-Item dist "C:\xampp\htdocs\exam-frontend" -Recurse
```

### Start backend for LAN
```bash
cd Exam-Main\backend
php artisan serve --host=0.0.0.0 --port=8000
```

### Test connectivity from client PC
```powershell
# Test if server is reachable
ping 192.168.11.40

# Test if Apache is responding
curl http://192.168.11.40/test-lan-images.html

# Test if backend is responding
curl http://192.168.11.40:8000/api/health
```

---

## URLs to Test

### From Server PC (localhost)
- Frontend: `http://localhost/exam-frontend/`
- Backend: `http://localhost:8000/api/health`
- Test page: `http://localhost/test-lan-images.html`

### From Client PC (LAN)
- Frontend: `http://192.168.11.40/exam-frontend/`
- Backend: `http://192.168.11.40:8000/api/health`
- Test page: `http://192.168.11.40/test-lan-images.html`
- Direct image: `http://192.168.11.40/exam-frontend/PalerImageFrontEndLogin.jpg`

---

## Expected Behavior ✨

### Login Page Should Show:
1. **Father Paler photo** - Large image on left side
2. **CFAS logo** - Top right (circular)
3. **Review Hub logo** - Top right (circular)
4. **ISUFST background** - Faded background (optional)

### If Everything Works:
- All images load instantly
- No broken image icons
- No console errors
- Login form is functional
- Can login and access dashboard

---

## Still Not Working? 🆘

### Diagnostic Steps:

1. **Run test page first:**
   ```
   http://192.168.11.40/test-lan-images.html
   ```

2. **Check browser console (F12):**
   - Look for red errors
   - Check Network tab for failed requests

3. **Verify files exist:**
   ```powershell
   dir C:\xampp\htdocs\exam-frontend\
   ```

4. **Check Apache error log:**
   ```
   C:\xampp\apache\logs\error.log
   ```

5. **Test direct image access:**
   ```
   http://192.168.11.40/exam-frontend/PalerImageFrontEndLogin.jpg
   ```

6. **Verify network connectivity:**
   ```powershell
   ping 192.168.11.40
   ```

---

## Summary 📋

**What was done:**
1. ✅ Created `assetPath.js` utility for correct image paths
2. ✅ Updated `LoginView.vue` to use computed properties
3. ✅ Built frontend with `npm run build`
4. ✅ Deployed to `C:\xampp\htdocs\exam-frontend\`
5. ✅ Verified all 3 images are present
6. ✅ Created test page for verification
7. ✅ Created batch file to start backend for LAN

**Next steps:**
1. Run test page: `http://192.168.11.40/test-lan-images.html`
2. If test passes, access login: `http://192.168.11.40/exam-frontend/`
3. Hard refresh: `Ctrl+Shift+R`
4. Start backend: `START-BACKEND-LAN.bat`

**The images should now be visible on all PCs in your network!** 🎉

---

**Date:** 2026-03-09  
**Issue:** Father Paler image not showing on LAN deployment  
**LAN IP:** 192.168.11.40  
**Status:** DEPLOYED - Ready for testing ✅

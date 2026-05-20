# 🔧 CFAS Login Troubleshooting Guide
## Giya sa Pag-ayo sang Login Problems

---

## 🚨 PROBLEMA: Indi ka maka-login after deployment

Kon indi ka maka-login sa system after deployment, sundon ini nga mga hakang:

---

## ⚡ QUICK FIX (Madali nga Solusyon)

### Hakang 1: Run ang Diagnostic Tool

1. Adto sa folder: `Exam-Main`
2. Double-click: `DIAGNOSE-LOGIN.bat`
3. Antay hasta matapos ang diagnostic
4. Basaha ang results

### Hakang 2: Sundon ang Recommendations

Ang diagnostic tool mag-sulti kon ano ang problema kag ano ang solusyon.

---

## 🔍 COMMON PROBLEMS & SOLUTIONS

### Problem 1: Apache indi nag-run

**Symptoms:**
- Indi mag-load ang website
- "Connection refused" error
- "This site can't be reached"

**Solution:**
1. Buksan ang XAMPP Control Panel
2. I-click ang "Start" sa Apache
3. Antay hasta mag-green
4. Try ulit ang login

---

### Problem 2: MySQL indi nag-run

**Symptoms:**
- "Database connection error"
- "SQLSTATE[HY000]" error
- Login button indi nag-work

**Solution:**
1. Buksan ang XAMPP Control Panel
2. I-click ang "Start" sa MySQL
3. Antay hasta mag-green
4. Try ulit ang login

---

### Problem 3: Backend API indi nag-respond

**Symptoms:**
- Login button nag-load pero wala nag-happen
- "Network Error" sa browser console
- "404 Not Found" error

**Solution:**
1. Run: `fix-apache-routing-simple.ps1`
2. Restart Apache sa XAMPP
3. Clear browser cache (Ctrl+Shift+Delete)
4. Try ulit ang login

**Manual Fix:**
```powershell
cd "C:\Users\Hi\Desktop\CFAS REVIEW CENTER EXAMINATION SYSTEM\Exam-Main"
powershell -ExecutionPolicy Bypass -File "fix-apache-routing-simple.ps1"
```

---

### Problem 4: Frontend using wrong API URL

**Symptoms:**
- Login fails with "Network Error"
- Browser console shows wrong URL
- API calls going to localhost instead of 192.168.11.40

**Solution:**
1. Run: `rebuild-frontend-simple.ps1`
2. Antay hasta matapos ang build (5-10 minutes)
3. Clear browser cache (Ctrl+Shift+Delete)
4. Close browser completely
5. Open browser ulit
6. Try ang login

**Manual Fix:**
```powershell
cd "C:\Users\Hi\Desktop\CFAS REVIEW CENTER EXAMINATION SYSTEM\Exam-Main"
powershell -ExecutionPolicy Bypass -File "rebuild-frontend-simple.ps1"
```

---

### Problem 5: Wrong username or password

**Symptoms:**
- "Invalid credentials" error
- "Wrong username or password"
- Login form shakes

**Solution:**

**Default Credentials:**
- Username: `admin`
- Password: `admin123`

**Kon nakalimtan ang password:**
1. Run: `reset-admin-password.php`
```cmd
cd "C:\xampp\htdocs\exam-backend"
php reset-admin-password.php
```
2. Ang password ma-reset to: `admin123`
3. Try ulit ang login

---

### Problem 6: Browser cache issue

**Symptoms:**
- Old version sang website nag-load
- Changes indi makita
- Login indi nag-work after update

**Solution:**

**Clear Cache (Chrome/Edge):**
1. Press: `Ctrl + Shift + Delete`
2. Select: "Cached images and files"
3. Time range: "All time"
4. Click: "Clear data"
5. Close browser completely
6. Open browser ulit
7. Go to: `http://192.168.11.40/exam-frontend`

**Clear Cache (Firefox):**
1. Press: `Ctrl + Shift + Delete`
2. Select: "Cache"
3. Time range: "Everything"
4. Click: "Clear Now"
5. Close browser completely
6. Open browser ulit
7. Go to: `http://192.168.11.40/exam-frontend`

---

### Problem 7: CORS errors

**Symptoms:**
- "CORS policy" error sa console
- "Access-Control-Allow-Origin" error
- API calls blocked

**Solution:**
1. Run: `fix-apache-routing-simple.ps1`
2. Restart Apache
3. Clear browser cache
4. Try ulit

---

### Problem 8: Session/Token issues

**Symptoms:**
- Login successful pero immediately logout
- "Token expired" error
- "Unauthorized" error

**Solution:**
1. Clear browser cache
2. Clear localStorage:
   - Press F12 (Developer Tools)
   - Go to "Application" tab
   - Click "Local Storage"
   - Right-click → "Clear"
3. Close browser
4. Open browser ulit
5. Try login

---

## 🛠️ DIAGNOSTIC CHECKLIST

Sundon ini nga checklist para ma-diagnose ang problema:

### Environment Checks:
- [ ] Apache is running (green sa XAMPP)
- [ ] MySQL is running (green sa XAMPP)
- [ ] Backend files exist sa `C:\xampp\htdocs\exam-backend`
- [ ] Frontend files exist sa `C:\xampp\htdocs\exam-frontend`

### Backend Checks:
- [ ] Health API responds: `http://192.168.11.40/exam-backend/public/api/health`
- [ ] .htaccess exists sa `exam-backend` folder
- [ ] .htaccess exists sa `exam-backend/public` folder
- [ ] Database connection working

### Frontend Checks:
- [ ] Frontend loads: `http://192.168.11.40/exam-frontend`
- [ ] Login page displays correctly
- [ ] No console errors (F12)
- [ ] API URL is correct sa network tab

### Authentication Checks:
- [ ] Login endpoint responds: `POST /api/auth/login`
- [ ] Admin user exists sa database
- [ ] Password is correct
- [ ] Token is generated

---

## 🔬 ADVANCED TROUBLESHOOTING

### Check Backend API Health:

**Using Browser:**
1. Open: `http://192.168.11.40/exam-backend/public/api/health`
2. Dapat makita:
```json
{
  "status": "ok",
  "message": "CFAS Exam System API is running",
  "timestamp": "...",
  "version": "1.0.0"
}
```

**Using PowerShell:**
```powershell
Invoke-WebRequest -Uri "http://192.168.11.40/exam-backend/public/api/health" -UseBasicParsing
```

### Check Database Connection:

```cmd
cd C:\xampp\mysql\bin
mysql -u root -e "USE review_center_exam; SELECT COUNT(*) FROM users;"
```

Dapat may result. Kon may error, ang database indi nag-run or wala ang database.

### Check Apache Error Logs:

```cmd
notepad C:\xampp\apache\logs\error.log
```

Basaha ang latest errors para makita kon ano ang problema.

### Check PHP Errors:

```cmd
notepad C:\xampp\htdocs\exam-backend\storage\logs\laravel.log
```

Basaha ang latest errors sa backend.

---

## 📞 STEP-BY-STEP COMPLETE FIX

Kon wala pa gid nag-work ang tanan, sundon ini nga complete fix:

### Step 1: Stop Everything
1. Close all browsers
2. Stop Apache sa XAMPP
3. Stop MySQL sa XAMPP

### Step 2: Fix Backend
```powershell
cd "C:\Users\Hi\Desktop\CFAS REVIEW CENTER EXAMINATION SYSTEM\Exam-Main"
powershell -ExecutionPolicy Bypass -File "fix-apache-routing-simple.ps1"
```

### Step 3: Rebuild Frontend
```powershell
cd "C:\Users\Hi\Desktop\CFAS REVIEW CENTER EXAMINATION SYSTEM\Exam-Main"
powershell -ExecutionPolicy Bypass -File "rebuild-frontend-simple.ps1"
```

### Step 4: Reset Admin Password
```cmd
cd C:\xampp\htdocs\exam-backend
php reset-admin-password.php
```

### Step 5: Start Services
1. Start MySQL sa XAMPP (wait for green)
2. Start Apache sa XAMPP (wait for green)

### Step 6: Clear Browser
1. Press: `Ctrl + Shift + Delete`
2. Clear: "Cached images and files"
3. Time: "All time"
4. Click: "Clear data"
5. Close browser completely

### Step 7: Test Login
1. Open browser
2. Go to: `http://192.168.11.40/exam-frontend`
3. Username: `admin`
4. Password: `admin123`
5. Click: "Continue"

**DAPAT MAG-WORK NA!** ✅

---

## 🎯 PREVENTION TIPS

Para indi na mag-occur ang login problems:

1. **Always start XAMPP first** before opening browser
2. **Don't close XAMPP** while using the system
3. **Clear cache regularly** after updates
4. **Use the launcher** (`START-CFAS-FINAL.bat`) instead of manual
5. **Don't modify files** sa `C:\xampp\htdocs` directly
6. **Always deploy properly** using the deployment scripts

---

## 📊 DIAGNOSTIC TOOL OUTPUT

Ang diagnostic tool mag-show sang:

### PASS (Green):
- Component is working correctly
- No action needed

### FAIL (Red):
- Component has issues
- Follow the recommended fix

### ERROR (Red):
- Component cannot be tested
- Check if service is running

---

## 🆘 EMERGENCY RECOVERY

Kon wala gid nag-work ang tanan:

### Option 1: Complete Reinstall
1. Backup database:
```cmd
cd C:\xampp\mysql\bin
mysqldump -u root review_center_exam > backup.sql
```

2. Delete deployed files:
```cmd
rmdir /s /q C:\xampp\htdocs\exam-backend
rmdir /s /q C:\xampp\htdocs\exam-frontend
```

3. Redeploy:
```powershell
cd "C:\Users\Hi\Desktop\CFAS REVIEW CENTER EXAMINATION SYSTEM\Exam-Main"
.\SETUP-APACHE-BACKEND.bat
.\REBUILD-AND-DEPLOY-FRONTEND.bat
```

4. Restore database (if needed):
```cmd
cd C:\xampp\mysql\bin
mysql -u root review_center_exam < backup.sql
```

### Option 2: Rollback to Working Version
1. Check git history
2. Rollback to last working commit
3. Redeploy

---

## 📝 LOGGING & MONITORING

### Enable Detailed Logging:

**Backend (.env):**
```
APP_DEBUG=true
LOG_LEVEL=debug
```

**Frontend (browser console):**
1. Press F12
2. Go to "Console" tab
3. Check for errors

### Monitor API Calls:
1. Press F12
2. Go to "Network" tab
3. Filter: "XHR"
4. Watch API requests/responses

---

## ✅ VERIFICATION CHECKLIST

After fixing, verify:

- [ ] Can access: `http://192.168.11.40/exam-frontend`
- [ ] Login page loads without errors
- [ ] Can login with admin/admin123
- [ ] Dashboard loads after login
- [ ] No errors sa browser console (F12)
- [ ] No errors sa Network tab (F12)
- [ ] Token is stored sa localStorage
- [ ] Can navigate to different pages
- [ ] Can logout successfully
- [ ] Can login again after logout

**Kon TANAN checked, FIXED NA!** ✅

---

## 🎉 SUCCESS!

Kon nag-work na ang login:

1. **Test thoroughly** - Try all features
2. **Document changes** - Note what fixed it
3. **Train users** - Show them how to login
4. **Monitor** - Watch for issues
5. **Backup** - Save working configuration

---

## 📞 SUPPORT

Kon may problema pa:

1. **Run diagnostic tool** - `DIAGNOSE-LOGIN.bat`
2. **Check this guide** - Follow all steps
3. **Check logs** - Apache, PHP, Laravel
4. **Contact IT support** - Provide diagnostic results

---

**Remember:** Most login problems are caused by:
1. Services not running (Apache/MySQL)
2. Browser cache issues
3. Wrong API URL configuration
4. Missing .htaccess files

**Always try the simple fixes first!**

---

**System Version:** CFAS Exam System v2.0  
**Guide Version:** 1.0  
**Last Updated:** March 24, 2026  

---

**END OF GUIDE**

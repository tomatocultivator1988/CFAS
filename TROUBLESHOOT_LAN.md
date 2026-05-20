# 🔧 LAN Access Troubleshooting Guide

## Your Current Setup
- **Server IP**: `192.168.11.40`
- **Access URL**: `http://192.168.11.40/exam-frontend`
- **Apache**: ✅ Running
- **Port 80**: ✅ Listening on all interfaces
- **Firewall**: ✅ Rule exists
- **Backend Config**: ✅ Configured with IP
- **Frontend Config**: ✅ Configured with IP

---

## 🚨 Common Issues & Solutions

### Issue 1: "Can't reach this page" or "Connection timed out"

**Possible Causes:**
1. **Client PC not on same network**
2. **Windows Firewall blocking on server**
3. **Antivirus blocking connections**

**Solutions:**

#### A. Verify Same Network
On **client PC**, open Command Prompt:
```cmd
ipconfig
```
Check if IP starts with `192.168.11.x` (same subnet as server)

#### B. Test Ping
On **client PC**:
```cmd
ping 192.168.11.40
```
- ✅ If replies: Network is OK
- ❌ If timeout: Network issue or firewall

#### C. Temporarily Disable Firewall (Testing Only)
On **server PC**, run as admin:
```powershell
netsh advfirewall set allprofiles state off
```
Try accessing from client. If it works, firewall is the issue.

Turn firewall back on:
```powershell
netsh advfirewall set allprofiles state on
```

Then add proper rule:
```powershell
netsh advfirewall firewall add rule name="Apache HTTP" dir=in action=allow protocol=TCP localport=80
```

#### D. Check Antivirus
- Temporarily disable antivirus on server PC
- Try accessing from client
- If works, add exception for Apache/XAMPP

---

### Issue 2: "403 Forbidden" Error

**Cause:** Apache access control blocking external connections

**Solution:**
Edit `C:\xampp\apache\conf\httpd.conf`

Find sections like:
```apache
<Directory "C:/xampp/htdocs">
    Require local
</Directory>
```

Change to:
```apache
<Directory "C:/xampp/htdocs">
    Require all granted
</Directory>
```

Restart Apache in XAMPP.

---

### Issue 3: Frontend loads but API calls fail

**Symptoms:**
- Page loads but shows errors
- Login doesn't work
- Data doesn't load

**Cause:** CORS or API URL misconfiguration

**Solution A: Check Browser Console**
1. Press F12 in browser
2. Go to Console tab
3. Look for CORS errors

**Solution B: Verify Frontend Built with Correct IP**
The frontend must be rebuilt after changing IP:

```bash
cd Exam-Main/frontend
npm run build
```

Then copy `dist` folder contents to `C:\xampp\htdocs\exam-frontend`

**Solution C: Update CORS**
Edit `Exam-Main/backend/config/cors.php`:

```php
'allowed_origins' => [
    'http://localhost:5173',
    'http://192.168.11.40',
    'http://192.168.11.40/exam-frontend',
],

'allowed_origins_patterns' => [
    '/^https?:\/\/192\.168\.11\.\d+$/'
],
```

---

### Issue 4: Works on server PC but not on client PCs

**Cause:** Firewall or network isolation

**Solution:**

#### A. Check Windows Firewall Profile
On **server PC**:
```powershell
Get-NetFirewallProfile | Select-Object Name, Enabled
```

Make sure Apache rule is enabled for active profile:
```powershell
netsh advfirewall firewall show rule name="Apache HTTP"
```

#### B. Check Network Profile
On **server PC**:
```powershell
Get-NetConnectionProfile
```

If showing "Public", change to "Private":
```powershell
Set-NetConnectionProfile -InterfaceAlias "Ethernet" -NetworkCategory Private
```

#### C. Test Port from Client
On **client PC**:
```powershell
Test-NetConnection -ComputerName 192.168.11.40 -Port 80
```

Should show `TcpTestSucceeded : True`

---

### Issue 5: IP Address Changed

**Symptoms:**
- Worked before, now doesn't
- Server got new IP from DHCP

**Solution:**

#### A. Find New IP
On **server PC**:
```powershell
ipconfig
```

#### B. Update All Configurations
Run the fix script:
```powershell
cd Exam-Main
.\fix-lan-access.ps1
```

Or manually update:
1. `backend/.env` → `APP_URL`
2. `frontend/src/services/api.js` → `baseURL`
3. `backend/config/cors.php` → `allowed_origins`
4. Rebuild frontend
5. Restart Apache

#### C. Set Static IP (Recommended)
1. Open Network Settings
2. Change adapter options
3. Right-click Ethernet → Properties
4. Select IPv4 → Properties
5. Use these settings:
   - IP: `192.168.11.40`
   - Subnet: `255.255.255.0`
   - Gateway: `192.168.11.1` (your router)
   - DNS: `8.8.8.8`

---

### Issue 6: "Mixed Content" or HTTPS Errors

**Cause:** Browser blocking HTTP content

**Solution:**
For now, use HTTP. For production:
1. Get SSL certificate
2. Configure Apache for HTTPS
3. Update all URLs to HTTPS

---

## 🧪 Testing Checklist

### On Server PC:
- [ ] Apache running in XAMPP
- [ ] Can access `http://localhost/exam-frontend`
- [ ] Can access `http://192.168.11.40/exam-frontend`
- [ ] Firewall rule exists
- [ ] Port 80 listening on `0.0.0.0:80`

### On Client PC:
- [ ] Connected to same network
- [ ] Can ping `192.168.11.40`
- [ ] Can access `http://192.168.11.40/exam-frontend`
- [ ] Can login successfully
- [ ] Can see exams list

---

## 🔍 Quick Diagnostic Commands

### On Server PC:

**Check IP:**
```powershell
ipconfig | findstr IPv4
```

**Check Apache:**
```powershell
Get-Process httpd
```

**Check Port:**
```powershell
netstat -an | findstr :80
```

**Check Firewall:**
```powershell
netsh advfirewall firewall show rule name="Apache HTTP"
```

### On Client PC:

**Check Network:**
```cmd
ipconfig
```

**Test Connection:**
```cmd
ping 192.168.11.40
```

**Test Port:**
```powershell
Test-NetConnection -ComputerName 192.168.11.40 -Port 80
```

**Test in Browser:**
```
http://192.168.11.40/exam-frontend
```

---

## 📱 Quick Fix Script

Run this on **server PC** as Administrator:

```powershell
cd Exam-Main
.\fix-lan-access.ps1
```

This will:
1. Add firewall rules
2. Update Apache config
3. Update backend .env
4. Update frontend API URL
5. Update CORS config

Then:
1. Restart Apache
2. Rebuild frontend: `cd frontend && npm run build`
3. Copy dist to `C:\xampp\htdocs\exam-frontend`

---

## 🆘 Still Not Working?

### Check Apache Error Log:
```
C:\xampp\apache\logs\error.log
```

### Check Laravel Log:
```
Exam-Main/backend/storage/logs/laravel.log
```

### Enable Debug Mode:
Edit `Exam-Main/backend/.env`:
```
APP_DEBUG=true
```

### Test Backend API Directly:
In browser on client PC:
```
http://192.168.11.40/exam-backend/api/health
```

Should return JSON response.

---

## 📞 Common Error Messages

| Error | Cause | Solution |
|-------|-------|----------|
| "This site can't be reached" | Network/Firewall | Check ping, firewall rules |
| "403 Forbidden" | Apache access control | Change `Require local` to `Require all granted` |
| "CORS policy" | CORS misconfiguration | Update cors.php with server IP |
| "Failed to fetch" | API URL wrong | Check frontend API URL |
| "Connection refused" | Apache not running | Start Apache in XAMPP |
| "Timeout" | Firewall blocking | Add firewall rule |

---

## ✅ Success Indicators

When everything works:
- ✅ Client can ping server IP
- ✅ Client can access frontend URL
- ✅ Login page loads completely
- ✅ Can login successfully
- ✅ Dashboard loads with data
- ✅ No errors in browser console (F12)

---

**Your Access URL:** `http://192.168.11.40/exam-frontend`

Share this URL with all students on the same network!

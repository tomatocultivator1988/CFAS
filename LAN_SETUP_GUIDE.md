# 🌐 LAN Network Setup Guide

## Access the Exam System from Other PCs on Same Network

### 📋 Prerequisites
- All PCs connected to same router/network
- XAMPP running on server PC
- Windows Firewall configured

---

## 🔧 Step 1: Find Your Server PC's IP Address

On the **SERVER PC** (where XAMPP is installed):

```powershell
ipconfig
```

Look for **IPv4 Address** under your active network adapter:
- Example: `192.168.1.100`
- Or: `192.168.0.50`

**Note this IP address!**

---

## 🔥 Step 2: Configure Windows Firewall

### Option A: Allow Apache through Firewall (Recommended)

1. Open **Windows Defender Firewall**
2. Click **"Allow an app through firewall"**
3. Click **"Change settings"**
4. Find **"Apache HTTP Server"** in the list
5. Check both **Private** and **Public** boxes
6. Click **OK**

### Option B: Create Firewall Rule Manually

Run as Administrator:

```powershell
# Allow port 80 (HTTP)
netsh advfirewall firewall add rule name="Apache HTTP" dir=in action=allow protocol=TCP localport=80

# Allow port 443 (HTTPS) - optional
netsh advfirewall firewall add rule name="Apache HTTPS" dir=in action=allow protocol=TCP localport=443
```

---

## ⚙️ Step 3: Configure Apache (XAMPP)

### Edit httpd.conf

1. Open XAMPP Control Panel
2. Click **Config** next to Apache
3. Select **httpd.conf**
4. Find this line:
   ```apache
   Listen 80
   ```
5. Make sure it says `Listen 80` (not `Listen 127.0.0.1:80`)

6. Find this section:
   ```apache
   <Directory "C:/xampp/htdocs">
       Options Indexes FollowSymLinks Includes ExecCGI
       AllowOverride All
       Require local
   </Directory>
   ```

7. Change `Require local` to:
   ```apache
   Require all granted
   ```

8. Save and **Restart Apache**

---

## 🔧 Step 4: Update Frontend Configuration

### Update API Base URL

Edit: `Exam-Main/frontend/src/services/api.js`

Change from:
```javascript
const API_BASE_URL = 'http://localhost/exam-backend/api'
```

To (use your server IP):
```javascript
const API_BASE_URL = 'http://192.168.1.100/exam-backend/api'
```

### Rebuild Frontend

```bash
cd Exam-Main/frontend
npm run build
```

Copy `dist` folder contents to `C:\xampp\htdocs\exam-frontend`

---

## 🔧 Step 5: Update Backend Configuration

### Edit .env file

Edit: `Exam-Main/backend/.env`

Update these lines:
```env
APP_URL=http://192.168.1.100/exam-backend

# Update CORS settings
FRONTEND_URL=http://192.168.1.100/exam-frontend
```

### Update CORS Configuration

Edit: `Exam-Main/backend/config/cors.php`

```php
'allowed_origins' => [
    'http://localhost:5173',
    'http://localhost',
    'http://192.168.1.100',  // Add your server IP
    'http://192.168.1.*',    // Allow all IPs in subnet
],
```

---

## 🧪 Step 6: Test Connection

### From Server PC:
```
http://192.168.1.100/exam-frontend
```

### From Client PC:
```
http://192.168.1.100/exam-frontend
```

---

## 📱 Step 7: Access from Client PCs

On any PC connected to the same network:

1. Open web browser
2. Go to: `http://[SERVER-IP]/exam-frontend`
   - Example: `http://192.168.1.100/exam-frontend`
3. Login with credentials

---

## 🔍 Troubleshooting

### Can't Access from Other PCs?

**1. Check Firewall:**
```powershell
# Test if port 80 is open
Test-NetConnection -ComputerName 192.168.1.100 -Port 80
```

**2. Check Apache is Listening:**
```powershell
netstat -an | findstr :80
```

Should show: `0.0.0.0:80` (not `127.0.0.1:80`)

**3. Ping Server PC:**
```powershell
ping 192.168.1.100
```

**4. Check Apache Error Logs:**
- `C:\xampp\apache\logs\error.log`

**5. Temporarily Disable Firewall (Testing Only):**
```powershell
# Turn off firewall (TESTING ONLY!)
netsh advfirewall set allprofiles state off

# Turn back on
netsh advfirewall set allprofiles state on
```

---

## 🚀 Quick Setup Script

Save as `setup-lan-access.ps1`:

```powershell
# Get server IP
$ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*"} | Select-Object -First 1).IPAddress

Write-Host "🌐 Server IP: $ip" -ForegroundColor Cyan

# Add firewall rules
Write-Host "`n🔥 Adding firewall rules..." -ForegroundColor Yellow
netsh advfirewall firewall add rule name="Apache HTTP" dir=in action=allow protocol=TCP localport=80
netsh advfirewall firewall add rule name="Apache HTTPS" dir=in action=allow protocol=TCP localport=443

Write-Host "`n✅ Firewall configured!" -ForegroundColor Green
Write-Host "`n📝 Next steps:" -ForegroundColor Cyan
Write-Host "1. Update frontend API URL to: http://$ip/exam-backend/api"
Write-Host "2. Update backend .env APP_URL to: http://$ip/exam-backend"
Write-Host "3. Restart Apache in XAMPP"
Write-Host "4. Access from other PCs: http://$ip/exam-frontend"
```

---

## 📊 Network Diagram

```
Router (192.168.1.1)
    |
    |-- Server PC (192.168.1.100) - XAMPP + Exam System
    |
    |-- Client PC 1 (192.168.1.101) - Browser
    |
    |-- Client PC 2 (192.168.1.102) - Browser
    |
    |-- Client PC 3 (192.168.1.103) - Browser
```

---

## 🔒 Security Notes

1. **Only for Local Network** - Don't expose to internet without proper security
2. **Use HTTPS** - For production, set up SSL certificate
3. **Firewall** - Only allow access from trusted network
4. **Strong Passwords** - Ensure all accounts have strong passwords
5. **Regular Updates** - Keep XAMPP and system updated

---

## 📞 Support

If you encounter issues:
1. Check all steps above
2. Verify IP address is correct
3. Ensure Apache is running
4. Check firewall settings
5. Review Apache error logs

---

## ✅ Checklist

- [ ] Found server IP address
- [ ] Configured Windows Firewall
- [ ] Updated Apache httpd.conf
- [ ] Updated frontend API URL
- [ ] Updated backend .env
- [ ] Updated CORS configuration
- [ ] Rebuilt frontend
- [ ] Restarted Apache
- [ ] Tested from server PC
- [ ] Tested from client PC

---

**🎯 Once configured, students can access the exam system from any PC on the same network!**

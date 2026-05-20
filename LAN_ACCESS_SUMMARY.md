# 🌐 LAN Access - Quick Reference

## ✅ Your System Status

**Server IP:** `192.168.11.40`  
**Access URL:** `http://192.168.11.40/exam-frontend`

### Current Configuration:
- ✅ Apache: Running
- ✅ Port 80: Listening on all interfaces
- ✅ Firewall: Rule configured
- ✅ Backend: Configured with IP (192.168.11.40)
- ✅ Frontend: Configured with IP
- ✅ CORS: Configured

---

## 🚀 For Students/Clients

### To Access the Exam System:

1. **Connect to the same network** as the server
2. **Open any web browser**
3. **Go to:** `http://192.168.11.40/exam-frontend`
4. **Login** with your credentials

### Requirements:
- Must be on same WiFi/LAN network
- IP must start with `192.168.11.x`
- No special software needed, just a browser

---

## 🔧 For Server Administrator

### If Students Can't Access:

#### Quick Check (Run on Server PC):
```powershell
cd Exam-Main
.\check-lan.ps1
```

#### Quick Fix (Run as Admin on Server PC):
```powershell
cd Exam-Main
.\fix-lan-access.ps1
```

### Most Common Issues:

1. **Firewall Blocking**
   - Solution: Run `fix-lan-access.ps1` as admin
   
2. **Different Network**
   - Solution: Ensure all PCs connected to same router
   
3. **IP Changed**
   - Solution: Run `fix-lan-access.ps1` to update configs
   
4. **Apache Not Running**
   - Solution: Start Apache in XAMPP Control Panel

---

## 📱 Testing

### Test from Server PC:
```
http://localhost/exam-frontend
http://192.168.11.40/exam-frontend
```

### Test from Client PC:
1. Copy `test-from-client.ps1` to client PC
2. Run it to diagnose issues
3. Or just open browser and go to: `http://192.168.11.40/exam-frontend`

---

## 🆘 Troubleshooting

### Client Can't Connect:

**Step 1: Verify Network**
On client PC, open Command Prompt:
```cmd
ipconfig
ping 192.168.11.40
```

**Step 2: Check Firewall**
On server PC, run as admin:
```powershell
netsh advfirewall firewall add rule name="Apache HTTP" dir=in action=allow protocol=TCP localport=80
```

**Step 3: Restart Apache**
In XAMPP Control Panel:
- Stop Apache
- Start Apache

**Step 4: Test Again**
From client browser: `http://192.168.11.40/exam-frontend`

---

## 📋 Files Reference

| File | Purpose |
|------|---------|
| `check-lan.ps1` | Quick diagnostic check |
| `fix-lan-access.ps1` | Auto-fix common issues |
| `test-from-client.ps1` | Test from client PC |
| `TROUBLESHOOT_LAN.md` | Detailed troubleshooting guide |
| `LAN_SETUP_GUIDE.md` | Complete setup instructions |

---

## 🔒 Security Notes

- This setup is for **local network only**
- Do NOT expose to internet without proper security
- Use strong passwords for all accounts
- Consider setting up HTTPS for production use

---

## 📞 Quick Commands

### Get Server IP:
```powershell
ipconfig | findstr IPv4
```

### Check Apache:
```powershell
Get-Process httpd
```

### Add Firewall Rule:
```powershell
netsh advfirewall firewall add rule name="Apache HTTP" dir=in action=allow protocol=TCP localport=80
```

### Test from Client:
```cmd
ping 192.168.11.40
```

---

## ✅ Success Checklist

- [ ] Server PC has static IP or noted current IP
- [ ] Apache running in XAMPP
- [ ] Firewall rule added
- [ ] Can access from server PC
- [ ] Can ping from client PC
- [ ] Can access from client PC browser
- [ ] Students can login successfully

---

**Share this URL with students:**

# `http://192.168.11.40/exam-frontend`

---

*Last Updated: Based on current configuration*  
*Server IP: 192.168.11.40*

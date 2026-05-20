# 🎉 CFAS EXAM SYSTEM - APACHE SETUP COMPLETE!
## Simple Guide para sa Faculty (Bisaya Version)

---

## ✅ ANO ANG NATAPOS NA?

Ang backend kag frontend subong nag-run na TANAN sa Apache!  
**WALA NA ang separate backend server!**  
**WALA NA ang terminal windows!**  
**SIMPLE NA GIDKAAYO!**

---

## 🚀 PAANO MAG-START (DAILY USE)

### Hakang 1: Start XAMPP
1. Buksan ang **XAMPP Control Panel**
2. I-click ang **Start** sa Apache (dapat mag-green)
3. I-click ang **Start** sa MySQL (dapat mag-green)

### Hakang 2: Open CFAS System
**Option A: Gamit ang Desktop Icon (Recommended)**
1. Double-click ang **"CFAS Exam System"** icon sa desktop
2. Automatic mag-open ang browser
3. **TAPOS NA!** Pwede na mag-login!

**Option B: Manual sa Browser**
1. Buksan ang browser (Chrome, Firefox, Edge)
2. I-type sa address bar: `http://192.168.11.40/exam-frontend`
3. Press Enter
4. Pwede na mag-login!

### Hakang 3: Login
- **Admin Username:** `admin`
- **Admin Password:** `admin123`

---

## 🛑 PAANO MAG-STOP

Kon human na mag-gamit:
1. I-close ang browser
2. Adto sa XAMPP Control Panel
3. I-click ang **Stop** sa Apache
4. I-click ang **Stop** sa MySQL
5. **TAPOS NA!**

---

## 📋 ONE-TIME SETUP (Kon wala pa ang desktop icon)

### Para Mag-create sang Desktop Shortcut:
1. Adto sa folder: `C:\Users\Hi\Desktop\CFAS REVIEW CENTER EXAMINATION SYSTEM\Exam-Main`
2. Double-click ang: `CREATE-DESKTOP-SHORTCUT-APACHE.bat`
3. Makita mo ang icon sa desktop
4. **TAPOS NA!** Pwede na gamiton!

---

## 🌐 SYSTEM URLS

### Para sa Server Computer (imo computer):
- **Frontend:** `http://192.168.11.40/exam-frontend`
- **Backend API:** `http://192.168.11.40/exam-backend/public/api`
- **O:** `http://localhost/exam-frontend`

### Para sa Iban nga Computer (LAN):
- **Frontend:** `http://192.168.11.40/exam-frontend`
- Siguraduhon nga connected sa same network!

---

## 💡 KEY BENEFITS

✅ **NO SEPARATE BACKEND** - Tanan sa Apache na!  
✅ **NO TERMINAL WINDOWS** - Clean, walang nakita!  
✅ **AUTO-START** - Kon mag-start ang Apache, nag-run na ang backend!  
✅ **STABLE** - Apache ang nag-handle, proven stable!  
✅ **SIMPLE** - Start XAMPP, open browser, TAPOS NA!  
✅ **FACULTY-FRIENDLY** - Indi complicated!  

---

## 🆘 TROUBLESHOOTING

### Problem: "Apache is not running"
**Solution:**
1. Buksan ang XAMPP Control Panel
2. I-click ang **Start** sa Apache
3. Antay hasta mag-green
4. I-run ulit ang launcher

### Problem: "MySQL is not running"
**Solution:**
1. Buksan ang XAMPP Control Panel
2. I-click ang **Start** sa MySQL
3. Antay hasta mag-green
4. I-run ulit ang launcher

### Problem: "Page not found" o "404 Error"
**Solution:**
1. Check kon nag-run ang Apache sa XAMPP
2. Check ang URL: `http://192.168.11.40/exam-frontend`
3. Check kon naa ang files sa:
   - `C:\xampp\htdocs\exam-frontend`
   - `C:\xampp\htdocs\exam-backend`

### Problem: Login indi mag-work
**Solution:**
1. Check kon nag-run ang MySQL sa XAMPP
2. Check ang username kag password (case-sensitive!)
3. Try i-clear ang browser cache:
   - Press `Ctrl + Shift + Delete`
   - I-select "Cached images and files"
   - I-click "Clear data"
4. I-refresh ang page (`F5`)

### Problem: Ang iban nga computer indi maka-access
**Solution:**
1. Check kon same network kamo
2. Check ang IP address:
   - Sa server computer, open Command Prompt
   - Type: `ipconfig`
   - Pangitaon ang "IPv4 Address"
   - Dapat `192.168.11.40`
3. Check ang firewall:
   - I-allow ang Apache sa Windows Firewall
4. Try i-ping ang server:
   - Sa client computer, open Command Prompt
   - Type: `ping 192.168.11.40`
   - Dapat may reply

---

## 📝 DAILY CHECKLIST

### Morning (Pag-start):
- [ ] Start XAMPP Control Panel
- [ ] Start Apache (green)
- [ ] Start MySQL (green)
- [ ] Double-click CFAS icon (or open browser)
- [ ] Login
- [ ] Ready!

### Evening (Pag-close):
- [ ] Close browser
- [ ] Stop Apache sa XAMPP
- [ ] Stop MySQL sa XAMPP
- [ ] Close XAMPP
- [ ] Done!

---

## 🎓 TIPS FOR FACULTY

1. **Keep XAMPP running** - Indi i-close while nag-gamit sang system
2. **Bookmark ang URL** - Para dali lang i-access
3. **Use the desktop icon** - Pinaka-simple nga way
4. **Don't close XAMPP accidentally** - Mag-stop ang system kon i-close
5. **Restart XAMPP kon may problema** - Solve na gid ang kadamo nga issues

---

## 📞 NEED HELP?

Kon may problema pa:
1. **Check ang guide ini first** - Basi naa diri ang solution
2. **I-restart ang XAMPP** - Solve na gid ang kadamo
3. **I-restart ang computer** - Kon indi pa gid
4. **Contact IT Support** - Kon indi pa gid ma-solve

---

## 🎉 SUMMARY

**Para mag-start:**
1. Start XAMPP (Apache + MySQL)
2. Double-click CFAS icon
3. Login!

**Para mag-stop:**
1. Close browser
2. Stop XAMPP
3. Done!

**SIMPLE LANG GIDKAAYO!** 🚀

---

## 📂 IMPORTANT FILES

### Setup Files (One-time use):
- `SETUP-APACHE-BACKEND.bat` - Backend setup (DONE NA!)
- `REBUILD-AND-DEPLOY-FRONTEND.bat` - Frontend rebuild (DONE NA!)
- `CREATE-DESKTOP-SHORTCUT-APACHE.bat` - Create desktop icon

### Daily Use Files:
- `START-CFAS-APACHE.bat` - Main launcher
- Desktop Icon: **"CFAS Exam System"** - Double-click ini!

### Backend Location:
- `C:\xampp\htdocs\exam-backend`

### Frontend Location:
- `C:\xampp\htdocs\exam-frontend`

---

## ✨ WHAT'S DIFFERENT NOW?

### Before (Old Setup):
- ❌ Need to start backend separately
- ❌ Terminal window stays open
- ❌ Backend can crash or stop
- ❌ Complicated for faculty

### Now (New Setup):
- ✅ Everything runs through Apache
- ✅ No terminal windows
- ✅ Stable and reliable
- ✅ Simple for faculty!

---

**System Version:** CFAS Exam System v2.0 (Apache Edition)  
**Setup Date:** March 2026  
**Status:** ✅ READY TO USE!

---

## 🎊 CONGRATULATIONS!

Ang system subong READY NA para sa faculty!  
Simple lang - Start XAMPP, open browser, TAPOS NA!

**ENJOY USING THE CFAS EXAM SYSTEM!** 🎉📝✨

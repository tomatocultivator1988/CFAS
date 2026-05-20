# PAANO MAG-START SANG CFAS EXAM SYSTEM
## Para sa Faculty - Simple Guide

---

## ⚡ QUICK START (Pinaka-Simple!)

### Hakang 1: Siguraduhon nga nag-run ang XAMPP
1. Buksan ang **XAMPP Control Panel**
2. I-click ang **Start** sa Apache (dapat mag-green)
3. I-click ang **Start** sa MySQL (dapat mag-green)

### Hakang 2: I-run ang CFAS System
1. **Double-click** lang ang file nga:
   ```
   START-CFAS-ULTIMATE.bat
   ```
2. Mag-antay 5-10 seconds
3. Automatic nga mag-open ang browser
4. **TAPOS NA!** Pwede na mag-login

---

## 📋 Ano ang Mahitabo?

Kon i-double-click mo ang `START-CFAS-ULTIMATE.bat`:

1. ✅ Mag-check kon nag-run na ang backend
2. ✅ Kon wala pa, mag-start sang backend (hidden sa background)
3. ✅ Mag-wait hasta mag-ready ang backend
4. ✅ Automatic mag-open sang browser
5. ✅ Pwede na mag-login!

---

## 🌐 Paano Mag-Access?

### Sa Server Computer (imo computer):
- Buksan ang browser
- Adto sa: `http://192.168.11.40/exam-frontend`
- O: `http://localhost/exam-frontend`

### Sa Iban nga Computer (LAN):
- Buksan ang browser
- Adto sa: `http://192.168.11.40/exam-frontend`
- Siguraduhon nga connected sa same network

---

## 🔐 Default Login Credentials

### Admin Account:
- **Username:** `admin`
- **Password:** `admin123`

### Reviewee Account (Test):
- **Username:** `reviewee1`
- **Password:** `password123`

---

## ❌ Paano Mag-Stop?

### Kon gusto mo i-stop ang system:
1. Buksan ang **XAMPP Control Panel**
2. I-click ang **Stop** sa Apache
3. I-click ang **Stop** sa MySQL
4. **TAPOS NA!**

---

## 🆘 Kon May Problema

### Problema: "Backend is taking longer than expected"
**Solution:**
- Antay lang 30 seconds
- Kon indi pa gid, i-close ang window
- I-run ulit ang `START-CFAS-ULTIMATE.bat`

### Problema: "Cannot connect to backend"
**Solution:**
1. Check kon nag-run ang XAMPP (Apache kag MySQL)
2. I-restart ang XAMPP
3. I-run ulit ang `START-CFAS-ULTIMATE.bat`

### Problema: "Page not found" o "404 Error"
**Solution:**
1. Check kon tama ang URL: `http://192.168.11.40/exam-frontend`
2. Check kon nag-run ang Apache sa XAMPP
3. Check kon naa ang files sa `C:\xampp\htdocs\exam-frontend`

### Problema: Ang login indi mag-work
**Solution:**
1. Check kon nag-run ang MySQL sa XAMPP
2. Check kon nag-run ang backend (port 8000)
3. I-restart ang system:
   - I-stop ang XAMPP
   - I-start ulit ang XAMPP
   - I-run ang `START-CFAS-ULTIMATE.bat`

---

## 📝 Important Notes

1. **XAMPP dapat nag-run permi** - Apache kag MySQL
2. **Indi dapat i-close ang XAMPP** while nag-gamit sang system
3. **Ang backend nag-run sa background** - indi mo makita pero nag-work
4. **Pwede i-close ang launcher window** human mag-open sang browser
5. **Para ma-access sa iban nga computer**, dapat same network kamo

---

## 🎯 Summary

**Para mag-start:**
1. Start XAMPP (Apache + MySQL)
2. Double-click `START-CFAS-ULTIMATE.bat`
3. Antay mag-open ang browser
4. Login!

**Para mag-stop:**
1. Stop XAMPP (Apache + MySQL)
2. Tapos na!

---

## 📞 Need Help?

Kon may problema pa, contact ang IT support o ang nag-setup sini nga system.

**System Version:** CFAS Exam System v2.0
**Last Updated:** March 2026

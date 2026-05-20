# 🚀 Quick Fix Guide - LAN Access

## ✅ PROBLEM SOLVED!

The issue was: **Frontend was using `localhost` instead of server IP**

**Solution:** Updated `.env` file and rebuilt frontend.

---

## 📱 Access Information

**Server IP:** `192.168.11.40`  
**Access URL:** `http://192.168.11.40/exam-frontend`

Share this URL with all students on the same network!

---

## 🔧 Quick Commands

### Verify Everything is Working:
```powershell
cd Exam-Main
.\verify-deployment.ps1
```

### If IP Changes:
```powershell
cd Exam-Main
.\deploy-for-lan.ps1
```

### Rebuild & Deploy Frontend:
```batch
cd Exam-Main
.\deploy-frontend.bat
```

### Check Status:
```powershell
cd Exam-Main
.\check-lan.ps1
```

---

## 🆘 Common Issues

### Issue: CORS Error
**Fix:** Clear browser cache or use Incognito mode

### Issue: Can't Connect from Client
**Fix:** 
1. Check same network: `ipconfig` (should be 192.168.11.x)
2. Test ping: `ping 192.168.11.40`
3. Check firewall on server

### Issue: Login Doesn't Work
**Fix:** 
1. Press F12 in browser
2. Check Console for errors
3. Check Network tab for API calls
4. Verify they're going to `192.168.11.40` not `localhost`

---

## ✅ Checklist

- [x] Frontend .env updated with server IP
- [x] Frontend rebuilt (`npm run build`)
- [x] Files deployed to XAMPP
- [x] Apache running
- [x] MySQL running
- [x] Firewall configured
- [x] CORS configured
- [x] Can access from server PC
- [ ] Can access from client PC (test this!)

---

## 📞 Test from Client PC

1. **Connect to same WiFi/network**
2. **Open browser**
3. **Go to:** `http://192.168.11.40/exam-frontend`
4. **Try logging in**

If it works: ✅ You're done!  
If not: Run `.\test-from-client.ps1` on client PC

---

## 🎯 Key Files

| File | Purpose |
|------|---------|
| `verify-deployment.ps1` | Check if everything is configured |
| `deploy-for-lan.ps1` | Full deployment (when IP changes) |
| `deploy-frontend.bat` | Quick frontend rebuild & deploy |
| `check-lan.ps1` | Quick status check |
| `test-from-client.ps1` | Test from client PC |
| `LAN_ISSUE_FIXED.md` | Detailed explanation of fix |
| `TROUBLESHOOT_LAN.md` | Complete troubleshooting guide |

---

## 💡 Remember

**After ANY frontend code changes:**
1. Run `npm run build` in frontend folder
2. Copy `dist/*` to `C:\xampp\htdocs\exam-frontend\`

**Or just run:** `.\deploy-frontend.bat`

**Backend changes:** No rebuild needed, just refresh browser

---

## 🎉 Status: FIXED ✅

The system is now properly configured for LAN access!

**Last Updated:** February 10, 2026  
**Server IP:** 192.168.11.40

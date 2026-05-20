# 🚀 Auto-Start Guide - CFAS Exam System

## Mga Scripts nga Ginhimo

### 1. START-EXAM-SYSTEM.bat
**Gamit:** Basic auto-start script
- Mag-start sang Apache
- Mag-start sang MySQL
- Mag-open sang browser

**Paano gamiton:**
```
Double-click lang ang START-EXAM-SYSTEM.bat
```

---

### 2. START-EXAM-SYSTEM-ADVANCED.bat ⭐ (RECOMMENDED)
**Gamit:** Smart auto-start script
- Mag-check kung nag-run na ba ang Apache/MySQL
- Indi mag-duplicate kung nag-run na
- May verification kung successful ang start
- May option kung mag-open sang browser

**Paano gamiton:**
```
Double-click ang START-EXAM-SYSTEM-ADVANCED.bat
```

---

### 3. STOP-EXAM-SYSTEM.bat
**Gamit:** Para i-stop ang services
- Mag-stop sang Apache
- Mag-stop sang MySQL

**Paano gamiton:**
```
Double-click ang STOP-EXAM-SYSTEM.bat
```

---

### 4. create-desktop-shortcuts.vbs
**Gamit:** Mag-create sang shortcuts sa Desktop
- START Exam System shortcut
- STOP Exam System shortcut

**Paano gamiton:**
```
Double-click ang create-desktop-shortcuts.vbs
```

Makita mo sa Desktop:
- 🟢 START Exam System
- 🔴 STOP Exam System

---

### 5. setup-auto-startup.bat (OPTIONAL)
**Gamit:** Auto-start kada mag-boot ang Windows
- Automatic mag-start ang system kada mag-on ang PC

**Paano gamiton:**
```
Double-click ang setup-auto-startup.bat
```

**Para i-disable:**
```
Double-click ang remove-auto-startup.bat
```

---

## 📋 Quick Setup Guide

### Step 1: Create Desktop Shortcuts
```
1. Double-click: create-desktop-shortcuts.vbs
2. Click OK
3. Makita mo na sa Desktop ang shortcuts
```

### Step 2: Test ang Auto-Start
```
1. Double-click: START Exam System (sa Desktop)
2. Hulaton 5-10 seconds
3. Mag-open ang browser automatically
```

### Step 3: Share URL sa Students
```
http://192.168.11.40
```

---

## 🎯 Daily Usage

### Kada Aga (Before Exam):
```
1. Double-click: START Exam System
2. Hulaton mag-ready
3. Share URL sa students: http://192.168.11.40
```

### Kada Hapon (After Exam):
```
1. Double-click: STOP Exam System
2. Done!
```

---

## 🔄 Auto-Start on Windows Boot (Optional)

Kung gusto mo automatic mag-start kada mag-on ang PC:

### Enable Auto-Start:
```
1. Double-click: setup-auto-startup.bat
2. Press any key
3. Done! Kada mag-boot na ang Windows, automatic na mag-start
```

### Disable Auto-Start:
```
1. Double-click: remove-auto-startup.bat
2. Done!
```

---

## 🆘 Troubleshooting

### Problem: "Apache already running"
**Solution:** Normal lang na! Nag-skip lang ang script. Nag-run na ang Apache.

### Problem: "MySQL failed to start"
**Solution:** 
1. Run: STOP-EXAM-SYSTEM.bat
2. Wait 5 seconds
3. Run: START-EXAM-SYSTEM-ADVANCED.bat

### Problem: Browser indi mag-open
**Solution:** Manual lang i-open ang browser tapos type:
```
http://192.168.11.40
```

---

## 📁 File Summary

| File | Purpose | When to Use |
|------|---------|-------------|
| `START-EXAM-SYSTEM-ADVANCED.bat` | Start system | Every day before exam |
| `STOP-EXAM-SYSTEM.bat` | Stop system | After exam |
| `create-desktop-shortcuts.vbs` | Create shortcuts | One time setup |
| `setup-auto-startup.bat` | Enable auto-boot | Optional |
| `remove-auto-startup.bat` | Disable auto-boot | If needed |

---

## ✅ Recommended Setup

**For Daily Use:**
1. Create desktop shortcuts (one time)
2. Use START/STOP shortcuts every day
3. No need for auto-startup (unless gusto mo)

**For Permanent Setup:**
1. Create desktop shortcuts
2. Enable auto-startup
3. System mag-start automatically kada mag-on ang PC

---

## 🎓 Access Information

**Main URL:** `http://192.168.11.40`

**Admin Login:**
- Username: `admin`
- Password: `admin123`

**Student Login:**
- Created by admin
- Each student has unique credentials

---

## 💡 Tips

1. **Gamit ang ADVANCED version** - May checking kung nag-run na
2. **Create desktop shortcuts** - Mas dali gamiton
3. **Test before exam day** - Make sure nag-work tanan
4. **Share URL early** - Para students ready na

---

**Enjoy! Wala na manual nga pag-start! 🎉**

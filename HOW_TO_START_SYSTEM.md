# 🚀 How to Start CFAS Exam System

## SIMPLEST WAY - Use This! ✅

```
Double-click: LAUNCH-CFAS.bat
```

---

## What Happens:

1. **Window appears** with system information
2. **Shows what will start:**
   - Apache Web Server (Frontend)
   - MySQL Database Server
   - Laravel Backend API Server
3. **Press any key** to start
4. **Services start** in background
5. **Wait 10 seconds**
6. **Browser opens** automatically
7. **Done!** ✨

---

## Alternative (If LAUNCH-CFAS.bat doesn't work):

```
Double-click: START-EXAM-SYSTEM.bat
```

This is the core startup script. It will:
- Start Apache
- Start MySQL  
- Start Laravel Backend
- Show you the URLs

Then manually open browser to:
```
http://192.168.11.40/exam-frontend
```

---

## To Stop System:

```
Double-click: STOP-EXAM-SYSTEM.bat
```

---

## Access URLs:

- **Frontend**: http://192.168.11.40/exam-frontend
- **Backend API**: http://192.168.11.40:8000/api

**Login:**
- Username: `admin`
- Password: `admin123`

---

## Troubleshooting:

### Services Not Starting?
1. Check if XAMPP is installed
2. Run `START-EXAM-SYSTEM.bat` to see error messages
3. Check Task Manager for `httpd.exe`, `mysqld.exe`, `php.exe`

### Browser Doesn't Open?
- Manually open: http://192.168.11.40/exam-frontend

### PowerShell Issues?
- Use `START-EXAM-SYSTEM.bat` directly instead

---

## Summary:

**Easiest:**
```
LAUNCH-CFAS.bat
```

**Alternative:**
```
START-EXAM-SYSTEM.bat
```

Both work! Use whichever you prefer! 😊

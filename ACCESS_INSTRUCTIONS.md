# 📱 How to Access the Exam System

## ✅ Correct URLs

### Option 1: With trailing slash (RECOMMENDED)
```
http://192.168.11.40/exam-frontend/
```
**Note the trailing slash `/` at the end!**

### Option 2: With index.html
```
http://192.168.11.40/exam-frontend/index.html
```

---

## ❌ Common Mistakes

### This will NOT work:
```
http://192.168.11.40
```
**Error:** Redirects to XAMPP dashboard

### This might not work:
```
http://192.168.11.40/exam-frontend
```
**Error:** May give 404 without trailing slash

---

## 📋 Instructions for Students

### Step-by-Step:

1. **Connect to the same WiFi/network** as the server

2. **Open any web browser** (Chrome, Firefox, Edge, etc.)

3. **Type this URL exactly:**
   ```
   http://192.168.11.40/exam-frontend/
   ```
   **Important:** Include the `/` at the end!

4. **Press Enter**

5. **Login** with your credentials

---

## 🖨️ Print This for Students

```
═══════════════════════════════════════════
    CFAS EXAM SYSTEM - ACCESS INFORMATION
═══════════════════════════════════════════

URL: http://192.168.11.40/exam-frontend/

Instructions:
1. Connect to the WiFi network
2. Open web browser
3. Type the URL above (include the / at end)
4. Login with your username and password

Need help? Ask the administrator.
═══════════════════════════════════════════
```

---

## 🔧 For Administrator

### Make Root Redirect (Optional)

If you want `http://192.168.11.40` to automatically redirect to the exam system:

```powershell
cd Exam-Main
.\setup-root-redirect.ps1
```

This will make it so students can just type `http://192.168.11.40` and it will automatically go to the exam system.

---

## 🧪 Test URLs

### Test from Server PC:
```
http://localhost/exam-frontend/
http://127.0.0.1/exam-frontend/
http://192.168.11.40/exam-frontend/
```

All three should work from the server PC.

### Test from Client PC:
```
http://192.168.11.40/exam-frontend/
```

Only this one will work from client PCs.

---

## 🆘 Troubleshooting

### "Not Found" Error

**Problem:** URL is wrong or missing trailing slash

**Solutions:**
1. Make sure URL ends with `/`
2. Try: `http://192.168.11.40/exam-frontend/index.html`
3. Clear browser cache (Ctrl+Shift+Delete)

### "Can't reach this page"

**Problem:** Network or firewall issue

**Solutions:**
1. Check if on same network: `ipconfig`
2. Test connection: `ping 192.168.11.40`
3. Check firewall on server

### Page loads but login fails

**Problem:** API connection issue

**Solutions:**
1. Press F12, check Console for errors
2. Verify backend is running
3. Check CORS configuration

---

## 📱 QR Code (Optional)

You can create a QR code for the URL to make it easier for students:

**URL to encode:** `http://192.168.11.40/exam-frontend/`

Use any QR code generator online, print it, and post it in the exam room!

---

## ✅ Quick Check

Run this to verify everything:
```powershell
cd Exam-Main
.\verify-deployment.ps1
```

---

## 🎯 Summary

**The correct URL is:**
# `http://192.168.11.40/exam-frontend/`

**Don't forget the trailing slash `/` !**

Share this exact URL with all students.

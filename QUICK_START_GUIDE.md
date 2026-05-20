# 🚀 Quick Start Guide - CFAS Exam System

## Simplest Way to Use the Launchers! 

### Step 1: Create Shortcuts

Run this file:
```
CREATE-SHORTCUTS-HERE.bat
```

This creates TWO shortcuts **in the Exam-Main folder**:
- `START CFAS Exam.lnk` 
- `STOP CFAS Exam.lnk`

---

### Step 2: Use the Shortcuts

You have 3 options:

#### Option 1: Use Directly (Easiest!)
Just double-click the shortcuts in the Exam-Main folder!
- No need to move anywhere
- Works immediately

#### Option 2: Move to Desktop
1. Find the shortcuts in Exam-Main folder
2. **Drag and drop** to Desktop
3. Now you can use from Desktop

#### Option 3: Pin to Taskbar
1. Right-click the shortcut
2. Select "Pin to Taskbar"
3. Always visible at bottom of screen

---

## How to Start the System

### Using START Launcher
1. **Double-click**: `START CFAS Exam.lnk`
2. Beautiful purple window appears
3. **Click**: "🚀 Start System" button
4. Wait 10 seconds (progress shown)
5. Browser opens automatically
6. Done! ✅

---

## How to Stop the System

### Using STOP Launcher
1. **Double-click**: `STOP CFAS Exam.lnk`
2. Beautiful pink/red window appears
3. Read the warning
4. **Click**: "🛑 Stop System" button
5. Wait 3 seconds
6. Done! ✅

---

## Alternative: Use HTA Files Directly

If shortcuts don't work, you can use the HTA files directly:

**To Start:**
```
Double-click: CFAS-Exam-Launcher.hta
```

**To Stop:**
```
Double-click: CFAS-Exam-Stopper.hta
```

These are the actual launcher files with the beautiful GUI!

---

## Files You Need to Know

### Main Launchers (Use These!)
- `CFAS-Exam-Launcher.hta` - START launcher (Purple GUI)
- `CFAS-Exam-Stopper.hta` - STOP launcher (Pink/Red GUI)

### Shortcut Creator
- `CREATE-SHORTCUTS-HERE.bat` - Creates shortcuts in this folder

### Shortcuts (After Running Creator)
- `START CFAS Exam.lnk` - Shortcut to START launcher
- `STOP CFAS Exam.lnk` - Shortcut to STOP launcher

---

## What Each Launcher Does

### START Launcher (Purple)
1. Starts Apache (Frontend server)
2. Starts MySQL (Database)
3. Starts Laravel Backend (API server)
4. Opens browser to: http://192.168.11.40/exam-frontend
5. Closes automatically

### STOP Launcher (Pink/Red)
1. Stops Apache
2. Stops MySQL
3. Stops Laravel Backend
4. Shows success message
5. Closes automatically

---

## Troubleshooting

### Shortcuts Not Working?
**Solution**: Use the HTA files directly!
- `CFAS-Exam-Launcher.hta` (for START)
- `CFAS-Exam-Stopper.hta` (for STOP)

### HTA Files Blocked?
1. Right-click HTA file
2. Properties
3. Check "Unblock"
4. Click OK
5. Try again

### Services Not Starting?
Run the old batch file to see errors:
```
START-EXAM-SYSTEM.bat
```

---

## Summary

**Easiest Method:**
1. Run: `CREATE-SHORTCUTS-HERE.bat`
2. Double-click: `START CFAS Exam.lnk` (in Exam-Main folder)
3. Click: "🚀 Start System"
4. Done!

**Alternative Method:**
1. Double-click: `CFAS-Exam-Launcher.hta` (in Exam-Main folder)
2. Click: "🚀 Start System"
3. Done!

**Both work the same!** Use whichever you prefer! 🎉

---

## Access URLs

After starting:
- **Frontend**: http://192.168.11.40/exam-frontend
- **Backend API**: http://192.168.11.40:8000/api

**Login:**
- Username: `admin`
- Password: `admin123`

---

Simple lang boss! 😊

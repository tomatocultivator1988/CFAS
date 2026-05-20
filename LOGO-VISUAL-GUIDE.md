# CFAS Launcher Logo - Visual Guide 🎨

## Unsa ang Dapat Makita? (What Should You See?)

### CORRECT: Logo Naa (Logo Present) ✅

```
┌────────────────────────────────────────────────┐
│  CFAS Exam System Launcher            [_][□][X]│
├────────────────────────────────────────────────┤
│                                                │
│                                                │
│              ╔════════════╗                    │
│              ║            ║                    │
│              ║   CFAS     ║  <-- LOGO HERE!    │
│              ║   LOGO     ║      (120x120)     │
│              ║            ║                    │
│              ╚════════════╝                    │
│                                                │
│         CFAS EXAM SYSTEM                       │
│    Review Center Management System             │
│                                                │
│  ┌──────────────────────────────────────────┐ │
│  │  System will start:                      │ │
│  │  [OK] Apache Web Server (Frontend)       │ │
│  │  [OK] MySQL Database Server              │ │
│  │  [OK] Laravel Backend API Server         │ │
│  └──────────────────────────────────────────┘ │
│                                                │
│  ┌──────────┐  ┌────────────────────────────┐ │
│  │ CANCEL   │  │  START SYSTEM              │ │
│  └──────────┘  └────────────────────────────┘ │
│                                                │
└────────────────────────────────────────────────┘
```

**Terminal Output:**
```
Initializing CFAS Exam System Launcher...

Logo loaded successfully          <-- GREEN TEXT ✅

Showing launcher GUI...
```

---

### WRONG: Wala ang Logo (No Logo - Fallback) ❌

```
┌────────────────────────────────────────────────┐
│  CFAS Exam System Launcher            [_][□][X]│
├────────────────────────────────────────────────┤
│                                                │
│                                                │
│              ╔════════════╗                    │
│              ║            ║                    │
│              ║   BLUE     ║  <-- BLUE BOX      │
│              ║   BOX      ║      (Fallback)    │
│              ║            ║                    │
│              ╚════════════╝                    │
│                                                │
│         CFAS EXAM SYSTEM                       │
│    Review Center Management System             │
│                                                │
│  ┌──────────────────────────────────────────┐ │
│  │  System will start:                      │ │
│  │  [OK] Apache Web Server (Frontend)       │ │
│  │  [OK] MySQL Database Server              │ │
│  │  [OK] Laravel Backend API Server         │ │
│  └──────────────────────────────────────────┘ │
│                                                │
│  ┌──────────┐  ┌────────────────────────────┐ │
│  │ CANCEL   │  │  START SYSTEM              │ │
│  └──────────┘  └────────────────────────────┘ │
│                                                │
└────────────────────────────────────────────────┘
```

**Terminal Output:**
```
Initializing CFAS Exam System Launcher...

Logo file not found, using fallback    <-- YELLOW TEXT ⚠️

Showing launcher GUI...
```

---

## How to Test (Paano i-Test)

### Option 1: Quick Check (Fastest)
```
Double-click: QUICK-LOGO-CHECK.ps1
```

This will check:
- ✅ Logo file exists
- ✅ Windows Forms works
- ✅ Logo can be loaded
- ✅ Launcher script configured correctly

**Expected Output:**
```
========================================
  CFAS Launcher - Logo Quick Check
========================================

[1/4] Checking logo file...
      PASS - Logo file found!
      Size: 636369 bytes

[2/4] Checking Windows Forms...
      PASS - Windows Forms loaded!

[3/4] Testing logo loading...
      PASS - Logo loaded successfully!
      Dimensions: 1024 x 1024 pixels

[4/4] Checking launcher script...
      PASS - Launcher script found!
      PASS - Logo path configured correctly!

========================================
  ALL CHECKS PASSED!
========================================

The logo should work in the launcher!
```

### Option 2: Test Launcher GUI (See Actual Logo)
```
Double-click: TEST-LAUNCHER-WITH-LOGO.bat
```

This will:
1. Open PowerShell terminal (stays open)
2. Show console messages
3. Open GUI window with logo
4. You can see if logo appears!

**What to Look For:**
- Terminal shows: `Logo loaded successfully` (GREEN)
- GUI shows: CFAS logo image at top (not blue box)

### Option 3: Full Test (Logo File Only)
```
Double-click: TEST-LOGO.ps1
```

This tests just the logo file:
- File exists?
- File can be loaded?
- Image dimensions correct?

---

## Common Problems (Mga Kasagaran nga Problema)

### Problem 1: Blue Box Instead of Logo

**Cause:** Logo file not found or corrupt

**Solution:**
1. Run `QUICK-LOGO-CHECK.ps1`
2. If FAIL, check if `frontend\public\cfas-logo.jpg` exists
3. If missing, copy the logo file there
4. If corrupt, get a fresh copy

### Problem 2: Terminal Shows Yellow Warning

**Terminal says:** `Logo file not found, using fallback`

**Solution:**
```powershell
# Check if file exists
dir frontend\public\cfas-logo.jpg

# If missing, you need to copy it
# Make sure the path is correct!
```

### Problem 3: Logo Test Passes But GUI Shows Blue Box

**Cause:** Launcher script might have wrong path

**Solution:**
1. Open `CFAS-System-Launcher.ps1`
2. Find line 17: `$script:logoPath = ...`
3. Make sure it says: `Join-Path $PSScriptRoot "frontend\public\cfas-logo.jpg"`
4. Save and test again

---

## Desktop Shortcut Icon (Bonus)

**Note:** Ang desktop shortcut icon DIFFERENT sa GUI logo!

### GUI Logo (Inside the Window)
- ✅ Always works if file exists
- ✅ Shows 120x120 pixels
- ✅ Guaranteed to display

### Desktop Shortcut Icon (The .lnk file icon)
- ⚠️ May or may not work (JPG support limited)
- ⚠️ Windows prefers .ico files
- ⚠️ Might show default PowerShell icon

**To get icon on desktop shortcut:**
1. Convert `cfas-logo.jpg` to `cfas-icon.ico`
2. Update `create-desktop-shortcuts.vbs`
3. Use .ico file instead of .jpg

---

## File Locations (Asa ang Files)

```
Exam-Main/
├── CFAS-System-Launcher.ps1          <-- Main launcher
├── TEST-LOGO.ps1                     <-- Test logo file
├── TEST-LAUNCHER-WITH-LOGO.bat       <-- Test GUI with logo
├── QUICK-LOGO-CHECK.ps1              <-- Quick diagnostic
├── LOGO-VISUAL-GUIDE.md              <-- This file
├── LOGO-TROUBLESHOOTING.md           <-- Detailed troubleshooting
└── frontend/
    └── public/
        └── cfas-logo.jpg             <-- LOGO FILE HERE!
```

---

## Quick Reference

| Test Script | Purpose | What It Shows |
|------------|---------|---------------|
| `QUICK-LOGO-CHECK.ps1` | Fast diagnostic | Pass/Fail for each check |
| `TEST-LOGO.ps1` | Test logo file only | File exists and loads |
| `TEST-LAUNCHER-WITH-LOGO.bat` | Test actual GUI | See logo in window |

---

## Summary Checklist

Before running the launcher, make sure:

- [ ] Logo file exists: `frontend\public\cfas-logo.jpg`
- [ ] Logo file is valid JPG (not corrupt)
- [ ] Windows Forms is available
- [ ] Launcher script has correct path
- [ ] Run `QUICK-LOGO-CHECK.ps1` - all PASS

If all ✅, then the logo will appear in the GUI!

---

**Created:** 2026-03-05
**Purpose:** Visual guide for logo display in CFAS Launcher
**Related:** LOGO-COMPLETE.md, LOGO-TROUBLESHOOTING.md

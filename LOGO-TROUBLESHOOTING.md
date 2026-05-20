# Logo Troubleshooting Guide - CFAS Launcher

## Problema: "Wala ang logo sa launcher" 🔍

Kung wala ka makita ang CFAS logo sa launcher GUI, sundin ini nga steps:

## Quick Test

### Step 1: Test kung naa ang logo file
```
Double-click: TEST-LOGO.ps1
```

**Expected Result:**
```
[Test 1] Checking if logo file exists...
  SUCCESS: Logo file found!
  File Size: 636369 bytes

[Test 2] Testing logo loading with Windows Forms...
  SUCCESS: Logo loaded successfully!
  Image Size: 1024 x 1024 pixels
```

✅ **Kung SUCCESS ang duha ka tests** - ang logo file okay!

### Step 2: Test ang actual launcher
```
Double-click: TEST-LAUNCHER-WITH-LOGO.bat
```

**What to check:**
1. PowerShell terminal opens
2. Look for this message: `Logo loaded successfully` (GREEN text)
3. GUI window opens
4. Check kung naa ang CFAS logo sa taas (120x120 pixels)

## Possible Issues and Solutions

### Issue 1: Logo file wala (Logo file not found)

**Symptoms:**
- Terminal shows: `Logo file not found, using fallback` (YELLOW)
- GUI shows BLUE BOX instead of logo

**Solution:**
```powershell
# Check kung naa ang logo file
dir frontend\public\cfas-logo.jpg
```

If wala, copy ang logo file:
```powershell
# From another location or download it
copy [source]\cfas-logo.jpg frontend\public\cfas-logo.jpg
```

### Issue 2: Logo file corrupt (Logo file damaged)

**Symptoms:**
- Terminal shows: `Using fallback logo` (YELLOW)
- GUI shows BLUE BOX instead of logo
- TEST-LOGO.ps1 fails at Test 2

**Solution:**
1. Delete ang corrupt file
2. Get a fresh copy of cfas-logo.jpg
3. Make sure it's a valid JPG/JPEG file

### Issue 3: Path problem (Wrong path)

**Symptoms:**
- Terminal shows: `Logo file not found, using fallback` (YELLOW)
- But ang file naa man!

**Solution:**
Check ang path sa launcher script:
```powershell
# Open CFAS-System-Launcher.ps1
# Line 17 should be:
$script:logoPath = Join-Path $PSScriptRoot "frontend\public\cfas-logo.jpg"
```

### Issue 4: Windows Forms issue

**Symptoms:**
- Terminal shows: `Using fallback logo` (YELLOW)
- Error message about System.Drawing

**Solution:**
```powershell
# Run this in PowerShell:
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
```

If error, Windows Forms might not be installed properly.

## What You Should See

### Terminal Output (Correct):
```
Initializing CFAS Exam System Launcher...

Logo loaded successfully          <-- GREEN (GOOD!)

Showing launcher GUI...
```

### Terminal Output (Fallback):
```
Initializing CFAS Exam System Launcher...

Logo file not found, using fallback    <-- YELLOW (Problem!)

Showing launcher GUI...
```

### GUI Window (Correct):
```
┌─────────────────────────────────────────┐
│                                         │
│      [CFAS LOGO IMAGE - 120x120]        │  <-- LOGO HERE!
│                                         │
│        CFAS EXAM SYSTEM                 │
│   Review Center Management System       │
│                                         │
```

### GUI Window (Fallback):
```
┌─────────────────────────────────────────┐
│                                         │
│      [BLUE BOX - 120x120]               │  <-- BLUE BOX (No logo)
│                                         │
│        CFAS EXAM SYSTEM                 │
│   Review Center Management System       │
│                                         │
```

## Desktop Shortcut Icon

**Note:** Ang desktop shortcut icon different sa GUI logo!

- **GUI Logo**: Guaranteed to work (if file exists)
- **Shortcut Icon**: May or may not work (JPG support limited)

Kung gusto nimo ug icon sa desktop shortcut:
1. Convert cfas-logo.jpg to cfas-icon.ico
2. Update ang create-desktop-shortcuts.vbs
3. Use .ico file instead of .jpg

## Quick Diagnostic Commands

### Check logo file:
```powershell
Test-Path "frontend\public\cfas-logo.jpg"
# Should return: True
```

### Check file size:
```powershell
(Get-Item "frontend\public\cfas-logo.jpg").Length
# Should return: 636369 (or similar)
```

### Check image properties:
```powershell
Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Image]::FromFile("$PWD\frontend\public\cfas-logo.jpg")
Write-Host "Size: $($img.Width) x $($img.Height)"
$img.Dispose()
# Should return: Size: 1024 x 1024
```

## Still Not Working?

If wala gihapon ang logo after trying all solutions:

1. **Take a screenshot** of the terminal output
2. **Take a screenshot** of the GUI window
3. **Run this command** and save the output:
   ```powershell
   Get-ChildItem frontend\public\*.jpg | Format-List *
   ```

Then we can debug further!

## Summary

✅ **Logo file exists** - Check with TEST-LOGO.ps1
✅ **Logo loads in test** - Windows Forms can read it
✅ **Launcher shows logo** - Check terminal for "Logo loaded successfully"
✅ **GUI displays logo** - Should see image at top of window

If all ✅ are green, ang logo working na!

---

**Created:** 2026-03-05
**Purpose:** Troubleshoot logo display issues in CFAS Launcher
**Related Files:** 
- TEST-LOGO.ps1 (test logo file)
- TEST-LAUNCHER-WITH-LOGO.bat (test launcher GUI)
- CFAS-System-Launcher.ps1 (main launcher)

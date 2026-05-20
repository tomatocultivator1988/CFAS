# CFAS Launcher Troubleshooting Guide

## Problem: Wala gid nag-gwa nga GUI kung i-double click ang desktop icon

### Possible Causes & Solutions:

### 1. PowerShell Execution Policy
**Symptom:** Wala gid may nag-happen, nag-auto close lang

**Solution:**
```powershell
# Run this in PowerShell as Administrator:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 2. Test if GUI Works
**Try this:**
1. Open PowerShell
2. Navigate to Exam-Main folder:
   ```powershell
   cd "C:\Users\Hi\Desktop\CFAS REVIEW CENTER EXAMINATION SYSTEM\Exam-Main"
   ```
3. Run the launcher directly:
   ```powershell
   .\CFAS-System-Launcher.ps1
   ```

Kung nag-gwa ang GUI, okay ang launcher. Ang problema is sa shortcut.

### 3. Recreate the Shortcut
**Steps:**
1. Delete ang old shortcut sa desktop
2. Right-click `Create-Desktop-Shortcut.ps1`
3. Select "Run with PowerShell"
4. Wait for success message
5. Try ulit ang new shortcut

### 4. Manual Test
**Run this test script:**
```powershell
cd Exam-Main
.\Test-GUI-Only.ps1
```

This will test kung nag-open ang GUI.

### 5. Check Paths
**Verify these paths exist:**
- `C:\xampp` - XAMPP installation
- `Exam-Main\backend` - Laravel backend
- `Exam-Main\frontend\public\cfas-logo.jpg` - CFAS logo

### 6. Alternative: Run Without Shortcut
**If shortcut doesn't work, create a .bat file:**

Create `Launch-CFAS.bat` with this content:
```batch
@echo off
cd /d "%~dp0Exam-Main"
powershell.exe -ExecutionPolicy Bypass -NoProfile -File "CFAS-System-Launcher.ps1"
pause
```

Put this .bat file sa desktop and double-click it.

## Common Issues

### Issue: "Cannot load Windows Forms"
**Solution:** Update PowerShell to version 5.1 or higher

### Issue: "XAMPP not found"
**Solution:** Install XAMPP at C:\xampp or update the path in the launcher

### Issue: Logo doesn't show
**Solution:** This is okay! The launcher will use a blue box fallback

### Issue: Services don't start
**Solution:** 
1. Check if XAMPP is installed
2. Check if ports 80, 3306, 8000 are available
3. Run XAMPP control panel manually first

## Debug Mode

To see what's happening, run the launcher with visible console:

```powershell
cd Exam-Main
powershell.exe -NoExit -File "CFAS-System-Launcher.ps1"
```

The `-NoExit` flag keeps the console open so you can see any errors.

## Quick Fixes

### Fix 1: Reset Everything
```powershell
# Delete old shortcut
Remove-Item "$env:USERPROFILE\Desktop\CFAS Exam System.lnk" -Force

# Recreate shortcut
cd Exam-Main
.\Create-Desktop-Shortcut.ps1
```

### Fix 2: Test Launcher Directly
```powershell
cd Exam-Main
.\CFAS-System-Launcher.ps1
```

### Fix 3: Check PowerShell Version
```powershell
$PSVersionTable.PSVersion
```

Should be 5.1 or higher.

## Still Not Working?

Try the old CFAS-LAUNCHER.ps1 instead:
```powershell
cd Exam-Main
.\CFAS-LAUNCHER.ps1
```

This is a simpler version without the GUI.

## Contact Info

If nothing works, check:
1. Windows version (should be Windows 7+)
2. PowerShell version (should be 5.1+)
3. XAMPP installation
4. Antivirus blocking PowerShell scripts

## Success Checklist

- [ ] PowerShell version 5.1+
- [ ] XAMPP installed at C:\xampp
- [ ] Backend folder exists
- [ ] Execution policy allows scripts
- [ ] Desktop shortcut created
- [ ] GUI opens when running launcher directly
- [ ] Services start successfully

If all checked, the launcher should work!

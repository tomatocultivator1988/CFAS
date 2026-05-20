# Fix: Launcher Wala Nag-gwa

## Problema
Kung i-double click mo ang desktop icon, nag-auto close lang wala may nag-gwa nga GUI.

## Quick Fix - Test First

### Step 1: Test kung nag-work ang GUI

Right-click `CFAS-Launcher-Debug.ps1` → Run with PowerShell

Kung nag-gwa ang window nga may "GUI Works!", okay ang launcher. Ang problema is sa shortcut lang.

### Step 2: Recreate ang Shortcut

1. Delete ang old shortcut sa desktop
2. Right-click `Create-Desktop-Shortcut.ps1` → Run with PowerShell
3. Wait for "SUCCESS!" message
4. Try ulit ang new shortcut

## Alternative: Direct Run

Kung wala gid nag-work ang shortcut, pwede mo i-run directly:

### Option 1: Run from PowerShell
```powershell
cd "C:\Users\Hi\Desktop\CFAS REVIEW CENTER EXAMINATION SYSTEM\Exam-Main"
.\CFAS-System-Launcher.ps1
```

### Option 2: Create Simple .bat File

Create `START-CFAS.bat` sa desktop with this content:
```batch
@echo off
cd /d "C:\Users\Hi\Desktop\CFAS REVIEW CENTER EXAMINATION SYSTEM\Exam-Main"
powershell.exe -ExecutionPolicy Bypass -NoProfile -File "CFAS-System-Launcher.ps1"
```

Double-click ang .bat file to launch.

## Files to Test

1. **CFAS-Launcher-Debug.ps1** - Test kung nag-work ang GUI
2. **Test-GUI-Only.ps1** - Simple GUI test
3. **CFAS-System-Launcher.ps1** - Main launcher

## What I Fixed

✅ Removed `-WindowStyle Hidden` from shortcut (para makita mo ang window)  
✅ Fixed backend path (removed duplicate "Exam-Main")  
✅ Fixed logo path  
✅ Added debug scripts for testing  

## Try These in Order

1. Run `CFAS-Launcher-Debug.ps1` - Check if GUI works
2. If GUI works, recreate desktop shortcut
3. If shortcut still doesn't work, use .bat file alternative
4. If nothing works, run launcher directly from PowerShell

## Expected Behavior

When working correctly:
1. Double-click desktop icon
2. GUI window appears with CFAS logo
3. Shows confirmation dialog
4. Click "START SYSTEM"
5. Progress bar shows services starting
6. Browser opens automatically

## Need More Help?

Check `LAUNCHER-TROUBLESHOOTING.md` for detailed troubleshooting steps.

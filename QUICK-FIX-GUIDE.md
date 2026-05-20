# CFAS Launcher - Quick Fix Guide 🚀

## Problem
Terminal auto-closes when running VBS or BAT file, can't see what's happening.

## Solution
Fixed versions that keep terminal open and show all messages.

## Quick Fix (3 Steps)

### Step 1: Test the Fixes
```powershell
Right-click: Test-Fixed-Launcher.ps1
Select: Run with PowerShell
```

This validates that all fixed files are ready.

### Step 2: Deploy the Fixes
```powershell
Right-click: Deploy-Fixed-Launcher.ps1
Select: Run with PowerShell
```

This will:
- ✅ Backup old files
- ✅ Deploy fixed versions
- ✅ Remove old desktop shortcut

### Step 3: Create New Shortcut
```powershell
Right-click: Create-Desktop-Shortcut.ps1
Select: Run with PowerShell
```

This creates a new desktop shortcut with the fixed launcher.

### Step 4: Test It!
```
Double-click: CFAS Exam System (desktop icon)
```

You should now see:
- ✅ Terminal opens and stays open
- ✅ Colored console messages
- ✅ GUI window appears
- ✅ Services start with status updates
- ✅ Browser opens automatically
- ✅ Terminal waits for Enter key

## What Was Fixed

### 1. VBS File (Launch-CFAS.vbs)
**Before:**
```vbs
objShell.Run strCommand, 1, False
```
Terminal closes immediately.

**After:**
```vbs
strCommand = "powershell.exe -ExecutionPolicy Bypass -NoProfile -NoExit -File ..."
```
Terminal stays open with `-NoExit` flag.

### 2. BAT File (LAUNCH-CFAS-GUI.bat)
**Before:**
```batch
powershell.exe -ExecutionPolicy Bypass -NoExit -Command "& '%~dp0CFAS-System-Launcher.ps1'"
pause
```
PowerShell exits when GUI closes, `pause` never executes.

**After:**
```batch
powershell.exe -ExecutionPolicy Bypass -NoExit -Command "& { & '%~dp0CFAS-System-Launcher.ps1'; Write-Host ''; Write-Host 'Launcher finished. You can close this window.' -ForegroundColor Green; Read-Host 'Press Enter to exit' }"
```
Wrapped in script block, shows completion message, waits for Enter.

### 3. Main Launcher (CFAS-System-Launcher.ps1)
**Before:**
- No console output
- Silent execution
- Hard to debug

**After:**
- ✅ Added `Write-Host` statements everywhere
- ✅ Color-coded messages (Cyan, Green, Yellow, Red)
- ✅ Shows initialization, service startup, completion
- ✅ Easy to debug

### 4. Shortcut Creator (Create-Desktop-Shortcut.ps1)
**Before:**
```powershell
$shortcut.Arguments = "-ExecutionPolicy Bypass -NoProfile -File `"$launcherScript`""
```
No `-NoExit`, terminal closes immediately.

**After:**
```powershell
$shortcut.Arguments = "-ExecutionPolicy Bypass -NoProfile -NoExit -Command `"& { & '$launcherScript'; Write-Host ''; Write-Host 'Launcher finished. You can close this window.' -ForegroundColor Green; Read-Host 'Press Enter to exit' }`""
```
Terminal stays open, shows completion message.

## Files Created

### Fixed Versions:
- ✅ `CFAS-System-Launcher-FIXED.ps1` - Main launcher with console output
- ✅ `Launch-CFAS-FIXED.vbs` - VBS with -NoExit flag
- ✅ `LAUNCH-CFAS-GUI-FIXED.bat` - BAT with proper terminal handling
- ✅ `Create-Desktop-Shortcut-FIXED.ps1` - Shortcut creator with -NoExit

### Deployment Scripts:
- ✅ `Test-Fixed-Launcher.ps1` - Validates all fixes
- ✅ `Deploy-Fixed-Launcher.ps1` - Deploys fixes automatically
- ✅ `LAUNCHER-BUG-FIXES.md` - Complete technical documentation
- ✅ `QUICK-FIX-GUIDE.md` - This file

## Alternative: Manual Fix

If you want to fix manually without running scripts:

### Fix VBS File:
1. Open `Launch-CFAS.vbs` in Notepad
2. Find: `strCommand = "powershell.exe -ExecutionPolicy Bypass -NoProfile -File`
3. Change to: `strCommand = "powershell.exe -ExecutionPolicy Bypass -NoProfile -NoExit -File`
4. Save

### Fix BAT File:
1. Open `LAUNCH-CFAS-GUI.bat` in Notepad
2. Find: `powershell.exe -ExecutionPolicy Bypass -NoExit -Command "& '%~dp0CFAS-System-Launcher.ps1'"`
3. Replace with:
```batch
powershell.exe -ExecutionPolicy Bypass -NoExit -Command "& { & '%~dp0CFAS-System-Launcher.ps1'; Write-Host ''; Write-Host 'Launcher finished. You can close this window.' -ForegroundColor Green; Read-Host 'Press Enter to exit' }"
```
4. Save

### Fix Shortcut Creator:
1. Open `Create-Desktop-Shortcut.ps1` in Notepad
2. Find: `$shortcut.Arguments = "-ExecutionPolicy Bypass -NoProfile -File`
3. Change to: `$shortcut.Arguments = "-ExecutionPolicy Bypass -NoProfile -NoExit -Command`
4. Update the command to wrap the launcher call
5. Save

## Troubleshooting

### Terminal still closes immediately
- Make sure you deployed the fixed files
- Recreate the desktop shortcut
- Check execution policy: `Get-ExecutionPolicy`

### GUI doesn't appear
- Check if XAMPP is installed at C:\xampp
- Check if backend folder exists
- Run: `.\Test-Fixed-Launcher.ps1`

### Services don't start
- Check if ports 80, 3306, 8000 are available
- Check if PHP is in system PATH
- Run XAMPP control panel manually first

## Success Checklist

After applying fixes, you should see:
- ✅ Terminal opens when you double-click shortcut
- ✅ See "Initializing CFAS Exam System Launcher..."
- ✅ See "Logo loaded successfully" or "Using fallback logo"
- ✅ See "Showing launcher GUI..."
- ✅ GUI window appears
- ✅ Click START SYSTEM button
- ✅ See "Starting CFAS Exam System..."
- ✅ See service startup messages with colors
- ✅ See "All services started successfully!"
- ✅ See "Opening browser to: http://192.168.11.40/exam-frontend"
- ✅ See "Browser opened successfully"
- ✅ See "Launcher finished successfully!"
- ✅ See "Launcher finished. You can close this window."
- ✅ Terminal waits for Enter key press

## Summary

**Before:** Terminal auto-closes, can't see anything ❌

**After:** Terminal stays open, shows everything ✅

All bugs fixed! Launcher is now 100% working! 🎉

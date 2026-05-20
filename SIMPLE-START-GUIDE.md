# CFAS Launcher - Simple Start Guide

## Problema: PowerShell nag-auto close

Kung nag-auto close ang PowerShell, gamiton ang .bat files instead!

## Solution: Use .bat Files

### Option 1: Test First (Recommended)

**Double-click:** `TEST-GUI-SIMPLE.bat`

- Mag-gwa ang console window
- Mag-gwa ang GUI window with CFAS logo
- Kung nag-gwa, okay na!

### Option 2: Direct Launch

**Double-click:** `LAUNCH-CFAS-GUI.bat`

- Mag-start ang GUI launcher
- Click "START SYSTEM" button
- Services mag-start automatic
- Browser mag-open automatic

### Option 3: Create Desktop Shortcut

**Right-click:** `Create-Desktop-Shortcut-BAT.ps1` → Run with PowerShell

- Mag-create sang desktop icon
- Double-click ang icon to launch

## Files to Use

### For Testing:
- `TEST-GUI-SIMPLE.bat` - Test kung nag-work ang GUI

### For Daily Use:
- `LAUNCH-CFAS-GUI.bat` - Main launcher
- Desktop shortcut (after creating)

## Why .bat Files?

.bat files diri mag-auto close compared to PowerShell shortcuts. Makita mo ang console window kag ang GUI window.

## Expected Behavior

1. Double-click `LAUNCH-CFAS-GUI.bat`
2. Console window mag-gwa (green text)
3. GUI window mag-gwa with CFAS logo
4. Click "START SYSTEM"
5. Services mag-start
6. Browser mag-open

## Troubleshooting

### Wala gid may nag-gwa
- Check kung nag-exist ang XAMPP sa C:\xampp
- Check kung nag-exist ang backend folder
- Try `TEST-GUI-SIMPLE.bat` first

### Console lang nag-gwa, wala GUI
- May error sa PowerShell
- Check ang error message sa console
- Try to run: `powershell.exe -ExecutionPolicy Bypass -File "CFAS-System-Launcher.ps1"`

### GUI nag-gwa pero wala nag-start ang services
- Check kung running na ang XAMPP
- Check kung available ang ports 80, 3306, 8000

## Quick Start (3 Steps)

1. **Test:** Double-click `TEST-GUI-SIMPLE.bat`
2. **Use:** Double-click `LAUNCH-CFAS-GUI.bat`
3. **Click:** "START SYSTEM" button sa GUI

That's it! 🚀

## Alternative: Manual PowerShell

Kung gusto mo manual:

1. Open PowerShell
2. Navigate to Exam-Main:
   ```
   cd "C:\Users\Hi\Desktop\CFAS REVIEW CENTER EXAMINATION SYSTEM\Exam-Main"
   ```
3. Run:
   ```
   .\CFAS-System-Launcher.ps1
   ```

## Files Summary

| File | Purpose |
|------|---------|
| `TEST-GUI-SIMPLE.bat` | Test kung nag-work ang GUI |
| `LAUNCH-CFAS-GUI.bat` | Main launcher (use this!) |
| `Create-Desktop-Shortcut-BAT.ps1` | Create desktop icon |
| `CFAS-System-Launcher.ps1` | Actual GUI script |

## Recommended Workflow

**First Time:**
1. Test with `TEST-GUI-SIMPLE.bat`
2. If works, create desktop shortcut
3. Use desktop shortcut daily

**Daily Use:**
- Just double-click desktop icon or `LAUNCH-CFAS-GUI.bat`

Done! 🎉

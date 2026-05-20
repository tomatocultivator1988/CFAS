# CFAS Logo Test Guide

## Problema: Wala ang Logo

Kung wala ka makita ang logo sa launcher GUI or sa desktop shortcut, sundon ni nga steps:

## Step 1: Test ang Logo File

**Double-click:** `TEST-LOGO.ps1`

Makita nimo:
- ✅ "Logo file found!" - Kung naa ang logo
- ✅ "Logo loaded successfully!" - Kung ma-load ang logo
- ❌ "Logo file NOT found!" - Kung wala ang logo
- ❌ "Failed to load logo!" - Kung may problema ang logo file

## Possible Issues ug Solutions

### Issue 1: Logo File Wala
**Symptoms:** "Logo file NOT found!"

**Solution:**
1. Check kung naa ba ang file: `frontend/public/cfas-logo.jpg`
2. Kung wala, copy ang logo file didto
3. Or download ug logo ug save as `cfas-logo.jpg`

### Issue 2: Logo File Corrupted
**Symptoms:** "Failed to load logo!"

**Solution:**
1. Ang logo file basin corrupted or dili valid JPG
2. Try ug open ang logo sa image viewer
3. Kung dili ma-open, replace ang logo file

### Issue 3: Logo sa GUI Wala (pero file naa)
**Symptoms:** Launcher nag-run pero wala ang logo sa GUI

**Possible Causes:**
- Ang launcher nag-use ug fallback (blue box)
- Ang logo path dili tama
- Ang logo file dili ma-access

**Solution:**
1. Run `TEST-LOGO.ps1` para ma-check
2. Check ang console output sa launcher
3. Dapat makita nimo: "Logo loaded successfully" (Green)
4. Kung wala, check ang error message

### Issue 4: Desktop Shortcut Icon Wala Logo
**Symptoms:** Desktop shortcut nag-use ug PowerShell icon

**Explanation:**
- Windows shortcuts prefer .ico files
- JPG files may limited support sa shortcuts
- Ang launcher GUI guaranteed na may logo!
- Ang shortcut icon optional lang

**Solution (Optional):**
1. Convert ang JPG to ICO format
2. Use online converter: https://convertio.co/jpg-ico/
3. Save as `cfas-icon.ico` sa Exam-Main folder
4. Update ang VBS script para mag-use ug .ico file

## Expected Results

### Kung Working ang Logo:

**TEST-LOGO.ps1 Output:**
```
Testing CFAS Logo...

Script Directory: C:\...\Exam-Main
Logo Path: C:\...\Exam-Main\frontend\public\cfas-logo.jpg

[Test 1] Checking if logo file exists...
  SUCCESS: Logo file found!
  File Size: 12345 bytes
  Last Modified: 2026-03-05 10:00:00 AM

[Test 2] Testing logo loading with Windows Forms...
  SUCCESS: Logo loaded successfully!
  Image Size: 800 x 600 pixels
  Image Format: Jpeg

Logo test complete!
```

**Launcher Console Output:**
```
Initializing CFAS Exam System Launcher...

Logo loaded successfully                    [Green]

Showing launcher GUI...
```

**GUI Window:**
- May CFAS logo image sa taas (120x120 pixels)
- Professional design
- Logo naa sa center

## Quick Test

1. **Test ang logo file:**
   ```
   Double-click: TEST-LOGO.ps1
   ```

2. **Test ang launcher:**
   ```
   Double-click: TEST-LAUNCHER-ENCODING.bat
   ```

3. **Check ang console output:**
   - Dapat makita: "Logo loaded successfully" (Green)
   - Kung wala: "Using fallback logo" (Yellow)

## Summary

✅ **Logo file location:** `frontend/public/cfas-logo.jpg`
✅ **Test script:** `TEST-LOGO.ps1`
✅ **Launcher GUI:** Guaranteed na may logo (or blue box fallback)
⚠️ **Desktop shortcut icon:** Optional (JPG support limited)

## Next Steps

1. Run `TEST-LOGO.ps1` para ma-check ang logo
2. Kung naa ang logo, run ang launcher
3. Kung wala pa gihapon, check ang console output
4. Kung may error, basaha ang error message

---

**Date:** 2026-03-05
**Status:** TESTING
**File:** TEST-LOGO.ps1

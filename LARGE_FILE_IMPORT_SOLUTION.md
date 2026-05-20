# Large File Import Solution - 1000+ Questions

## Problema

Kung damo gid ang questions (1000+), naga-timeout or internal server error sa kalagitnaan sang import.

### Common Causes:
1. ❌ PHP execution timeout (default: 30 seconds)
2. ❌ PHP memory limit (default: 128MB)
3. ❌ File upload size limit (default: 2MB)
4. ❌ Processing too many questions at once

---

## Solution: 3 Approaches

### **Approach 1: Increase PHP Limits (QUICK FIX)** ⭐

Increase ang PHP limits para ma-handle ang large files.

### **Approach 2: Split Files (WORKAROUND)**

I-split ang large file into smaller batches.

### **Approach 3: Batch Processing (BEST LONG-TERM)**

Process questions in batches with progress tracking.

---

## Approach 1: Increase PHP Limits (QUICK FIX) ⭐

### Step 1: Edit php.ini

Location: `C:\xampp\php\php.ini`

Find and change these values:

```ini
; Maximum execution time (seconds)
max_execution_time = 300  ; Change from 30 to 300 (5 minutes)

; Maximum memory limit
memory_limit = 512M  ; Change from 128M to 512M

; Maximum file upload size
upload_max_filesize = 50M  ; Change from 2M to 50M

; Maximum POST data size
post_max_size = 50M  ; Change from 8M to 50M
```

### Step 2: Restart Apache

```
# Via XAMPP Control Panel
Click "Stop" on Apache
Click "Start" on Apache
```

### Step 3: Test Import

Try importing your large file again. Dapat mag-work na!

---

## Approach 2: Split Files (WORKAROUND)

Kung dili pa gid mag-work ang Approach 1, i-split ang file.

### Manual Split:

1. Open ang large DOCX file
2. Copy first 200-300 questions
3. Paste to new document
4. Save as "Questions_Part1.docx"
5. Repeat for remaining questions

### Import Each Part:

1. Import Questions_Part1.docx
2. Wait for completion
3. Import Questions_Part2.docx
4. Repeat until done

### Advantages:
- ✅ Guaranteed to work
- ✅ Can track progress per batch
- ✅ Can resume if interrupted

### Disadvantages:
- ❌ Manual work required
- ❌ Time-consuming
- ❌ Multiple imports needed

---

## Approach 3: Batch Processing (BEST LONG-TERM)

Modify ang import system to process questions in batches.

### How It Works:

```
1. Upload file
2. Extract all questions
3. Process 50 questions at a time
4. Show progress bar
5. Continue until done
```

### Implementation Needed:

This requires code changes to:
- Backend: Process in chunks
- Frontend: Show progress
- Database: Track import status

**Note:** Ini ang best solution pero need code changes. Kung gusto mo, I can implement this!

---

## Quick Fix Script

Gin-create ko na ang script para i-increase ang PHP limits automatically:

### INCREASE-PHP-LIMITS.bat

```batch
@echo off
echo ========================================
echo    INCREASE PHP LIMITS FOR LARGE IMPORTS
echo ========================================
echo.
echo Ini nga script mag-increase sang:
echo - Execution time: 30s → 300s (5 minutes)
echo - Memory limit: 128M → 512M
echo - Upload size: 2M → 50M
echo.
pause

echo.
echo [1/3] Backing up php.ini...
copy "C:\xampp\php\php.ini" "C:\xampp\php\php.ini.backup"
echo [OK] Backup created

echo.
echo [2/3] Updating php.ini...
powershell -Command "(Get-Content 'C:\xampp\php\php.ini') -replace 'max_execution_time = 30', 'max_execution_time = 300' | Set-Content 'C:\xampp\php\php.ini'"
powershell -Command "(Get-Content 'C:\xampp\php\php.ini') -replace 'memory_limit = 128M', 'memory_limit = 512M' | Set-Content 'C:\xampp\php\php.ini'"
powershell -Command "(Get-Content 'C:\xampp\php\php.ini') -replace 'upload_max_filesize = 2M', 'upload_max_filesize = 50M' | Set-Content 'C:\xampp\php\php.ini'"
powershell -Command "(Get-Content 'C:\xampp\php\php.ini') -replace 'post_max_size = 8M', 'post_max_size = 50M' | Set-Content 'C:\xampp\php\php.ini'"
echo [OK] php.ini updated

echo.
echo [3/3] Restarting Apache...
echo.
echo IMPORTANTE: I-restart ang Apache sa XAMPP Control Panel!
echo 1. Click "Stop" on Apache
echo 2. Click "Start" on Apache
echo.
echo After restart, try liwat ang import!
echo.
pause
```

---

## Recommended Workflow for 1000+ Questions

### Step 1: Increase PHP Limits
```
cd Exam-Main
.\INCREASE-PHP-LIMITS.bat
```

### Step 2: Restart Apache
- Stop Apache in XAMPP
- Start Apache in XAMPP

### Step 3: Test with Smaller File First
- Try importing 100 questions first
- Verify it works
- Then try full file

### Step 4: Import Large File
- Upload your 1000+ questions file
- Wait patiently (may take 2-5 minutes)
- Don't close browser!
- Don't refresh page!

### Step 5: Verify Import
- Check if all questions imported
- Check if correct answers detected
- Test a few questions

---

## Troubleshooting

### Still Getting Timeout?

**Increase limits more:**
```ini
max_execution_time = 600  ; 10 minutes
memory_limit = 1024M      ; 1GB
```

### Still Getting Error?

**Split file into smaller batches:**
- 200-300 questions per file
- Import one at a time

### Progress Bar Stuck?

**Don't panic!**
- Backend is still processing
- Wait 5-10 minutes
- Check database if questions are being added

### How to Check Progress?

Open another browser tab:
```sql
-- Count questions in database
SELECT COUNT(*) FROM questions;
```

Run this every minute to see if count is increasing.

---

## Prevention Tips

### For Future Imports:

1. ✅ Keep files under 500 questions if possible
2. ✅ Split large files into batches
3. ✅ Test with small file first
4. ✅ Don't close browser during import
5. ✅ Have good internet connection
6. ✅ Close other programs to free memory

---

## Summary

**Quick Fix (RECOMMENDED):**
1. Run `INCREASE-PHP-LIMITS.bat`
2. Restart Apache
3. Try import again

**Workaround:**
1. Split file into 200-300 question batches
2. Import one batch at a time

**Long-term Solution:**
1. Implement batch processing
2. Add progress tracking
3. Add resume capability

---

## Current Limits (Default XAMPP)

```
Execution Time: 30 seconds
Memory Limit: 128MB
Upload Size: 2MB
POST Size: 8MB
```

## Recommended Limits (For Large Imports)

```
Execution Time: 300 seconds (5 minutes)
Memory Limit: 512MB
Upload Size: 50MB
POST Size: 50MB
```

## Maximum Safe Limits

```
Execution Time: 600 seconds (10 minutes)
Memory Limit: 1024MB (1GB)
Upload Size: 100MB
POST Size: 100MB
```

---

## Need Help?

Kung after sang fix, dili pa gid mag-work:
1. Check Apache error log
2. Check Laravel log (storage/logs/laravel.log)
3. Try smaller batch size
4. Let me know the exact error message

Pero most likely, ang INCREASE-PHP-LIMITS.bat mag-fix na sini! 💪

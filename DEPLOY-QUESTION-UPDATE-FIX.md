# Deploy Question Update Fix to Hostinger

## What Was Fixed
Fixed the "database error" when editing questions that have been answered by students.

## File to Deploy
Only one file needs to be updated:

```
backend/app/Services/ExamManagementService.php
```

## Deployment Steps

### Option 1: Via FileZilla/FTP

1. Connect to your Hostinger FTP
2. Navigate to: `public_html/api/app/Services/`
3. Upload the updated file:
   ```
   Local: Exam-Main/backend/app/Services/ExamManagementService.php
   Remote: public_html/api/app/Services/ExamManagementService.php
   ```
4. Done! No need to restart anything.

### Option 2: Via Hostinger File Manager

1. Login to Hostinger control panel
2. Go to File Manager
3. Navigate to: `public_html/api/app/Services/`
4. Delete the old `ExamManagementService.php`
5. Upload the new file from: `Exam-Main/backend/app/Services/ExamManagementService.php`
6. Done!

### Option 3: Via SSH (if available)

```bash
# Connect to Hostinger
ssh u123456789@yourdomain.com

# Navigate to services directory
cd public_html/api/app/Services/

# Backup old file
cp ExamManagementService.php ExamManagementService.php.backup

# Upload new file (use SCP or paste content)
# Then clear Laravel cache
cd ../../../
php artisan config:clear
php artisan cache:clear
```

## Verification

After deployment, test by:
1. Login as admin
2. Go to Question Management
3. Edit a question that has been answered by students
4. Change answer choices
5. Click Update
6. Should work without "database error"!

## Rollback (if needed)

If something goes wrong, restore the backup:
```bash
cd public_html/api/app/Services/
cp ExamManagementService.php.backup ExamManagementService.php
```

## Notes

- This fix is backward compatible
- No database changes needed
- No frontend changes needed
- Works with existing student answers
- Safe to deploy anytime

## Date
February 16, 2026

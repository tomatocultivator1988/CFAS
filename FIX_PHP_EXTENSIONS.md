# Fix PHP Extensions for Composer

Composer needs the ZIP extension to install packages. Here's how to enable it:

## Step 1: Enable ZIP Extension

1. Open file: `C:\xampp\php\php.ini` in a text editor (Notepad++)
2. Find this line (use Ctrl+F to search):
   ```
   ;extension=zip
   ```
3. Remove the semicolon (`;`) at the beginning:
   ```
   extension=zip
   ```
4. Save the file

## Step 2: Verify Extension is Enabled

Run this command:
```powershell
php -m | findstr zip
```

You should see `zip` in the output.

## Step 3: Try Composer Install Again

```powershell
cd Exam-Main\backend
composer install
```

## Alternative: Install Git (Recommended)

Composer can also download packages using Git. Install Git from:
https://git-scm.com/download/win

After installing Git, restart PowerShell and try `composer install` again.

## Quick Fix Commands

After enabling the extension, run:
```powershell
cd Exam-Main\backend
composer install
copy .env.example .env
php artisan key:generate
```

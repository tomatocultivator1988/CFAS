# Installation Checklist

Follow this checklist step by step. Check off each item as you complete it.

## Phase 1: Download Software

- [ ] Download PHP 8.1+ from https://windows.php.net/download/
- [ ] Download Composer from https://getcomposer.org/Composer-Setup.exe
- [ ] Download Node.js 18+ from https://nodejs.org/
- [ ] Download MySQL 8.0+ from https://dev.mysql.com/downloads/installer/

## Phase 2: Install Software

- [ ] Install PHP to `C:\php`
- [ ] Edit `C:\php\php.ini` and enable extensions (openssl, pdo_mysql, mbstring, fileinfo, curl)
- [ ] Add `C:\php` to Windows PATH
- [ ] Install Composer (point it to `C:\php\php.exe`)
- [ ] Install Node.js (check "Automatically install necessary tools")
- [ ] Install MySQL (remember your root password!)

## Phase 3: Verify Installation

Open a NEW PowerShell window and verify:

- [ ] `php --version` shows PHP 8.1+
- [ ] `composer --version` shows Composer 2.x
- [ ] `node --version` shows Node.js 18+
- [ ] `npm --version` shows npm 9+
- [ ] `mysql --version` shows MySQL 8.0+

## Phase 4: Create Database

- [ ] Run: `mysql -u root -p`
- [ ] Enter your MySQL password
- [ ] Run: `CREATE DATABASE review_center_exam CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;`
- [ ] Run: `EXIT;`

## Phase 5: Setup Backend

- [ ] Navigate to: `cd Exam-Main\backend`
- [ ] Run: `composer install`
- [ ] Run: `copy .env.example .env`
- [ ] Run: `php artisan key:generate`
- [ ] Edit `.env` file and set your MySQL password
- [ ] Run: `php artisan migrate`
- [ ] Run: `php artisan serve`
- [ ] Verify: http://localhost:8000 is accessible

## Phase 6: Setup Frontend

Open a NEW PowerShell window:

- [ ] Navigate to: `cd Exam-Main\frontend`
- [ ] Run: `npm install`
- [ ] Run: `copy .env.example .env`
- [ ] Run: `npm run dev`
- [ ] Verify: https://localhost:5173 shows the login page

## ✅ Installation Complete!

If all checkboxes are checked, your system is ready!

Next step: Proceed to Task 2 - Implement authentication and session management

---

## Having Issues?

See `INSTALLATION_GUIDE.md` for detailed instructions and troubleshooting.

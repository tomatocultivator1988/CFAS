# Complete Installation Guide for Windows

This guide will help you install all required software to run the Review Center Examination System.

## What You Need to Install

1. ✅ PHP 8.1 or higher
2. ✅ Composer (PHP package manager)
3. ✅ Node.js 18 or higher (includes npm)
4. ✅ MySQL 8.0 or higher

## Installation Steps

### Step 1: Install PHP 8.1+

**Download:**
1. Go to: https://windows.php.net/download/
2. Download **PHP 8.1 or 8.2** (Thread Safe version)
3. Choose the **VS16 x64 Thread Safe** ZIP file

**Install:**
1. Extract the ZIP file to `C:\php`
2. Rename `php.ini-development` to `php.ini`
3. Open `php.ini` in a text editor and enable these extensions (remove the `;` at the start):
   ```ini
   extension=openssl
   extension=pdo_mysql
   extension=mbstring
   extension=fileinfo
   extension=curl
   ```

**Add to PATH:**
1. Press `Windows + X` and select "System"
2. Click "Advanced system settings"
3. Click "Environment Variables"
4. Under "System variables", find "Path" and click "Edit"
5. Click "New" and add: `C:\php`
6. Click "OK" on all windows

**Verify:**
Open a NEW PowerShell window and run:
```powershell
php --version
```
You should see PHP version 8.1 or higher.

---

### Step 2: Install Composer

**Download:**
1. Go to: https://getcomposer.org/Composer-Setup.exe
2. Download and run the installer

**Install:**
1. Run the Composer-Setup.exe
2. When asked for PHP location, browse to `C:\php\php.exe`
3. Complete the installation with default settings

**Verify:**
Open a NEW PowerShell window and run:
```powershell
composer --version
```
You should see Composer version 2.x

---

### Step 3: Install Node.js 18+

**Download:**
1. Go to: https://nodejs.org/
2. Download the **LTS version** (18.x or higher)
3. Choose the Windows Installer (.msi) 64-bit

**Install:**
1. Run the installer
2. Accept the license agreement
3. Use default installation path
4. **IMPORTANT:** Check the box "Automatically install the necessary tools"
5. Complete the installation

**Verify:**
Open a NEW PowerShell window and run:
```powershell
node --version
npm --version
```
You should see Node.js v18+ and npm v9+

---

### Step 4: Install MySQL 8.0+

**Download:**
1. Go to: https://dev.mysql.com/downloads/installer/
2. Download **MySQL Installer for Windows**
3. Choose the larger "mysql-installer-community" file

**Install:**
1. Run the MySQL Installer
2. Choose "Developer Default" setup type
3. Click "Next" through the installation
4. When prompted, set a **root password** (remember this!)
5. Complete the installation
6. MySQL will start automatically as a Windows service

**Verify:**
Open a NEW PowerShell window and run:
```powershell
mysql --version
```
You should see MySQL version 8.0+

---

## After Installation - Setup the Project

Once all software is installed, follow these steps:

### 1. Create the Database

Open PowerShell and run:
```powershell
mysql -u root -p
```
Enter your MySQL root password, then run:
```sql
CREATE DATABASE review_center_exam CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
EXIT;
```

### 2. Setup Backend (Laravel)

```powershell
# Navigate to backend
cd "Exam-Main\backend"

# Install PHP dependencies
composer install

# Copy environment file
copy .env.example .env

# Generate application key
php artisan key:generate
```

**Edit the .env file:**
Open `Exam-Main\backend\.env` in a text editor and update:
```env
DB_DATABASE=review_center_exam
DB_USERNAME=root
DB_PASSWORD=your_mysql_password_here
```

**Run migrations:**
```powershell
php artisan migrate
```

**Start the backend server:**
```powershell
php artisan serve
```

The backend will run at: http://localhost:8000

### 3. Setup Frontend (Vue.js)

Open a NEW PowerShell window:
```powershell
# Navigate to frontend
cd "Exam-Main\frontend"

# Install Node.js dependencies
npm install

# Copy environment file
copy .env.example .env

# Start the development server
npm run dev
```

The frontend will run at: https://localhost:5173

---

## Troubleshooting

### PHP Issues

**"php is not recognized"**
- Close and reopen PowerShell after adding PHP to PATH
- Verify `C:\php` is in your PATH environment variable

**"Class 'PDO' not found"**
- Open `C:\php\php.ini`
- Find `;extension=pdo_mysql` and remove the `;`
- Save and restart

### Composer Issues

**"composer is not recognized"**
- Close and reopen PowerShell
- Reinstall Composer and make sure it finds php.exe

### Node.js Issues

**"node is not recognized"**
- Close and reopen PowerShell
- Reinstall Node.js with default settings

### MySQL Issues

**"mysql is not recognized"**
- Add MySQL to PATH: `C:\Program Files\MySQL\MySQL Server 8.0\bin`
- Close and reopen PowerShell

**"Access denied for user 'root'"**
- Check your password in the .env file
- Make sure MySQL service is running

**"Connection refused"**
- Start MySQL service:
  ```powershell
  net start MySQL80
  ```

---

## Quick Verification Checklist

After installation, verify everything works:

```powershell
# Check PHP
php --version

# Check Composer
composer --version

# Check Node.js
node --version

# Check npm
npm --version

# Check MySQL
mysql --version
```

All commands should return version numbers without errors.

---

## Next Steps

Once everything is installed and running:

1. ✅ Backend running at http://localhost:8000
2. ✅ Frontend running at https://localhost:5173
3. ✅ Database tables created in MySQL

You can then:
- Visit https://localhost:5173 to see the login page
- Proceed to Task 2: Implement authentication and session management

---

## Need Help?

If you encounter issues:
1. Make sure you opened a NEW PowerShell window after each installation
2. Check that all software is added to your PATH
3. Verify MySQL service is running
4. Check the SETUP_INSTRUCTIONS.md for more detailed troubleshooting

## Download Links Summary

- **PHP**: https://windows.php.net/download/
- **Composer**: https://getcomposer.org/Composer-Setup.exe
- **Node.js**: https://nodejs.org/
- **MySQL**: https://dev.mysql.com/downloads/installer/

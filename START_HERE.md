# 🚀 START HERE - Installation Instructions

## You Need to Install 4 Things

Since PHP, Composer, Node.js, and MySQL are not installed on your system, you need to install them manually. I cannot install software through the terminal, but I've created detailed guides to help you!

## 📋 Follow These Steps

### Option 1: Quick Checklist (Recommended)
Open `INSTALLATION_CHECKLIST.md` and follow the step-by-step checklist.

### Option 2: Detailed Guide
Open `INSTALLATION_GUIDE.md` for detailed instructions with troubleshooting.

## 🔗 Direct Download Links

Click these links to download the required software:

1. **PHP 8.1+**: https://windows.php.net/download/
   - Download the "VS16 x64 Thread Safe" ZIP file
   - Extract to `C:\php`

2. **Composer**: https://getcomposer.org/Composer-Setup.exe
   - Download and run the installer
   - Point it to `C:\php\php.exe`

3. **Node.js 18+**: https://nodejs.org/
   - Download the LTS version
   - Run the installer with default settings

4. **MySQL 8.0+**: https://dev.mysql.com/downloads/installer/
   - Download the MySQL Installer
   - Choose "Developer Default" setup
   - Set a root password (remember it!)

## ⚡ After Installation

Once all 4 are installed, open PowerShell and run:

```powershell
# Verify installations
php --version
composer --version
node --version
mysql --version

# Create database
mysql -u root -p
# Then run: CREATE DATABASE review_center_exam;
# Then run: EXIT;

# Setup backend
cd Exam-Main\backend
composer install
copy .env.example .env
php artisan key:generate
# Edit .env and set your MySQL password
php artisan migrate
php artisan serve

# In a NEW PowerShell window, setup frontend
cd Exam-Main\frontend
npm install
npm run dev
```

## ✅ Success!

When both servers are running:
- Backend: http://localhost:8000
- Frontend: https://localhost:5173

You'll see the login page and all 13 database tables will be created!

## 📚 Additional Resources

- `INSTALLATION_GUIDE.md` - Detailed installation instructions
- `INSTALLATION_CHECKLIST.md` - Step-by-step checklist
- `QUICK_START.md` - Quick commands reference
- `SETUP_INSTRUCTIONS.md` - Troubleshooting guide

## ❓ Need Help?

If you get stuck:
1. Check the INSTALLATION_GUIDE.md for troubleshooting
2. Make sure you open a NEW PowerShell window after each installation
3. Verify all software is added to your Windows PATH

---

**Note:** I cannot install software through the terminal, but these guides will help you install everything you need. The installation process typically takes 15-30 minutes.

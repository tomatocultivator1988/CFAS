# Backend Structure Explained

## The Problem: Nested Public Folders

You have duplicate Laravel installations inside `backend/public/`. This happened because someone accidentally copied the entire project into the public folder multiple times.

## Current Structure (With Duplicates)

```
backend/
├── app/                    ✓ USED (Laravel application code)
├── public/                 ✓ USED (Web root - XAMPP DocumentRoot)
│   ├── index.php          ✓ USED (Entry point)
│   ├── .htaccess          ✓ USED (Apache config)
│   ├── app/               ✗ DUPLICATE (not used)
│   ├── public/            ✗ DUPLICATE (not used)
│   │   ├── public/        ✗ DUPLICATE (not used)
│   │   │   └── public/... ✗ DUPLICATE (10+ levels deep!)
│   ├── vendor/            ✗ DUPLICATE (not used)
│   └── ...                ✗ DUPLICATE (not used)
├── vendor/                ✓ USED (Dependencies)
└── ...                    ✓ USED (Other Laravel folders)
```

## Which One Does The System Use?

**The system uses the CORRECT structure:**

```
backend/
├── app/              ← Controllers, Models, Services
├── public/           ← XAMPP points here (DocumentRoot)
│   └── index.php     ← Entry point (loads ../vendor/autoload.php)
├── vendor/           ← Dependencies (loaded by index.php)
└── ...
```

**XAMPP Configuration:**
- DocumentRoot: `C:/xampp/htdocs/exam-backend/public`
- Entry point: `public/index.php`
- This file loads: `../vendor/autoload.php` (goes UP to backend/vendor/)

## The Nested Folders Are NOT Used

All the folders inside `backend/public/` (except `index.php` and `.htaccess`) are duplicates:

- `backend/public/app/` ← NOT USED
- `backend/public/public/` ← NOT USED
- `backend/public/vendor/` ← NOT USED
- etc.

These are wasting disk space (~200-500 MB) but NOT affecting the system.

## How To Verify Which Is Used

Check `backend/public/index.php`:

```php
require __DIR__.'/../vendor/autoload.php';
//            ^^^ Goes UP one level to backend/vendor/
```

This confirms it uses `backend/vendor/`, NOT `backend/public/vendor/`.

## Should You Clean It Up?

**Yes, but carefully:**

### Benefits:
- Free up 200-500 MB disk space
- Cleaner project structure
- Faster GitHub uploads (less files)
- Less confusion

### Safe To Delete:
From `backend/public/`, you can safely delete:
- `app/` folder
- `public/` folder (the nested one)
- `bootstrap/` folder
- `config/` folder
- `database/` folder
- `resources/` folder
- `routes/` folder
- `storage/` folder
- `tests/` folder
- `vendor/` folder
- `.env` file
- `artisan` file
- `composer.json` file
- etc.

### Must KEEP in `backend/public/`:
- `index.php` ✓
- `.htaccess` ✓
- Any uploaded files (if you have an uploads folder)

## How To Clean Up

Run the cleanup script:

```powershell
.\cleanup-nested-public.ps1
```

Or manually delete the duplicate folders from `backend/public/`.

## Correct Laravel Structure

After cleanup, your structure should be:

```
backend/
├── app/
│   ├── Console/
│   ├── Exceptions/
│   ├── Http/
│   │   └── Controllers/
│   ├── Models/
│   ├── Providers/
│   └── Services/
├── bootstrap/
│   └── app.php
├── config/
│   ├── app.php
│   ├── database.php
│   └── ...
├── database/
│   ├── migrations/
│   └── seeders/
├── public/              ← XAMPP DocumentRoot
│   ├── index.php       ← Entry point ONLY
│   └── .htaccess       ← Apache config ONLY
├── resources/
│   └── views/
├── routes/
│   ├── api.php
│   ├── console.php
│   └── web.php
├── storage/
│   ├── app/
│   ├── framework/
│   └── logs/
├── tests/
├── vendor/
├── .env
├── artisan
├── composer.json
└── composer.lock
```

## Why Did This Happen?

Someone probably:
1. Deployed the entire `backend/` folder to XAMPP
2. Then copied it again into `public/`
3. Then copied it again into `public/public/`
4. And so on...

This is a common mistake when deploying Laravel without understanding the structure.

## Summary

- ✓ System is working correctly (uses `backend/public/index.php`)
- ✗ Duplicate folders are wasting space
- ✓ Safe to clean up (run `cleanup-nested-public.ps1`)
- ✓ Won't affect the running system

## Need Help?

Run: `.\cleanup-nested-public.ps1` to automatically clean up the duplicates.

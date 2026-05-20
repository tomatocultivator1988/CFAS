# Setup with XAMPP

Since you're using XAMPP, follow these steps:

## Step 1: Start XAMPP Services

1. Open XAMPP Control Panel
2. Start **Apache** (for phpMyAdmin)
3. Start **MySQL** (for database)

## Step 2: Create Database

1. Open your browser and go to: http://localhost/phpmyadmin
2. Click "New" in the left sidebar
3. Database name: `review_center_exam`
4. Collation: `utf8mb4_unicode_ci`
5. Click "Create"

## Step 3: Setup Backend

Now run these commands in PowerShell:

```powershell
cd Exam-Main\backend

# Install dependencies
composer install

# Copy environment file
copy .env.example .env

# Generate application key
php artisan key:generate
```

## Step 4: Configure Database Connection

The `.env` file should already have the correct XAMPP settings:
- DB_HOST=127.0.0.1
- DB_PORT=3306
- DB_DATABASE=review_center_exam
- DB_USERNAME=root
- DB_PASSWORD= (leave empty for XAMPP default)

## Step 5: Run Migrations

```powershell
php artisan migrate
```

This will create all 13 tables in your database!

## Step 6: Start Backend Server

```powershell
php artisan serve
```

Backend will run at: http://localhost:8000

## Step 7: Setup Frontend (New PowerShell Window)

```powershell
cd Exam-Main\frontend

# Install dependencies
npm install

# Copy environment file
copy .env.example .env

# Start development server
npm run dev
```

Frontend will run at: https://localhost:5173

## Verify

- Backend: http://localhost:8000/api/auth/login
- Frontend: https://localhost:5173
- Database: Check phpMyAdmin - you should see 13 tables in review_center_exam database

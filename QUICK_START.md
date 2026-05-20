# Quick Start Guide

## Prerequisites Required

Before you can run this project, you need to install:

1. **PHP 8.1+** - https://windows.php.net/download/
2. **Composer** - https://getcomposer.org/Composer-Setup.exe
3. **Node.js 18+** - https://nodejs.org/
4. **MySQL 8.0+** - https://dev.mysql.com/downloads/installer/

## Quick Setup (After Installing Prerequisites)

### 1. Backend Setup

```bash
# Navigate to backend
cd Exam-Main/backend

# Install dependencies
composer install

# Copy environment file
copy .env.example .env

# Generate application key
php artisan key:generate

# Create database (in MySQL)
mysql -u root -p
CREATE DATABASE review_center_exam;
EXIT;

# Update .env with your MySQL password
# DB_PASSWORD=your_password_here

# Run migrations
php artisan migrate

# Start server
php artisan serve
```

Backend will run at: http://localhost:8000

### 2. Frontend Setup

Open a new terminal:

```bash
# Navigate to frontend
cd Exam-Main/frontend

# Install dependencies
npm install

# Copy environment file
copy .env.example .env

# Start development server
npm run dev
```

Frontend will run at: https://localhost:5173

## Verify Setup

1. Backend: Visit http://localhost:8000/api/auth/login
2. Frontend: Visit https://localhost:5173 (should show login page)
3. Database: Run `mysql -u root -p` then `USE review_center_exam; SHOW TABLES;`

## What's Next?

After setup is complete, proceed to:
- **Task 2**: Implement authentication and session management
- See `.kiro/specs/review-center-examination-system/tasks.md` for full task list

## Need Help?

- See `SETUP_INSTRUCTIONS.md` for detailed setup guide
- See `README.md` for project overview
- See `TASK_1_COMPLETION_SUMMARY.md` for what was created

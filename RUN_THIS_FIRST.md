# 🚀 Quick Setup Guide (With XAMPP)

## Prerequisites Check ✅

You have:
- ✅ PHP 8.2.12 (via XAMPP)
- ✅ Composer 2.9.5
- ✅ Node.js 24.13.0
- ✅ npm 11.6.2
- ✅ MySQL (via XAMPP)

## Setup Steps

### Step 1: Add MySQL to PATH (Optional but Recommended)

1. Open System Environment Variables
2. Add to PATH: `C:\xampp\mysql\bin`
3. Restart PowerShell

### Step 2: Start XAMPP Services

1. Open XAMPP Control Panel
2. Click "Start" for **Apache**
3. Click "Start" for **MySQL**

### Step 3: Create Database

**Option A: Using phpMyAdmin (Easiest)**
1. Open browser: http://localhost/phpmyadmin
2. Click "New" in left sidebar
3. Database name: `review_center_exam`
4. Collation: `utf8mb4_unicode_ci`
5. Click "Create"

**Option B: Using MySQL Command (if added to PATH)**
```powershell
mysql -u root -p
# Press Enter (no password for XAMPP default)
# Then paste:
CREATE DATABASE review_center_exam CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
EXIT;
```

**Option C: Using SQL File**
1. Open phpMyAdmin
2. Click "Import" tab
3. Choose file: `Exam-Main/create-database.sql`
4. Click "Go"

### Step 4: Setup Backend

**Option A: Using Batch File (Easiest)**
```powershell
cd Exam-Main
.\setup-backend.bat
```

**Option B: Manual Commands**
```powershell
cd Exam-Main\backend
composer install
copy .env.example .env
php artisan key:generate
```

### Step 5: Run Database Migrations

```powershell
cd Exam-Main\backend
php artisan migrate
```

You should see:
```
Migration table created successfully.
Migrating: 2024_01_01_000001_create_users_table
Migrated:  2024_01_01_000001_create_users_table
Migrating: 2024_01_01_000002_create_exams_table
Migrated:  2024_01_01_000002_create_exams_table
... (13 tables total)
```

### Step 6: Start Backend Server

```powershell
php artisan serve
```

Keep this window open. Backend runs at: http://localhost:8000

### Step 7: Setup Frontend (New PowerShell Window)

**Option A: Using Batch File (Easiest)**
```powershell
cd Exam-Main
.\setup-frontend.bat
```

**Option B: Manual Commands**
```powershell
cd Exam-Main\frontend
npm install
copy .env.example .env
```

### Step 8: Start Frontend Server

```powershell
cd Exam-Main\frontend
npm run dev
```

Frontend runs at: https://localhost:5173

## Verify Installation ✅

1. **Backend API**: Open http://localhost:8000/api/auth/login
   - Should see JSON response

2. **Frontend**: Open https://localhost:5173
   - Should see login page

3. **Database**: Open http://localhost/phpmyadmin
   - Select `review_center_exam` database
   - Should see 13 tables:
     - users
     - exams
     - questions
     - answer_choices
     - exam_questions
     - exam_assignments
     - exam_attempts
     - attempt_answers
     - security_violations
     - auth_tokens
     - audit_logs
     - ml_predictions
     - ml_model_metrics

## Troubleshooting

**"SQLSTATE[HY000] [1045] Access denied"**
- Edit `backend\.env`
- Set `DB_PASSWORD=` (empty for XAMPP default)

**"SQLSTATE[HY000] [2002] Connection refused"**
- Make sure MySQL is running in XAMPP Control Panel

**"npm ERR! code ENOENT"**
- Make sure you're in the `frontend` directory
- Try: `npm cache clean --force` then `npm install`

**Port 8000 already in use**
- Use: `php artisan serve --port=8001`

**Port 5173 already in use**
- Edit `frontend/vite.config.js` and change the port

## Next Steps

Once everything is running:
1. ✅ Task 1 is complete (Infrastructure setup)
2. 📝 Proceed to Task 2: Implement authentication and session management
3. 📋 See `.kiro/specs/review-center-examination-system/tasks.md` for full task list

## Quick Commands Reference

```powershell
# Start backend
cd Exam-Main\backend
php artisan serve

# Start frontend (new window)
cd Exam-Main\frontend
npm run dev

# Run migrations
cd Exam-Main\backend
php artisan migrate

# Clear cache (if needed)
php artisan cache:clear
php artisan config:clear
```

---

**Need help?** Check the other documentation files:
- `XAMPP_SETUP.md` - XAMPP-specific instructions
- `INSTALLATION_GUIDE.md` - Detailed installation guide
- `SETUP_INSTRUCTIONS.md` - Troubleshooting guide

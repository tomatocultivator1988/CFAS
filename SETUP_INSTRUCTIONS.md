# Setup Instructions

This document provides step-by-step instructions to set up the Review Center Examination System after completing Task 1 (Project Infrastructure Setup).

## Prerequisites Installation

### 1. Install PHP (8.1 or higher)

**Windows:**
- Download PHP from https://windows.php.net/download/
- Extract to `C:\php`
- Add `C:\php` to system PATH
- Copy `php.ini-development` to `php.ini`
- Enable required extensions in `php.ini`:
  ```ini
  extension=openssl
  extension=pdo_mysql
  extension=mbstring
  extension=fileinfo
  ```

**Verify installation:**
```bash
php --version
```

### 2. Install Composer

**Windows:**
- Download from https://getcomposer.org/Composer-Setup.exe
- Run the installer
- Follow the installation wizard

**Verify installation:**
```bash
composer --version
```

### 3. Install Node.js (18.x or higher)

**Windows:**
- Download from https://nodejs.org/
- Run the installer
- Choose "Automatically install necessary tools" option

**Verify installation:**
```bash
node --version
npm --version
```

### 4. Install MySQL (8.0 or higher)

**Windows:**
- Download MySQL Installer from https://dev.mysql.com/downloads/installer/
- Run the installer
- Choose "Developer Default" setup type
- Set root password during installation
- Complete the installation

**Verify installation:**
```bash
mysql --version
```

## Project Setup

### Step 1: Backend Setup (Laravel)

1. Navigate to the backend directory:
```bash
cd Exam-Main/backend
```

2. Install PHP dependencies:
```bash
composer install
```

3. Copy the environment file:
```bash
copy .env.example .env
```

4. Generate application key:
```bash
php artisan key:generate
```

5. Create MySQL database:
```sql
mysql -u root -p
CREATE DATABASE review_center_exam CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
EXIT;
```

6. Configure database in `.env` file:
```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=review_center_exam
DB_USERNAME=root
DB_PASSWORD=your_mysql_password
```

7. Run database migrations:
```bash
php artisan migrate
```

8. Start the Laravel development server:
```bash
php artisan serve --host=localhost --port=8000
```

The backend API will be available at: `http://localhost:8000`

### Step 2: Frontend Setup (Vue.js)

1. Open a new terminal and navigate to the frontend directory:
```bash
cd Exam-Main/frontend
```

2. Install Node.js dependencies:
```bash
npm install
```

3. Copy the environment file:
```bash
copy .env.example .env
```

4. Start the Vite development server:
```bash
npm run dev
```

The frontend will be available at: `https://localhost:5173`

## Verification

### 1. Check Backend

Open your browser and navigate to:
- `http://localhost:8000/api/auth/login` - Should return a JSON message

### 2. Check Frontend

Open your browser and navigate to:
- `https://localhost:5173` - Should display the login page

### 3. Check Database

Connect to MySQL and verify tables were created:
```sql
mysql -u root -p
USE review_center_exam;
SHOW TABLES;
```

You should see 13 tables:
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

### Backend Issues

**Issue: "Class 'PDO' not found"**
- Solution: Enable `extension=pdo_mysql` in `php.ini`

**Issue: "SQLSTATE[HY000] [2002] Connection refused"**
- Solution: Ensure MySQL is running and credentials in `.env` are correct

**Issue: "The stream or file could not be opened"**
- Solution: Run `php artisan cache:clear` and ensure storage directory has write permissions

### Frontend Issues

**Issue: "Cannot find module '@vitejs/plugin-vue'"**
- Solution: Delete `node_modules` and `package-lock.json`, then run `npm install` again

**Issue: "EADDRINUSE: address already in use"**
- Solution: Change the port in `vite.config.js` or stop the process using port 5173

**Issue: "net::ERR_CERT_AUTHORITY_INVALID"**
- Solution: This is expected for local HTTPS development. Click "Advanced" and "Proceed to localhost"

## Next Steps

After successful setup:

1. Verify all services are running:
   - Backend: http://localhost:8000
   - Frontend: https://localhost:5173
   - Database: MySQL on port 3306

2. Proceed to Task 2: Implement authentication and session management

3. Refer to `.kiro/specs/review-center-examination-system/tasks.md` for the complete implementation plan

## Development Workflow

### Starting Development

1. Start MySQL service
2. Start Laravel backend: `cd backend && php artisan serve`
3. Start Vue.js frontend: `cd frontend && npm run dev`

### Stopping Development

1. Press `Ctrl+C` in the frontend terminal
2. Press `Ctrl+C` in the backend terminal
3. Stop MySQL service (optional)

## Additional Configuration

### HTTPS/TLS Setup (Production)

For production deployment, you'll need to:

1. Obtain SSL/TLS certificates (Let's Encrypt recommended)
2. Configure web server (Apache/Nginx) with SSL
3. Update `.env` files with production URLs
4. Set `FORCE_HTTPS=true` in backend `.env`

### CORS Configuration

The CORS settings are pre-configured in `backend/config/cors.php` to allow requests from the frontend. If you change the frontend URL, update the `allowed_origins` setting.

### Security Settings

Review and adjust these settings in `backend/.env`:

```env
SESSION_TIMEOUT_MINUTES=30
VIOLATION_THRESHOLD=3
BCRYPT_ROUNDS=12
LAB_IP_RANGE=192.168.1.0/24
```

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review the main README.md file
3. Consult the design document at `.kiro/specs/review-center-examination-system/design.md`

# System Architecture Analysis

## Complete Directory Structure Comparison

### Your Development Folder vs XAMPP Deployment

---

## 1. DEVELOPMENT FOLDER STRUCTURE

**Location**: `C:\Users\Hi\Desktop\CFAS REVIEW CENTER EXAMINATION SYSTEM\Exam-Main\`

```
Exam-Main/                                    (Development Root)
├── .git/                                     (Git repository)
├── backend/                                  (Laravel Backend - Source)
│   ├── app/                                 (Application code)
│   │   ├── Console/                         (CLI commands)
│   │   ├── Exceptions/                      (Error handlers)
│   │   ├── Http/
│   │   │   ├── Controllers/                (API controllers)
│   │   │   └── Middleware/                 (Request middleware)
│   │   ├── Models/                         (Database models)
│   │   ├── Providers/                      (Service providers)
│   │   └── Services/                       (Business logic)
│   ├── bootstrap/                          (Laravel bootstrap)
│   ├── config/                             (Configuration files)
│   ├── database/
│   │   ├── migrations/                     (Database schema)
│   │   └── seeders/                        (Test data)
│   ├── public/                             (Web root - CLEANED ✓)
│   │   ├── .htaccess                       (Apache config)
│   │   ├── index.php                       (Entry point)
│   │   ├── ml-debug-dashboard.php          (Debug tool)
│   │   ├── reset-circuit-breaker.php       (Utility)
│   │   └── test-ml-direct.php              (Test script)
│   ├── resources/                          (Views, assets)
│   ├── routes/                             (API routes)
│   │   ├── api.php                         (API endpoints)
│   │   ├── console.php                     (CLI routes)
│   │   └── web.php                         (Web routes)
│   ├── storage/                            (Logs, cache, uploads)
│   │   ├── app/                            (File storage)
│   │   ├── framework/                      (Framework cache)
│   │   └── logs/                           (Application logs)
│   ├── tests/                              (Unit/Feature tests)
│   ├── vendor/                             (PHP dependencies)
│   ├── .env                                (Environment config)
│   ├── artisan                             (CLI tool)
│   ├── composer.json                       (Dependencies)
│   └── composer.lock                       (Locked versions)
│
├── frontend/                                (Vue.js Frontend - Source)
│   ├── dist/                               (Built files - generated)
│   ├── node_modules/                       (Node dependencies)
│   ├── public/                             (Static assets)
│   ├── src/                                (Source code)
│   │   ├── assets/                         (Images, styles)
│   │   ├── components/                     (Vue components)
│   │   ├── composables/                    (Reusable logic)
│   │   ├── router/                         (Vue Router)
│   │   ├── stores/                         (Pinia stores)
│   │   ├── views/                          (Page components)
│   │   │   ├── admin/                      (Admin pages)
│   │   │   └── reviewee/                   (Student pages)
│   │   ├── App.vue                         (Root component)
│   │   └── main.js                         (Entry point)
│   ├── .env                                (Frontend config)
│   ├── index.html                          (HTML template)
│   ├── package.json                        (Dependencies)
│   ├── package-lock.json                   (Locked versions)
│   └── vite.config.js                      (Build config)
│
├── ml_model/                                (Machine Learning Service)
│   ├── models/                             (Trained ML models)
│   ├── predict_api.py                      (Flask API server)
│   ├── train_model.py                      (Training script)
│   ├── requirements.txt                    (Python dependencies)
│   └── README.md                           (ML documentation)
│
├── vendor/                                  (Root-level PHP dependencies)
│   └── phpoffice/                          (For DOCX parsing)
│
├── .gitignore                              (Git ignore rules)
├── composer.json                           (Root dependencies)
├── requirements.txt                        (Python dependencies)
├── README.md                               (Project documentation)
│
└── [200+ files]                            (Scripts, docs, test files)
    ├── deploy-*.bat                        (Deployment scripts)
    ├── test-*.php/ps1                      (Test scripts)
    ├── setup-*.bat/ps1                     (Setup scripts)
    ├── *.docx                              (Sample exam files)
    ├── *.sql                               (Database dumps)
    └── *.md                                (Documentation)
```

---

## 2. XAMPP DEPLOYMENT STRUCTURE

**Location**: `C:\xampp\htdocs\`

```
C:\xampp\htdocs/
├── exam-backend/                            (Laravel Backend - Deployed)
│   ├── app/                                (Same as development)
│   ├── bootstrap/
│   ├── config/
│   ├── database/
│   ├── public/                             (Apache DocumentRoot)
│   │   ├── .htaccess                       (URL rewriting)
│   │   └── index.php                       (Entry point)
│   ├── resources/
│   ├── routes/
│   ├── storage/                            (Writable by Apache)
│   ├── vendor/                             (Installed via composer)
│   ├── .env                                (Production config)
│   └── artisan
│
└── exam-frontend/                           (Vue.js Frontend - Deployed)
    ├── assets/                             (Built CSS/JS)
    ├── index.html                          (Entry HTML)
    └── [other built files]
```

---

## 3. KEY DIFFERENCES

### Development vs Production

| Aspect | Development (Exam-Main) | Production (XAMPP) |
|--------|------------------------|-------------------|
| **Location** | Desktop folder | C:\xampp\htdocs\ |
| **Backend** | Full source + vendor | Deployed copy |
| **Frontend** | Source + node_modules | Built dist/ only |
| **Git** | Yes (.git folder) | No |
| **Dependencies** | Installed locally | Copied/installed |
| **Environment** | .env (local) | .env (production) |
| **Purpose** | Development & testing | Running system |

---

## 4. URL MAPPING

### Backend API

**Development**:
- Files: `Exam-Main/backend/`
- Not directly accessible via URL

**Production (XAMPP)**:
- Files: `C:\xampp\htdocs\exam-backend/`
- URL: `http://192.168.11.40/exam-backend/public/api`
- DocumentRoot: `C:\xampp\htdocs\exam-backend/public/`
- Entry: `public/index.php`

**Apache Configuration**:
```apache
DocumentRoot "C:/xampp/htdocs/exam-backend/public"
<Directory "C:/xampp/htdocs/exam-backend/public">
    AllowOverride All
    Require all granted
</Directory>
```

### Frontend

**Development**:
- Files: `Exam-Main/frontend/src/`
- Dev server: `npm run dev` (usually port 5173)

**Production (XAMPP)**:
- Files: `C:\xampp\htdocs\exam-frontend/`
- URL: `http://192.168.11.40/exam-frontend`
- Serves: Built files from `frontend/dist/`

---

## 5. DEPLOYMENT FLOW

### Backend Deployment

```
Exam-Main/backend/
    ↓ (deploy-backend.bat)
    ↓ (robocopy)
C:\xampp\htdocs\exam-backend/
    ↓ (composer install)
    ↓ (Apache serves)
http://192.168.11.40/exam-backend/public/api
```

**What Gets Copied**:
- ✓ app/, bootstrap/, config/, database/, public/, resources/, routes/
- ✓ .env, artisan, composer.json
- ✗ node_modules/, vendor/ (reinstalled)
- ✗ storage/logs/, storage/framework/cache/ (recreated)
- ✗ .git/, test files

### Frontend Deployment

```
Exam-Main/frontend/src/
    ↓ (npm run build)
Exam-Main/frontend/dist/
    ↓ (deploy-frontend.bat)
    ↓ (xcopy)
C:\xampp\htdocs\exam-frontend/
    ↓ (Apache serves)
http://192.168.11.40/exam-frontend
```

**What Gets Copied**:
- ✓ Built HTML, CSS, JS from dist/
- ✗ src/, node_modules/, package.json

---

## 6. FILE PATHS IN CODE

### Backend (Laravel)

**In Development**:
```php
// Exam-Main/backend/public/index.php
require __DIR__.'/../vendor/autoload.php';
// Loads: Exam-Main/backend/vendor/autoload.php
```

**In Production (XAMPP)**:
```php
// C:\xampp\htdocs\exam-backend\public\index.php
require __DIR__.'/../vendor/autoload.php';
// Loads: C:\xampp\htdocs\exam-backend\vendor\autoload.php
```

**Both use relative paths** - works in both environments!

### Frontend (Vue.js)

**In Development**:
```javascript
// Exam-Main/frontend/.env
VITE_API_URL=http://192.168.11.40/exam-backend/public/api
```

**In Production (Built)**:
```javascript
// C:\xampp\htdocs\exam-frontend\assets\index-*.js
// API URL is baked into the built JavaScript
const API_URL = "http://192.168.11.40/exam-backend/public/api";
```

---

## 7. DATABASE CONNECTION

**Both environments use the same database**:

```
Host: 127.0.0.1 (localhost)
Port: 3306
Database: review_center_exam
Username: root
Password: (empty)
```

**Location**: XAMPP MySQL Server
- Data: `C:\xampp\mysql\data\review_center_exam\`
- Config: `C:\xampp\mysql\bin\my.ini`

---

## 8. ML SERVICE

**Development**:
```
Location: Exam-Main/ml_model/
Run: python predict_api.py
URL: http://localhost:5000
```

**Production**:
```
Same location (not deployed to XAMPP)
Runs independently as Python Flask server
Backend connects via: ML_SERVICE_URL=http://localhost:5000
```

---

## 9. STORAGE & UPLOADS

### Backend Storage

**Development**:
```
Exam-Main/backend/storage/
├── app/
│   ├── public/          (Public files)
│   └── temp/            (Temporary uploads)
├── framework/
│   ├── cache/           (Application cache)
│   ├── sessions/        (User sessions)
│   └── views/           (Compiled views)
└── logs/
    └── laravel.log      (Application logs)
```

**Production (XAMPP)**:
```
C:\xampp\htdocs\exam-backend\storage/
(Same structure, but writable by Apache)
```

---

## 10. CONFIGURATION FILES

### Backend .env

**Development** (`Exam-Main/backend/.env`):
```env
APP_URL=http://192.168.11.40/exam-backend
DB_HOST=127.0.0.1
DB_DATABASE=review_center_exam
ML_SERVICE_URL=http://localhost:5000
```

**Production** (`C:\xampp\htdocs\exam-backend\.env`):
```env
(Same file, copied during deployment)
```

### Frontend .env

**Development** (`Exam-Main/frontend/.env`):
```env
VITE_API_URL=http://192.168.11.40/exam-backend/public/api
```

**Production**:
```
(Baked into built JavaScript during npm run build)
```

---

## 11. WORKFLOW SUMMARY

### Development Workflow

1. **Edit code** in `Exam-Main/backend/` or `Exam-Main/frontend/src/`
2. **Test locally** (PHP artisan serve or npm run dev)
3. **Deploy** using `deploy-backend.bat` or `deploy-frontend.bat`
4. **Access** via `http://192.168.11.40/`

### Deployment Workflow

```
[Edit Code]
    ↓
[Test Locally]
    ↓
[Run deploy-backend.bat]
    ↓
[Backend copied to XAMPP]
    ↓
[Composer install]
    ↓
[Restart Apache]
    ↓
[System Live]
```

```
[Edit Frontend]
    ↓
[npm run build]
    ↓
[Run deploy-frontend.bat]
    ↓
[dist/ copied to XAMPP]
    ↓
[System Live]
```

---

## 12. IMPORTANT NOTES

### ✓ Correct Structure (After Cleanup)

```
backend/public/
├── .htaccess          ✓ (Apache config)
├── index.php          ✓ (Entry point)
└── [utility scripts]  ✓ (Debug tools)
```

**No nested folders!** The cleanup removed 15+ levels of duplicates.

### ✗ What Was Wrong (Before Cleanup)

```
backend/public/
├── index.php          ✓ (Correct)
├── public/            ✗ (Duplicate)
│   ├── public/        ✗ (Duplicate)
│   │   └── public/... ✗ (15+ levels!)
│   ├── app/           ✗ (Duplicate)
│   └── vendor/        ✗ (Duplicate)
```

---

## 13. SYSTEM COMPONENTS

### 1. Backend (Laravel PHP)
- **Development**: `Exam-Main/backend/`
- **Production**: `C:\xampp\htdocs\exam-backend/`
- **Entry**: `public/index.php`
- **URL**: `http://192.168.11.40/exam-backend/public/api`

### 2. Frontend (Vue.js)
- **Development**: `Exam-Main/frontend/src/`
- **Production**: `C:\xampp\htdocs\exam-frontend/`
- **Entry**: `index.html`
- **URL**: `http://192.168.11.40/exam-frontend`

### 3. Database (MySQL)
- **Server**: XAMPP MySQL (localhost:3306)
- **Database**: `review_center_exam`
- **Data**: `C:\xampp\mysql\data\`

### 4. ML Service (Python Flask)
- **Location**: `Exam-Main/ml_model/`
- **Server**: `http://localhost:5000`
- **Not deployed to XAMPP** (runs independently)

### 5. Web Server (Apache)
- **Location**: `C:\xampp\apache\`
- **Config**: `C:\xampp\apache\conf\httpd.conf`
- **DocumentRoot**: `C:\xampp\htdocs\`

---

## 14. ANSWER TO YOUR QUESTION

**Q: Is the directory structure the same in XAMPP?**

**A: No, but they're related:**

1. **Development folder** (`Exam-Main/`) contains:
   - Full source code
   - Git repository
   - Test files
   - Documentation
   - Deployment scripts

2. **XAMPP folder** (`C:\xampp\htdocs\`) contains:
   - Deployed backend (copy of `backend/`)
   - Deployed frontend (built from `frontend/dist/`)
   - No source files
   - No Git
   - No test files

3. **The system uses XAMPP**, not the development folder
   - Apache serves from `C:\xampp\htdocs\`
   - URLs point to XAMPP
   - Database is in XAMPP MySQL

4. **Development folder is for editing**
   - You edit code here
   - Then deploy to XAMPP
   - XAMPP serves the deployed code

---

## 15. VISUAL SUMMARY

```
┌─────────────────────────────────────────────────────────┐
│  YOUR COMPUTER                                          │
│                                                         │
│  ┌──────────────────────┐      ┌──────────────────┐   │
│  │  Development Folder  │      │      XAMPP       │   │
│  │  (Exam-Main/)        │      │  (C:\xampp\)     │   │
│  │                      │      │                  │   │
│  │  • Edit code here    │──┐   │  • Runs system   │   │
│  │  • Git repository    │  │   │  • Apache server │   │
│  │  • Test scripts      │  │   │  • MySQL DB      │   │
│  │  • Documentation     │  │   │  • Deployed code │   │
│  └──────────────────────┘  │   └──────────────────┘   │
│                            │            ▲              │
│                            │            │              │
│                            └─Deploy─────┘              │
│                         (deploy-*.bat)                 │
│                                                         │
└─────────────────────────────────────────────────────────┘
                              │
                              │ HTTP
                              ▼
                    ┌──────────────────┐
                    │   Web Browser    │
                    │                  │
                    │  192.168.11.40   │
                    └──────────────────┘
```

---

## Conclusion

Your development folder (`Exam-Main/`) and XAMPP deployment (`C:\xampp\htdocs\`) are **separate but connected**:

- **Exam-Main/** = Source code (where you edit)
- **C:\xampp\htdocs/** = Running system (what users access)
- **Deployment scripts** = Bridge between them

The system is **NOT the same** - XAMPP has only the deployed, production-ready files, while your development folder has everything including source, tests, and documentation.

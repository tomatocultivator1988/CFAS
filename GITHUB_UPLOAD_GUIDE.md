# GitHub Upload Guide

## ✅ Safe to Upload

Your XAMPP code is safe to upload to GitHub! The `.gitignore` file is configured to exclude sensitive and unnecessary files.

## 📋 What Will Be Uploaded

### ✓ Source Code
- Backend PHP/Laravel code (`/backend/app/`, `/backend/routes/`, etc.)
- Frontend Vue.js code (`/frontend/src/`)
- ML model training scripts (`/ml_model/*.py`)
- Configuration files (`.env.example` files only, NOT `.env`)

### ✓ Documentation
- All `.md` files (guides, documentation)
- README files
- Setup instructions

### ✓ Scripts
- Batch files (`.bat`)
- PowerShell scripts (`.ps1`)
- Python scripts (`.py`)

## 🚫 What Will NOT Be Uploaded (Excluded by .gitignore)

### ✗ Sensitive Files
- `.env` files (contains database passwords, API keys)
- `.env.hostinger` (production credentials)
- Database files (`.sql`, `.sqlite`)

### ✗ Dependencies (Can be reinstalled)
- `/backend/vendor/` (PHP dependencies - run `composer install`)
- `/frontend/node_modules/` (Node dependencies - run `npm install`)
- `/ml_model/venv/` (Python virtual environment)

### ✗ Generated Files
- `/frontend/dist/` (built frontend - run `npm run build`)
- `/backend/storage/logs/` (log files)
- `/backend/storage/framework/cache/` (cache files)
- Trained ML models (`.pkl`, `.joblib` files)

### ✗ Temporary Files
- Test output files
- Cache files
- Editor settings

## 🔧 Steps to Upload to GitHub

### 1. Initialize Git (if not already done)
```bash
cd "C:\Users\Hi\Desktop\CFAS REVIEW CENTER EXAMINATION SYSTEM\Exam-Main"
git init
```

### 2. Add Remote Repository
```bash
# Replace with your GitHub repository URL
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
```

### 3. Check What Will Be Uploaded
```bash
# See what files will be included
git status

# See what files are ignored
git status --ignored
```

### 4. Add Files
```bash
# Add all files (respecting .gitignore)
git add .
```

### 5. Commit
```bash
git commit -m "Initial commit: CFAS Review Center Exam System"
```

### 6. Push to GitHub
```bash
# First time push
git push -u origin main

# Or if your branch is named 'master'
git push -u origin master
```

## ⚠️ Important: Before Uploading

### 1. Check for Sensitive Data
Run this command to search for potential sensitive data:
```bash
# Search for passwords in code
git grep -i "password" -- "*.php" "*.js" "*.vue"

# Search for API keys
git grep -i "api_key\|apikey\|secret" -- "*.php" "*.js" "*.vue"
```

### 2. Verify .env Files Are Excluded
```bash
# This should return nothing (files are ignored)
git status | findstr ".env"
```

### 3. Create .env.example Files
Make sure you have example environment files:
- `backend/.env.example` ✓ (already exists)
- `frontend/.env.example` ✓ (already exists)

## 📝 After Someone Clones Your Repository

They will need to:

### 1. Install Backend Dependencies
```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
```

### 2. Install Frontend Dependencies
```bash
cd frontend
npm install
cp .env.example .env
```

### 3. Install Python Dependencies
```bash
cd ml_model
pip install -r requirements.txt
```

### 4. Setup Database
```bash
# Create database
# Import schema or run migrations
php artisan migrate
```

### 5. Train ML Model (if needed)
```bash
cd ml_model
python train_model.py
```

## 🔒 Security Best Practices

### ✓ DO Upload
- Source code
- Configuration templates (`.env.example`)
- Documentation
- Setup scripts
- Database schema (structure only, no data)

### ✗ DON'T Upload
- `.env` files with real credentials
- Database dumps with real user data
- API keys or secrets
- Trained ML models (too large, can be retrained)
- Vendor/node_modules folders
- Personal information

## 📦 Optional: Large Files

If you want to upload large files (like trained ML models or sample documents):

### Option 1: Git LFS (Large File Storage)
```bash
# Install Git LFS
git lfs install

# Track large files
git lfs track "*.pkl"
git lfs track "*.joblib"
git lfs track "*.docx"

# Add .gitattributes
git add .gitattributes
git commit -m "Add Git LFS tracking"
```

### Option 2: External Storage
- Upload large files to Google Drive, Dropbox, etc.
- Add download links in README.md

## 🎯 Recommended Repository Structure

```
your-repo/
├── README.md                 # Main documentation
├── .gitignore               # Already configured ✓
├── backend/                 # Laravel backend
│   ├── .env.example        # Template ✓
│   └── ...
├── frontend/               # Vue.js frontend
│   ├── .env.example       # Template ✓
│   └── ...
├── ml_model/              # ML training scripts
│   ├── requirements.txt   # Python dependencies
│   └── ...
└── docs/                  # All .md documentation files
```

## 🚀 Quick Upload Commands

```bash
# Navigate to project
cd "C:\Users\Hi\Desktop\CFAS REVIEW CENTER EXAMINATION SYSTEM\Exam-Main"

# Initialize and upload
git init
git add .
git commit -m "Initial commit: CFAS Exam System with ML predictions"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git push -u origin main
```

## ✅ Verification Checklist

Before pushing to GitHub, verify:

- [ ] `.env` files are NOT in git status
- [ ] `vendor/` and `node_modules/` are NOT in git status
- [ ] No passwords or API keys in committed code
- [ ] `.env.example` files exist and are included
- [ ] README.md has setup instructions
- [ ] .gitignore is properly configured
- [ ] Database files (.sql) are excluded (or sanitized)

## 📞 Need Help?

If you see any sensitive files about to be uploaded:
```bash
# Remove file from git (but keep locally)
git rm --cached path/to/sensitive/file

# Update .gitignore
echo "path/to/sensitive/file" >> .gitignore

# Commit the change
git add .gitignore
git commit -m "Update .gitignore"
```

## 🎉 You're Ready!

Your code is safe to upload to GitHub. The `.gitignore` file will protect your sensitive data while sharing your source code with others.

# 🚀 GitHub Quick Start - Bisaya/Hiligaynon Guide

## Ano ang Kinahanglan?

Wala pa ka Git sa imo computer! Kinahanglan mo install una.

## Pinakadali nga Paagi (Recommended)

### GitHub Desktop - Visual Interface

1. **Download GitHub Desktop**
   - Adto sa: https://desktop.github.com/
   - I-download ug i-install

2. **Sign In**
   - Mag-create ug GitHub account (kung wala pa)
   - Sign in sa GitHub Desktop

3. **Add Your Project**
   - File → Add Local Repository
   - Browse sa: `C:\Users\Hi\Desktop\CFAS REVIEW CENTER EXAMINATION SYSTEM\Exam-Main`
   - Click "Add Repository"

4. **Publish to GitHub**
   - Click "Publish repository"
   - Pilion kung Public o Private
   - Click "Publish"

5. **TAPOS NA!** ✓
   - Naa na sa GitHub ang imo code!
   - Pwede na nimo i-share ang link!

---

## Lain nga Paagi (Command Line)

Kung gusto mo mag-use ug terminal:

### 1. Install Git
- Download: https://git-scm.com/download/win
- I-install (default settings lang)
- Restart PowerShell

### 2. Run Commands
```bash
cd "C:\Users\Hi\Desktop\CFAS REVIEW CENTER EXAMINATION SYSTEM\Exam-Main"
git init
git add .
git commit -m "Initial commit"
```

### 3. Create Repository sa GitHub
- Adto sa: https://github.com/new
- Create new repository
- Copy ang URL

### 4. Push to GitHub
```bash
git remote add origin YOUR_GITHUB_URL
git branch -M main
git push -u origin main
```

---

## Ano ang Ma-Upload?

### ✓ Ma-Upload (Safe)
- Source code (PHP, Vue.js)
- Documentation (.md files)
- Scripts (.bat, .ps1, .py)
- Setup instructions

### ✗ Dili Ma-Upload (Protected)
- .env files (passwords, secrets)
- vendor/ folder (dependencies)
- node_modules/ folder (dependencies)
- Database files (.sql)
- Log files

---

## Verification

Run una: `check-github-ready.bat`

Kung makita mo:
```
[SUCCESS] READY TO UPLOAD TO GITHUB!
```

Okay na! Safe na i-upload!

---

## Need Help?

### Files to Read:
1. `INSTALL_GIT.md` - Git installation guide
2. `GITHUB_READY.md` - Verification results
3. `GITHUB_UPLOAD_GUIDE.md` - Detailed guide

### Scripts to Run:
1. `install-git.bat` - Install Git helper
2. `check-github-ready.bat` - Verify project is safe

---

## Recommended: GitHub Desktop

Para sa beginners, GitHub Desktop ang pinakadali:
- ✓ Visual interface
- ✓ No command line
- ✓ Easy to use
- ✓ Automatic Git installation

Download: https://desktop.github.com/

---

## Summary

1. Install GitHub Desktop (easiest)
2. Sign in with GitHub account
3. Add your Exam-Main folder
4. Click "Publish repository"
5. DONE! ✓

Ang imo code naa na sa GitHub ug safe ang tanan nga passwords!

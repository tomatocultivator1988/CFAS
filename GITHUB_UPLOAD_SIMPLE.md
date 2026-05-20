# Upload to GitHub - Simple Guide

## Quick Upload

Run this script:
```
.\UPLOAD-TO-GITHUB-NOW.bat
```

This will:
1. Add all your files
2. Create a commit with message: "Auto-logout fix + Latest updates - Feb 25, 2026"
3. Push to: https://github.com/tomatocultivator1988/CFAS.git

---

## What You Need

### GitHub Personal Access Token

You'll need a Personal Access Token (NOT your password) to push to GitHub.

#### How to Create a Token:

1. Go to: https://github.com/settings/tokens
2. Click "Generate new token" → "Generate new token (classic)"
3. Give it a name: "CFAS Upload"
4. Select scopes:
   - ✅ repo (all)
5. Click "Generate token"
6. COPY THE TOKEN (you won't see it again!)

#### When Prompted:

```
Username: tomatocultivator1988
Password: [paste your token here]
```

---

## What Will Be Uploaded

### ✅ Safe to Upload:
- All PHP code (backend)
- All Vue.js code (frontend)
- All Python scripts (ML model)
- All documentation (.md files)
- All batch scripts (.bat files)
- Configuration files

### ❌ NOT Uploaded (Protected by .gitignore):
- .env files (passwords, API keys)
- vendor/ folder (dependencies)
- node_modules/ folder (dependencies)
- Database files (.sql)
- Log files
- Cache files

---

## After Upload

Your code will be available at:
```
https://github.com/tomatocultivator1988/CFAS
```

Anyone can:
- View your code
- Clone the repository
- See your commit history
- Download the code

---

## Troubleshooting

### "Git not found"
- Git is installed at: `C:\Program Files\Git\bin\git.exe`
- The script will add it to PATH automatically

### "Authentication failed"
- Make sure you're using a Personal Access Token, NOT your password
- Create token at: https://github.com/settings/tokens
- Token needs "repo" scope

### "Repository not found"
- Make sure the repository exists: https://github.com/tomatocultivator1988/CFAS
- Check if you have access to it

### "Remote already exists"
- The script will remove and re-add the remote automatically

---

## Manual Upload (If Script Fails)

```powershell
# 1. Set Git path
$env:PATH += ";C:\Program Files\Git\bin"

# 2. Add files
git add .

# 3. Commit
git commit -m "Auto-logout fix + Latest updates - Feb 25, 2026"

# 4. Add remote
git remote add origin https://github.com/tomatocultivator1988/CFAS.git

# 5. Push
git push -u origin main
```

---

## What's Included in This Upload

### Latest Features:
- ✅ Auto-logout disabled (30 days session)
- ✅ Exam review question order fix
- ✅ Nested public folders cleaned up
- ✅ All documentation updated

### System Components:
- Backend (Laravel PHP)
- Frontend (Vue.js)
- ML Model (Python)
- Database migrations
- Deployment scripts
- Testing scripts
- Documentation

---

## File Count

Approximately:
- 200+ PHP files
- 50+ Vue.js files
- 20+ Python scripts
- 100+ documentation files
- 50+ batch/PowerShell scripts

Total: ~500 files (excluding vendor/ and node_modules/)

---

## Repository Size

Estimated: 5-10 MB (without dependencies)

With dependencies (if uploaded):
- vendor/: ~50 MB
- node_modules/: ~200 MB

But these are excluded by .gitignore, so only 5-10 MB will be uploaded.

---

## Next Steps After Upload

1. Verify upload: Visit https://github.com/tomatocultivator1988/CFAS
2. Check files are there
3. Read the README.md on GitHub
4. Share the link with others if needed

---

## Updating Later

To upload new changes:

```
git add .
git commit -m "Your update message"
git push
```

Or run the script again:
```
.\UPLOAD-TO-GITHUB-NOW.bat
```

---

## Security Note

Your .env files with passwords and API keys are NOT uploaded because they're in .gitignore. This is safe!

Protected files:
- backend/.env (database password, API keys)
- frontend/.env (API URLs)
- All sensitive configuration

---

## Support

If you need help:
1. Check the error message
2. Make sure you have a GitHub Personal Access Token
3. Verify the repository exists
4. Check your internet connection

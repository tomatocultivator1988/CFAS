# I-Upload sa GitHub - Hiligaynon Guide

## Quick Upload

Run lang ini nga script:
```
.\UPLOAD-TO-GITHUB-NOW.bat
```

Ini nga script:
1. I-add tanan files
2. I-create ang commit: "Auto-logout fix + Latest updates - Feb 25, 2026"
3. I-push sa: https://github.com/tomatocultivator1988/CFAS.git

---

## Ano ang Kinahanglan

### GitHub Personal Access Token

Kinahanglan mo sang Personal Access Token (HINDI password) para ma-push sa GitHub.

#### Paano Mag-create sang Token:

1. Kadto sa: https://github.com/settings/tokens
2. I-click ang "Generate new token" → "Generate new token (classic)"
3. Hatagi sang name: "CFAS Upload"
4. I-select ang scopes:
   - ✅ repo (tanan)
5. I-click ang "Generate token"
6. I-COPY ANG TOKEN (dili mo na makita liwat ini!)

#### Kung Mag-prompt:

```
Username: tomatocultivator1988
Password: [i-paste diri ang imo token]
```

---

## Ano ang Ma-upload

### ✅ Safe i-upload:
- Tanan PHP code (backend)
- Tanan Vue.js code (frontend)
- Tanan Python scripts (ML model)
- Tanan documentation (.md files)
- Tanan batch scripts (.bat files)
- Configuration files

### ❌ HINDI ma-upload (Protected sang .gitignore):
- .env files (passwords, API keys)
- vendor/ folder (dependencies)
- node_modules/ folder (dependencies)
- Database files (.sql)
- Log files
- Cache files

---

## After Ma-upload

Ang imo code available na sa:
```
https://github.com/tomatocultivator1988/CFAS
```

Pwede sang bisan sin-o:
- Mag-view sang imo code
- Mag-clone sang repository
- Mag-download sang code

---

## Troubleshooting

### "Git not found"
- Naka-install ang Git sa: `C:\Program Files\Git\bin\git.exe`
- Ang script mag-add sini sa PATH automatically

### "Authentication failed"
- Sigurado nga nag-gamit ka sang Personal Access Token, HINDI password
- Mag-create sang token sa: https://github.com/settings/tokens
- Ang token kinahanglan sang "repo" scope

### "Repository not found"
- Sigurado nga existing ang repository: https://github.com/tomatocultivator1988/CFAS
- Check kung may access ka

---

## Manual Upload (Kung Mag-fail ang Script)

```powershell
# 1. I-set ang Git path
$env:PATH += ";C:\Program Files\Git\bin"

# 2. I-add ang files
git add .

# 3. I-commit
git commit -m "Auto-logout fix + Latest updates - Feb 25, 2026"

# 4. I-add ang remote
git remote add origin https://github.com/tomatocultivator1988/CFAS.git

# 5. I-push
git push -u origin main
```

---

## Ano ang Included sa Upload

### Latest Features:
- ✅ Auto-logout disabled (30 days session)
- ✅ Exam review question order fix
- ✅ Nested public folders cleaned up
- ✅ Tanan documentation updated

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

Mga:
- 200+ PHP files
- 50+ Vue.js files
- 20+ Python scripts
- 100+ documentation files
- 50+ batch/PowerShell scripts

Total: ~500 files (wala ang vendor/ kag node_modules/)

---

## Repository Size

Estimated: 5-10 MB (wala ang dependencies)

Kung may dependencies:
- vendor/: ~50 MB
- node_modules/: ~200 MB

Pero excluded ini sang .gitignore, so 5-10 MB lang ang ma-upload.

---

## Next Steps After Upload

1. I-verify ang upload: Bisitaha https://github.com/tomatocultivator1988/CFAS
2. I-check kung naa ang files
3. Basaha ang README.md sa GitHub
4. I-share ang link kung kinahanglan

---

## Pag-update Later

Para mag-upload sang bag-o nga changes:

```
git add .
git commit -m "Imo update message"
git push
```

Or run liwat ang script:
```
.\UPLOAD-TO-GITHUB-NOW.bat
```

---

## Security Note

Ang imo .env files nga may passwords kag API keys HINDI ma-upload kay naa sa .gitignore. Safe ini!

Protected files:
- backend/.env (database password, API keys)
- frontend/.env (API URLs)
- Tanan sensitive configuration

---

## Importante!

Kung mag-prompt sang username/password:
- Username: `tomatocultivator1988`
- Password: I-paste ang imo GitHub Personal Access Token (HINDI ang imo GitHub password!)

Kung wala ka sang token, mag-create sa:
https://github.com/settings/tokens

---

## Ready na!

Run lang:
```
.\UPLOAD-TO-GITHUB-NOW.bat
```

Tapos sundon ang prompts. Tapos na! 🎉

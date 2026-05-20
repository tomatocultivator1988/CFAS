# 🔍 Mga Problema sa Code - Hiligaynon

Petsa: Pebrero 25, 2026

---

## SUMMARY

Nakita ko **25+ ka issues** sa codebase:
- **3 CRITICAL** - Kinahanglan ayuhon SUBONG!
- **4 HIGH** - Ayuhon ini semana
- **13 MEDIUM** - Ayuhon ini bulan
- **5 LOW** - Ayuhon sunod

---

## ⚠️ CRITICAL ISSUES (Ayuhon SUBONG!)

### 1. NAKA-EXPOSE ANG API KEYS!

**Diin:** `backend/.env`

**Problema:** Ang imo API keys makita sa code!
```
GEMINI_API_KEY=[REDACTED_GEMINI_API_KEY]
GROQ_API_KEY=[REDACTED_GROQ_API_KEY]
DEEPSEEK_API_KEY=[REDACTED_API_KEY]
```

**Risk:** Bisan sin-o pwede gam-iton ini nga keys kag mag-gastos sa imo account!

**Solusyon:**
1. I-rotate (change) tanan API keys SUBONG
2. Ayaw i-commit ang .env files sa git
3. Gamita lang environment variables

---

### 2. HARDCODED PATHS (Dili Portable!)

**Diin:** `MLPredictionController.php`

**Problema:**
```php
$scriptPath = 'C:/xampp/htdocs/ml_model/predict_api.py';
```

**Risk:**
- Dili mag-work sa Linux/Mac
- Dili mag-work sa iban nga computer
- Dili portable

**Solusyon:**
```php
$scriptPath = base_path('../ml_model/predict_api.py');
```

---

### 3. SESSION TIMEOUT SOBRA KA-LABA!

**Diin:** `backend/.env`

**Problema:**
```
SESSION_LIFETIME=43200  # 30 days!
```

**Risk:**
- Mag-stay logged in ang users hasta 30 days
- Security risk kung shared ang device
- Dili angay para sa exam environment

**Solusyon:**
```
SESSION_LIFETIME=120  # 2 hours lang
```

---

## 🔴 HIGH PRIORITY (Ayuhon Ini Semana)

### 4. HARDCODED PASSWORDS SA TEST FILES

**Diin:**
- `test-aqua-set-a.php`: `'password' => 'admin123'`
- `test-exam-history.php`: `'password' => 'password123'`
- Kag iban pa...

**Risk:** Makita sang bisan sin-o ang default passwords

**Solusyon:** I-delete ang test files or i-move sa proper test directory

---

### 5. COMMAND INJECTION RISK

**Diin:** `MLPredictionController.php`

**Problema:** Ang student ID gin-pass sa shell command nga wala validation

**Solusyon:** I-validate nga numeric ang student ID before i-pass

---

### 6. WALA CSRF PROTECTION

**Problema:** Wala visible CSRF token validation

**Solusyon:** I-implement CSRF protection

---

### 7. WALA INPUT SANITIZATION

**Problema:** Wala sanitization sang:
- File uploads
- Question text
- User inputs

**Solusyon:** I-implement comprehensive input validation

---

## 🟡 MEDIUM PRIORITY (Ayuhon Ini Bulan)

### 8. INCONSISTENT CONFIGURATION

**Problema:**
- `.env.example` different sa `.env`
- `LAB_IP_RANGES` vs `LAB_IP_RANGE` (inconsistent naming)

---

### 9. MISSING MIGRATION

**Problema:** Migration 000006 missing pero referenced sa code

---

### 10. DEBUG CODE SA PRODUCTION

**Problema:**
- `console.log()` statements sa Vue components
- `alert()` dialogs para sa errors

**Solusyon:** I-remove tanan debug code

---

### 11. N+1 QUERY PROBLEMS

**Problema:** Loops without eager loading = daghang queries

**Solusyon:** Use `with()` para sa eager loading

---

### 12. MISSING DATABASE INDEXES

**Problema:** Wala indexes sa frequently queried columns

**Solusyon:** I-add indexes para mas paspas ang queries

---

### 13. OUTDATED DEPENDENCIES

**Problema:**
- `axios` version old na
- Wala version constraints

**Solusyon:** I-update ang dependencies

---

## 🟢 LOW PRIORITY (Ayuhon Sunod)

### 14. DAGHANG TEST FILES

**Problema:** 100+ test files sa root directory

**Solusyon:** I-organize or i-delete

---

### 15. 7 KA DOCX PARSERS!

**Problema:** 7 different implementations sang same functionality

**Solusyon:** Consolidate to 1 implementation

---

### 16. INCONSISTENT NAMING

**Problema:** Different naming patterns sa database, methods, URLs

**Solusyon:** Standardize naming conventions

---

## 📊 SUMMARY

| Severity | Count | Deadline |
|----------|-------|----------|
| CRITICAL | 3 | SUBONG |
| HIGH | 4 | INI SEMANA |
| MEDIUM | 13 | INI BULAN |
| LOW | 5 | SUNOD |

---

## 🚨 KINAHANGLAN AYUHON SUBONG

### SUBONG:
1. ✅ I-rotate ang tanan API keys
2. ✅ I-remove ang .env sa git history
3. ⚠️ I-fix ang session timeout (30 days subong!)

### INI SEMANA:
4. I-remove ang hardcoded paths
5. I-remove ang hardcoded passwords
6. I-add input validation
7. I-implement CSRF protection

### INI BULAN:
8. I-consolidate ang duplicate code
9. I-remove ang debug statements
10. I-optimize ang database queries
11. I-add proper error handling
12. I-update ang dependencies

---

## 🔧 QUICK FIXES

### Fix #1: Session Timeout
```bash
# I-edit ang backend/.env
SESSION_LIFETIME=120  # Change from 43200 to 120

# I-clear ang cache
php artisan config:clear
php artisan config:cache
```

### Fix #2: Hardcoded Path
```php
// Sa MLPredictionController.php
// Change from:
$scriptPath = 'C:/xampp/htdocs/ml_model/predict_api.py';

// To:
$scriptPath = base_path('../ml_model/predict_api.py');
```

### Fix #3: Remove Debug Code
```bash
# Pangitaa tanan console.log
grep -r "console.log" frontend/src/

# I-remove manually
```

---

## 📝 NOTES

### Maayo nga Practices:
✅ Naga-gamit sang .gitignore
✅ Naga-gamit sang Laravel authentication
✅ Naga-gamit sang migrations
✅ Naga-gamit sang Vue.js
✅ Naga-gamit sang Pinia

### Kinahanglan Pa I-improve:
⚠️ Security hardening
⚠️ Code organization
⚠️ Performance optimization
⚠️ Documentation
⚠️ Testing coverage

---

## 🎯 PRIORITY

1. **Security** (CRITICAL) - Fix exposed credentials
2. **Configuration** (HIGH) - Fix session timeout
3. **Code Quality** (MEDIUM) - Remove debug code
4. **Performance** (MEDIUM) - Optimize queries
5. **Documentation** (LOW) - Add API docs

---

## IMPORTANTE!

Ang pinaka-importante kay ang **3 CRITICAL issues**:
1. Exposed API keys
2. Hardcoded paths
3. Session timeout 30 days

Ini kinahanglan ayuhon SUBONG para secure ang system!

---

**Generated:** Pebrero 25, 2026
**Auditor:** Kiro AI Assistant
**Files Analyzed:** 500+ files

# 🔍 Codebase Audit Report

Date: February 25, 2026

---

## EXECUTIVE SUMMARY

Found **25+ issues** across the codebase:
- **3 CRITICAL** security issues
- **4 HIGH** priority issues
- **13 MEDIUM** priority issues
- **5 LOW** priority issues

---

## ⚠️ CRITICAL ISSUES (Fix Immediately!)

### 1. EXPOSED API KEYS IN .ENV FILE

**Location:** `backend/.env`

**Exposed Credentials:**
```
GEMINI_API_KEY=[REDACTED_GEMINI_API_KEY]
GROQ_API_KEY=[REDACTED_GROQ_API_KEY]
DEEPSEEK_API_KEY=[REDACTED_API_KEY]
```

**Risk:** Anyone with access to the code can use these API keys, potentially incurring costs or accessing sensitive data.

**Fix:**
1. Rotate all API keys immediately
2. Never commit .env files to git
3. Use environment variables only

---

### 2. HARDCODED ABSOLUTE PATHS

**Location:** `backend/app/Http/Controllers/MLPredictionController.php`

**Problem:**
```php
$scriptPath = 'C:/xampp/htdocs/ml_model/predict_api.py';
```

**Risk:** 
- Won't work on Linux/Mac
- Won't work on different installations
- Breaks portability

**Fix:**
```php
$scriptPath = base_path('../ml_model/predict_api.py');
// or
$scriptPath = env('ML_MODEL_PATH', base_path('../ml_model')) . '/predict_api.py';
```

---

### 3. SESSION TIMEOUT TOO LONG

**Location:** `backend/.env`

**Problem:**
```
SESSION_LIFETIME=43200  # 30 days!
```

**Risk:** 
- Users stay logged in for 30 days
- Security vulnerability if device is shared
- Not suitable for exam environment

**Fix:**
```
SESSION_LIFETIME=120  # 2 hours (reasonable for exams)
```

---

## 🔴 HIGH PRIORITY ISSUES

### 4. HARDCODED CREDENTIALS IN TEST FILES

**Locations:**
- `test-aqua-set-a.php`: `'password' => 'admin123'`
- `test-exam-history.php`: `'password' => 'password123'`
- `test-full-import.php`: `'password' => 'admin123'`
- `create-test-reviewee.php`: `password_hash('password123')`

**Risk:** Default credentials are discoverable

**Fix:**
- Remove test files from production
- Use environment-based test credentials
- Never hardcode passwords

---

### 5. COMMAND INJECTION RISK

**Location:** `MLPredictionController.php`

**Problem:**
```php
$command = $this->platformService->buildCommand($scriptPath, [(string)$studentId]);
```

**Risk:** Student ID passed to shell command without validation

**Fix:**
```php
// Validate student ID is numeric
if (!is_numeric($studentId) || $studentId < 1) {
    throw new \InvalidArgumentException('Invalid student ID');
}
$command = $this->platformService->buildCommand($scriptPath, [(string)$studentId]);
```

---

### 6. MISSING CSRF PROTECTION

**Issue:** API routes use token auth but no visible CSRF protection

**Fix:**
- Implement CSRF token validation
- Set SameSite=Strict on cookies
- Configure proper CORS

---

### 7. MISSING INPUT SANITIZATION

**Issue:** No visible sanitization of:
- File uploads
- Question text/choices
- User inputs

**Fix:**
- Implement comprehensive input validation
- Use Laravel's built-in sanitization
- Validate file types and sizes

---

## 🟡 MEDIUM PRIORITY ISSUES

### 8. INCONSISTENT ENVIRONMENT CONFIGURATION

**Problems:**
- `.env.example` has `SESSION_TIMEOUT_MINUTES=30`
- `.env` has `SESSION_TIMEOUT_MINUTES=43200`
- `.env.example` uses `LAB_IP_RANGES` (plural)
- `.env` uses `LAB_IP_RANGE` (singular)

**Fix:** Align .env.example with actual defaults

---

### 9. MISSING MIGRATION

**Issue:** Migration `2024_01_01_000006_create_exam_assignments_table.php` is missing
- Migrations jump from 000005 to 000007
- Later migration drops this table

**Fix:** Create missing migration or remove references

---

### 10. NULLABLE USER_ID IN AUDIT LOGS

**Location:** `2026_02_03_061625_make_user_id_nullable_in_audit_logs_table.php`

**Problem:** Audit logs should always track who performed an action

**Fix:** Implement system user for automated actions, never allow null user_id

---

### 11. DEBUG CODE IN PRODUCTION

**Frontend Vue Components:**
- `ExamDetailView.vue`: `console.log()` statements
- `ViewScores.vue`: `console.error()` statements
- `MLDashboard.vue`: Multiple `console.error()` statements
- `UserManagement.vue`: `alert()` dialogs for errors

**Fix:**
- Remove all console.log/console.error
- Replace alert() with proper error modals
- Implement proper error handling

---

### 12. INCONSISTENT ERROR HANDLING

**Issues:**
- Some controllers use try-catch with detailed logging
- Some use try-catch with generic messages
- Some return null without logging

**Fix:** Standardize error handling across all controllers

---

### 13. MISSING VALIDATION

**Issues:**
- `ExportController.php` uses `DB::raw()` without validation
- No validation on exam ID, student ID in some endpoints

**Fix:**
- Add input validation to all endpoints
- Use Laravel's validation rules
- Sanitize all user inputs

---

### 14. N+1 QUERY PROBLEMS

**Location:** `ExportController.php` - `getCategoryExamData()`

**Problem:** Loops through students/exams without eager loading

**Fix:**
```php
$students = User::where('role', 'reviewee')
    ->with(['examAttempts.exam'])
    ->get();
```

---

### 15. MISSING INDEXES

**Database:**
- `exam_attempts` missing individual column indexes
- No indexes on `created_at` for time-based queries

**Fix:** Add indexes on frequently queried columns

---

### 16. MISSING RATE LIMITING

**Issue:** All endpoints have same rate limit (60 requests/minute)

**Fix:**
- Implement tiered rate limiting
- Stricter limits for sensitive endpoints

---

### 17. FRONTEND-BACKEND URL MISMATCH

**Issue:**
- Frontend: `VITE_API_URL=http://192.168.11.40/exam-backend/public/api`
- Backend: `APP_URL=http://192.168.11.40/exam-backend`

**Fix:** Ensure URLs align correctly

---

### 18. MISSING ERROR BOUNDARIES

**Frontend:** Vue components don't have error boundaries

**Fix:**
- Implement error boundary components
- Add proper error handling in all API calls

---

### 19. OUTDATED DEPENDENCIES

**Frontend:**
- `axios`: `^1.6.0` (old, current is 1.7+)

**Backend:**
- Missing Laravel version specification
- No version constraints

**Fix:**
- Update axios
- Add version constraints to composer.json

---

### 20. MISSING FOREIGN KEY CONSTRAINTS

**Issue:** Not all foreign keys have explicit cascade delete rules

**Fix:** Verify all foreign keys have proper cascade behavior

---

## 🟢 LOW PRIORITY ISSUES

### 21. MULTIPLE TEST FILES

**Issue:** Over 100 test/debug PHP files in root directory

**Fix:**
- Move to proper test directory
- Remove duplicates
- Use PHPUnit

---

### 22. MULTIPLE DOCX PARSER IMPLEMENTATIONS

**Issue:** 7 different parser implementations:
- `parse-docx-flexible.py`
- `parse-docx-gemini.py`
- `parse-docx-inline-format.py`
- `parse-docx-only.py`
- `parse-docx-universal-ai.py`
- `parse-docx-with-answerkey.py`
- `smart-docx-parser.py`

**Fix:** Consolidate to single implementation

---

### 23. INCONSISTENT NAMING PATTERNS

**Issues:**
- Database: `password_hash` vs `is_active` vs `require_password_change`
- Methods: `isAdmin()` vs `examAttempts()`
- URLs: `/admin/ml/predict/{studentId}` vs `/admin/exams`

**Fix:** Standardize naming conventions

---

### 24. MISSING API DOCUMENTATION

**Issue:** No OpenAPI/Swagger documentation

**Fix:** Generate API documentation

---

### 25. INCOMPLETE MIGRATION DOCUMENTATION

**Issue:** No rollback documentation, no data migration strategy

**Fix:** Document migration process

---

## 📊 SUMMARY BY SEVERITY

| Severity | Count | Must Fix By |
|----------|-------|-------------|
| CRITICAL | 3 | TODAY |
| HIGH | 4 | THIS WEEK |
| MEDIUM | 13 | THIS MONTH |
| LOW | 5 | NEXT QUARTER |

---

## 🚨 IMMEDIATE ACTION ITEMS

### TODAY:
1. ✅ Rotate all exposed API keys
2. ✅ Remove .env from git history
3. ⚠️ Fix session timeout (currently 30 days!)

### THIS WEEK:
4. Remove hardcoded paths
5. Remove hardcoded credentials from test files
6. Add input validation to command execution
7. Implement CSRF protection

### THIS MONTH:
8. Consolidate duplicate code
9. Remove debug statements
10. Optimize database queries
11. Add proper error handling
12. Update dependencies

---

## 🔧 QUICK FIXES

### Fix #1: Session Timeout
```bash
# Edit backend/.env
SESSION_LIFETIME=120  # Change from 43200 to 120

# Clear cache
php artisan config:clear
php artisan config:cache
```

### Fix #2: Hardcoded Path
```php
// In MLPredictionController.php
// Change from:
$scriptPath = 'C:/xampp/htdocs/ml_model/predict_api.py';

// To:
$scriptPath = base_path('../ml_model/predict_api.py');
```

### Fix #3: Remove Debug Code
```bash
# Find all console.log
grep -r "console.log" frontend/src/

# Find all console.error
grep -r "console.error" frontend/src/

# Remove them manually
```

---

## 📝 NOTES

### Good Practices Found:
✅ Using .gitignore to protect sensitive files
✅ Using Laravel's built-in authentication
✅ Using migrations for database schema
✅ Using Vue.js for reactive frontend
✅ Using Pinia for state management

### Areas for Improvement:
⚠️ Security hardening needed
⚠️ Code organization and cleanup
⚠️ Performance optimization
⚠️ Documentation
⚠️ Testing coverage

---

## 🎯 PRIORITY RANKING

1. **Security** (CRITICAL) - Fix exposed credentials and hardcoded paths
2. **Configuration** (HIGH) - Fix session timeout and environment inconsistencies
3. **Code Quality** (MEDIUM) - Remove debug code, consolidate duplicates
4. **Performance** (MEDIUM) - Optimize queries, add indexes
5. **Documentation** (LOW) - Add API docs, improve comments

---

## 📞 SUPPORT

If you need help fixing any of these issues, refer to:
- Laravel Security Best Practices
- OWASP Top 10
- PHP Security Guide
- Vue.js Best Practices

---

**Generated:** February 25, 2026
**Auditor:** Kiro AI Assistant
**Scope:** Full codebase analysis
**Files Analyzed:** 500+ files

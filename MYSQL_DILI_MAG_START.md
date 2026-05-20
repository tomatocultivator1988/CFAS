# MySQL Dili Mag-Start - Quick Fix

## Ano ang Problema?

Ang MySQL naga-try mag-start pero immediately naga-stop. Wala naga-show ang port number (3306).

## Posible nga Causes

1. ❌ Corrupt nga my.ini configuration (dahil sa ENABLE-REMOTE-DATABASE-ACCESS.bat)
2. ❌ May naga-gamit na sang port 3306
3. ❌ May temporary files nga naga-lock
4. ❌ MySQL service naga-crash

---

## Quick Fix (2 Steps)

### Step 1: Run ang Diagnostic Tool

```
cd Exam-Main
.\DIAGNOSE-MYSQL.bat
```

Ini nga script mag-check sang:
- Kung naga-run ang MySQL
- Kung free ang port 3306
- Kung existing ang database files
- Kung may error logs

### Step 2: Run ang Complete Fix

```
cd Exam-Main
.\FIX-MYSQL-COMPLETE.bat
```

Ini nga script:
1. Mag-stop sang tanan MySQL processes
2. Mag-restore sang original my.ini
3. Mag-clear sang temporary files
4. Mag-guide sa imo paano mag-start

---

## Manual Fix (Kung dili mag-work ang scripts)

### Option 1: Restore my.ini Manually

1. Stop MySQL sa XAMPP (kung naga-run)

2. Restore ang backup:
```
copy /Y "C:\xampp\mysql\bin\my.ini.backup" "C:\xampp\mysql\bin\my.ini"
```

3. Start MySQL sa XAMPP

### Option 2: Check Error Log

1. Ablihi ang XAMPP Control Panel
2. I-click ang "Logs" button sa MySQL
3. Basaha ang error message
4. Kung naga-say:
   - "Port 3306 already in use" → May iban naga-gamit sang port
   - "Can't start server" → May corrupt nga files
   - "Access denied" → Permission problem

### Option 3: Clear Temporary Files

1. Stop MySQL sa XAMPP

2. Delete temporary files:
```
del "C:\xampp\mysql\data\*.pid"
del "C:\xampp\mysql\data\*.lock"
```

3. Start MySQL sa XAMPP

### Option 4: Check Port 3306

1. Check kung may naga-gamit sang port:
```
netstat -ano | findstr :3306
```

2. Kung may LISTENING, kill ang process:
```
taskkill /PID [process_id] /F
```

3. Try liwat mag-start sang MySQL

---

## Common Error Messages

### Error: "Port 3306 is already in use"

**Meaning:** May iban nga program naga-gamit sang port 3306

**Fix:**
```
netstat -ano | findstr :3306 | findstr LISTENING
taskkill /PID [process_id] /F
```

### Error: "Can't start server: Bind on TCP/IP port"

**Meaning:** Same sa taas - port conflict

**Fix:** Kill ang process nga naga-gamit sang port 3306

### Error: "InnoDB: Unable to lock ./ibdata1"

**Meaning:** May iban nga MySQL instance naga-run

**Fix:**
```
taskkill /F /IM mysqld.exe
timeout /t 5
```
Then start liwat sa XAMPP

### Error: "Table 'mysql.user' doesn't exist"

**Meaning:** Corrupt nga system tables

**Fix:** Kailangan mag-reinstall sang MySQL or restore backup

---

## Verification

Pag nag-start na ang MySQL, i-check kung naga-work:

### Test 1: Check sa XAMPP
- Ablihi ang XAMPP Control Panel
- Ang MySQL dapat naga-show nga "Running"
- Dapat makita ang port "3306"
- Dapat green ang status indicator

### Test 2: Check via Command Line
```
cd C:\xampp\mysql\bin
mysql -u root -e "SELECT 'MySQL is working!' as Status;"
```

Dapat mag-output sang:
```
+-------------------+
| Status            |
+-------------------+
| MySQL is working! |
+-------------------+
```

### Test 3: Check Database
```
cd C:\xampp\mysql\bin
mysql -u root -e "SHOW DATABASES;"
```

Dapat makita mo ang "review_center_exam".

### Test 4: Test Exam System
1. Ablihi ang browser
2. Adto sa http://localhost:5173
3. Try mag-login
4. Kung nag-work, TAPOS NA! ✅

---

## Last Resort: Reinstall MySQL

Kung wala gid mag-work ang tanan, kailangan mag-reinstall:

### Step 1: Backup Database
```
cd C:\xampp\mysql\bin
mysqldump -u root --all-databases > C:\backup_all_databases.sql
```

### Step 2: Uninstall XAMPP MySQL
1. Stop MySQL sa XAMPP
2. Delete C:\xampp\mysql folder
3. Download fresh XAMPP

### Step 3: Reinstall
1. Install XAMPP
2. Start MySQL
3. Restore database:
```
mysql -u root < C:\backup_all_databases.sql
```

---

## Prevention

Para dili na mag-crash liwat:

1. ✅ Ayaw gid gamiton ang `ENABLE-REMOTE-DATABASE-ACCESS.bat`
2. ✅ Gamiton lang ang XAMPP Control Panel para mag-start/stop
3. ✅ Ayaw mag-edit sang my.ini kung dili sigurado
4. ✅ Mag-backup anay before mag-change sang configuration

---

## Summary

1. Run `DIAGNOSE-MYSQL.bat` para makita ang problema
2. Run `FIX-MYSQL-COMPLETE.bat` para ma-fix
3. Start MySQL sa XAMPP Control Panel
4. Test kung naga-work ang exam system

Ang imo database files SAFE pa! Just need to fix ang MySQL service. 🎉

---

## Need Help?

Kung after sang fix, dili pa gid mag-start:

1. Run `DIAGNOSE-MYSQL.bat` liwat
2. I-screenshot ang output
3. I-check ang error log sa XAMPP
4. Tawag para mag-help

Pero most likely, ang `FIX-MYSQL-COMPLETE.bat` mag-fix na sini! 💪

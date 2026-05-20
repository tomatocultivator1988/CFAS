# Ayaw Auto-Logout - Hiligaynon Guide

## Problema

Naga-auto-logout ang mga users after 30 minutes, bisan naga-take pa sila sang exam or naga-gamit pa sang system.

## Solusyon

I-change ang `SESSION_TIMEOUT_MINUTES` halin 30 minutes pakadto sa 43200 minutes (30 days).

Ini means:
- Mag-stay logged in ang users hasta 30 days
- Mag-logout lang sila kung i-click nila ang "Logout" button
- Wala na auto-logout during exams!

---

## Quick Fix (Automatic)

Run lang ini nga script:
```
.\DISABLE-AUTO-LOGOUT.bat
```

Ini nga script:
1. I-update ang XAMPP .env file (30 → 43200 minutes)
2. I-update ang development .env file (120 → 43200 minutes)
3. I-clear ang Laravel cache
4. Mag-prompt sa imo nga i-restart ang Apache

---

## Manual Fix (Kung kinahanglan)

### Step 1: I-edit ang XAMPP .env file

Ablihi: `C:\xampp\htdocs\exam-backend\.env`

Pangitaa ini nga linya:
```
SESSION_TIMEOUT_MINUTES=30
```

I-change to:
```
SESSION_TIMEOUT_MINUTES=43200
```

### Step 2: I-edit ang Development .env file

Ablihi: `Exam-Main/backend/.env`

Pangitaa ini nga linya:
```
SESSION_TIMEOUT_MINUTES=120
```

I-change to:
```
SESSION_TIMEOUT_MINUTES=43200
```

### Step 3: I-clear ang Laravel cache

```
cd C:\xampp\htdocs\exam-backend
php artisan config:clear
php artisan cache:clear
```

### Step 4: I-restart ang Apache

1. Ablihi ang XAMPP Control Panel
2. I-Stop ang Apache
3. I-Start liwat ang Apache

---

## Ano ang Nag-change?

| Setting | Before | After |
|---------|--------|-------|
| XAMPP Session Timeout | 30 minutes | 43200 minutes (30 days) |
| Development Session Timeout | 120 minutes | 43200 minutes (30 days) |

---

## Ngaa 30 Days?

- Sobra na ka-laba nga dili ma-auto-logout ang users
- May expiration pa gihapon (para sa security)
- Kinahanglan i-click sang users ang "Logout" button para mag-logout
- Kung i-close ang browser, naka-preserve pa ang session (pwede mag-continue later)

---

## Testing

After ma-apply ang fix:

1. Mag-login bilang student
2. Mag-wait sang 30+ minutes nga wala nag-click sang bisan ano
3. Try mag-take sang exam or mag-navigate
4. Dapat naka-login ka pa gihapon! ✅

---

## Security Note

Safe ini kay:
- Kinahanglan pa gihapon mag-login sang username/password
- Ang sessions naka-store securely sa server
- Pwede pa gihapon mag-manual logout ang users
- 30 days reasonable para sa exam system
- Kadamo sang users mag-logout manually man

---

## Pag-revert (Kung kinahanglan)

Para mag-balik sa 30 minute timeout:

1. I-change ang `SESSION_TIMEOUT_MINUTES=43200` balik sa `SESSION_TIMEOUT_MINUTES=30`
2. Run `php artisan config:clear`
3. I-restart ang Apache

---

## Summary

✅ Wala na auto-logout after 30 minutes
✅ Mag-stay logged in ang users hasta i-click nila ang "Logout"
✅ Ang sessions mag-last hasta 30 days
✅ Safe kag secure
✅ Mas maayo nga user experience during exams

---

## Importante!

After ma-run ang script, KINAHANGLAN i-restart ang Apache!

1. Ablihi: `C:\xampp\xampp-control.exe`
2. I-click ang "Stop" sa Apache
3. I-click ang "Start" sa Apache

Tapos na! Wala na mag-auto-logout! 🎉

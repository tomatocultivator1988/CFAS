# Paano Ma-access ang Database Halin sa Iban nga PC

## Overview

Ini nga guide para ma-enable ang remote access sa imo MySQL database para ang iban nga PC sa same network pwede mag-connect.

---

## Quick Setup (3 Steps)

### Step 1: I-enable ang Remote Access
```
.\ENABLE-REMOTE-DATABASE-ACCESS.bat
```

Ini nga script:
- I-configure ang MySQL para mag-accept sang remote connections
- Mag-create sang remote user account
- I-update ang MySQL configuration

### Step 2: I-configure ang Firewall (Run as Administrator!)
```
Right-click: CONFIGURE-FIREWALL-FOR-MYSQL.bat
I-select: "Run as administrator"
```

Ini nga script:
- Mag-add sang firewall rule para sa MySQL port 3306
- Mag-allow sang incoming connections

### Step 3: I-test ang Connection
```
.\TEST-REMOTE-CONNECTION.bat
```

Ini para ma-verify nga naga-work ang remote connections.

---

## Connection Details

After setup, ang iban nga PC pwede mag-connect gamit:

```
Host: [Imo IP Address]
Port: 3306
Username: remote_user
Password: remote123
Database: review_center_exam
```

---

## Paano Makita ang Imo IP Address

### Method 1: Command Line
```
ipconfig
```

Pangitaa ang "IPv4 Address" sa imo active network adapter.

### Example:
```
IPv4 Address: 192.168.11.40
```

Amo na ang imo IP address!

---

## Pag-connect Halin sa Iban nga PC

### Gamit ang MySQL Command Line:
```bash
mysql -h 192.168.11.40 -u remote_user -premote123 review_center_exam
```

### Gamit ang PHP (Laravel):
```php
// Sa .env file
DB_HOST=192.168.11.40
DB_PORT=3306
DB_DATABASE=review_center_exam
DB_USERNAME=remote_user
DB_PASSWORD=remote123
```

### Gamit ang MySQL Workbench:
1. Ablihi ang MySQL Workbench
2. I-click ang "+" para mag-add sang new connection
3. I-enter ang connection details:
   - Connection Name: Remote Exam DB
   - Hostname: 192.168.11.40
   - Port: 3306
   - Username: remote_user
   - Password: remote123
4. I-click ang "Test Connection"
5. I-click ang "OK"

---

## Troubleshooting

### Dili Maka-connect

**Problema:** Dili maka-connect halin sa iban nga PC

**Solusyon:**

1. I-check kung naga-run ang MySQL:
   - Ablihi ang XAMPP Control Panel
   - Ang MySQL dapat "Running"

2. I-check ang firewall:
   - Run `CONFIGURE-FIREWALL-FOR-MYSQL.bat` as Administrator
   - Or manual nga i-add ang rule sa Windows Firewall

3. I-check ang IP address:
   - Run `ipconfig` para ma-verify ang imo IP
   - Sigurado nga tama ang IP nga ginagamit mo

4. I-check ang MySQL configuration:
   - Run liwat ang `ENABLE-REMOTE-DATABASE-ACCESS.bat`

---

### Access Denied

**Problema:** "Access denied for user 'remote_user'@'...'

**Solusyon:**

1. I-verify kung existing ang user:
```sql
SELECT User, Host FROM mysql.user WHERE User='remote_user';
```

2. I-recreate ang user:
```sql
DROP USER IF EXISTS 'remote_user'@'%';
CREATE USER 'remote_user'@'%' IDENTIFIED BY 'remote123';
GRANT ALL PRIVILEGES ON review_center_exam.* TO 'remote_user'@'%';
FLUSH PRIVILEGES;
```

---

### Firewall Naga-block

**Problema:** Ang firewall naga-block sang connections

**Solusyon:**

1. I-add ang firewall rule manually:
   - Ablihi ang Windows Defender Firewall
   - I-click ang "Advanced settings"
   - I-click ang "Inbound Rules"
   - I-click ang "New Rule..."
   - I-select ang "Port"
   - I-select ang "TCP" kag i-enter ang "3306"
   - I-select ang "Allow the connection"
   - I-check tanan profiles (Domain, Private, Public)
   - I-name sini nga "MySQL Server"
   - I-click ang "Finish"

---

## Security Tips

### I-change ang Default Password

Ang default password `remote123` weak. I-change sini:

```sql
ALTER USER 'remote_user'@'%' IDENTIFIED BY 'YourStrongPassword123!';
FLUSH PRIVILEGES;
```

### I-restrict ang Access by IP

Instead nga mag-allow sang tanan IPs (`%`), i-restrict sa specific IPs:

```sql
-- Allow lang ang specific IP
DROP USER IF EXISTS 'remote_user'@'%';
CREATE USER 'remote_user'@'192.168.11.50' IDENTIFIED BY 'remote123';
GRANT ALL PRIVILEGES ON review_center_exam.* TO 'remote_user'@'192.168.11.50';
FLUSH PRIVILEGES;
```

---

## Testing Halin sa Iban nga PC

### Test 1: Ping Test
```
ping 192.168.11.40
```

Dapat mag-reply successfully.

### Test 2: MySQL Connection
```
mysql -h 192.168.11.40 -u remote_user -premote123 -e "SELECT 1"
```

Dapat mag-return sang "1".

---

## Summary

1. Run `ENABLE-REMOTE-DATABASE-ACCESS.bat`
2. Run `CONFIGURE-FIREWALL-FOR-MYSQL.bat` as Administrator
3. Run `TEST-REMOTE-CONNECTION.bat` para ma-verify
4. Pangitaa ang imo IP gamit `ipconfig`
5. Mag-connect halin sa iban nga PC gamit:
   - Host: [Imo IP]
   - Port: 3306
   - Username: remote_user
   - Password: remote123
   - Database: review_center_exam

---

## Importante!

- Sigurado nga naga-run ang MySQL sa XAMPP
- Sigurado nga naka-configure ang firewall
- Sigurado nga tama ang IP address
- Sigurado nga same network ang duha ka PC

Tapos na! Pwede na mag-access ang iban nga PC sa imo database! 🎉

# Remote Database Access Guide

## Overview

This guide will help you enable remote access to your MySQL database so other PCs on the same network can connect to it.

---

## Quick Setup (3 Steps)

### Step 1: Enable Remote Access
```
.\ENABLE-REMOTE-DATABASE-ACCESS.bat
```

This will:
- Configure MySQL to accept remote connections
- Create a remote user account
- Update MySQL configuration

### Step 2: Configure Firewall (Run as Administrator!)
```
Right-click: CONFIGURE-FIREWALL-FOR-MYSQL.bat
Select: "Run as administrator"
```

This will:
- Add firewall rule for MySQL port 3306
- Allow incoming connections

### Step 3: Test Connection
```
.\TEST-REMOTE-CONNECTION.bat
```

This will verify that remote connections are working.

---

## Connection Details

After setup, other PCs can connect using:

```
Host: [Your IP Address]
Port: 3306
Username: remote_user
Password: remote123
Database: review_center_exam
```

---

## Finding Your IP Address

### Method 1: Command Line
```
ipconfig
```

Look for "IPv4 Address" under your active network adapter.

### Method 2: PowerShell
```powershell
(Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -like "192.168.*"}).IPAddress
```

### Example:
```
IPv4 Address: 192.168.11.40
```

---

## Connecting from Another PC

### Using MySQL Command Line:
```bash
mysql -h 192.168.11.40 -u remote_user -premote123 review_center_exam
```

### Using PHP (Laravel):
```php
// In .env file
DB_HOST=192.168.11.40
DB_PORT=3306
DB_DATABASE=review_center_exam
DB_USERNAME=remote_user
DB_PASSWORD=remote123
```

### Using MySQL Workbench:
1. Open MySQL Workbench
2. Click "+" to add new connection
3. Enter connection details:
   - Connection Name: Remote Exam DB
   - Hostname: 192.168.11.40
   - Port: 3306
   - Username: remote_user
   - Password: remote123
4. Click "Test Connection"
5. Click "OK"

---

## Troubleshooting

### Connection Refused

**Problem:** Can't connect from another PC

**Solutions:**
1. Check if MySQL is running:
   - Open XAMPP Control Panel
   - MySQL should show "Running"

2. Check firewall:
   - Run `CONFIGURE-FIREWALL-FOR-MYSQL.bat` as Administrator
   - Or manually add rule in Windows Firewall

3. Check IP address:
   - Run `ipconfig` to verify your IP
   - Make sure you're using the correct IP

4. Check MySQL configuration:
   - Run `ENABLE-REMOTE-DATABASE-ACCESS.bat` again

---

### Access Denied

**Problem:** "Access denied for user 'remote_user'@'...'

**Solutions:**
1. Verify user exists:
```sql
SELECT User, Host FROM mysql.user WHERE User='remote_user';
```

2. Recreate user:
```sql
DROP USER IF EXISTS 'remote_user'@'%';
CREATE USER 'remote_user'@'%' IDENTIFIED BY 'remote123';
GRANT ALL PRIVILEGES ON review_center_exam.* TO 'remote_user'@'%';
FLUSH PRIVILEGES;
```

---

### Firewall Blocking

**Problem:** Firewall is blocking connections

**Solutions:**

1. Add firewall rule manually:
   - Open Windows Defender Firewall
   - Click "Advanced settings"
   - Click "Inbound Rules"
   - Click "New Rule..."
   - Select "Port"
   - Select "TCP" and enter "3306"
   - Select "Allow the connection"
   - Check all profiles (Domain, Private, Public)
   - Name it "MySQL Server"
   - Click "Finish"

2. Or disable firewall temporarily (NOT RECOMMENDED):
   - Only for testing!
   - Turn off Windows Firewall
   - Test connection
   - Turn firewall back on

---

### Can't Find IP Address

**Problem:** Don't know your IP address

**Solutions:**

1. Run this command:
```
ipconfig | findstr IPv4
```

2. Or use PowerShell:
```powershell
Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -like "192.168.*"} | Select-Object IPAddress
```

3. Or check in XAMPP:
   - Open XAMPP Control Panel
   - Click "Netstat"
   - Look for your IP address

---

## Security Considerations

### Change Default Password

The default password `remote123` is weak. Change it:

```sql
ALTER USER 'remote_user'@'%' IDENTIFIED BY 'YourStrongPassword123!';
FLUSH PRIVILEGES;
```

### Restrict Access by IP

Instead of allowing all IPs (`%`), restrict to specific IPs:

```sql
-- Allow only specific IP
DROP USER IF EXISTS 'remote_user'@'%';
CREATE USER 'remote_user'@'192.168.11.50' IDENTIFIED BY 'remote123';
GRANT ALL PRIVILEGES ON review_center_exam.* TO 'remote_user'@'192.168.11.50';
FLUSH PRIVILEGES;
```

### Use Read-Only User

For clients that only need to read data:

```sql
CREATE USER 'readonly_user'@'%' IDENTIFIED BY 'readonly123';
GRANT SELECT ON review_center_exam.* TO 'readonly_user'@'%';
FLUSH PRIVILEGES;
```

---

## Advanced Configuration

### Change MySQL Port

If port 3306 is already in use:

1. Edit `C:\xampp\mysql\bin\my.ini`
2. Find `port=3306`
3. Change to `port=3307` (or any available port)
4. Restart MySQL
5. Update firewall rule for new port

### Enable SSL/TLS

For encrypted connections:

1. Generate SSL certificates
2. Configure MySQL to use SSL
3. Update client connections to use SSL

---

## Testing from Another PC

### Test 1: Ping Test
```
ping 192.168.11.40
```

Should reply successfully.

### Test 2: Port Test
```
telnet 192.168.11.40 3306
```

Should connect (may show garbled text, that's OK).

### Test 3: MySQL Connection
```
mysql -h 192.168.11.40 -u remote_user -premote123 -e "SELECT 1"
```

Should return "1".

---

## Reverting Changes

### Disable Remote Access

1. Edit `C:\xampp\mysql\bin\my.ini`
2. Change `bind-address = 0.0.0.0` to `bind-address = 127.0.0.1`
3. Restart MySQL

### Remove Remote User

```sql
DROP USER IF EXISTS 'remote_user'@'%';
FLUSH PRIVILEGES;
```

### Remove Firewall Rule

```
netsh advfirewall firewall delete rule name="MySQL Server"
```

---

## Common Use Cases

### Use Case 1: Multiple Admin PCs

Allow multiple admins to manage the database:

```sql
CREATE USER 'admin1'@'192.168.11.50' IDENTIFIED BY 'admin1pass';
CREATE USER 'admin2'@'192.168.11.51' IDENTIFIED BY 'admin2pass';
GRANT ALL PRIVILEGES ON review_center_exam.* TO 'admin1'@'192.168.11.50';
GRANT ALL PRIVILEGES ON review_center_exam.* TO 'admin2'@'192.168.11.51';
FLUSH PRIVILEGES;
```

### Use Case 2: Backup Server

Allow backup server to read database:

```sql
CREATE USER 'backup'@'192.168.11.100' IDENTIFIED BY 'backuppass';
GRANT SELECT, LOCK TABLES ON review_center_exam.* TO 'backup'@'192.168.11.100';
FLUSH PRIVILEGES;
```

### Use Case 3: Reporting Server

Allow reporting server to read data:

```sql
CREATE USER 'reports'@'192.168.11.200' IDENTIFIED BY 'reportspass';
GRANT SELECT ON review_center_exam.* TO 'reports'@'192.168.11.200';
FLUSH PRIVILEGES;
```

---

## Summary

1. Run `ENABLE-REMOTE-DATABASE-ACCESS.bat`
2. Run `CONFIGURE-FIREWALL-FOR-MYSQL.bat` as Administrator
3. Run `TEST-REMOTE-CONNECTION.bat` to verify
4. Find your IP with `ipconfig`
5. Connect from other PCs using:
   - Host: [Your IP]
   - Port: 3306
   - Username: remote_user
   - Password: remote123
   - Database: review_center_exam

---

## Support

If you encounter issues:
1. Check MySQL is running in XAMPP
2. Check firewall is configured
3. Check IP address is correct
4. Check network connectivity (ping test)
5. Check MySQL logs: `C:\xampp\mysql\data\*.err`

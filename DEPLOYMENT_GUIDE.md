# Deployment Guide

Complete guide for deploying the Review Center Examination System to production.

## Prerequisites

- PHP 8.1 or higher
- MySQL 8.0 or higher
- Node.js 18+ and npm
- Composer
- Web server (Apache/Nginx)
- SSL certificate

## Pre-Deployment Checklist

### 1. Code Preparation
- [ ] All tests passing
- [ ] Code reviewed and approved
- [ ] No debug code or console.log statements
- [ ] Environment variables configured
- [ ] Database migrations ready

### 2. Security
- [ ] SSL/TLS certificate installed
- [ ] Firewall configured
- [ ] Strong passwords set
- [ ] API rate limiting enabled
- [ ] CORS properly configured

### 3. Performance
- [ ] Production build created
- [ ] Assets optimized
- [ ] Caching configured
- [ ] Database indexed

## Backend Deployment

### Step 1: Server Setup

#### Install Dependencies
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install PHP and extensions
sudo apt install php8.1 php8.1-fpm php8.1-mysql php8.1-mbstring \
  php8.1-xml php8.1-curl php8.1-zip php8.1-bcmath -y

# Install MySQL
sudo apt install mysql-server -y

# Install Composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
```

### Step 2: Deploy Code

```bash
# Clone repository
cd /var/www
git clone <repository-url> exam-system
cd exam-system/backend

# Install dependencies
composer install --optimize-autoloader --no-dev

# Set permissions
sudo chown -R www-data:www-data storage bootstrap/cache
sudo chmod -R 775 storage bootstrap/cache
```

### Step 3: Configure Environment

```bash
# Copy environment file
cp .env.example .env

# Generate application key
php artisan key:generate

# Edit .env file
nano .env
```

**Production .env settings:**
```env
APP_NAME="Review Center Exam System"
APP_ENV=production
APP_DEBUG=false
APP_URL=https://your-domain.com

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=review_center_exam
DB_USERNAME=exam_user
DB_PASSWORD=strong_password_here

CACHE_DRIVER=file
SESSION_DRIVER=file
QUEUE_CONNECTION=database

# Security
SESSION_LIFETIME=30
SESSION_SECURE_COOKIE=true
SESSION_SAME_SITE=strict
```

### Step 4: Database Setup

```bash
# Create database
mysql -u root -p
```

```sql
CREATE DATABASE review_center_exam CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'exam_user'@'localhost' IDENTIFIED BY 'strong_password_here';
GRANT ALL PRIVILEGES ON review_center_exam.* TO 'exam_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

```bash
# Run migrations
php artisan migrate --force

# Seed initial data
php artisan db:seed --class=UserSeeder
```

### Step 5: Optimize Laravel

```bash
# Cache configuration
php artisan config:cache

# Cache routes
php artisan route:cache

# Cache views
php artisan view:cache

# Optimize autoloader
composer dump-autoload --optimize
```

### Step 6: Set Up Scheduler

```bash
# Edit crontab
crontab -e

# Add this line:
* * * * * cd /var/www/exam-system/backend && php artisan schedule:run >> /dev/null 2>&1
```

### Step 7: Configure Web Server

#### Nginx Configuration

Create `/etc/nginx/sites-available/exam-system`:

```nginx
server {
    listen 80;
    server_name your-domain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name your-domain.com;
    root /var/www/exam-system/backend/public;

    ssl_certificate /path/to/certificate.crt;
    ssl_certificate_key /path/to/private.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";
    add_header X-XSS-Protection "1; mode=block";

    index index.php;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }

    # Enable gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/json;
}
```

```bash
# Enable site
sudo ln -s /etc/nginx/sites-available/exam-system /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

## Frontend Deployment

### Step 1: Build for Production

```bash
cd /var/www/exam-system/frontend

# Install dependencies
npm ci

# Update API URL in .env
echo "VITE_API_URL=https://your-domain.com/api" > .env

# Build for production
npm run build
```

### Step 2: Deploy Build

#### Option A: Serve with Nginx

```nginx
server {
    listen 443 ssl http2;
    server_name app.your-domain.com;
    root /var/www/exam-system/frontend/dist;

    ssl_certificate /path/to/certificate.crt;
    ssl_certificate_key /path/to/private.key;

    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

#### Option B: Use CDN
Upload `dist` folder contents to your CDN.

## Post-Deployment

### 1. Verify Installation

```bash
# Check backend
curl https://your-domain.com/api/health

# Check frontend
curl https://app.your-domain.com
```

### 2. Test Critical Paths

- [ ] Login (admin and reviewee)
- [ ] Create exam
- [ ] Take exam
- [ ] Submit exam
- [ ] View results
- [ ] Analytics

### 3. Monitor Logs

```bash
# Laravel logs
tail -f /var/www/exam-system/backend/storage/logs/laravel.log

# Nginx logs
tail -f /var/log/nginx/error.log
tail -f /var/log/nginx/access.log
```

### 4. Set Up Monitoring

#### Application Monitoring
- Install Laravel Telescope (optional)
- Set up error tracking (Sentry, Bugsnag)
- Configure uptime monitoring

#### Server Monitoring
- CPU usage
- Memory usage
- Disk space
- Network traffic

### 5. Backup Strategy

```bash
# Create backup script
nano /usr/local/bin/backup-exam-system.sh
```

```bash
#!/bin/bash
BACKUP_DIR="/backups/exam-system"
DATE=$(date +%Y-%m-%d_%H-%M-%S)

# Database backup
mysqldump -u exam_user -p'password' review_center_exam > "$BACKUP_DIR/db_$DATE.sql"

# Files backup
tar -czf "$BACKUP_DIR/files_$DATE.tar.gz" /var/www/exam-system

# Clean old backups (keep 30 days)
find $BACKUP_DIR -type f -mtime +30 -delete

echo "Backup completed: $DATE"
```

```bash
chmod +x /usr/local/bin/backup-exam-system.sh

# Schedule daily backups
crontab -e
# Add: 0 2 * * * /usr/local/bin/backup-exam-system.sh
```

## Maintenance

### Regular Tasks

#### Daily
- Check error logs
- Monitor disk space
- Verify backups

#### Weekly
- Review performance metrics
- Check security updates
- Analyze user activity

#### Monthly
- Update dependencies
- Review and optimize database
- Test disaster recovery

### Updates

```bash
# Pull latest code
cd /var/www/exam-system
git pull origin main

# Backend updates
cd backend
composer install --optimize-autoloader --no-dev
php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Frontend updates
cd ../frontend
npm ci
npm run build

# Restart services
sudo systemctl restart php8.1-fpm
sudo systemctl restart nginx
```

## Troubleshooting

### Common Issues

#### 500 Internal Server Error
- Check Laravel logs
- Verify file permissions
- Check .env configuration

#### Database Connection Failed
- Verify credentials in .env
- Check MySQL service status
- Test connection manually

#### Frontend Not Loading
- Check build output
- Verify nginx configuration
- Check browser console

#### Slow Performance
- Enable OPcache
- Configure caching
- Optimize database queries

## Security Hardening

### 1. Server Security

```bash
# Install fail2ban
sudo apt install fail2ban -y

# Configure firewall
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443
sudo ufw enable
```

### 2. Application Security

- Keep dependencies updated
- Use strong passwords
- Enable rate limiting
- Regular security audits
- Monitor for vulnerabilities

### 3. Database Security

- Use strong passwords
- Limit user privileges
- Regular backups
- Enable binary logging
- Monitor for suspicious activity

## Rollback Procedure

If deployment fails:

```bash
# Revert code
git reset --hard <previous-commit>

# Rollback database
mysql -u exam_user -p review_center_exam < backup.sql

# Clear caches
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

# Restart services
sudo systemctl restart php8.1-fpm nginx
```

## Support

For issues or questions:
- Check logs first
- Review documentation
- Contact system administrator

## Additional Resources

- [Laravel Deployment](https://laravel.com/docs/deployment)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [MySQL Documentation](https://dev.mysql.com/doc/)
- [Let's Encrypt SSL](https://letsencrypt.org/)

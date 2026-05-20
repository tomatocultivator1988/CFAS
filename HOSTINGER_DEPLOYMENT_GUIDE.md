# Hostinger Deployment Guide

Complete guide for deploying the CFAS Exam System to Hostinger shared hosting.

## Overview

This guide covers all necessary changes to deploy your Laravel + Vue.js + Python ML application to Hostinger.

## Prerequisites

- Hostinger Business or Premium plan (for SSH access and Python support)
- Domain name configured in Hostinger
- SSH access enabled
- MySQL database created in Hostinger panel

---

## Part 1: Backend (Laravel) Changes

### 1.1 Environment Configuration

Create `backend/.env.production`:

```env
APP_NAME="CFAS Exam System"
APP_ENV=production
APP_KEY=base64:YOUR_GENERATED_KEY_HERE
APP_DEBUG=false
APP_URL=https://yourdomain.com

LOG_CHANNEL=stack
LOG_LEVEL=error

# Hostinger MySQL Database
DB_CONNECTION=mysql
DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=u123456789_exam_db
DB_USERNAME=u123456789_exam_user
DB_PASSWORD=YOUR_SECURE_PASSWORD

BROADCAST_DRIVER=log
CACHE_DRIVER=file
FILESYSTEM_DISK=local
QUEUE_CONNECTION=database
SESSION_DRIVER=file
SESSION_LIFETIME=120

# Security Settings
SESSION_TIMEOUT_MINUTES=30
VIOLATION_THRESHOLD=3
BCRYPT_ROUNDS=12
FORCE_HTTPS=true

# Leave empty to allow all IPs (or specify your allowed IPs)
LAB_IP_RANGES=

# ML Service (will run on same server)
ML_SERVICE_URL=https://yourdomain.com/ml-api
```

### 1.2 Update .htaccess for Hostinger

Replace `backend/public/.htaccess`:

```apache
<IfModule mod_rewrite.c>
    <IfModule mod_negotiation.c>
        Options -MultiViews -Indexes
    </IfModule>

    RewriteEngine On

    # Force HTTPS
    RewriteCond %{HTTPS} off
    RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]

    # Handle Authorization Header
    RewriteCond %{HTTP:Authorization} .
    RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]

    # Redirect Trailing Slashes If Not A Folder
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_URI} (.+)/$
    RewriteRule ^ %1 [L,R=301]

    # Send Requests To Front Controller
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteRule ^ index.php [L]
</IfModule>

# Disable directory browsing
Options -Indexes

# Protect sensitive files
<FilesMatch "^\.">
    Order allow,deny
    Deny from all
</FilesMatch>

# Protect .env file
<Files .env>
    Order allow,deny
    Deny from all
</Files>
```

### 1.3 Root .htaccess (for public_html)

Create `backend-root.htaccess` (to be placed in public_html root):

```apache
<IfModule mod_rewrite.c>
    RewriteEngine On
    
    # Force HTTPS
    RewriteCond %{HTTPS} off
    RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
    
    # Redirect all requests to public folder
    RewriteCond %{REQUEST_URI} !^/public/
    RewriteRule ^(.*)$ /public/$1 [L]
</IfModule>
```

### 1.4 Update composer.json

Ensure production dependencies are set:

```json
{
    "require": {
        "php": "^8.1",
        "laravel/framework": "^10.0",
        "laravel/sanctum": "^3.2"
    },
    "config": {
        "optimize-autoloader": true,
        "preferred-install": "dist",
        "sort-packages": true
    },
    "scripts": {
        "post-install-cmd": [
            "@php artisan clear-compiled",
            "@php artisan optimize"
        ]
    }
}
```

---

## Part 2: Frontend (Vue.js) Changes

### 2.1 Update Environment Configuration

Create `frontend/.env.production`:

```env
VITE_API_URL=https://yourdomain.com/api
```

### 2.2 Update vite.config.js

```javascript
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { fileURLToPath, URL } from 'node:url'

export default defineConfig({
  base: '/',  // Changed from '/exam-frontend/'
  plugins: [vue()],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    }
  },
  build: {
    outDir: 'dist',
    sourcemap: false,
    minify: 'terser',
    rollupOptions: {
      output: {
        manualChunks: {
          'vue-vendor': ['vue', 'vue-router', 'pinia'],
          'chart-vendor': ['chart.js', 'vue-chartjs']
        }
      }
    },
    chunkSizeWarningLimit: 1000
  }
})
```

### 2.3 Update API Service

Update `frontend/src/services/api.js`:

```javascript
import axios from 'axios'

const API_URL = import.meta.env.VITE_API_URL || 'https://yourdomain.com/api'

const api = axios.create({
  baseURL: API_URL,
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  }
})

// Add request interceptor for auth token
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('auth_token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => Promise.reject(error)
)

// Add response interceptor for error handling
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('auth_token')
      window.location.href = '/login'
    }
    return Promise.reject(error)
  }
)

export default api
```

### 2.4 Create .htaccess for Frontend

Create `frontend/dist/.htaccess` (will be in dist after build):

```apache
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteBase /
    
    # Force HTTPS
    RewriteCond %{HTTPS} off
    RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
    
    # Handle Vue Router (SPA)
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule ^ index.html [L]
</IfModule>

# Caching
<IfModule mod_expires.c>
    ExpiresActive On
    ExpiresByType image/jpg "access plus 1 year"
    ExpiresByType image/jpeg "access plus 1 year"
    ExpiresByType image/gif "access plus 1 year"
    ExpiresByType image/png "access plus 1 year"
    ExpiresByType text/css "access plus 1 month"
    ExpiresByType application/javascript "access plus 1 month"
</IfModule>

# Compression
<IfModule mod_deflate.c>
    AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css application/javascript
</IfModule>
```

---

## Part 3: ML Service Changes

### 3.1 Update predict_api.py for Production

Create `ml_model/predict_api_production.py`:

```python
"""
Production ML API for Hostinger deployment
Uses CGI for execution
"""

import sys
import json
import os

# Add parent directory to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from predict_api import FastPredictor

def main():
    """CGI-compatible main function"""
    # Print CGI headers
    print("Content-Type: application/json")
    print()
    
    # Get query parameters
    query_string = os.environ.get('QUERY_STRING', '')
    path_info = os.environ.get('PATH_INFO', '')
    
    predictor = FastPredictor()
    
    # Parse command from path or query
    if 'student_id=' in query_string:
        student_id = query_string.split('student_id=')[1].split('&')[0]
        result = predictor.predict(int(student_id))
    elif 'at-risk' in path_info or 'at-risk' in query_string:
        result = predictor.get_at_risk_students()
    elif 'metrics' in path_info or 'metrics' in query_string:
        result = predictor.get_metrics()
    else:
        result = {
            'error': 'Invalid request',
            'usage': 'Use ?student_id=X or /at-risk or /metrics'
        }
    
    print(json.dumps(result, indent=2))

if __name__ == "__main__":
    main()
```

### 3.2 Create ML API .htaccess

Create `ml_model/.htaccess`:

```apache
<IfModule mod_rewrite.c>
    RewriteEngine On
    
    # Force HTTPS
    RewriteCond %{HTTPS} off
    RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
    
    # Route all requests to Python CGI script
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule ^(.*)$ predict_api_production.py [L]
</IfModule>

# Enable CGI execution for Python
AddHandler cgi-script .py
Options +ExecCGI

# Security
<Files "*.pkl">
    Order allow,deny
    Deny from all
</Files>

<Files "*.json">
    Order allow,deny
    Deny from all
</Files>
```

### 3.3 Update Database Connection

Update `ml_model/predict_api.py` database connection:

```python
def connect_database(self):
    """Connect to MySQL database - Hostinger compatible"""
    try:
        # Try to load from .env first
        load_dotenv('../backend/.env')
        
        connection = mysql.connector.connect(
            host=os.getenv('DB_HOST', 'localhost'),
            database=os.getenv('DB_DATABASE'),
            user=os.getenv('DB_USERNAME'),
            password=os.getenv('DB_PASSWORD'),
            port=int(os.getenv('DB_PORT', 3306)),
            charset='utf8mb4',
            use_unicode=True
        )
        return connection
    except Error as e:
        print(json.dumps({'error': f'Database connection failed: {str(e)}'}))
        return None
```

---

## Part 4: Deployment Structure

### 4.1 Hostinger Directory Structure

```
public_html/                          # Your domain root
├── .htaccess                         # Root redirect to Laravel public
├── api/                              # Laravel backend
│   ├── app/
│   ├── bootstrap/
│   ├── config/
│   ├── database/
│   ├── public/                       # Laravel public folder
│   │   ├── index.php
│   │   └── .htaccess
│   ├── routes/
│   ├── storage/                      # Needs 755 permissions
│   ├── vendor/
│   ├── .env                          # Production environment
│   └── artisan
├── ml-api/                           # Python ML service
│   ├── models/
│   ├── predict_api.py
│   ├── predict_api_production.py
│   ├── requirements.txt
│   └── .htaccess
├── index.html                        # Vue.js built files
├── assets/                           # Vue.js assets
├── favicon.ico
└── .htaccess                         # Vue Router handling
```

### 4.2 Symbolic Link Setup (via SSH)

```bash
# Connect via SSH
ssh u123456789@yourdomain.com

# Navigate to public_html
cd public_html

# Create symbolic link for Laravel public folder
ln -s api/public backend

# Set permissions
chmod -R 755 api/storage
chmod -R 755 api/bootstrap/cache
```

---

## Part 5: Deployment Steps

### 5.1 Prepare Files Locally

```bash
# Backend - Install production dependencies
cd backend
composer install --no-dev --optimize-autoloader

# Frontend - Build for production
cd ../frontend
npm run build

# Copy .htaccess to dist
copy .htaccess dist/.htaccess
```

### 5.2 Upload to Hostinger

Using FileZilla or Hostinger File Manager:

1. **Upload Backend:**
   - Upload entire `backend/` folder to `public_html/api/`
   - Rename `.env.production` to `.env`
   - Set permissions: `storage/` and `bootstrap/cache/` to 755

2. **Upload Frontend:**
   - Upload contents of `frontend/dist/` to `public_html/`
   - Ensure `.htaccess` is included

3. **Upload ML Service:**
   - Upload `ml_model/` folder to `public_html/ml-api/`
   - Make Python files executable: `chmod +x *.py`

### 5.3 Database Setup

Via Hostinger MySQL panel or SSH:

```bash
# Import database structure
mysql -u u123456789_exam_user -p u123456789_exam_db < database_backup.sql

# Or run migrations via SSH
cd public_html/api
php artisan migrate --force
php artisan db:seed --force
```

### 5.4 Laravel Configuration

```bash
# SSH into server
ssh u123456789@yourdomain.com

cd public_html/api

# Generate application key
php artisan key:generate

# Clear and cache config
php artisan config:clear
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Create storage link
php artisan storage:link
```

### 5.5 Python Dependencies

```bash
# Install Python packages (if pip available)
cd public_html/ml-api
pip3 install --user -r requirements.txt

# Or use virtual environment
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

---

## Part 6: Configuration Checklist

### 6.1 Backend Checklist

- [ ] `.env` file configured with Hostinger database credentials
- [ ] `APP_KEY` generated
- [ ] `APP_DEBUG=false`
- [ ] `APP_URL` set to your domain
- [ ] `FORCE_HTTPS=true`
- [ ] Storage permissions set (755)
- [ ] Config cached
- [ ] Routes cached

### 6.2 Frontend Checklist

- [ ] `VITE_API_URL` points to production API
- [ ] Built with `npm run build`
- [ ] `.htaccess` in place for SPA routing
- [ ] Assets loading correctly

### 6.3 ML Service Checklist

- [ ] Python 3.9+ available
- [ ] Dependencies installed
- [ ] `.htaccess` configured for CGI
- [ ] Model files uploaded
- [ ] Database connection working

### 6.4 Security Checklist

- [ ] HTTPS enforced
- [ ] `.env` file protected
- [ ] Directory browsing disabled
- [ ] Sensitive files blocked
- [ ] CORS configured properly
- [ ] Rate limiting enabled

---

## Part 7: Testing Deployment

### 7.1 Test Backend API

```bash
# Health check
curl https://yourdomain.com/api/health

# Expected response:
{
  "status": "ok",
  "message": "CFAS Exam System API is running",
  "timestamp": "2026-02-12T...",
  "version": "1.0.0"
}
```

### 7.2 Test Frontend

Visit: `https://yourdomain.com`
- Should load login page
- No console errors
- Assets loading correctly

### 7.3 Test ML Service

```bash
curl "https://yourdomain.com/ml-api/predict_api_production.py?student_id=1"
```

---

## Part 8: Troubleshooting

### Common Issues

**500 Internal Server Error:**
- Check `.htaccess` syntax
- Verify file permissions (755 for directories, 644 for files)
- Check Laravel logs: `storage/logs/laravel.log`

**Database Connection Failed:**
- Verify credentials in `.env`
- Check if database exists
- Ensure user has proper privileges

**ML Service Not Working:**
- Verify Python version: `python3 --version`
- Check if CGI is enabled
- Review error logs in cPanel

**Frontend 404 Errors:**
- Ensure `.htaccess` is in place
- Check Vue Router base path
- Verify API URL in environment

---

## Part 9: Performance Optimization

### 9.1 Enable OPcache (php.ini)

```ini
opcache.enable=1
opcache.memory_consumption=128
opcache.max_accelerated_files=10000
opcache.revalidate_freq=60
```

### 9.2 Enable Gzip Compression

Already included in `.htaccess` files

### 9.3 Database Optimization

```sql
-- Add indexes for frequently queried columns
ALTER TABLE exam_attempts ADD INDEX idx_reviewee_status (reviewee_id, status);
ALTER TABLE attempt_answers ADD INDEX idx_attempt (attempt_id);
```

---

## Part 10: Maintenance

### Backup Strategy

```bash
# Database backup
mysqldump -u username -p database_name > backup_$(date +%Y%m%d).sql

# File backup
tar -czf backup_$(date +%Y%m%d).tar.gz public_html/
```

### Update Procedure

1. Backup database and files
2. Upload new files
3. Run migrations: `php artisan migrate --force`
4. Clear cache: `php artisan cache:clear`
5. Test functionality

---

## Support

For Hostinger-specific issues:
- Hostinger Knowledge Base: https://support.hostinger.com
- Contact Hostinger Support via live chat

For application issues:
- Check Laravel logs: `storage/logs/laravel.log`
- Check browser console for frontend errors
- Review ML service error output

---

## Summary of Key Changes

1. **Environment files** updated for production
2. **.htaccess files** configured for Hostinger
3. **API URLs** changed from localhost to domain
4. **ML service** adapted for CGI execution
5. **Database connection** configured for Hostinger MySQL
6. **File permissions** set correctly
7. **HTTPS** enforced throughout
8. **Caching and optimization** enabled

Deploy with confidence! 🚀

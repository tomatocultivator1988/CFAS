# Hostinger Deployment Checklist

Quick reference checklist for deploying to Hostinger.

## Pre-Deployment

### Local Preparation
- [ ] Run `deploy-to-hostinger.bat` (Windows) or `deploy-to-hostinger.sh` (Linux/Mac)
- [ ] Update `backend/.env` with Hostinger database credentials
- [ ] Update `frontend/.env.production` with your domain name
- [ ] Test build locally to ensure no errors

### Hostinger Setup
- [ ] Create MySQL database in Hostinger panel
- [ ] Note database name, username, and password
- [ ] Enable SSH access (if not already enabled)
- [ ] Verify PHP version is 8.1 or higher
- [ ] Verify Python 3.9+ is available

## File Upload

### Backend Files
- [ ] Upload `backend/` folder to `public_html/api/`
- [ ] Rename `backend/.env.hostinger` to `backend/.env` (or upload configured .env)
- [ ] Verify `.htaccess` files are uploaded (enable "Show hidden files")

### Frontend Files
- [ ] Upload contents of `frontend/dist/` to `public_html/`
- [ ] Upload `frontend/dist.htaccess` as `public_html/.htaccess`
- [ ] Verify `index.html` is in `public_html/`

### ML Service Files
- [ ] Upload `ml_model/` folder to `public_html/ml-api/`
- [ ] Rename `.htaccess.hostinger` to `.htaccess`
- [ ] Verify model files (.pkl) are uploaded

### Root Configuration
- [ ] Upload `hostinger-root.htaccess` as `public_html/.htaccess`

## SSH Configuration

### Connect to Server
```bash
ssh u123456789@yourdomain.com
```

### Laravel Setup
```bash
cd public_html/api

# Set permissions
chmod -R 755 storage
chmod -R 755 bootstrap/cache

# Generate key (if not done locally)
php artisan key:generate --force

# Run migrations
php artisan migrate --force

# Seed database (optional)
php artisan db:seed --force

# Cache configuration
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Create storage link
php artisan storage:link
```

### Python ML Setup
```bash
cd public_html/ml-api

# Install dependencies
pip3 install --user -r requirements.txt

# Make scripts executable
chmod +x *.py

# Test ML service
python3 predict_api.py metrics
```

## Testing

### Backend API Test
- [ ] Visit: `https://yourdomain.com/api/health`
- [ ] Should return JSON with status "ok"

### Frontend Test
- [ ] Visit: `https://yourdomain.com`
- [ ] Login page loads correctly
- [ ] No console errors
- [ ] Assets load properly

### ML Service Test
- [ ] Test endpoint: `https://yourdomain.com/ml-api/predict_api_production.py?student_id=1`
- [ ] Should return prediction JSON

### Full Flow Test
- [ ] Login as admin
- [ ] Create a test exam
- [ ] Login as reviewee
- [ ] Take exam
- [ ] View results
- [ ] Check ML predictions

## Security Verification

- [ ] HTTPS is enforced (http redirects to https)
- [ ] `.env` file is not accessible via browser
- [ ] Directory browsing is disabled
- [ ] Database credentials are secure
- [ ] `APP_DEBUG=false` in production

## Performance Optimization

- [ ] OPcache enabled (check with hosting provider)
- [ ] Gzip compression working (check browser dev tools)
- [ ] Static assets cached properly
- [ ] Database queries optimized

## Post-Deployment

### Create Admin User
```bash
cd public_html/api
php artisan tinker

# In tinker:
$user = new App\Models\User();
$user->username = 'admin';
$user->password = bcrypt('your-secure-password');
$user->role = 'admin';
$user->first_name = 'Admin';
$user->last_name = 'User';
$user->save();
```

### Train ML Model
```bash
cd public_html/ml-api
python3 train_model.py
```

### Setup Cron Jobs (Optional)
Add to crontab for automated tasks:
```bash
# Laravel scheduler (if using queues/scheduled tasks)
* * * * * cd /home/u123456789/public_html/api && php artisan schedule:run >> /dev/null 2>&1

# ML model retraining (weekly)
0 2 * * 0 cd /home/u123456789/public_html/ml-api && python3 train_model.py
```

## Troubleshooting

### 500 Internal Server Error
1. Check `.htaccess` syntax
2. Verify file permissions (755 for directories, 644 for files)
3. Check Laravel logs: `storage/logs/laravel.log`
4. Enable error display temporarily: `APP_DEBUG=true`

### Database Connection Failed
1. Verify credentials in `.env`
2. Check database exists in Hostinger panel
3. Ensure user has proper privileges
4. Test connection: `php artisan tinker` then `DB::connection()->getPdo();`

### Frontend 404 Errors
1. Verify `.htaccess` in public_html root
2. Check Vue Router configuration
3. Verify API URL in `.env.production`

### ML Service Not Working
1. Check Python version: `python3 --version`
2. Verify CGI is enabled
3. Check file permissions: `chmod +x *.py`
4. Review error logs in cPanel

### Assets Not Loading
1. Check browser console for errors
2. Verify base path in `vite.config.js`
3. Clear browser cache
4. Check file permissions

## Maintenance

### Regular Backups
```bash
# Database backup
mysqldump -u username -p database_name > backup_$(date +%Y%m%d).sql

# File backup
tar -czf backup_$(date +%Y%m%d).tar.gz public_html/
```

### Update Application
1. Backup database and files
2. Upload new files
3. Run migrations: `php artisan migrate --force`
4. Clear cache: `php artisan cache:clear`
5. Test functionality

### Monitor Logs
- Laravel: `storage/logs/laravel.log`
- Hostinger: Check error logs in cPanel
- Browser: Check console for frontend errors

## Support Resources

- **Hostinger Support**: https://support.hostinger.com
- **Laravel Docs**: https://laravel.com/docs
- **Vue.js Docs**: https://vuejs.org/guide/
- **Deployment Guide**: See `HOSTINGER_DEPLOYMENT_GUIDE.md`

---

## Quick Commands Reference

```bash
# SSH Login
ssh u123456789@yourdomain.com

# Navigate to Laravel
cd public_html/api

# Clear all caches
php artisan cache:clear && php artisan config:clear && php artisan route:clear && php artisan view:clear

# Rebuild caches
php artisan config:cache && php artisan route:cache && php artisan view:cache

# Check Laravel version
php artisan --version

# Run migrations
php artisan migrate --force

# Check database connection
php artisan tinker
>>> DB::connection()->getPdo();

# View logs
tail -f storage/logs/laravel.log

# Check disk space
df -h

# Check permissions
ls -la storage/
```

---

**Deployment Date**: _____________

**Deployed By**: _____________

**Domain**: _____________

**Notes**: _____________________________________________

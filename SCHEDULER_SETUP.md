# Laravel Scheduler Setup

The Review Center Examination System uses Laravel's task scheduler to automate maintenance tasks.

## Scheduled Tasks

The following tasks are configured to run automatically:

### Daily Tasks

1. **Database Backup** (2:00 AM)
   - Creates a full database backup
   - Stores backups in `storage/app/backups/`
   - Automatically cleans up backups older than 7 days
   - Logs success/failure

2. **Session Cleanup** (3:00 AM)
   - Removes expired auth tokens
   - Cleans up old session files
   - Frees up storage space

3. **ML Model Retraining Check** (4:00 AM)
   - Checks if model retraining is needed
   - Placeholder for ML service integration

4. **Daily Analytics Summary** (5:00 AM)
   - Generates daily analytics reports
   - Placeholder for future implementation

### Hourly Tasks

1. **Expired Token Cleanup**
   - Removes expired authentication tokens
   - Runs every hour

## Setup Instructions

### Windows (Development)

1. **Using Task Scheduler:**
   ```
   - Open Task Scheduler
   - Create a new task
   - Set trigger to run every minute
   - Set action to run: php C:\path\to\Exam-Main\backend\artisan schedule:run
   ```

2. **Using a batch file:**
   Create `run-scheduler.bat`:
   ```batch
   @echo off
   cd C:\path\to\Exam-Main\backend
   php artisan schedule:run
   ```
   
   Then schedule this batch file to run every minute.

### Linux/Mac (Production)

Add this cron entry:
```bash
* * * * * cd /path/to/Exam-Main/backend && php artisan schedule:run >> /dev/null 2>&1
```

To edit crontab:
```bash
crontab -e
```

## Manual Commands

You can run scheduled tasks manually:

### Database Backup
```bash
php artisan backup:run
```

With verification:
```bash
php artisan backup:run --verify
```

### Session Cleanup
```bash
php artisan session:gc
```

### View Scheduled Tasks
```bash
php artisan schedule:list
```

### Test Scheduler
```bash
php artisan schedule:work
```
This runs the scheduler every minute for testing.

## Backup Location

Backups are stored in:
```
storage/app/backups/backup_YYYY-MM-DD_HH-MM-SS.sql
```

## Logs

All scheduled task activities are logged to:
```
storage/logs/laravel.log
```

## Important Notes

1. **Scheduler Must Be Running**: The Laravel scheduler only works if the cron job (or Task Scheduler on Windows) is set up to run `php artisan schedule:run` every minute.

2. **Backup Requirements**: The database backup command requires `mysqldump` to be available in your system PATH.

3. **Storage Permissions**: Ensure the `storage/app/backups` directory is writable by the web server user.

4. **Production Setup**: In production, always use a proper cron job rather than Task Scheduler for reliability.

## Troubleshooting

### Scheduler Not Running
- Check if cron job is set up correctly
- Verify PHP path in cron command
- Check Laravel logs for errors

### Backup Fails
- Verify mysqldump is installed and in PATH
- Check database credentials in `.env`
- Ensure storage directory is writable

### Token Cleanup Not Working
- Check database connection
- Verify `auth_tokens` table exists
- Check Laravel logs for errors

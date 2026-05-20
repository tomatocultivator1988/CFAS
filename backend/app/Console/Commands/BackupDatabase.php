<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Storage;

class BackupDatabase extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'backup:run {--verify : Verify backup integrity}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Create a backup of the database';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info('Starting database backup...');

        $database = config('database.connections.mysql.database');
        $username = config('database.connections.mysql.username');
        $password = config('database.connections.mysql.password');
        $host = config('database.connections.mysql.host');
        
        $backupPath = storage_path('app/backups');
        
        // Create backups directory if it doesn't exist
        if (!file_exists($backupPath)) {
            mkdir($backupPath, 0755, true);
        }
        
        $filename = 'backup_' . date('Y-m-d_H-i-s') . '.sql';
        $filepath = $backupPath . '/' . $filename;
        
        // Build mysqldump command
        $command = sprintf(
            'mysqldump --user=%s --password=%s --host=%s %s > %s',
            escapeshellarg($username),
            escapeshellarg($password),
            escapeshellarg($host),
            escapeshellarg($database),
            escapeshellarg($filepath)
        );
        
        // Execute backup
        exec($command, $output, $returnCode);
        
        if ($returnCode === 0) {
            $this->info("Backup created successfully: {$filename}");
            
            // Verify backup if requested
            if ($this->option('verify')) {
                $this->verifyBackup($filepath);
            }
            
            // Clean up old backups (keep last 7 days)
            $this->cleanupOldBackups($backupPath);
            
            \Log::info("Database backup created: {$filename}");
            
            return Command::SUCCESS;
        } else {
            $this->error('Backup failed!');
            \Log::error('Database backup failed', ['return_code' => $returnCode]);
            
            return Command::FAILURE;
        }
    }
    
    /**
     * Verify backup integrity
     */
    protected function verifyBackup($filepath)
    {
        if (file_exists($filepath) && filesize($filepath) > 0) {
            $this->info('Backup verification: OK');
            \Log::info('Backup verified successfully', ['file' => $filepath]);
        } else {
            $this->error('Backup verification: FAILED');
            \Log::error('Backup verification failed', ['file' => $filepath]);
        }
    }
    
    /**
     * Clean up old backups
     */
    protected function cleanupOldBackups($backupPath)
    {
        $files = glob($backupPath . '/backup_*.sql');
        $now = time();
        $deleted = 0;
        
        foreach ($files as $file) {
            // Delete files older than 7 days
            if ($now - filemtime($file) >= 7 * 24 * 3600) {
                unlink($file);
                $deleted++;
            }
        }
        
        if ($deleted > 0) {
            $this->info("Cleaned up {$deleted} old backup(s)");
            \Log::info("Cleaned up {$deleted} old backups");
        }
    }
}

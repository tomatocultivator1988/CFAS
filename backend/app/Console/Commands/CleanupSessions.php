<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

class CleanupSessions extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'session:gc';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Clean up expired sessions and tokens';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info('Cleaning up expired sessions and tokens...');

        // Clean up expired auth tokens
        $expiredTokens = DB::table('auth_tokens')
            ->where('expires_at', '<', now())
            ->count();
            
        DB::table('auth_tokens')
            ->where('expires_at', '<', now())
            ->delete();

        $this->info("Deleted {$expiredTokens} expired token(s)");

        // Clean up old session files (if using file driver)
        $sessionPath = storage_path('framework/sessions');
        if (is_dir($sessionPath)) {
            $files = glob($sessionPath . '/*');
            $now = time();
            $deleted = 0;
            
            foreach ($files as $file) {
                if (is_file($file)) {
                    // Delete session files older than 24 hours
                    if ($now - filemtime($file) >= 24 * 3600) {
                        unlink($file);
                        $deleted++;
                    }
                }
            }
            
            $this->info("Deleted {$deleted} old session file(s)");
        }

        \Log::info('Session cleanup completed', [
            'expired_tokens' => $expiredTokens
        ]);

        return Command::SUCCESS;
    }
}

<?php

namespace App\Console;

use Illuminate\Console\Scheduling\Schedule;
use Illuminate\Foundation\Console\Kernel as ConsoleKernel;

class Kernel extends ConsoleKernel
{
    /**
     * Define the application's command schedule.
     */
    protected function schedule(Schedule $schedule): void
    {
        // Daily database backup at 2 AM
        $schedule->command('backup:run')
            ->daily()
            ->at('02:00')
            ->onSuccess(function () {
                \Log::info('Database backup completed successfully');
            })
            ->onFailure(function () {
                \Log::error('Database backup failed');
            });

        // Clean up expired auth tokens every hour
        $schedule->call(function () {
            \DB::table('auth_tokens')
                ->where('expires_at', '<', now())
                ->delete();
            \Log::info('Expired tokens cleaned up');
        })->hourly();

        // Clean up old session data daily at 3 AM
        $schedule->command('session:gc')
            ->daily()
            ->at('03:00');

        // Check for ML model retraining needs daily at 4 AM
        // This will be implemented when ML service is ready
        $schedule->call(function () {
            // Check if retraining is needed (100+ new attempts since last training)
            // This is a placeholder for when ML service is implemented
            \Log::info('ML retraining check completed');
        })->daily()->at('04:00');

        // Generate daily analytics summary at 5 AM
        $schedule->call(function () {
            \Log::info('Daily analytics summary generated');
        })->daily()->at('05:00');
    }

    /**
     * Register the commands for the application.
     */
    protected function commands(): void
    {
        $this->load(__DIR__.'/Commands');

        require base_path('routes/console.php');
    }
}

<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use App\Services\PlatformService;
use App\Services\InputValidator;
use App\Services\CacheService;
use App\Services\ErrorHandler;
use App\Services\HealthMonitor;
use App\Services\FallbackService;
use App\Services\ResponseFormatter;

class MLServiceProvider extends ServiceProvider
{
    /**
     * Register ML prediction services
     */
    public function register(): void
    {
        // Register PlatformService as singleton
        $this->app->singleton(PlatformService::class, function ($app) {
            return new PlatformService();
        });

        // Register InputValidator as singleton
        $this->app->singleton(InputValidator::class, function ($app) {
            return new InputValidator();
        });

        // Register CacheService as singleton
        $this->app->singleton(CacheService::class, function ($app) {
            $cacheDir = storage_path('app/cache');
            if (!is_dir($cacheDir)) {
                mkdir($cacheDir, 0755, true);
            }
            return new CacheService($cacheDir);
        });

        // Register ErrorHandler as singleton
        $this->app->singleton(ErrorHandler::class, function ($app) {
            return new ErrorHandler();
        });

        // Register HealthMonitor as singleton
        $this->app->singleton(HealthMonitor::class, function ($app) {
            return new HealthMonitor(
                $app->make(PlatformService::class),
                $app->make(ErrorHandler::class)
            );
        });

        // Register FallbackService as singleton
        $this->app->singleton(FallbackService::class, function ($app) {
            return new FallbackService(
                $app->make(ErrorHandler::class),
                $app->make(CacheService::class)
            );
        });

        // Register ResponseFormatter as singleton
        $this->app->singleton(ResponseFormatter::class, function ($app) {
            return new ResponseFormatter();
        });
    }

    /**
     * Bootstrap services
     */
    public function boot(): void
    {
        //
    }
}
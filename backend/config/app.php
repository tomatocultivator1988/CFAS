<?php

use Illuminate\Support\Facades\Facade;
use Illuminate\Support\ServiceProvider;

return [

    'name' => env('APP_NAME', 'Laravel'),
    'env' => env('APP_ENV', 'production'),
    'debug' => (bool) env('APP_DEBUG', false),
    'url' => env('APP_URL', 'http://localhost'),
    'asset_url' => env('ASSET_URL'),
    'timezone' => 'Asia/Manila',
    'locale' => 'en',
    'fallback_locale' => 'en',
    'faker_locale' => 'en_US',
    'key' => env('APP_KEY'),
    'cipher' => 'AES-256-CBC',
    'force_https' => env('FORCE_HTTPS', false),

    'maintenance' => [
        'driver' => 'file',
    ],

    'providers' => ServiceProvider::defaultProviders()->merge([
        App\Providers\RouteServiceProvider::class,
        App\Providers\AnalyticsServiceProvider::class,
    ])->toArray(),

    'aliases' => Facade::defaultAliases()->merge([
        // 'Example' => App\Facades\Example::class,
    ])->toArray(),

    /*
    |--------------------------------------------------------------------------
    | Lab IP Ranges
    |--------------------------------------------------------------------------
    |
    | Define allowed IP addresses/ranges for exam access. Supports:
    | - Exact IP: '192.168.1.100'
    | - CIDR notation: '192.168.1.0/24'
    | - Wildcard: '192.168.1.*'
    | - Range: '192.168.1.1-192.168.1.100'
    |
    | Leave empty to allow all IPs (development mode).
    |
    */

    'lab_ip_ranges' => env('LAB_IP_RANGES')
        ? explode(',', env('LAB_IP_RANGES'))
        : (env('LAB_IP_RANGE') ? explode(',', env('LAB_IP_RANGE')) : [
        // Example configurations (uncomment to enable):
        // '127.0.0.1',           // Localhost
        // '192.168.1.0/24',      // Local network
        // '10.0.0.*',            // Wildcard
        // '172.16.0.1-172.16.0.50', // Range
    ]),

];

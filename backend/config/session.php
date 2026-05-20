<?php

return [

    'driver' => env('SESSION_DRIVER', 'file'),
    'lifetime' => env('SESSION_TIMEOUT_MINUTES', 30),
    'expire_on_close' => false,
    'encrypt' => false,
    'files' => storage_path('framework/sessions'),
    'connection' => env('SESSION_CONNECTION'),
    'table' => 'sessions',
    'store' => env('SESSION_STORE'),
    'lottery' => [2, 100],
    'cookie' => env(
        'SESSION_COOKIE',
        str_replace(' ', '_', strtolower(env('APP_NAME', 'laravel'))).'_session'
    ),
    // Dedicated API auth cookie for token-based guard.
    'auth_cookie_name' => env('AUTH_COOKIE_NAME', 'auth_token'),
    'path' => '/',
    'domain' => env('SESSION_DOMAIN'),
    'secure' => env('SESSION_SECURE_COOKIE'),
    'http_only' => true,
    'same_site' => 'lax',
    'partitioned' => false,

];

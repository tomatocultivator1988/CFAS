<?php
/**
 * Emergency maintenance utility.
 * This endpoint is intentionally locked down and should not be exposed publicly.
 */

require __DIR__ . '/../vendor/autoload.php';

$app = require_once __DIR__ . '/../bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

$remoteIp = $_SERVER['REMOTE_ADDR'] ?? '';
$isLocalIp = in_array($remoteIp, ['127.0.0.1', '::1'], true);
$isLocalEnv = app()->environment(['local', 'testing']);
$providedToken = $_GET['token'] ?? '';
$expectedToken = env('MAINTENANCE_RESET_TOKEN', '');

if (!$isLocalEnv || !$isLocalIp || empty($expectedToken) || !hash_equals($expectedToken, $providedToken)) {
    http_response_code(403);
    echo 'Forbidden';
    exit;
}

echo "<h2>Circuit Breaker Reset</h2>";
echo "<p>Clearing caches...</p>";

\Illuminate\Support\Facades\Artisan::call('cache:clear');
\Illuminate\Support\Facades\Artisan::call('config:clear');
\Illuminate\Support\Facades\Artisan::call('route:clear');

echo "<p style='color: green;'>✓ Caches cleared</p>";

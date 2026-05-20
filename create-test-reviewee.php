<?php

/**
 * Create a test reviewee user with default password
 */

require __DIR__ . '/backend/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

// Bootstrap Laravel
$app = require_once __DIR__ . '/backend/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "=== Creating Test Reviewee ===\n\n";

// Delete existing test user
DB::table('users')->where('username', 'testuser')->delete();
echo "✓ Cleaned up existing test user\n";

// Create new test user
$userId = DB::table('users')->insertGetId([
    'username' => 'testuser',
    'password_hash' => password_hash('password123', PASSWORD_DEFAULT),
    'role' => 'reviewee',
    'first_name' => 'Test',
    'last_name' => 'User',
    'middle_initial' => 'R',
    'is_active' => true,
    'require_password_change' => true,
    'created_at' => now(),
]);

echo "✓ Created test reviewee user\n\n";
echo "Login Credentials:\n";
echo "  Username: testuser\n";
echo "  Password: password123\n";
echo "  User ID: $userId\n\n";
echo "✓ User will be forced to change password on first login\n";
echo "\nYou can now login at: http://localhost:5173\n";

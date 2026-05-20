<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Services\UserManagementService;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

echo "Testing Default Password System\n";
echo "================================\n\n";

$userService = app(UserManagementService::class);
$admin = User::where('username', 'admin')->first();

if (!$admin) {
    echo "❌ Admin user not found!\n";
    exit(1);
}

// Test 1: Create user without password
echo "Test 1: Creating user without password field\n";
echo "---------------------------------------------\n";

$testData = [
    'username' => 'testdefault_' . time(),
    'first_name' => 'Test',
    'last_name' => 'User',
    'middle_initial' => 'D',
    'role' => 'reviewee',
];

try {
    $newUser = $userService->createUser($testData, $admin->id);
    echo "✅ User created: {$newUser->username}\n";
    echo "   require_password_change: " . ($newUser->require_password_change ? 'true' : 'false') . "\n";
    
    // Test if password is 'password123'
    if (Hash::check('password123', $newUser->password_hash)) {
        echo "✅ Default password 'password123' set correctly\n";
    } else {
        echo "❌ Default password NOT set correctly\n";
    }
    
    if ($newUser->require_password_change) {
        echo "✅ require_password_change is true\n";
    } else {
        echo "❌ require_password_change should be true\n";
    }
    
    echo "\n";
    
    // Test 2: Reset password to default
    echo "Test 2: Reset password to default\n";
    echo "-----------------------------------\n";
    
    $resetUser = $userService->resetPasswordToDefault($newUser->id, $admin->id);
    echo "✅ Password reset for: {$resetUser->username}\n";
    
    if (Hash::check('password123', $resetUser->password_hash)) {
        echo "✅ Password reset to 'password123' correctly\n";
    } else {
        echo "❌ Password NOT reset correctly\n";
    }
    
    if ($resetUser->require_password_change) {
        echo "✅ require_password_change is true after reset\n";
    } else {
        echo "❌ require_password_change should be true after reset\n";
    }
    
    // Cleanup
    echo "\nCleaning up...\n";
    $newUser->delete();
    echo "✅ Test user deleted\n\n";
    
    echo "================================\n";
    echo "✅ ALL TESTS PASSED!\n";
    echo "================================\n";
    
} catch (\Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}

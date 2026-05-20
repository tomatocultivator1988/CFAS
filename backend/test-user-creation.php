<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Services\UserManagementService;
use App\Models\User;

echo "Testing User Creation with Name Fields\n";
echo "========================================\n\n";

// Get the service
$userService = app(UserManagementService::class);

// Get admin user ID
$admin = User::where('username', 'admin')->first();
if (!$admin) {
    echo "❌ Admin user not found!\n";
    exit(1);
}

echo "✓ Admin user found (ID: {$admin->id})\n\n";

// Test data
$testData = [
    'username' => 'testuser_' . time(),
    'password' => 'Test123!',
    'first_name' => 'John',
    'last_name' => 'Doe',
    'middle_initial' => 'M',
    'role' => 'reviewee',
    'require_password_change' => false,
];

echo "Creating test user with data:\n";
echo "  Username: {$testData['username']}\n";
echo "  First Name: {$testData['first_name']}\n";
echo "  Last Name: {$testData['last_name']}\n";
echo "  Middle Initial: {$testData['middle_initial']}\n";
echo "  Role: {$testData['role']}\n\n";

try {
    // Create user
    $newUser = $userService->createUser($testData, $admin->id);
    
    echo "✅ User created successfully!\n\n";
    
    // Verify the data
    echo "Verifying saved data:\n";
    echo "  ID: {$newUser->id}\n";
    echo "  Username: {$newUser->username}\n";
    echo "  First Name: " . ($newUser->first_name ?? 'NULL') . "\n";
    echo "  Last Name: " . ($newUser->last_name ?? 'NULL') . "\n";
    echo "  Middle Initial: " . ($newUser->middle_initial ?? 'NULL') . "\n";
    echo "  Role: {$newUser->role}\n";
    echo "  Active: " . ($newUser->is_active ? 'Yes' : 'No') . "\n\n";
    
    // Check if name fields are saved correctly
    if ($newUser->first_name === $testData['first_name'] &&
        $newUser->last_name === $testData['last_name'] &&
        $newUser->middle_initial === $testData['middle_initial']) {
        echo "✅ All name fields saved correctly!\n\n";
    } else {
        echo "❌ Name fields don't match!\n";
        echo "  Expected: {$testData['first_name']} {$testData['middle_initial']} {$testData['last_name']}\n";
        echo "  Got: {$newUser->first_name} {$newUser->middle_initial} {$newUser->last_name}\n\n";
    }
    
    // Clean up - delete test user
    echo "Cleaning up test user...\n";
    $newUser->delete();
    echo "✅ Test user deleted\n\n";
    
    echo "========================================\n";
    echo "✅ TEST PASSED - User creation works!\n";
    
} catch (\Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    echo "\nStack trace:\n";
    echo $e->getTraceAsString() . "\n";
    exit(1);
}

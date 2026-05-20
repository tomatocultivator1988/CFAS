<?php
/**
 * Create 13 Reviewee Accounts
 * Names: Reviewee01 to Reviewee13
 * Default password: password123
 */

require __DIR__ . '/backend/vendor/autoload.php';

// Load environment
$dotenv = Dotenv\Dotenv::createImmutable(__DIR__ . '/backend');
$dotenv->load();

// Bootstrap Laravel
$app = require_once __DIR__ . '/backend/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

echo "========================================\n";
echo "  CREATE 13 REVIEWEE ACCOUNTS\n";
echo "========================================\n\n";

$created = 0;
$skipped = 0;
$errors = 0;

for ($i = 1; $i <= 13; $i++) {
    $number = str_pad($i, 2, '0', STR_PAD_LEFT); // 01, 02, 03, etc.
    $username = "reviewee{$number}";
    $firstName = "Reviewee";
    $lastName = $number;
    $email = "reviewee{$number}@example.com";
    $password = 'password123';
    
    try {
        // Check if user already exists
        $existingUser = \App\Models\User::where('username', $username)->first();
        
        if ($existingUser) {
            echo "[$i/13] SKIP: {$username} already exists\n";
            $skipped++;
            continue;
        }
        
        // Create user
        $user = \App\Models\User::create([
            'username' => $username,
            'first_name' => $firstName,
            'last_name' => $lastName,
            'password_hash' => password_hash($password, PASSWORD_BCRYPT),
            'role' => 'reviewee',
            'is_active' => true
        ]);
        
        echo "[$i/13] ✓ Created: {$username} (ID: {$user->id})\n";
        echo "        Name: {$firstName} {$lastName}\n";
        echo "        Email: {$email}\n";
        echo "        Password: {$password}\n\n";
        
        $created++;
        
    } catch (\Exception $e) {
        echo "[$i/13] ✗ ERROR: {$username} - {$e->getMessage()}\n\n";
        $errors++;
    }
}

echo "========================================\n";
echo "  SUMMARY\n";
echo "========================================\n\n";

echo "Created: {$created} accounts\n";
echo "Skipped: {$skipped} accounts (already exist)\n";
echo "Errors:  {$errors} accounts\n";
echo "Total:   13 accounts\n\n";

if ($created > 0) {
    echo "========================================\n";
    echo "  LOGIN CREDENTIALS\n";
    echo "========================================\n\n";
    
    echo "All accounts use the same password: password123\n\n";
    
    echo "Usernames:\n";
    for ($i = 1; $i <= 13; $i++) {
        $number = str_pad($i, 2, '0', STR_PAD_LEFT);
        echo "  - reviewee{$number}\n";
    }
    
    echo "\nLogin URL: http://localhost/exam-frontend\n";
}

echo "\n";

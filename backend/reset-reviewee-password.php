<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\User;
use Illuminate\Support\Facades\Hash;

// Reset reviewee password
$user = User::where('username', 'reviewee')->first();
if ($user) {
    $user->password_hash = Hash::make('password');
    $user->require_password_change = false;
    $user->save();
    echo "✅ Password reset for 'reviewee' to 'password'\n";
} else {
    echo "❌ User 'reviewee' not found\n";
}

// Also reset other reviewees
$reviewees = User::where('role', 'reviewee')->where('username', '!=', 'reviewee')->get();
foreach ($reviewees as $rev) {
    $rev->password_hash = Hash::make('password');
    $rev->require_password_change = false;
    $rev->save();
    echo "✅ Password reset for '{$rev->username}' to 'password'\n";
}

echo "\n📝 All reviewee accounts now have password: 'password'\n";
echo "\n🔑 Test Login:\n";
echo "   Username: reviewee\n";
echo "   Password: password\n";

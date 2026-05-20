<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\User;

// Activate all reviewees
$reviewees = User::where('role', 'reviewee')->get();

foreach ($reviewees as $user) {
    $user->is_active = true;
    $user->save();
    echo "✅ Activated user: {$user->username}\n";
}

echo "\n📝 All reviewee accounts are now ACTIVE\n";
echo "\n🔑 You can now login with:\n";
echo "   Username: reviewee\n";
echo "   Password: password\n";

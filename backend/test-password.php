<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\User;
use Illuminate\Support\Facades\Hash;

$user = User::where('username', 'reviewee')->first();

echo "Username: {$user->username}\n";
echo "Hash: " . substr($user->password_hash, 0, 30) . "...\n";
echo "Password check ('password'): " . (Hash::check('password', $user->password_hash) ? '✅ VALID' : '❌ INVALID') . "\n";
echo "Password check ('wrong'): " . (Hash::check('wrong', $user->password_hash) ? '✅ VALID' : '❌ INVALID') . "\n";

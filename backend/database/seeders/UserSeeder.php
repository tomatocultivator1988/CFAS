<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Create admin user
        User::create([
            'username' => 'admin',
            'password_hash' => Hash::make('admin123', ['rounds' => 12]),
            'first_name' => 'Admin',
            'last_name' => 'User',
            'middle_initial' => 'A',
            'role' => 'admin',
            'is_active' => true,
            'require_password_change' => false,
        ]);

        // Create reviewee user
        User::create([
            'username' => 'reviewee',
            'password_hash' => Hash::make('reviewee123', ['rounds' => 12]),
            'first_name' => 'Test',
            'last_name' => 'Reviewee',
            'middle_initial' => 'R',
            'role' => 'reviewee',
            'is_active' => true,
            'require_password_change' => false,
        ]);

        echo "✅ Test users created:\n";
        echo "   Admin: username=admin, password=admin123\n";
        echo "   Reviewee: username=reviewee, password=reviewee123\n";
    }
}

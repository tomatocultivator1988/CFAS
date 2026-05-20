<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('username', 255)->unique();
            $table->string('password_hash', 255);
            $table->enum('role', ['admin', 'reviewee']);
            $table->boolean('is_active')->default(true);
            $table->boolean('require_password_change')->default(false);
            $table->timestamp('created_at')->useCurrent();
            $table->timestamp('last_login_at')->nullable();
            
            // Indexes for performance
            $table->index('username');
            $table->index('role');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('users');
    }
};

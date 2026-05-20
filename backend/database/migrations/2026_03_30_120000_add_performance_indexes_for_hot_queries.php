<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('exam_attempts', function (Blueprint $table) {
            $table->index(['status', 'start_time'], 'exam_attempts_status_start_time_index');
            $table->index(['reviewee_id', 'status', 'id'], 'exam_attempts_reviewee_status_id_index');
        });

        Schema::table('users', function (Blueprint $table) {
            $table->index(['role', 'is_active', 'id'], 'users_role_is_active_id_index');
        });
    }

    public function down(): void
    {
        Schema::table('exam_attempts', function (Blueprint $table) {
            $table->dropIndex('exam_attempts_status_start_time_index');
            $table->dropIndex('exam_attempts_reviewee_status_id_index');
        });

        Schema::table('users', function (Blueprint $table) {
            $table->dropIndex('users_role_is_active_id_index');
        });
    }
};

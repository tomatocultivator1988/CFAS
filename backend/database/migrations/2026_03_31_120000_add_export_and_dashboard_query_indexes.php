<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('exam_attempts', function (Blueprint $table) {
            $table->index(['status', 'exam_id', 'reviewee_id', 'start_time'], 'exam_attempts_status_exam_reviewee_start_idx');
            $table->index(['status', 'end_time'], 'exam_attempts_status_end_time_idx');
        });

        Schema::table('users', function (Blueprint $table) {
            $table->index(['role', 'is_active', 'username'], 'users_role_active_username_idx');
            $table->index(['role', 'last_name', 'first_name'], 'users_role_last_first_idx');
        });

        Schema::table('exams', function (Blueprint $table) {
            $table->index(['category', 'title'], 'exams_category_title_idx');
        });
    }

    public function down(): void
    {
        Schema::table('exam_attempts', function (Blueprint $table) {
            $table->dropIndex('exam_attempts_status_exam_reviewee_start_idx');
            $table->dropIndex('exam_attempts_status_end_time_idx');
        });

        Schema::table('users', function (Blueprint $table) {
            $table->dropIndex('users_role_active_username_idx');
            $table->dropIndex('users_role_last_first_idx');
        });

        Schema::table('exams', function (Blueprint $table) {
            $table->dropIndex('exams_category_title_idx');
        });
    }
};

<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     * Add cascade delete to reviewee-related tables so all data is deleted when reviewee is deleted.
     */
    public function up(): void
    {
        // Drop and recreate foreign keys with cascade delete
        
        // 1. exam_attempts table - CASCADE DELETE
        Schema::table('exam_attempts', function (Blueprint $table) {
            $table->dropForeign(['reviewee_id']);
        });
        
        Schema::table('exam_attempts', function (Blueprint $table) {
            $table->foreign('reviewee_id')
                ->references('id')
                ->on('users')
                ->onDelete('cascade');
        });
        
        // 2. ml_predictions table - CASCADE DELETE
        Schema::table('ml_predictions', function (Blueprint $table) {
            $table->dropForeign(['reviewee_id']);
        });
        
        Schema::table('ml_predictions', function (Blueprint $table) {
            $table->foreign('reviewee_id')
                ->references('id')
                ->on('users')
                ->onDelete('cascade');
        });
        
        // 3. audit_logs table - SET NULL (keep logs for compliance)
        Schema::table('audit_logs', function (Blueprint $table) {
            $table->dropForeign(['user_id']);
        });
        
        Schema::table('audit_logs', function (Blueprint $table) {
            $table->foreign('user_id')
                ->references('id')
                ->on('users')
                ->onDelete('set null');
        });
        
        // Note: 
        // - auth_tokens already has cascade delete
        // - attempt_answers and security_violations already cascade from exam_attempts
        // - So when exam_attempts are deleted, their related data will also be deleted
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Revert to no cascade delete
        
        Schema::table('exam_attempts', function (Blueprint $table) {
            $table->dropForeign(['reviewee_id']);
        });
        
        Schema::table('exam_attempts', function (Blueprint $table) {
            $table->foreign('reviewee_id')
                ->references('id')
                ->on('users');
        });
        
        Schema::table('ml_predictions', function (Blueprint $table) {
            $table->dropForeign(['reviewee_id']);
        });
        
        Schema::table('ml_predictions', function (Blueprint $table) {
            $table->foreign('reviewee_id')
                ->references('id')
                ->on('users');
        });
        
        Schema::table('audit_logs', function (Blueprint $table) {
            $table->dropForeign(['user_id']);
        });
        
        Schema::table('audit_logs', function (Blueprint $table) {
            $table->foreign('user_id')
                ->references('id')
                ->on('users');
        });
    }
};

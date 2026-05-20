<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     * Adds support for offline exam submissions with automatic sync.
     */
    public function up(): void
    {
        // Add offline submission columns to exam_attempts table
        Schema::table('exam_attempts', function (Blueprint $table) {
            // UUID from client to prevent duplicate submissions
            $table->string('submission_id', 36)->nullable()->unique()->after('id');
            
            // SHA-256 checksum for data integrity verification
            $table->string('checksum', 64)->nullable()->after('submission_id');
            
            // Track whether submission was made online or offline
            $table->enum('sync_source', ['online', 'offline'])->default('online')->after('checksum');
            
            // Index for fast duplicate detection
            $table->index('submission_id', 'exam_attempts_submission_id_index');
        });

        // Create submission_logs table for audit trail
        Schema::create('submission_logs', function (Blueprint $table) {
            $table->id();
            $table->string('submission_id', 36)->index();
            $table->foreignId('attempt_id')->nullable()->constrained('exam_attempts')->onDelete('cascade');
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->enum('action', ['received', 'duplicate', 'created', 'failed']);
            $table->timestamp('timestamp')->useCurrent();
            $table->string('ip_address', 45)->nullable();
            $table->text('user_agent')->nullable();
            $table->text('error_message')->nullable();
            
            // Indexes for querying logs
            $table->index(['submission_id', 'timestamp']);
            $table->index(['user_id', 'timestamp']);
            $table->index(['action', 'timestamp']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('submission_logs');
        
        Schema::table('exam_attempts', function (Blueprint $table) {
            $table->dropIndex('exam_attempts_submission_id_index');
            $table->dropColumn(['submission_id', 'checksum', 'sync_source']);
        });
    }
};

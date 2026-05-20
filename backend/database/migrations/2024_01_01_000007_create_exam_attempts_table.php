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
        Schema::create('exam_attempts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('exam_id')->constrained('exams');
            $table->foreignId('reviewee_id')->constrained('users');
            $table->integer('attempt_number');
            $table->integer('randomization_seed');
            $table->timestamp('start_time');
            $table->timestamp('end_time')->nullable();
            $table->integer('time_limit_seconds');
            $table->integer('violation_count')->default(0);
            $table->enum('status', ['in_progress', 'completed', 'auto_submitted'])->default('in_progress');
            $table->integer('score')->nullable();
            $table->integer('total_questions');
            $table->float('percentage')->nullable();
            
            // Indexes for performance
            $table->index(['reviewee_id', 'exam_id']);
            $table->index('status');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('exam_attempts');
    }
};

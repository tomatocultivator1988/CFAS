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
        Schema::create('ml_predictions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('reviewee_id')->constrained('users');
            $table->float('pass_probability');
            $table->float('fail_probability');
            $table->enum('risk_level', ['Low', 'Medium', 'High']);
            $table->float('predicted_next_score')->nullable();
            $table->float('confidence');
            $table->json('features');
            $table->timestamp('predicted_at')->useCurrent();
            
            // Indexes for performance
            $table->index('reviewee_id');
            $table->index('risk_level');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('ml_predictions');
    }
};

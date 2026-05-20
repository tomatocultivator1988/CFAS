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
        Schema::create('ml_model_metrics', function (Blueprint $table) {
            $table->id();
            $table->float('accuracy');
            $table->float('precision_score');
            $table->float('recall_score');
            $table->float('f1_score');
            $table->integer('training_samples');
            $table->timestamp('trained_at')->useCurrent();
            
            // Index for performance
            $table->index('trained_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('ml_model_metrics');
    }
};

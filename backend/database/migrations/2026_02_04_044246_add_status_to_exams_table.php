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
        Schema::table('exams', function (Blueprint $table) {
            // Add status column (active, inactive, archived)
            $table->enum('status', ['active', 'inactive', 'archived'])->default('inactive')->after('is_deleted');
        });
        
        // Set existing exams to active if not deleted
        DB::statement("UPDATE exams SET status = 'active' WHERE is_deleted = 0");
        DB::statement("UPDATE exams SET status = 'archived' WHERE is_deleted = 1");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('exams', function (Blueprint $table) {
            $table->dropColumn('status');
        });
    }
};

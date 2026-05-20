<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('exams', function (Blueprint $table) {
            $table->tinyInteger('passing_score')
                  ->unsigned()
                  ->default(75)
                  ->after('max_attempts')
                  ->comment('Minimum score percentage required to pass the exam (0-100)');
        });
        
        // Update existing exam records to have the default passing score
        DB::table('exams')->whereNull('passing_score')->update(['passing_score' => 75]);
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('exams', function (Blueprint $table) {
            $table->dropColumn('passing_score');
        });
    }
};
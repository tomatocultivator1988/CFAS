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
        Schema::table('auth_tokens', function (Blueprint $table) {
            $table->string('token_hash', 64)->nullable()->after('token');
            $table->index('token_hash');
        });

        // Backfill hashes for existing tokens.
        DB::table('auth_tokens')
            ->whereNotNull('token')
            ->orderBy('id')
            ->chunkById(200, function ($tokens) {
                foreach ($tokens as $tokenRow) {
                    DB::table('auth_tokens')
                        ->where('id', $tokenRow->id)
                        ->update([
                            'token_hash' => hash('sha256', $tokenRow->token),
                        ]);
                }
            });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('auth_tokens', function (Blueprint $table) {
            $table->dropIndex(['token_hash']);
            $table->dropColumn('token_hash');
        });
    }
};

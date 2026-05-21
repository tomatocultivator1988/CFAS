<?php

namespace App\Http\Controllers;

use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class AdminAttemptController extends Controller
{
    public function purgeHiddenOrOrphanAttempts(): JsonResponse
    {
        try {
            $attemptIds = DB::table('exam_attempts as ea')
                ->leftJoin('exams as e', 'ea.exam_id', '=', 'e.id')
                ->where(function ($query) {
                    $query->whereNull('e.id')
                        ->orWhere('e.is_deleted', 1);
                })
                ->pluck('ea.id');

            if ($attemptIds->isEmpty()) {
                return response()->json([
                    'success' => true,
                    'message' => 'No hidden or orphan attempts found.',
                    'deleted_attempts' => 0,
                ]);
            }

            DB::transaction(function () use ($attemptIds) {
                DB::table('attempt_answers')->whereIn('attempt_id', $attemptIds)->delete();
                DB::table('security_violations')->whereIn('attempt_id', $attemptIds)->delete();
                DB::table('exam_attempts')->whereIn('id', $attemptIds)->delete();
            });

            return response()->json([
                'success' => true,
                'message' => 'Hidden or orphan attempts purged successfully.',
                'deleted_attempts' => $attemptIds->count(),
            ]);
        } catch (\Throwable $e) {
            Log::error('Failed to purge hidden or orphan attempts', [
                'error' => $e->getMessage(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to purge hidden or orphan attempts.',
            ], 500);
        }
    }
}

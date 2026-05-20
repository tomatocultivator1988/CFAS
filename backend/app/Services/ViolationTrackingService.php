<?php

namespace App\Services;

use App\Models\SecurityViolation;
use App\Models\ExamAttempt;
use Illuminate\Support\Facades\DB;

class ViolationTrackingService
{
    protected ExamDeliveryService $examDeliveryService;

    public function __construct(ExamDeliveryService $examDeliveryService)
    {
        $this->examDeliveryService = $examDeliveryService;
    }

    /**
     * Record a security violation.
     *
     * @param int $attemptId
     * @param string $violationType
     * @param int $revieweeId
     * @return array
     * @throws \Exception
     */
    public function recordViolation(int $attemptId, string $violationType, int $revieweeId): array
    {
        $attempt = ExamAttempt::with('exam')->findOrFail($attemptId);

        // Verify ownership
        if ($attempt->reviewee_id !== $revieweeId) {
            throw new \Exception('Unauthorized access to this attempt.');
        }

        // Check if attempt is still in progress
        if (!$attempt->isInProgress()) {
            throw new \Exception('Cannot record violation for completed attempt.');
        }

        // Validate violation type
        $validTypes = ['focus_loss', 'alt_tab', 'prohibited_key'];
        if (!in_array($violationType, $validTypes)) {
            throw new \Exception('Invalid violation type.');
        }

        return DB::transaction(function () use ($attempt, $violationType, $revieweeId) {
            // Record the violation
            SecurityViolation::create([
                'attempt_id' => $attempt->id,
                'violation_type' => $violationType,
                'detected_at' => now(),
            ]);

            // Increment violation count
            $attempt->increment('violation_count');
            $attempt->refresh();

            // Check if threshold exceeded
            $thresholdExceeded = $this->isThresholdExceeded($attempt->id);

            // Auto-submit if threshold exceeded
            if ($thresholdExceeded) {
                $this->examDeliveryService->submitExam($attempt->id, $revieweeId, true);
                $attempt->refresh();
            }

            return [
                'violation_count' => $attempt->violation_count,
                'threshold' => $attempt->exam->violation_threshold,
                'threshold_exceeded' => $thresholdExceeded,
                'auto_submitted' => $thresholdExceeded,
            ];
        });
    }

    /**
     * Get violation count for an attempt.
     *
     * @param int $attemptId
     * @param int $revieweeId
     * @return int
     */
    public function getViolationCount(int $attemptId, int $revieweeId): int
    {
        $attempt = ExamAttempt::findOrFail($attemptId);
        if ($attempt->reviewee_id !== $revieweeId) {
            throw new \Exception('Unauthorized access to this attempt.');
        }

        return SecurityViolation::where('attempt_id', $attemptId)->count();
    }

    /**
     * Check if violation threshold has been exceeded.
     *
     * @param int $attemptId
     * @return bool
     */
    public function isThresholdExceeded(int $attemptId): bool
    {
        $attempt = ExamAttempt::with('exam')->findOrFail($attemptId);
        return $attempt->violation_count >= $attempt->exam->violation_threshold;
    }

    /**
     * Get all violations for an attempt.
     *
     * @param int $attemptId
     * @return \Illuminate\Database\Eloquent\Collection
     */
    public function getViolations(int $attemptId)
    {
        return SecurityViolation::where('attempt_id', $attemptId)
            ->orderBy('detected_at', 'desc')
            ->get();
    }
}

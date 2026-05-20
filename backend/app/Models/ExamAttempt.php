<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class ExamAttempt extends Model
{
    public $timestamps = false;

    protected $fillable = [
        'exam_id',
        'reviewee_id',
        'attempt_number',
        'randomization_seed',
        'start_time',
        'end_time',
        'time_limit_seconds',
        'violation_count',
        'status',
        'score',
        'total_questions',
        'percentage',
        'submission_id',
        'checksum',
        'sync_source',
    ];

    protected $casts = [
        'start_time' => 'datetime',
        'end_time' => 'datetime',
        'attempt_number' => 'integer',
        'time_limit_seconds' => 'integer',
        'violation_count' => 'integer',
        'score' => 'integer',
        'total_questions' => 'integer',
        'percentage' => 'float',
    ];

    /**
     * Get the exam for this attempt.
     */
    public function exam(): BelongsTo
    {
        return $this->belongsTo(Exam::class);
    }

    /**
     * Get the reviewee for this attempt.
     */
    public function reviewee(): BelongsTo
    {
        return $this->belongsTo(User::class, 'reviewee_id');
    }

    /**
     * Get the answers for this attempt.
     */
    public function answers(): HasMany
    {
        return $this->hasMany(AttemptAnswer::class, 'attempt_id');
    }

    /**
     * Check if attempt is still in progress.
     */
    public function isInProgress(): bool
    {
        return $this->status === 'in_progress';
    }

    /**
     * Check if attempt is completed.
     */
    public function isCompleted(): bool
    {
        return in_array($this->status, ['completed', 'auto_submitted']);
    }

    /**
     * Get remaining time in seconds.
     */
    public function getRemainingSeconds(): int
    {
        if ($this->isCompleted()) {
            return 0;
        }

        $elapsed = now()->diffInSeconds($this->start_time);
        $remaining = $this->time_limit_seconds - $elapsed;

        return max(0, $remaining);
    }

    /**
     * Check if time has expired.
     */
    public function hasTimeExpired(): bool
    {
        return $this->getRemainingSeconds() <= 0;
    }
}

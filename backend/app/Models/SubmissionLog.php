<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SubmissionLog extends Model
{
    public $timestamps = false;

    protected $fillable = [
        'submission_id',
        'attempt_id',
        'user_id',
        'action',
        'timestamp',
        'ip_address',
        'user_agent',
        'error_message',
    ];

    protected $casts = [
        'timestamp' => 'datetime',
    ];

    /**
     * Get the exam attempt for this log entry.
     */
    public function attempt(): BelongsTo
    {
        return $this->belongsTo(ExamAttempt::class, 'attempt_id');
    }

    /**
     * Get the user for this log entry.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}

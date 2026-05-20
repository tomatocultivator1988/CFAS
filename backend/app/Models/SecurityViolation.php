<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SecurityViolation extends Model
{
    public $timestamps = false;

    protected $fillable = [
        'attempt_id',
        'violation_type',
        'detected_at',
    ];

    protected $casts = [
        'detected_at' => 'datetime',
    ];

    /**
     * Get the attempt for this violation.
     */
    public function attempt(): BelongsTo
    {
        return $this->belongsTo(ExamAttempt::class, 'attempt_id');
    }
}

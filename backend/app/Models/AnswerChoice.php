<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AnswerChoice extends Model
{
    public $timestamps = false;

    protected $fillable = [
        'question_id',
        'choice_text',
        'is_correct',
        'display_order',
    ];

    protected $casts = [
        'is_correct' => 'boolean',
        'display_order' => 'integer',
    ];

    /**
     * Get the question that owns the answer choice.
     */
    public function question(): BelongsTo
    {
        return $this->belongsTo(Question::class);
    }
}

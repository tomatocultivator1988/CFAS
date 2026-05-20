<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Question extends Model
{
    protected $fillable = [
        'question_text',
        'topic',
        'difficulty',
    ];

    /**
     * Get the answer choices for the question.
     */
    public function answerChoices(): HasMany
    {
        return $this->hasMany(AnswerChoice::class)->orderBy('display_order');
    }

    /**
     * Get the exams that include this question.
     */
    public function exams(): BelongsToMany
    {
        return $this->belongsToMany(Exam::class, 'exam_questions')
            ->withPivot('display_order');
    }

    /**
     * Get the correct answer for this question.
     */
    public function correctAnswer()
    {
        return $this->answerChoices()->where('is_correct', true)->first();
    }
}

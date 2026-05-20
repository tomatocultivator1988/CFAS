<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Exam extends Model
{
    protected $fillable = [
        'title',
        'category',
        'description',
        'time_limit_minutes',
        'max_attempts',
        'passing_score',
        'randomize_questions',
        'randomize_choices',
        'violation_threshold',
        'is_deleted',
        'status',
    ];

    protected $casts = [
        'randomize_questions' => 'boolean',
        'randomize_choices' => 'boolean',
        'is_deleted' => 'boolean',
        'time_limit_minutes' => 'integer',
        'max_attempts' => 'integer',
        'passing_score' => 'integer',
        'violation_threshold' => 'integer',
    ];

    protected $appends = ['questions_count'];

    /**
     * Get the questions count attribute.
     */
    public function getQuestionsCountAttribute(): int
    {
        return $this->questions()->count();
    }

    /**
     * Get the questions for the exam.
     */
    public function questions(): BelongsToMany
    {
        return $this->belongsToMany(Question::class, 'exam_questions')
            ->withPivot('display_order')
            ->orderBy('exam_questions.display_order');
    }

    /**
     * Scope to get only active exams.
     */
    public function scopeActive($query)
    {
        return $query->where('status', 'active')->where('is_deleted', false);
    }
    
    /**
     * Scope to get non-deleted exams (for admin).
     */
    public function scopeNotDeleted($query)
    {
        return $query->where('is_deleted', false);
    }
    
    /**
     * Get the exam attempts for this exam.
     */
    public function examAttempts(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(ExamAttempt::class, 'exam_id');
    }
}

<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    /**
     * The table associated with the model.
     *
     * @var string
     */
    protected $table = 'users';

    /**
     * Indicates if the model should be timestamped.
     *
     * @var bool
     */
    public $timestamps = false;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'username',
        'password_hash',
        'first_name',
        'last_name',
        'middle_initial',
        'role',
        'is_active',
        'require_password_change',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'password_hash',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'is_active' => 'boolean',
        'require_password_change' => 'boolean',
        'last_login_at' => 'datetime',
        'created_at' => 'datetime',
    ];

    /**
     * Get the password for authentication.
     *
     * @return string
     */
    public function getAuthPassword()
    {
        return $this->password_hash;
    }

    /**
     * Check if user is an admin.
     *
     * @return bool
     */
    public function isAdmin(): bool
    {
        return $this->role === 'admin';
    }

    /**
     * Check if user is a reviewee.
     *
     * @return bool
     */
    public function isReviewee(): bool
    {
        return $this->role === 'reviewee';
    }

    /**
     * Exam attempts relationship.
     */
    public function examAttempts()
    {
        return $this->hasMany(ExamAttempt::class, 'reviewee_id');
    }

    /**
     * Auth tokens relationship.
     */
    public function authTokens()
    {
        return $this->hasMany(AuthToken::class);
    }

    /**
     * Audit logs relationship.
     */
    public function auditLogs()
    {
        return $this->hasMany(AuditLog::class);
    }
}

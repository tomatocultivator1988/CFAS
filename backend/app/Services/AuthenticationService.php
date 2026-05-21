<?php

namespace App\Services;

use App\Models\User;
use App\Models\AuthToken;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use Carbon\Carbon;

class AuthenticationService
{
    private const TOKEN_HASH_ALGO = 'sha256';

    /**
     * Authenticate user and create session.
     *
     * @param string $username
     * @param string $password
     * @return array|null
     */
    public function login(string $username, string $password): ?array
    {
        // Log authentication attempt
        Log::info('Authentication attempt', [
            'username' => $username,
            'ip' => request()->ip(),
            'user_agent' => request()->userAgent(),
        ]);
        
        // Find user by username
        $user = User::where('username', $username)->first();

        // Check if user exists and is active
        if (!$user || !$user->is_active) {
            Log::warning('Authentication failed', [
                'username' => $username,
                'reason' => !$user ? 'user_not_found' : 'user_inactive',
                'ip' => request()->ip(),
            ]);
            return null;
        }

        // Verify password using bcrypt
        if (!Hash::check($password, $user->password_hash)) {
            Log::warning('Authentication failed: Invalid password', [
                'username' => $username,
                'user_id' => $user->id,
                'ip' => request()->ip(),
            ]);
            return null;
        }

        // Generate authentication token
        $token = $this->generateToken();
        $expiresAt = Carbon::now()->addMinutes(config('session.lifetime', 30));

        // Create auth token record
        AuthToken::create([
            'user_id' => $user->id,
            'token' => $token,
            'token_hash' => $this->hashToken($token),
            'expires_at' => $expiresAt,
        ]);

        // Update last login timestamp
        $user->update(['last_login_at' => Carbon::now()]);
        
        Log::info('Authentication successful', [
            'username' => $username,
            'user_id' => $user->id,
            'role' => $user->role,
            'ip' => request()->ip(),
        ]);

        return [
            'token' => $token,
            'expires_at' => $expiresAt->toIso8601String(),
            'user' => [
                'id' => $user->id,
                'username' => $user->username,
                'email' => $user->email,
                'first_name' => $user->first_name,
                'last_name' => $user->last_name,
                'role' => $user->role,
                'require_password_change' => $user->require_password_change,
            ],
        ];
    }

    /**
     * Validate authentication token.
     *
     * @param string $token
     * @return User|null
     */
    public function validateToken(string $token): ?User
    {
        $tokenHash = $this->hashToken($token);
        $authToken = AuthToken::where('token_hash', $tokenHash)
            // Backward compatibility for legacy plaintext tokens
            ->orWhere('token', $token)
            ->first();

        if (!$authToken) {
            return null;
        }

        // Check if token is expired
        if ($authToken->isExpired()) {
            $authToken->delete();
            return null;
        }

        $user = $authToken->user;

        // Block deactivated users even with a still-valid token.
        if (!$user || !$user->is_active) {
            $authToken->delete();
            return null;
        }

        return $user;
    }

    /**
     * Logout user and invalidate token.
     *
     * @param string $token
     * @return bool
     */
    public function logout(string $token): bool
    {
        $tokenHash = $this->hashToken($token);
        $deleted = AuthToken::where('token_hash', $tokenHash)
            // Backward compatibility for legacy plaintext tokens
            ->orWhere('token', $token)
            ->delete();
        return $deleted > 0;
    }

    /**
     * Check if session is expired.
     *
     * @param string $token
     * @return bool
     */
    public function isSessionExpired(string $token): bool
    {
        $tokenHash = $this->hashToken($token);
        $authToken = AuthToken::where('token_hash', $tokenHash)
            // Backward compatibility for legacy plaintext tokens
            ->orWhere('token', $token)
            ->first();

        if (!$authToken) {
            return true;
        }

        return $authToken->isExpired();
    }

    /**
     * Generate a unique authentication token.
     *
     * @return string
     */
    private function generateToken(): string
    {
        return Str::random(64);
    }

    /**
     * Hash password using bcrypt with work factor 12.
     *
     * @param string $password
     * @return string
     */
    public function hashPassword(string $password): string
    {
        return Hash::make($password, [
            'rounds' => config('hashing.bcrypt.rounds', 12),
        ]);
    }

    /**
     * Clean up expired tokens.
     *
     * @return int Number of tokens deleted
     */
    public function cleanupExpiredTokens(): int
    {
        return AuthToken::where('expires_at', '<', Carbon::now())->delete();
    }

    /**
     * Revoke all tokens for a user except one current token.
     *
     * @param int $userId
     * @param string|null $exceptToken
     * @return int
     */
    public function revokeUserTokens(int $userId, ?string $exceptToken = null): int
    {
        $query = AuthToken::where('user_id', $userId);

        if ($exceptToken) {
            $exceptHash = $this->hashToken($exceptToken);
            $query->where(function ($innerQuery) use ($exceptHash, $exceptToken) {
                $innerQuery->where('token_hash', '!=', $exceptHash)
                    ->where('token', '!=', $exceptToken);
            });
        }

        return $query->delete();
    }

    /**
     * Hash token for secure DB storage.
     */
    private function hashToken(string $token): string
    {
        return hash(self::TOKEN_HASH_ALGO, $token);
    }
}

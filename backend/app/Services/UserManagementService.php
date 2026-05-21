<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class UserManagementService
{
    /**
     * Default password for new users and password resets
     */
    const DEFAULT_PASSWORD = 'password123';

    /**
     * Create a new user account.
     *
     * @param array $data
     * @param int $adminId
     * @return User
     * @throws \Exception
     */
    public function createUser(array $data, int $adminId): User
    {
        // Validate username uniqueness
        if (User::where('username', $data['username'])->exists()) {
            throw new \Exception('Username already exists.');
        }

        DB::beginTransaction();
        try {
            // Create user with default password
            $user = User::create([
                'username' => $data['username'],
                'email' => $this->normalizeEmail($data['email'] ?? null),
                'password_hash' => Hash::make(self::DEFAULT_PASSWORD),
                'first_name' => $data['first_name'] ?? null,
                'last_name' => $data['last_name'] ?? null,
                'middle_initial' => $data['middle_initial'] ?? null,
                'role' => $data['role'] ?? 'reviewee',
                'is_active' => true,
                'require_password_change' => true, // Force password change on first login
            ]);

            // Log the action
            $this->logUserAction($adminId, 'user_created', $user->id, [
                'username' => $user->username,
                'email' => $user->email,
                'role' => $user->role,
            ]);

            DB::commit();
            return $user;
        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }

    /**
     * Update user account information.
     *
     * @param int $userId
     * @param array $data
     * @param int $adminId
     * @return User
     * @throws \Exception
     */
    public function updateUser(int $userId, array $data, int $adminId): User
    {
        $user = User::findOrFail($userId);

        // Check username uniqueness if changing username
        if (isset($data['username']) && $data['username'] !== $user->username) {
            if (User::where('username', $data['username'])->where('id', '!=', $userId)->exists()) {
                throw new \Exception('Username already exists.');
            }
        }

        DB::beginTransaction();
        try {
            $changes = [];

            // Update allowed fields
            if (isset($data['username'])) {
                $changes['username'] = ['old' => $user->username, 'new' => $data['username']];
                $user->username = $data['username'];
            }

            if (array_key_exists('email', $data)) {
                $email = $this->normalizeEmail($data['email'] ?? null);
                $changes['email'] = ['old' => $user->email, 'new' => $email];
                $user->email = $email;
            }

            if (isset($data['first_name'])) {
                $changes['first_name'] = ['old' => $user->first_name, 'new' => $data['first_name']];
                $user->first_name = $data['first_name'];
            }

            if (isset($data['last_name'])) {
                $changes['last_name'] = ['old' => $user->last_name, 'new' => $data['last_name']];
                $user->last_name = $data['last_name'];
            }

            if (isset($data['middle_initial'])) {
                $changes['middle_initial'] = ['old' => $user->middle_initial, 'new' => $data['middle_initial']];
                $user->middle_initial = $data['middle_initial'];
            }

            if (isset($data['role'])) {
                $changes['role'] = ['old' => $user->role, 'new' => $data['role']];
                $user->role = $data['role'];
            }

            if (isset($data['is_active'])) {
                $changes['is_active'] = ['old' => $user->is_active, 'new' => $data['is_active']];
                $user->is_active = $data['is_active'];
            }

            if (isset($data['require_password_change'])) {
                $changes['require_password_change'] = ['old' => $user->require_password_change, 'new' => $data['require_password_change']];
                $user->require_password_change = $data['require_password_change'];
            }

            $user->save();

            // Log the action
            $this->logUserAction($adminId, 'user_updated', $user->id, [
                'changes' => $changes,
            ]);

            DB::commit();
            return $user;
        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }

    /**
     * Deactivate a user account (soft delete).
     *
     * @param int $userId
     * @param int $adminId
     * @return User
     * @throws \Exception
     */
    public function deactivateUser(int $userId, int $adminId): User
    {
        $user = User::findOrFail($userId);

        if (!$user->is_active) {
            throw new \Exception('User is already deactivated.');
        }

        DB::beginTransaction();
        try {
            $user->is_active = false;
            $user->save();

            // Log the action
            $this->logUserAction($adminId, 'user_deactivated', $user->id, [
                'username' => $user->username,
            ]);

            DB::commit();
            return $user;
        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }

    /**
     * Reset user password to default.
     *
     * @param int $userId
     * @param int $adminId
     * @return User
     * @throws \Exception
     */
    public function resetPasswordToDefault(int $userId, int $adminId): User
    {
        $user = User::findOrFail($userId);

        DB::beginTransaction();
        try {
            $user->password_hash = Hash::make(self::DEFAULT_PASSWORD);
            $user->require_password_change = true;
            $user->save();

            // Invalidate all existing tokens for security
            DB::table('auth_tokens')->where('user_id', $userId)->delete();

            // Log the action
            $this->logUserAction($adminId, 'password_reset', $user->id, [
                'username' => $user->username,
                'reset_to_default' => true,
            ]);

            DB::commit();
            return $user;
        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }

    /**
     * Reset user password (legacy method - kept for compatibility).
     *
     * @param int $userId
     * @param string $newPassword
     * @param bool $requireChange
     * @param int $adminId
     * @return User
     * @throws \Exception
     */
    public function resetPassword(int $userId, string $newPassword, bool $requireChange, int $adminId): User
    {
        $user = User::findOrFail($userId);

        DB::beginTransaction();
        try {
            $user->password_hash = Hash::make($newPassword);
            $user->require_password_change = $requireChange;
            $user->save();

            // Invalidate all existing tokens for security
            DB::table('auth_tokens')->where('user_id', $userId)->delete();

            // Log the action
            $this->logUserAction($adminId, 'password_reset', $user->id, [
                'username' => $user->username,
                'require_password_change' => $requireChange,
            ]);

            DB::commit();
            return $user;
        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }

    /**
     * Get all users with optional filters.
     *
     * @param array $filters
     * @return \Illuminate\Database\Eloquent\Collection
     */
    public function getUsers(array $filters = [])
    {
        $query = User::query();

        if (isset($filters['role'])) {
            $query->where('role', $filters['role']);
        }

        if (isset($filters['is_active'])) {
            $query->where('is_active', $filters['is_active']);
        }

        return $query->orderBy('created_at', 'desc')->get();
    }

    /**
     * Get user by ID.
     *
     * @param int $userId
     * @return User
     */
    public function getUser(int $userId): User
    {
        return User::findOrFail($userId);
    }

    /**
     * Get audit log for a specific user.
     *
     * @param int $userId
     * @return \Illuminate\Support\Collection
     */
    public function getUserAuditLog(int $userId)
    {
        return DB::table('audit_logs')
            ->where('entity_type', 'user')
            ->where('entity_id', $userId)
            ->orderBy('created_at', 'desc')
            ->get();
    }

    /**
     * Permanently delete a user from the database.
     * Only allowed for deactivated users.
     *
     * @param int $userId
     * @param int $adminId
     * @return void
     * @throws \Exception
     */
    public function permanentlyDeleteUser(int $userId, int $adminId): void
    {
        $user = User::findOrFail($userId);

        // Only allow deletion of deactivated users
        if ($user->is_active) {
            throw new \Exception('Cannot permanently delete an active user. Please deactivate the user first.');
        }

        // Prevent deleting yourself
        if ($userId === $adminId) {
            throw new \Exception('You cannot delete your own account.');
        }

        DB::beginTransaction();
        try {
            // Log the action before deletion
            $this->logUserAction($adminId, 'user_permanently_deleted', $user->id, [
                'username' => $user->username,
                'role' => $user->role,
                'first_name' => $user->first_name,
                'last_name' => $user->last_name,
            ]);

            // Delete the user (cascade will handle related data)
            $user->delete();

            DB::commit();
        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }

    /**
     * Log user management action to audit_logs table.
     *
     * @param int $adminId
     * @param string $action
     * @param int $userId
     * @param array $details
     * @return void
     */
    private function logUserAction(int $adminId, string $action, int $userId, array $details): void
    {
        DB::table('audit_logs')->insert([
            'user_id' => $adminId,
            'action' => $action,
            'entity_type' => 'user',
            'entity_id' => $userId,
            'details' => json_encode($details),
            'ip_address' => request()->ip(),
            'created_at' => now(),
        ]);
    }

    private function normalizeEmail(?string $email): ?string
    {
        $email = trim((string) $email);

        return $email === '' ? null : strtolower($email);
    }
}

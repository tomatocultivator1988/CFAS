<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Services\ScoreSummaryEmailService;
use App\Services\UserManagementService;
use Illuminate\Support\Str;

class UserController extends Controller
{
    protected UserManagementService $userService;
    protected ScoreSummaryEmailService $scoreSummaryEmailService;

    public function __construct(UserManagementService $userService, ScoreSummaryEmailService $scoreSummaryEmailService)
    {
        $this->userService = $userService;
        $this->scoreSummaryEmailService = $scoreSummaryEmailService;
    }

    /**
     * Get all users.
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function index(Request $request): JsonResponse
    {
        $filters = $request->only(['role', 'is_active']);
        $users = $this->userService->getUsers($filters);

        return response()->json([
            'users' => $users
        ], 200);
    }

    /**
     * Get a specific user.
     *
     * @param int $id
     * @return JsonResponse
     */
    public function show(int $id): JsonResponse
    {
        try {
            $user = $this->userService->getUser($id);

            return response()->json([
                'user' => $user
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => $e->getMessage()
            ], 404);
        }
    }

    /**
     * Create a new user.
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'username' => 'required|string|min:3|max:50|unique:users,username',
            'email' => 'required|email|max:255|unique:users,email',
            'first_name' => 'required|string|max:100',
            'last_name' => 'required|string|max:100',
            'middle_initial' => 'nullable|string|max:10',
            'role' => 'required|in:admin,reviewee',
        ]);

        try {
            $adminId = $request->user()->id;
            $user = $this->userService->createUser($request->all(), $adminId);

            return response()->json([
                'message' => 'User created successfully with default password.',
                'user' => $user
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'message' => $e->getMessage()
            ], 400);
        }
    }

    /**
     * Update a user.
     *
     * @param Request $request
     * @param int $id
     * @return JsonResponse
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $request->validate([
            'username' => 'string|min:3|max:50',
            'email' => 'nullable|email|max:255|unique:users,email,' . $id,
            'first_name' => 'string|max:100',
            'last_name' => 'string|max:100',
            'middle_initial' => 'nullable|string|max:10',
            'role' => 'in:admin,reviewee',
            'is_active' => 'boolean',
            'require_password_change' => 'boolean',
        ]);

        try {
            $adminId = $request->user()->id;
            $user = $this->userService->updateUser($id, $request->all(), $adminId);

            return response()->json([
                'message' => 'User updated successfully.',
                'user' => $user
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => $e->getMessage()
            ], 400);
        }
    }

    /**
     * Deactivate a user.
     *
     * @param Request $request
     * @param int $id
     * @return JsonResponse
     */
    public function destroy(Request $request, int $id): JsonResponse
    {
        try {
            $adminId = $request->user()->id;
            $user = $this->userService->deactivateUser($id, $adminId);

            return response()->json([
                'message' => 'User deactivated successfully.',
                'user' => $user
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => $e->getMessage()
            ], 400);
        }
    }

    /**
     * Permanently delete a user (only if already deactivated).
     *
     * @param Request $request
     * @param int $id
     * @return JsonResponse
     */
    public function permanentlyDelete(Request $request, int $id): JsonResponse
    {
        try {
            $adminId = $request->user()->id;
            $this->userService->permanentlyDeleteUser($id, $adminId);

            return response()->json([
                'message' => 'User permanently deleted successfully.'
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => $e->getMessage()
            ], 400);
        }
    }

    /**
     * Reset user password to default.
     *
     * @param Request $request
     * @param int $id
     * @return JsonResponse
     */
    public function resetPassword(Request $request, int $id): JsonResponse
    {
        try {
            $adminId = $request->user()->id;
            $user = $this->userService->resetPasswordToDefault($id, $adminId);

            return response()->json([
                'message' => 'Password reset to default successfully.',
                'user' => [
                    'id' => $user->id,
                    'username' => $user->username,
                    'require_password_change' => $user->require_password_change,
                ]
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => $e->getMessage()
            ], 400);
        }
    }

    /**
     * Get audit log for a user.
     *
     * @param int $id
     * @return JsonResponse
     */
    public function auditLog(int $id): JsonResponse
    {
        try {
            $logs = $this->userService->getUserAuditLog($id);

            return response()->json([
                'audit_logs' => $logs
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => $e->getMessage()
            ], 400);
        }
    }

    public function sendScoreSummary(Request $request, int $id): JsonResponse
    {
        try {
            $result = $this->scoreSummaryEmailService->sendSingle($id, (int) $request->user()->id);

            return response()->json([
                'success' => true,
                'message' => 'Score summary sent successfully.',
                'data' => [
                    'reviewee_id' => $result['reviewee_id'],
                    'email' => $result['email'],
                ],
            ], 200);
        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Active reviewee was not found.',
            ], 404);
        } catch (\InvalidArgumentException $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 422);
        } catch (\Throwable $e) {
            \Log::error('Send score summary failed', [
                'reviewee_id' => $id,
                'error' => $e->getMessage(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to send score summary. Please check SMTP settings.',
            ], 500);
        }
    }

    public function sendScoreSummaryBulk(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'user_ids' => 'nullable|array',
            'user_ids.*' => 'integer|exists:users,id',
            'search' => 'nullable|string|max:100',
        ]);

        $result = $this->scoreSummaryEmailService->sendBulk(
            $validated['user_ids'] ?? [],
            $validated['search'] ?? null,
            (int) $request->user()->id
        );

        return response()->json([
            'success' => true,
            'message' => 'Bulk score summary send completed.',
            'data' => $result,
        ], 200);
    }
}

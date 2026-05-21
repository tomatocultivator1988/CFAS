<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Services\AuthenticationService;
use Illuminate\Support\Facades\Cookie;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class AuthController extends Controller
{
    protected $authService;

    public function __construct(AuthenticationService $authService)
    {
        $this->authService = $authService;
    }

    /**
     * Login user.
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function login(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'username' => 'required|string',
            'password' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed.',
                'errors' => $validator->errors()
            ], 422);
        }

        $result = $this->authService->login(
            $request->input('username'),
            $request->input('password')
        );

        if (!$result) {
            return response()->json([
                'message' => 'Invalid credentials or account is inactive.'
            ], 401);
        }

        $cookieName = config('session.auth_cookie_name', 'auth_token');
        $cookieLifetimeMinutes = (int) config('session.lifetime', 30);
        $isSecure = (bool) config('session.secure', false) || $request->isSecure();

        return response()->json([
            'message' => 'Login successful.',
            // Token is still returned for backward compatibility.
            'data' => $result
        ], 200)->cookie(
            $cookieName,
            $result['token'],
            $cookieLifetimeMinutes,
            '/',
            config('session.domain'),
            $isSecure,
            true,
            false,
            config('session.same_site', 'lax')
        );
    }

    /**
     * Validate current session.
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function validateSession(Request $request): JsonResponse
    {
        $user = $request->user();

        return response()->json([
            'message' => 'Token is valid.',
            'user' => [
                'id' => $user->id,
                'username' => $user->username,
                'email' => $user->email,
                'first_name' => $user->first_name,
                'last_name' => $user->last_name,
                'role' => $user->role,
                'require_password_change' => $user->require_password_change,
            ]
        ], 200);
    }

    /**
     * Logout user.
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function logout(Request $request): JsonResponse
    {
        $cookieName = config('session.auth_cookie_name', 'auth_token');
        $token = $request->bearerToken() ?: $request->cookie($cookieName);

        if (!$token) {
            return response()->json([
                'message' => 'No token provided.'
            ], 400);
        }

        $this->authService->logout($token);

        return response()->json([
            'message' => 'Logout successful.'
        ], 200)->withCookie(Cookie::forget(
            $cookieName,
            '/',
            config('session.domain')
        ));
    }

    /**
     * Get current authenticated user.
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function me(Request $request): JsonResponse
    {
        $user = $request->user();

        return response()->json([
            'user' => [
                'id' => $user->id,
                'username' => $user->username,
                'email' => $user->email,
                'first_name' => $user->first_name,
                'last_name' => $user->last_name,
                'role' => $user->role,
                'is_active' => $user->is_active,
                'require_password_change' => $user->require_password_change,
                'last_login_at' => $user->last_login_at,
                'created_at' => $user->created_at,
            ]
        ], 200);
    }

    /**
     * Update the current user's email address.
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function updateEmail(Request $request): JsonResponse
    {
        $user = $request->user();
        $email = trim((string) $request->input('email', ''));
        $normalizedEmail = $email === '' ? null : strtolower($email);

        $validator = Validator::make(['email' => $normalizedEmail], [
            'email' => 'nullable|email|max:255|unique:users,email,' . $user->id,
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed.',
                'errors' => $validator->errors()
            ], 422);
        }

        $user->email = $normalizedEmail;
        $user->save();

        return response()->json([
            'message' => $normalizedEmail ? 'Email address saved successfully.' : 'Email address removed successfully.',
            'user' => [
                'id' => $user->id,
                'username' => $user->username,
                'email' => $user->email,
                'first_name' => $user->first_name,
                'last_name' => $user->last_name,
                'role' => $user->role,
                'is_active' => $user->is_active,
                'require_password_change' => $user->require_password_change,
                'last_login_at' => $user->last_login_at,
                'created_at' => $user->created_at,
            ]
        ], 200);
    }

    /**
     * Change user password.
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function changePassword(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'current_password' => 'required|string',
            'new_password' => 'required|string|min:6|different:current_password',
            'new_password_confirmation' => 'required|string|same:new_password',
        ], [
            'new_password.different' => 'New password must be different from the current password.',
            'new_password_confirmation.same' => 'Password confirmation does not match.',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed.',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = $request->user();

        // Verify current password
        if (!Hash::check($request->input('current_password'), $user->password_hash)) {
            return response()->json([
                'message' => 'Current password is incorrect.'
            ], 401);
        }

        // Check if new password is the default password
        if ($request->input('new_password') === 'password123') {
            return response()->json([
                'message' => 'You cannot use the default password. Please choose a different password.'
            ], 422);
        }

        // Update password
        $user->password_hash = $this->authService->hashPassword($request->input('new_password'));
        $user->require_password_change = false;
        $user->save();

        // Revoke all existing tokens after password change.
        $this->authService->revokeUserTokens($user->id);

        return response()->json([
            'message' => 'Password changed successfully. Please log in again.'
        ], 200);
    }
}

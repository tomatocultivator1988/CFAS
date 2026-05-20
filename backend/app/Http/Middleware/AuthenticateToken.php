<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;
use App\Services\AuthenticationService;

class AuthenticateToken
{
    protected $authService;

    public function __construct(AuthenticationService $authService)
    {
        $this->authService = $authService;
    }

    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $cookieName = config('session.auth_cookie_name', 'auth_token');
        $token = $request->bearerToken() ?: $request->cookie($cookieName);

        if (!$token) {
            return response()->json([
                'message' => 'Authentication token required.'
            ], 401);
        }

        $user = $this->authService->validateToken($token);

        if (!$user) {
            return response()->json([
                'message' => 'Invalid or expired token.'
            ], 401);
        }

        // Set authenticated user
        $request->setUserResolver(function () use ($user) {
            return $user;
        });

        return $next($request);
    }
}

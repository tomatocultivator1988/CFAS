<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Symfony\Component\HttpFoundation\Response;

class LogApiRequests
{
    /**
     * Handle an incoming request and log it.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        // Process the request
        $response = $next($request);

        // Log the request asynchronously (after response is sent)
        $this->logRequest($request, $response);

        return $response;
    }

    /**
     * Log the API request to the audit_logs table.
     *
     * @param Request $request
     * @param Response $response
     * @return void
     */
    private function logRequest(Request $request, Response $response): void
    {
        try {
            $user = $request->user();
            
            DB::table('audit_logs')->insert([
                'user_id' => $user ? $user->id : null,
                'action' => 'api_request',
                'entity_type' => 'api',
                'entity_id' => null,
                'details' => json_encode([
                    'method' => $request->method(),
                    'endpoint' => $request->path(),
                    'url' => $request->fullUrl(),
                    'ip' => $request->ip(),
                    'user_agent' => $request->userAgent(),
                    'status_code' => $response->getStatusCode(),
                ]),
                'ip_address' => $request->ip(),
                'created_at' => now(),
            ]);
        } catch (\Exception $e) {
            // Silently fail - don't break the request if logging fails
            \Log::error('Failed to log API request: ' . $e->getMessage());
        }
    }
}

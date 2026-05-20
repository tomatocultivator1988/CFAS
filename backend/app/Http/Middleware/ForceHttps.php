<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class ForceHttps
{
    /**
     * Handle an incoming request and enforce HTTPS.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        // Check if HTTPS enforcement is enabled
        if (!config('app.force_https', false)) {
            return $next($request);
        }

        // Check if request is not secure and not from localhost
        if (!$request->secure() && !$this->isLocalEnvironment($request)) {
            // Redirect to HTTPS
            return redirect()->secure($request->getRequestUri(), 301);
        }

        // Add security headers
        $response = $next($request);

        // Add HSTS header (HTTP Strict Transport Security)
        $response->headers->set('Strict-Transport-Security', 'max-age=31536000; includeSubDomains');

        // Add other security headers
        $response->headers->set('X-Content-Type-Options', 'nosniff');
        $response->headers->set('X-Frame-Options', 'SAMEORIGIN');
        $response->headers->set('X-XSS-Protection', '1; mode=block');
        $response->headers->set('Referrer-Policy', 'strict-origin-when-cross-origin');

        return $response;
    }

    /**
     * Check if request is from local environment.
     *
     * @param Request $request
     * @return bool
     */
    private function isLocalEnvironment(Request $request): bool
    {
        $localIps = ['127.0.0.1', '::1', 'localhost'];
        return in_array($request->ip(), $localIps) || 
               app()->environment('local', 'testing');
    }
}

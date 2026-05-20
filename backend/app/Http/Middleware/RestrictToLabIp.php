<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class RestrictToLabIp
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        // Get allowed IP ranges from config
        $allowedIps = array_values(array_filter(array_map(
            static fn ($ip) => trim((string) $ip),
            config('app.lab_ip_ranges', [])
        )));
        
        // In production, missing config should fail closed.
        if (app()->environment('production') && empty($allowedIps)) {
            return response()->json([
                'message' => 'Access denied. Lab IP restrictions are not configured.',
                'error' => 'LAB_IP_CONFIGURATION_MISSING'
            ], 403);
        }

        // In local/testing, allow all when no ranges are configured.
        if (empty($allowedIps)) {
            return $next($request);
        }

        $clientIp = $request->ip();

        // Allow local machine loopback during local/testing development.
        if (app()->environment(['local', 'testing']) && in_array($clientIp, ['127.0.0.1', '::1'], true)) {
            return $next($request);
        }

        // Check if client IP is in allowed ranges
        if ($this->isIpAllowed($clientIp, $allowedIps)) {
            return $next($request);
        }

        // IP not allowed - return 403 Forbidden
        return response()->json([
            'message' => 'Access denied. Exams can only be accessed from the lab environment.',
            'error' => 'IP_RESTRICTED'
        ], 403);
    }

    /**
     * Check if IP is in allowed ranges.
     *
     * @param string $ip
     * @param array $allowedRanges
     * @return bool
     */
    private function isIpAllowed(string $ip, array $allowedRanges): bool
    {
        foreach ($allowedRanges as $range) {
            // Check for exact IP match
            if ($ip === $range) {
                return true;
            }

            // Check for CIDR notation (e.g., 192.168.1.0/24)
            if (strpos($range, '/') !== false) {
                if ($this->ipInCidrRange($ip, $range)) {
                    return true;
                }
            }

            // Check for wildcard notation (e.g., 192.168.1.*)
            if (strpos($range, '*') !== false) {
                if ($this->ipMatchesWildcard($ip, $range)) {
                    return true;
                }
            }

            // Check for range notation (e.g., 192.168.1.1-192.168.1.100)
            if (strpos($range, '-') !== false) {
                if ($this->ipInRange($ip, $range)) {
                    return true;
                }
            }
        }

        return false;
    }

    /**
     * Check if IP is in CIDR range.
     *
     * @param string $ip
     * @param string $cidr
     * @return bool
     */
    private function ipInCidrRange(string $ip, string $cidr): bool
    {
        list($subnet, $mask) = explode('/', $cidr);
        
        $ipLong = ip2long($ip);
        $subnetLong = ip2long($subnet);
        $maskLong = -1 << (32 - (int)$mask);
        
        return ($ipLong & $maskLong) === ($subnetLong & $maskLong);
    }

    /**
     * Check if IP matches wildcard pattern.
     *
     * @param string $ip
     * @param string $pattern
     * @return bool
     */
    private function ipMatchesWildcard(string $ip, string $pattern): bool
    {
        $pattern = str_replace('.', '\.', $pattern);
        $pattern = str_replace('*', '\d+', $pattern);
        $pattern = '/^' . $pattern . '$/';
        
        return preg_match($pattern, $ip) === 1;
    }

    /**
     * Check if IP is in range.
     *
     * @param string $ip
     * @param string $range
     * @return bool
     */
    private function ipInRange(string $ip, string $range): bool
    {
        list($start, $end) = explode('-', $range);
        
        $ipLong = ip2long(trim($ip));
        $startLong = ip2long(trim($start));
        $endLong = ip2long(trim($end));
        
        return $ipLong >= $startLong && $ipLong <= $endLong;
    }
}

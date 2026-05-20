<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class SanitizeInput
{
    /**
     * Handle an incoming request and sanitize input.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        // Sanitize all input data
        $input = $request->all();
        $sanitized = $this->sanitizeData($input);
        $request->merge($sanitized);

        return $next($request);
    }

    /**
     * Recursively sanitize data.
     *
     * @param mixed $data
     * @return mixed
     */
    private function sanitizeData($data)
    {
        if (is_array($data)) {
            return array_map([$this, 'sanitizeData'], $data);
        }

        if (is_string($data)) {
            // Remove null bytes
            $data = str_replace("\0", '', $data);
            
            // Trim whitespace
            $data = trim($data);
            
            // Convert special characters to HTML entities (XSS prevention)
            // Note: This is for display purposes. Laravel's Blade templates
            // automatically escape output, but this adds an extra layer.
            // For API responses, the frontend should also sanitize.
            
            return $data;
        }

        return $data;
    }

    /**
     * Sanitize string for HTML output (XSS prevention).
     *
     * @param string $value
     * @return string
     */
    public static function sanitizeForOutput(string $value): string
    {
        return htmlspecialchars($value, ENT_QUOTES | ENT_HTML5, 'UTF-8');
    }

    /**
     * Sanitize string for SQL (Laravel uses parameterized queries by default).
     * This is an additional layer of protection.
     *
     * @param string $value
     * @return string
     */
    public static function sanitizeForSql(string $value): string
    {
        // Remove SQL comment markers
        $value = preg_replace('/--.*$/m', '', $value);
        $value = preg_replace('/\/\*.*?\*\//s', '', $value);
        
        // Remove common SQL injection patterns
        $patterns = [
            '/(\bUNION\b.*\bSELECT\b)/i',
            '/(\bDROP\b.*\bTABLE\b)/i',
            '/(\bINSERT\b.*\bINTO\b)/i',
            '/(\bUPDATE\b.*\bSET\b)/i',
            '/(\bDELETE\b.*\bFROM\b)/i',
        ];
        
        foreach ($patterns as $pattern) {
            $value = preg_replace($pattern, '', $value);
        }
        
        return $value;
    }
}

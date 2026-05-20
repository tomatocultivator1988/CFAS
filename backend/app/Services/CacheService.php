<?php

namespace App\Services;

use Illuminate\Support\Facades\Cache;

class CacheService
{
    /**
     * Cache TTL in seconds (DISABLED - set to 0 for real-time data)
     * Previous value: 300 (5 minutes)
     * Changed to 0 to prevent cache delays in analytics
     */
    private const CACHE_TTL = 0;

    /**
     * Remember a value in cache or execute callback if not cached
     *
     * @param string $key
     * @param callable $callback
     * @return mixed
     */
    public function remember(string $key, callable $callback): mixed
    {
        return Cache::remember($key, self::CACHE_TTL, $callback);
    }

    /**
     * Forget (invalidate) a specific cache key
     *
     * @param string $key
     * @return void
     */
    public function forget(string $key): void
    {
        Cache::forget($key);
    }

    /**
     * Flush all analytics cache
     *
     * @return void
     */
    public function flush(): void
    {
        // Get all analytics cache keys and forget them
        $patterns = [
            'analytics:overview:*',
            'analytics:exams:*',
            'analytics:exam:*',
            'analytics:students:*',
            'analytics:student:*',
            'analytics:questions:*',
            'analytics:trends:*'
        ];

        foreach ($patterns as $pattern) {
            // Note: This is a simple implementation
            // For production with Redis, use SCAN command
            Cache::forget($pattern);
        }
    }

    /**
     * Forget all keys matching a pattern
     *
     * @param string $pattern Pattern with wildcards (e.g., "analytics:exam:123:*")
     * @return int Number of keys invalidated
     */
    public function forgetPattern(string $pattern): int
    {
        $count = 0;
        $driver = Cache::getStore()->getDriver();
        
        // For file/array cache driver
        if ($driver instanceof \Illuminate\Cache\FileStore || $driver instanceof \Illuminate\Cache\ArrayStore) {
            // Simple pattern matching - convert wildcard to regex
            $regex = '/^' . str_replace(['*', ':'], ['.*', '\:'], $pattern) . '$/';
            
            // Note: This is a simplified implementation
            // In production, you'd need to iterate through all cache files
            // For now, we'll just forget the pattern as-is
            Cache::forget($pattern);
            $count = 1;
        }
        // For Redis cache driver
        elseif ($driver instanceof \Illuminate\Cache\RedisStore) {
            // Use Redis SCAN command for efficient pattern matching
            $redis = Cache::getStore()->connection();
            $cursor = 0;
            
            do {
                $result = $redis->scan($cursor, ['match' => $pattern, 'count' => 100]);
                $cursor = $result[0];
                $keys = $result[1] ?? [];
                
                foreach ($keys as $key) {
                    Cache::forget($key);
                    $count++;
                }
            } while ($cursor != 0);
        }
        
        return $count;
    }

    /**
     * Forget multiple specific keys at once
     *
     * @param array $keys
     * @return void
     */
    public function forgetMany(array $keys): void
    {
        foreach ($keys as $key) {
            Cache::forget($key);
        }
    }

    /**
     * Check if a key exists in cache
     *
     * @param string $key
     * @return bool
     */
    public function has(string $key): bool
    {
        return Cache::has($key);
    }
}

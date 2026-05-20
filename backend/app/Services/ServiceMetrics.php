<?php

namespace App\Services;

use DateTime;

class ServiceMetrics
{
    public int $totalRequests;
    public int $successfulRequests;
    public int $failedRequests;
    public float $averageResponseTime;
    public int $cacheHits;
    public int $cacheMisses;
    public DateTime $collectedAt;

    public function __construct(
        int $totalRequests = 0,
        int $successfulRequests = 0,
        int $failedRequests = 0,
        float $averageResponseTime = 0.0,
        int $cacheHits = 0,
        int $cacheMisses = 0
    ) {
        $this->totalRequests = $totalRequests;
        $this->successfulRequests = $successfulRequests;
        $this->failedRequests = $failedRequests;
        $this->averageResponseTime = $averageResponseTime;
        $this->cacheHits = $cacheHits;
        $this->cacheMisses = $cacheMisses;
        $this->collectedAt = new DateTime();
    }

    public function getSuccessRate(): float
    {
        if ($this->totalRequests === 0) {
            return 0.0;
        }
        return ($this->successfulRequests / $this->totalRequests) * 100;
    }

    public function getCacheHitRate(): float
    {
        $totalCacheRequests = $this->cacheHits + $this->cacheMisses;
        if ($totalCacheRequests === 0) {
            return 0.0;
        }
        return ($this->cacheHits / $totalCacheRequests) * 100;
    }

    public function toArray(): array
    {
        return [
            'total_requests' => $this->totalRequests,
            'successful_requests' => $this->successfulRequests,
            'failed_requests' => $this->failedRequests,
            'success_rate' => round($this->getSuccessRate(), 2),
            'average_response_time' => round($this->averageResponseTime, 3),
            'cache_hits' => $this->cacheHits,
            'cache_misses' => $this->cacheMisses,
            'cache_hit_rate' => round($this->getCacheHitRate(), 2),
            'collected_at' => $this->collectedAt->format('c'),
        ];
    }

    public function addRequest(bool $success, float $responseTime): void
    {
        $this->totalRequests++;
        if ($success) {
            $this->successfulRequests++;
        } else {
            $this->failedRequests++;
        }
        
        // Update average response time
        $this->averageResponseTime = (
            ($this->averageResponseTime * ($this->totalRequests - 1)) + $responseTime
        ) / $this->totalRequests;
    }

    public function addCacheHit(): void
    {
        $this->cacheHits++;
    }

    public function addCacheMiss(): void
    {
        $this->cacheMisses++;
    }
}
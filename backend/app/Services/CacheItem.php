<?php

namespace App\Services;

/**
 * CacheItem represents a cached item with metadata
 * 
 * Contains the cached value, creation time, expiration time,
 * and metadata for comprehensive cache item management.
 */
class CacheItem
{
    public function __construct(
        public readonly string $key,
        public readonly mixed $value,
        public readonly \DateTime $createdAt,
        public readonly \DateTime $expiresAt,
        public readonly array $metadata = []
    ) {}

    /**
     * Check if the cache item has expired
     * 
     * @return bool True if expired
     */
    public function isExpired(): bool
    {
        return new \DateTime() > $this->expiresAt;
    }

    /**
     * Get remaining TTL in seconds
     * 
     * @return int Remaining TTL (0 if expired)
     */
    public function getRemainingTtl(): int
    {
        if ($this->isExpired()) {
            return 0;
        }
        
        $now = new \DateTime();
        $diff = $this->expiresAt->getTimestamp() - $now->getTimestamp();
        
        return max(0, $diff);
    }

    /**
     * Refresh the cache item with new TTL
     * 
     * @param int $ttl New TTL in seconds
     * @return CacheItem New cache item with updated expiration
     */
    public function refresh(int $ttl): CacheItem
    {
        return new self(
            key: $this->key,
            value: $this->value,
            createdAt: $this->createdAt,
            expiresAt: new \DateTime('+' . $ttl . ' seconds'),
            metadata: array_merge($this->metadata, [
                'refreshed_at' => new \DateTime(),
                'original_ttl' => $this->metadata['ttl'] ?? null,
                'new_ttl' => $ttl
            ])
        );
    }

    /**
     * Get the age of the cache item in seconds
     * 
     * @return int Age in seconds
     */
    public function getAge(): int
    {
        $now = new \DateTime();
        return $now->getTimestamp() - $this->createdAt->getTimestamp();
    }

    /**
     * Get the size of the cached value
     * 
     * @return int Size in bytes
     */
    public function getSize(): int
    {
        return $this->metadata['size'] ?? strlen(serialize($this->value));
    }

    /**
     * Get the type of the cached value
     * 
     * @return string Value type
     */
    public function getType(): string
    {
        return $this->metadata['type'] ?? gettype($this->value);
    }

    /**
     * Check if the cache item is still fresh (not expired and not stale)
     * 
     * @param float $stalenessThreshold Staleness threshold (0.0 to 1.0)
     * @return bool True if fresh
     */
    public function isFresh(float $stalenessThreshold = 0.8): bool
    {
        if ($this->isExpired()) {
            return false;
        }
        
        $totalTtl = $this->expiresAt->getTimestamp() - $this->createdAt->getTimestamp();
        $remainingTtl = $this->getRemainingTtl();
        
        $freshnessRatio = $remainingTtl / $totalTtl;
        
        return $freshnessRatio >= $stalenessThreshold;
    }

    /**
     * Convert to array representation
     * 
     * @return array Array representation
     */
    public function toArray(): array
    {
        return [
            'key' => $this->key,
            'value' => $this->value,
            'created_at' => $this->createdAt->format('Y-m-d H:i:s'),
            'expires_at' => $this->expiresAt->format('Y-m-d H:i:s'),
            'metadata' => $this->metadata,
            'is_expired' => $this->isExpired(),
            'remaining_ttl' => $this->getRemainingTtl(),
            'age' => $this->getAge(),
            'size' => $this->getSize(),
            'type' => $this->getType(),
            'is_fresh' => $this->isFresh()
        ];
    }

    /**
     * Convert to JSON representation
     * 
     * @return string JSON representation
     */
    public function toJson(): string
    {
        return json_encode($this->toArray(), JSON_PRETTY_PRINT);
    }

    /**
     * Create a cache item from array data
     * 
     * @param array $data Array data
     * @return CacheItem Cache item instance
     */
    public static function fromArray(array $data): CacheItem
    {
        return new self(
            key: $data['key'],
            value: $data['value'],
            createdAt: new \DateTime($data['created_at']),
            expiresAt: new \DateTime($data['expires_at']),
            metadata: $data['metadata'] ?? []
        );
    }
}
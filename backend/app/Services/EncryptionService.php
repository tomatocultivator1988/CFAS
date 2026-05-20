<?php

namespace App\Services;

use Illuminate\Support\Facades\Crypt;

class EncryptionService
{
    /**
     * Encrypt sensitive data using AES-256.
     *
     * @param string|null $value
     * @return string|null
     */
    public function encrypt(?string $value): ?string
    {
        if ($value === null || $value === '') {
            return null;
        }

        try {
            return Crypt::encryptString($value);
        } catch (\Exception $e) {
            \Log::error('Encryption failed: ' . $e->getMessage());
            throw new \Exception('Failed to encrypt data.');
        }
    }

    /**
     * Decrypt sensitive data.
     *
     * @param string|null $value
     * @return string|null
     */
    public function decrypt(?string $value): ?string
    {
        if ($value === null || $value === '') {
            return null;
        }

        try {
            return Crypt::decryptString($value);
        } catch (\Exception $e) {
            \Log::error('Decryption failed: ' . $e->getMessage());
            throw new \Exception('Failed to decrypt data.');
        }
    }

    /**
     * Encrypt an array of values.
     *
     * @param array $values
     * @return array
     */
    public function encryptArray(array $values): array
    {
        return array_map(function ($value) {
            return is_string($value) ? $this->encrypt($value) : $value;
        }, $values);
    }

    /**
     * Decrypt an array of values.
     *
     * @param array $values
     * @return array
     */
    public function decryptArray(array $values): array
    {
        return array_map(function ($value) {
            return is_string($value) ? $this->decrypt($value) : $value;
        }, $values);
    }
}

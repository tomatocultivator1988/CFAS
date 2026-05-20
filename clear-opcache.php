<?php
// Clear PHP opcache

if (function_exists('opcache_reset')) {
    if (opcache_reset()) {
        echo "✓ Opcache cleared successfully\n";
    } else {
        echo "✗ Failed to clear opcache\n";
    }
} else {
    echo "ℹ Opcache not enabled\n";
}

// Also clear realpath cache
clearstatcache(true);
echo "✓ Stat cache cleared\n";

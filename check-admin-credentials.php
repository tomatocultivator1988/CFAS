<?php
/**
 * Check admin credentials in database
 */

// Database connection
$host = '127.0.0.1';
$dbname = 'review_center_exam';
$username = 'root';
$password = '';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo "=== ADMIN CREDENTIALS CHECK ===\n\n";
    
    // Get admin users
    $stmt = $pdo->prepare("SELECT id, username, email, role, is_active, created_at FROM users WHERE role = 'admin'");
    $stmt->execute();
    $admins = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    if (empty($admins)) {
        echo "❌ No admin users found!\n";
        exit(1);
    }
    
    echo "Found " . count($admins) . " admin user(s):\n\n";
    
    foreach ($admins as $admin) {
        echo "ID: {$admin['id']}\n";
        echo "Username: {$admin['username']}\n";
        echo "Email: {$admin['email']}\n";
        echo "Role: {$admin['role']}\n";
        echo "Active: " . ($admin['is_active'] ? 'Yes' : 'No') . "\n";
        echo "Created: {$admin['created_at']}\n";
        echo "---\n";
    }
    
    // Try to get password hash for first admin
    if (!empty($admins)) {
        $firstAdmin = $admins[0];
        $stmt = $pdo->prepare("SELECT password FROM users WHERE id = ?");
        $stmt->execute([$firstAdmin['id']]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        
        echo "\nPassword hash for '{$firstAdmin['username']}': " . substr($result['password'], 0, 20) . "...\n";
        
        // Test common passwords
        $testPasswords = ['admin', 'admin123', 'password', '123456', 'cfas123'];
        echo "\nTesting common passwords:\n";
        
        foreach ($testPasswords as $testPass) {
            if (password_verify($testPass, $result['password'])) {
                echo "✅ Password '$testPass' works for user '{$firstAdmin['username']}'!\n";
                break;
            } else {
                echo "❌ Password '$testPass' does not work\n";
            }
        }
    }
    
} catch (PDOException $e) {
    echo "❌ Database error: " . $e->getMessage() . "\n";
    exit(1);
}
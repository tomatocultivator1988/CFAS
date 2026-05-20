<?php
// Check admin user in database
$host = '127.0.0.1';
$db = 'review_center_exam';
$user = 'root';
$pass = '';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$db", $user, $pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo "✓ Connected to database\n\n";
    
    // Check if users table exists
    $stmt = $pdo->query("SHOW TABLES LIKE 'users'");
    if ($stmt->rowCount() == 0) {
        echo "✗ Users table does not exist!\n";
        exit(1);
    }
    
    echo "✓ Users table exists\n\n";
    
    // Get all users
    $stmt = $pdo->query("SELECT id, username, role, is_active, require_password_change FROM users");
    $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo "Users in database:\n";
    echo str_repeat("-", 80) . "\n";
    foreach ($users as $user) {
        echo "ID: {$user['id']}\n";
        echo "Username: {$user['username']}\n";
        echo "Role: {$user['role']}\n";
        echo "Active: " . ($user['is_active'] ? 'Yes' : 'No') . "\n";
        echo "Require Password Change: " . ($user['require_password_change'] ? 'Yes' : 'No') . "\n";
        echo str_repeat("-", 80) . "\n";
    }
    
    // Check admin user specifically
    $stmt = $pdo->prepare("SELECT * FROM users WHERE username = ?");
    $stmt->execute(['admin']);
    $admin = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($admin) {
        echo "\n✓ Admin user found!\n";
        echo "Username: {$admin['username']}\n";
        echo "Role: {$admin['role']}\n";
        echo "Active: " . ($admin['is_active'] ? 'Yes' : 'No') . "\n";
        echo "Password hash: " . substr($admin['password_hash'], 0, 30) . "...\n\n";
        
        // Test password verification
        $testPassword = 'password';
        if (password_verify($testPassword, $admin['password_hash'])) {
            echo "✓ Password 'password' is CORRECT for admin user\n";
        } else {
            echo "✗ Password 'password' is INCORRECT for admin user\n";
            echo "Trying 'password123'...\n";
            if (password_verify('password123', $admin['password_hash'])) {
                echo "✓ Password 'password123' is CORRECT for admin user\n";
            } else {
                echo "✗ Password 'password123' is also INCORRECT\n";
            }
        }
    } else {
        echo "\n✗ Admin user NOT found!\n";
        echo "Creating admin user...\n";
        
        $stmt = $pdo->prepare("INSERT INTO users (username, password_hash, role, is_active, require_password_change) VALUES (?, ?, ?, ?, ?)");
        $passwordHash = password_hash('password', PASSWORD_DEFAULT);
        $stmt->execute(['admin', $passwordHash, 'admin', 1, 0]);
        
        echo "✓ Admin user created with password: password\n";
    }
    
} catch (PDOException $e) {
    echo "✗ Database error: " . $e->getMessage() . "\n";
    exit(1);
}
?>

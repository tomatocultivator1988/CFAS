<?php
try {
    $pdo = new PDO('mysql:host=127.0.0.1;dbname=review_center_exam', 'root', '');
    
    echo "Checking database structure...\n";
    
    // Check if email column exists
    $stmt = $pdo->query("SHOW COLUMNS FROM users LIKE 'email'");
    if ($stmt->rowCount() == 0) {
        echo "Adding email column to users table...\n";
        $pdo->exec("ALTER TABLE users ADD COLUMN email VARCHAR(255) UNIQUE AFTER username");
        echo "✅ Email column added\n";
    } else {
        echo "✅ Email column already exists\n";
    }
    
    // Update existing admin user to have email
    $stmt = $pdo->prepare("SELECT * FROM users WHERE username = 'admin'");
    $stmt->execute();
    
    if ($stmt->rowCount() > 0) {
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        if (empty($user['email'])) {
            echo "Updating admin user with email...\n";
            $updateStmt = $pdo->prepare("UPDATE users SET email = 'admin@example.com' WHERE username = 'admin'");
            $updateStmt->execute();
            echo "✅ Admin user updated with email\n";
        } else {
            echo "✅ Admin user already has email: " . $user['email'] . "\n";
        }
    } else {
        echo "Creating admin user...\n";
        $hashedPassword = password_hash('password', PASSWORD_DEFAULT);
        $stmt = $pdo->prepare("INSERT INTO users (username, email, password_hash, role, first_name, last_name, is_active) VALUES (?, ?, ?, ?, ?, ?, ?)");
        $result = $stmt->execute(['admin', 'admin@example.com', $hashedPassword, 'admin', 'Admin', 'User', 1]);
        
        if ($result) {
            echo "✅ Admin user created successfully\n";
        } else {
            echo "❌ Failed to create admin user\n";
        }
    }
    
    // Show final user structure
    echo "\nFinal admin user details:\n";
    $stmt = $pdo->prepare("SELECT id, username, email, role, is_active FROM users WHERE username = 'admin'");
    $stmt->execute();
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    if ($user) {
        echo "ID: " . $user['id'] . "\n";
        echo "Username: " . $user['username'] . "\n";
        echo "Email: " . $user['email'] . "\n";
        echo "Role: " . $user['role'] . "\n";
        echo "Active: " . ($user['is_active'] ? 'Yes' : 'No') . "\n";
    }
    
} catch (Exception $e) {
    echo "❌ Database error: " . $e->getMessage() . "\n";
}
?>
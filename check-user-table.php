<?php
/**
 * Check user table structure and admin credentials
 */

// Database connection
$host = '127.0.0.1';
$dbname = 'review_center_exam';
$username = 'root';
$password = '';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo "=== USER TABLE STRUCTURE ===\n\n";
    
    // Get table structure
    $stmt = $pdo->prepare("DESCRIBE users");
    $stmt->execute();
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo "Users table columns:\n";
    foreach ($columns as $column) {
        echo "- {$column['Field']} ({$column['Type']}) - {$column['Null']} - {$column['Key']}\n";
    }
    
    echo "\n=== ADMIN USERS ===\n\n";
    
    // Get admin users with available columns
    $stmt = $pdo->prepare("SELECT * FROM users WHERE role = 'admin' LIMIT 5");
    $stmt->execute();
    $admins = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    if (empty($admins)) {
        echo "❌ No admin users found!\n";
        
        // Check all users
        $stmt = $pdo->prepare("SELECT * FROM users LIMIT 5");
        $stmt->execute();
        $allUsers = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        echo "\nAll users in database:\n";
        foreach ($allUsers as $user) {
            print_r($user);
            echo "---\n";
        }
        
        exit(1);
    }
    
    echo "Found " . count($admins) . " admin user(s):\n\n";
    
    foreach ($admins as $admin) {
        echo "Admin user data:\n";
        print_r($admin);
        echo "---\n";
    }
    
    // Test login with first admin
    if (!empty($admins)) {
        $firstAdmin = $admins[0];
        $testPasswords = ['admin', 'admin123', 'password', '123456', 'cfas123'];
        
        echo "\nTesting passwords for user '{$firstAdmin['username']}':\n";
        
        foreach ($testPasswords as $testPass) {
            if (password_verify($testPass, $firstAdmin['password'])) {
                echo "✅ Password '$testPass' works!\n";
                
                // Test API login
                echo "\nTesting API login...\n";
                $loginUrl = 'http://192.168.11.40/exam-backend/public/api/auth/login';
                $loginData = [
                    'username' => $firstAdmin['username'],
                    'password' => $testPass
                ];
                
                $ch = curl_init($loginUrl);
                curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
                curl_setopt($ch, CURLOPT_POST, true);
                curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($loginData));
                curl_setopt($ch, CURLOPT_HTTPHEADER, [
                    'Content-Type: application/json',
                    'Accept: application/json'
                ]);
                $response = curl_exec($ch);
                $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
                curl_close($ch);
                
                echo "API Login Status: $httpCode\n";
                echo "Response: $response\n";
                
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
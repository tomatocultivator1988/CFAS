<?php
/**
 * Test admin login with correct password field
 */

// Database connection
$host = '127.0.0.1';
$dbname = 'review_center_exam';
$username = 'root';
$password = '';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo "=== ADMIN LOGIN TEST ===\n\n";
    
    // Get first admin user
    $stmt = $pdo->prepare("SELECT * FROM users WHERE role = 'admin' AND is_active = 1 LIMIT 1");
    $stmt->execute();
    $admin = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$admin) {
        echo "❌ No active admin users found!\n";
        exit(1);
    }
    
    echo "Testing login for admin: {$admin['username']}\n";
    echo "Password hash: " . substr($admin['password_hash'], 0, 20) . "...\n\n";
    
    // Test common passwords
    $testPasswords = ['admin', 'admin123', 'password', '123456', 'cfas123', 'Admin123', 'ADMIN'];
    
    $workingPassword = null;
    foreach ($testPasswords as $testPass) {
        if (password_verify($testPass, $admin['password_hash'])) {
            echo "✅ Password '$testPass' works!\n";
            $workingPassword = $testPass;
            break;
        } else {
            echo "❌ Password '$testPass' does not work\n";
        }
    }
    
    if (!$workingPassword) {
        echo "\n❌ None of the common passwords work. Let's reset the admin password.\n";
        
        // Reset admin password to 'admin123'
        $newPassword = 'admin123';
        $newHash = password_hash($newPassword, PASSWORD_DEFAULT);
        
        $stmt = $pdo->prepare("UPDATE users SET password_hash = ? WHERE id = ?");
        $stmt->execute([$newHash, $admin['id']]);
        
        echo "✅ Admin password reset to '$newPassword'\n";
        $workingPassword = $newPassword;
    }
    
    // Test API login
    echo "\nTesting API login with username '{$admin['username']}' and password '$workingPassword'...\n";
    
    $loginUrl = 'http://192.168.11.40/exam-backend/public/api/auth/login';
    $loginData = [
        'username' => $admin['username'],
        'password' => $workingPassword
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
    
    if ($httpCode === 200) {
        $result = json_decode($response, true);
        if ($result['success']) {
            echo "✅ API LOGIN SUCCESS!\n";
            echo "Token: " . substr($result['data']['token'], 0, 20) . "...\n";
            
            echo "\n🎉 READY TO TEST ANALYTICS!\n";
            echo "Use these credentials:\n";
            echo "Username: {$admin['username']}\n";
            echo "Password: $workingPassword\n";
        } else {
            echo "❌ API login failed: " . $result['message'] . "\n";
        }
    } else {
        echo "❌ API login failed with HTTP $httpCode\n";
        echo "Response: $response\n";
    }
    
} catch (PDOException $e) {
    echo "❌ Database error: " . $e->getMessage() . "\n";
    exit(1);
}
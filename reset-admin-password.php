<?php
// Reset admin password to 'password'
$host = '127.0.0.1';
$db = 'review_center_exam';
$user = 'root';
$pass = '';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$db", $user, $pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo "Resetting admin password...\n\n";
    
    $newPassword = 'password';
    $passwordHash = password_hash($newPassword, PASSWORD_DEFAULT);
    
    $stmt = $pdo->prepare("UPDATE users SET password_hash = ?, require_password_change = 0 WHERE username = ?");
    $stmt->execute([$passwordHash, 'admin']);
    
    echo "✓ Admin password reset successfully!\n";
    echo "Username: admin\n";
    echo "Password: password\n\n";
    
    // Verify the password
    $stmt = $pdo->prepare("SELECT password_hash FROM users WHERE username = ?");
    $stmt->execute(['admin']);
    $admin = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (password_verify($newPassword, $admin['password_hash'])) {
        echo "✓ Password verification successful!\n";
    } else {
        echo "✗ Password verification failed!\n";
    }
    
} catch (PDOException $e) {
    echo "✗ Database error: " . $e->getMessage() . "\n";
    exit(1);
}
?>

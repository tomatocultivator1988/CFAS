<?php
// Remove email column from users table
$host = '127.0.0.1';
$db = 'review_center_exam';
$user = 'root';
$pass = '';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$db", $user, $pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo "Checking users table structure...\n\n";
    
    // Check if email column exists
    $stmt = $pdo->query("SHOW COLUMNS FROM users LIKE 'email'");
    $emailColumn = $stmt->fetch();
    
    if ($emailColumn) {
        echo "✓ Email column found\n";
        echo "Removing email column...\n";
        
        $pdo->exec("ALTER TABLE users DROP COLUMN email");
        
        echo "✓ Email column removed successfully!\n\n";
        
        // Show updated table structure
        echo "Updated table structure:\n";
        echo str_repeat("-", 80) . "\n";
        $stmt = $pdo->query("DESCRIBE users");
        $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        foreach ($columns as $column) {
            echo sprintf("%-20s %-15s %-10s\n", 
                $column['Field'], 
                $column['Type'], 
                $column['Null'] === 'YES' ? 'NULL' : 'NOT NULL'
            );
        }
        echo str_repeat("-", 80) . "\n";
    } else {
        echo "✓ Email column does not exist (already removed)\n";
    }
    
} catch (PDOException $e) {
    echo "✗ Database error: " . $e->getMessage() . "\n";
    exit(1);
}
?>

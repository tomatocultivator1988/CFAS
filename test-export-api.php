<?php
// Test the export API directly
require __DIR__ . '/backend/vendor/autoload.php';

$app = require_once __DIR__ . '/backend/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

// Simulate the export controller
$controller = new \App\Http\Controllers\ExportController();
$response = $controller->exportAllResults();

$data = json_decode($response->getContent(), true);

echo "=== EXPORT API RESPONSE ===\n\n";
echo "Success: " . ($data['success'] ? 'YES' : 'NO') . "\n";
echo "Count: " . $data['count'] . "\n\n";

if (!empty($data['data'])) {
    echo "=== FIRST 3 ROWS ===\n\n";
    foreach (array_slice($data['data'], 0, 3) as $row) {
        echo "Student: " . $row['Student Name'] . " (" . $row['Username'] . ")\n";
        foreach ($row as $key => $value) {
            if ($key !== 'Student Name' && $key !== 'Username') {
                echo "  {$key}: {$value}\n";
            }
        }
        echo "\n";
    }
} else {
    echo "NO DATA!\n";
}

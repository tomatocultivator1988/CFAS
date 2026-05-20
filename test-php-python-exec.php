<?php
// Test PHP executing Python directly

$scriptPath = __DIR__ . '/ml_model/predict_api.py';
$command = "python \"$scriptPath\" 17 2>&1";

echo "Command: $command\n\n";
echo "Executing...\n\n";

$output = shell_exec($command);

echo "Output:\n";
echo $output;
echo "\n\n";

// Try with full path to python
$pythonPath = trim(shell_exec('where python'));
echo "Python path: $pythonPath\n\n";

$command2 = "\"$pythonPath\" \"$scriptPath\" 17 2>&1";
echo "Command 2: $command2\n\n";

$output2 = shell_exec($command2);
echo "Output 2:\n";
echo $output2;

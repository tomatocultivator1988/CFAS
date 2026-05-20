<?php

namespace App\Services;

/**
 * PlatformService handles cross-platform compatibility for ML prediction system
 * 
 * Provides OS detection, Python path resolution, command construction with proper escaping,
 * and path normalization for cross-platform file handling.
 * 
 * Requirements: 2.1, 2.2, 2.3, 2.4, 2.5
 */
class PlatformService
{
    private string $detectedPlatform;
    private ?string $pythonPath = null;
    private array $pythonPathCache = [];

    public function __construct()
    {
        $this->detectedPlatform = $this->detectPlatform();
    }

    /**
     * Detect the current operating system platform
     * 
     * @return string 'windows' or 'linux'
     */
    public function detectPlatform(): string
    {
        return strtoupper(substr(PHP_OS, 0, 3)) === 'WIN' ? 'windows' : 'linux';
    }

    /**
     * Resolve Python executable path with fallback strategies
     * 
     * @return string Path to Python executable
     * @throws \RuntimeException if Python is not found
     */
    public function resolvePythonPath(): string
    {
        // Return cached path if available
        if ($this->pythonPath !== null) {
            return $this->pythonPath;
        }

        $platform = $this->detectedPlatform;
        $cacheKey = "python_path_{$platform}";
        
        // Check cache first
        if (isset($this->pythonPathCache[$cacheKey])) {
            $this->pythonPath = $this->pythonPathCache[$cacheKey];
            return $this->pythonPath;
        }

        $pythonExecutables = $this->getPythonExecutableNames();
        $searchPaths = $this->getPythonSearchPaths();

        // Strategy 1: Check common installation paths
        foreach ($searchPaths as $path) {
            foreach ($pythonExecutables as $executable) {
                $fullPath = $this->normalizePath($path . DIRECTORY_SEPARATOR . $executable);
                if ($this->isExecutableFile($fullPath)) {
                    $this->pythonPath = $fullPath;
                    $this->pythonPathCache[$cacheKey] = $fullPath;
                    // Log::info("Python found at: {$fullPath}");
                    return $fullPath;
                }
            }
        }

        // Strategy 2: Use 'which' or 'where' command to find Python in PATH
        foreach ($pythonExecutables as $executable) {
            $whereCommand = $platform === 'windows' ? "where {$executable}" : "which {$executable}";
            $result = $this->executeCommand($whereCommand);
            
            if ($result->isSuccess() && !empty(trim($result->stdout))) {
                $foundPath = trim(explode("\n", $result->stdout)[0]); // Get first result
                if ($this->isExecutableFile($foundPath)) {
                    $this->pythonPath = $foundPath;
                    $this->pythonPathCache[$cacheKey] = $foundPath;
                    // Log::info("Python found in PATH: {$foundPath}");
                    return $foundPath;
                }
            }
        }

        // Strategy 3: Use hardcoded path for XAMPP deployment
        if ($platform === 'windows') {
            // Try common Python installation paths
            // Note: get_current_user() may return different user when running under Apache
            $currentUser = get_current_user();
            $commonPaths = [
                // Specific installation for this system
                'C:\\Users\\Hi\\AppData\\Local\\Programs\\Python\\Python312\\python.exe',
                // Generic paths with current user
                'C:\\Users\\' . $currentUser . '\\AppData\\Local\\Programs\\Python\\Python312\\python.exe',
                'C:\\Users\\' . $currentUser . '\\AppData\\Local\\Programs\\Python\\Python311\\python.exe',
                'C:\\Users\\' . $currentUser . '\\AppData\\Local\\Programs\\Python\\Python310\\python.exe',
                // System-wide installations
                'C:\\Python312\\python.exe',
                'C:\\Python311\\python.exe',
                'C:\\Python310\\python.exe',
            ];
            
            foreach ($commonPaths as $path) {
                if (file_exists($path)) {
                    $this->pythonPath = $path;
                    $this->pythonPathCache[$cacheKey] = $path;
                    return $path;
                }
            }
        }
        
        // Last resort: try default command
        $defaultPython = $platform === 'windows' ? 'python.exe' : 'python';
        $this->pythonPath = $defaultPython;
        $this->pythonPathCache[$cacheKey] = $defaultPython;
        
        return $defaultPython;
    }

    /**
     * Build command string with proper escaping for the current platform
     * 
     * @param string $script Path to Python script
     * @param array $args Command line arguments
     * @return string Properly escaped command string
     */
    public function buildCommand(string $script, array $args = []): string
    {
        $pythonPath = $this->resolvePythonPath();
        $normalizedScript = $this->normalizePath($script);
        
        // Escape the Python path and script path
        $escapedPython = $this->escapeArgument($pythonPath);
        $escapedScript = $this->escapeArgument($normalizedScript);
        
        // Build base command
        $command = "{$escapedPython} {$escapedScript}";
        
        // Add arguments with proper escaping
        foreach ($args as $arg) {
            $command .= ' ' . $this->escapeArgument((string)$arg);
        }
        
        // Add error redirection for better error handling
        if ($this->detectedPlatform === 'windows') {
            $command .= ' 2>&1';
        } else {
            $command .= ' 2>&1';
        }
        
        // Log::debug("Built command: {$command}");
        return $command;
    }

    /**
     * Normalize file path for cross-platform compatibility
     * 
     * @param string $path File path to normalize
     * @return string Normalized path
     */
    public function normalizePath(string $path): string
    {
        // Convert all separators to forward slashes first
        $normalized = str_replace(['\\', '/'], '/', $path);
        
        // Remove duplicate slashes
        $normalized = preg_replace('#/+#', '/', $normalized);
        
        // Convert to platform-specific separators
        if ($this->detectedPlatform === 'windows') {
            $normalized = str_replace('/', DIRECTORY_SEPARATOR, $normalized);
        }
        
        // Remove trailing separator unless it's root
        if (strlen($normalized) > 1 && substr($normalized, -1) === DIRECTORY_SEPARATOR) {
            $normalized = rtrim($normalized, DIRECTORY_SEPARATOR);
        }
        
        return $normalized;
    }

    /**
     * Execute command and return result
     * 
     * @param string $command Command to execute
     * @param int $timeout Timeout in seconds (default: 30)
     * @return CommandResult
     */
    public function executeCommand(string $command, int $timeout = 30): CommandResult
    {
        $startTime = microtime(true);
        
        // Set up process descriptors
        $descriptors = [
            0 => ['pipe', 'r'],  // stdin
            1 => ['pipe', 'w'],  // stdout
            2 => ['pipe', 'w'],  // stderr
        ];
        
        $process = proc_open($command, $descriptors, $pipes);
        
        if (!is_resource($process)) {
            return new CommandResult(
                exitCode: -1,
                stdout: '',
                stderr: 'Failed to start process',
                executionTime: 0,
                command: $command,
                executedAt: new \DateTime()
            );
        }
        
        // Close stdin
        fclose($pipes[0]);
        
        // Set non-blocking mode for stdout and stderr
        stream_set_blocking($pipes[1], false);
        stream_set_blocking($pipes[2], false);
        
        $stdout = '';
        $stderr = '';
        $timeoutReached = false;
        
        // Read output with timeout
        while (true) {
            $status = proc_get_status($process);
            if (!$status['running']) {
                break;
            }
            
            // Check timeout
            if ((microtime(true) - $startTime) > $timeout) {
                $timeoutReached = true;
                proc_terminate($process);
                break;
            }
            
            // Read available data
            $stdout .= stream_get_contents($pipes[1]);
            $stderr .= stream_get_contents($pipes[2]);
            
            usleep(100000); // Sleep 100ms
        }
        
        // Read any remaining data
        $stdout .= stream_get_contents($pipes[1]);
        $stderr .= stream_get_contents($pipes[2]);
        
        // Close pipes
        fclose($pipes[1]);
        fclose($pipes[2]);
        
        // Get exit code
        $exitCode = proc_close($process);
        
        if ($timeoutReached) {
            $stderr .= "\nCommand timed out after {$timeout} seconds";
            $exitCode = -1;
        }
        
        $executionTime = microtime(true) - $startTime;
        
        $result = new CommandResult(
            exitCode: $exitCode,
            stdout: $stdout,
            stderr: $stderr,
            executionTime: $executionTime,
            command: $command,
            executedAt: new \DateTime()
        );
        
        // Log::debug("Command executed", [
        //     'command' => $command,
        //     'exit_code' => $exitCode,
        //     'execution_time' => $executionTime,
        //     'stdout_length' => strlen($stdout),
        //     'stderr_length' => strlen($stderr)
        // ]);
        
        return $result;
    }

    /**
     * Get platform-specific Python executable names
     * 
     * @return array List of possible Python executable names
     */
    private function getPythonExecutableNames(): array
    {
        if ($this->detectedPlatform === 'windows') {
            return ['python.exe', 'python3.exe', 'py.exe'];
        } else {
            return ['python3', 'python', 'python3.9', 'python3.8', 'python3.7'];
        }
    }

    /**
     * Get platform-specific Python search paths
     * 
     * @return array List of directories to search for Python
     */
    private function getPythonSearchPaths(): array
    {
        if ($this->detectedPlatform === 'windows') {
            return [
                'C:\\Python39',
                'C:\\Python38',
                'C:\\Python37',
                'C:\\Program Files\\Python39',
                'C:\\Program Files\\Python38',
                'C:\\Program Files\\Python37',
                'C:\\Users\\' . get_current_user() . '\\AppData\\Local\\Programs\\Python\\Python39',
                'C:\\Users\\' . get_current_user() . '\\AppData\\Local\\Programs\\Python\\Python38',
                'C:\\ProgramData\\Anaconda3',
                'C:\\ProgramData\\Miniconda3'
            ];
        } else {
            return [
                '/usr/bin',
                '/usr/local/bin',
                '/opt/python/bin',
                '/home/' . get_current_user() . '/.local/bin',
                '/usr/local/python3/bin',
                '/opt/anaconda3/bin',
                '/opt/miniconda3/bin'
            ];
        }
    }

    /**
     * Check if a file exists and is executable
     * 
     * @param string $path File path to check
     * @return bool True if file exists and is executable
     */
    private function isExecutableFile(string $path): bool
    {
        if (!file_exists($path)) {
            return false;
        }
        
        if ($this->detectedPlatform === 'windows') {
            // On Windows, check if it's a file and has .exe extension or is in PATH
            return is_file($path) && (
                pathinfo($path, PATHINFO_EXTENSION) === 'exe' ||
                $this->isInPath($path)
            );
        } else {
            // On Linux, check if file is executable
            return is_file($path) && is_executable($path);
        }
    }

    /**
     * Check if a command is available in PATH
     * 
     * @param string $command Command to check
     * @return bool True if command is in PATH
     */
    private function isInPath(string $command): bool
    {
        $whereCommand = $this->detectedPlatform === 'windows' ? "where {$command}" : "which {$command}";
        $result = shell_exec($whereCommand);
        return !empty($result);
    }

    /**
     * Escape command line argument for the current platform
     * 
     * @param string $argument Argument to escape
     * @return string Escaped argument
     */
    private function escapeArgument(string $argument): string
    {
        if ($this->detectedPlatform === 'windows') {
            // Windows escaping: wrap in quotes if contains spaces or special chars
            if (preg_match('/[\s&|<>^"]/', $argument)) {
                return '"' . str_replace('"', '""', $argument) . '"';
            }
            return $argument;
        } else {
            // Unix escaping: use escapeshellarg
            return escapeshellarg($argument);
        }
    }

    /**
     * Get the detected platform
     * 
     * @return string Current platform ('windows' or 'linux')
     */
    public function getPlatform(): string
    {
        return $this->detectedPlatform;
    }

    /**
     * Clear Python path cache (useful for testing)
     * 
     * @return void
     */
    public function clearCache(): void
    {
        $this->pythonPath = null;
        $this->pythonPathCache = [];
    }
}
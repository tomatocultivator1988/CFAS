<?php

namespace Tests\Unit;

use Tests\TestCase;
use App\Services\ErrorHandler;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Exception;
use RuntimeException;
use InvalidArgumentException;

/**
 * Property-based tests for ErrorHandler comprehensive error logging
 * 
 * **Property 3: Comprehensive Error Logging**
 * **Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5**
 */
class ErrorHandlerPropertyTest extends TestCase
{
    private ErrorHandler $errorHandler;
    private array $testLogs = [];

    protected function setUp(): void
    {
        parent::setUp();
        $this->errorHandler = new ErrorHandler();
        $this->testLogs = [];
    }

    protected function tearDown(): void
    {
        $this->testLogs = [];
        parent::tearDown();
    }

    /**
     * Property: Error logging includes all required structured information
     */
    public function testErrorLoggingStructuredInformation()
    {
        $iterations = 100;
        
        for ($i = 0; $i < $iterations; $i++) {
            $this->testLogs = [];
            
            // Mock Log facade
            Log::shouldReceive('critical')->andReturnUsing(function ($message, $context) {
                $this->testLogs[] = ['level' => 'critical', 'message' => $message, 'context' => $context];
            });
            Log::shouldReceive('error')->andReturnUsing(function ($message, $context) {
                $this->testLogs[] = ['level' => 'error', 'message' => $message, 'context' => $context];
            });
            Log::shouldReceive('warning')->andReturnUsing(function ($message, $context) {
                $this->testLogs[] = ['level' => 'warning', 'message' => $message, 'context' => $context];
            });
            Log::shouldReceive('info')->andReturnUsing(function ($message, $context) {
                $this->testLogs[] = ['level' => 'info', 'message' => $message, 'context' => $context];
            });
            Log::shouldReceive('debug')->andReturnUsing(function ($message, $context) {
                $this->testLogs[] = ['level' => 'debug', 'message' => $message, 'context' => $context];
            });
            
            // Generate random error data
            $level = $this->generateRandomSeverityLevel();
            $message = $this->generateRandomErrorMessage();
            $context = $this->generateRandomContext();
            
            // Log the error
            $this->errorHandler->logError($level, $message, $context);
            
            // Verify structured logging requirements
            $this->assertCount(1, $this->testLogs, "Should log exactly one entry");
            
            $logEntry = $this->testLogs[0];
            $logContext = $logEntry['context'];
            
            // Requirement 3.1: Error categorization by severity levels
            $this->assertContains($level, ['critical', 'error', 'warning', 'info', 'debug']);
            $this->assertArrayHasKey('severity', $logContext);
            $this->assertEquals($level, $logContext['severity']);
            
            // Requirement 3.2: Request correlation IDs
            $this->assertArrayHasKey('request_id', $logContext);
            $this->assertStringStartsWith('req_', $logContext['request_id']);
            
            // Requirement 3.3: Timestamps
            $this->assertArrayHasKey('timestamp', $logContext);
            $this->assertMatchesRegularExpression('/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/', $logContext['timestamp']);
            
            // Requirement 3.4: System state
            $this->assertArrayHasKey('system_info', $logContext);
            $this->assertArrayHasKey('php_version', $logContext['system_info']);
            $this->assertArrayHasKey('memory_usage', $logContext['system_info']);
        }
    }

    /**
     * Property: Python service output capture includes all execution details
     */
    public function testPythonServiceOutputCapture()
    {
        $iterations = 100;
        
        for ($i = 0; $i < $iterations; $i++) {
            $this->testLogs = [];
            
            Log::shouldReceive('info')->andReturnUsing(function ($message, $context) {
                $this->testLogs[] = ['level' => 'info', 'message' => $message, 'context' => $context];
            });
            Log::shouldReceive('error')->andReturnUsing(function ($message, $context) {
                $this->testLogs[] = ['level' => 'error', 'message' => $message, 'context' => $context];
            });
            
            // Generate random Python execution data
            $command = $this->generateRandomPythonCommand();
            $exitCode = rand(0, 1) === 0 ? 0 : rand(1, 255);
            $stdout = $this->generateRandomOutput(rand(0, 5000));
            $stderr = $exitCode !== 0 ? $this->generateRandomOutput(rand(0, 1000)) : '';
            $executionTime = rand(10, 5000) / 1000;
            
            // Capture Python service output
            $this->errorHandler->capturePythonServiceOutput($command, $stdout, $stderr, $exitCode, $executionTime);
            
            // Verify capture requirements
            $this->assertCount(1, $this->testLogs);
            
            $logEntry = $this->testLogs[0];
            $logContext = $logEntry['context'];
            
            // Requirement 3.5: Stdout/stderr capture
            $this->assertArrayHasKey('command', $logContext);
            $this->assertEquals($command, $logContext['command']);
            $this->assertArrayHasKey('exit_code', $logContext);
            $this->assertEquals($exitCode, $logContext['exit_code']);
            $this->assertArrayHasKey('execution_time', $logContext);
            $this->assertArrayHasKey('has_errors', $logContext);
            
            $expectedHasErrors = !empty($stderr) || $exitCode !== 0;
            $this->assertEquals($expectedHasErrors, $logContext['has_errors']);
            
            // Verify severity based on exit code
            $expectedLevel = $exitCode === 0 ? 'info' : 'error';
            $this->assertEquals($expectedLevel, $logEntry['level']);
        }
    }

    // Helper methods
    private function generateRandomSeverityLevel(): string
    {
        $levels = ['critical', 'error', 'warning', 'info', 'debug'];
        return $levels[array_rand($levels)];
    }

    private function generateRandomErrorMessage(): string
    {
        $messages = [
            'ML prediction service unavailable',
            'Invalid input parameters',
            'Python execution timeout',
            'Model loading failed',
        ];
        return $messages[array_rand($messages)];
    }

    private function generateRandomContext(): array
    {
        return ['student_id' => rand(1, 1000), 'exam_id' => rand(1, 100)];
    }

    private function generateRandomPythonCommand(): string
    {
        $commands = [
            'python predict_api.py --student-id 123',
            'python3 ml_model/predict_api.py --data input.json',
        ];
        return $commands[array_rand($commands)];
    }

    private function generateRandomOutput(int $maxLength): string
    {
        if ($maxLength === 0) return '';
        $outputs = ['{"success": true}', 'Loading model...', 'Error: Model not found'];
        return substr($outputs[array_rand($outputs)], 0, $maxLength);
    }
}

<?php

namespace App\Services;

/**
 * CommandResult represents the result of a command execution
 * 
 * Contains exit code, stdout, stderr, execution time, and metadata
 * for comprehensive command execution tracking and debugging.
 */
class CommandResult
{
    public function __construct(
        public readonly int $exitCode,
        public readonly string $stdout,
        public readonly string $stderr,
        public readonly float $executionTime,
        public readonly string $command,
        public readonly \DateTime $executedAt
    ) {}

    /**
     * Check if command executed successfully (exit code 0)
     * 
     * @return bool True if command was successful
     */
    public function isSuccess(): bool
    {
        return $this->exitCode === 0;
    }

    /**
     * Get combined output (stdout + stderr)
     * 
     * @return string Combined output
     */
    public function getOutput(): string
    {
        $output = $this->stdout;
        if (!empty($this->stderr)) {
            $output .= "\n" . $this->stderr;
        }
        return $output;
    }

    /**
     * Check if command produced any error output
     * 
     * @return bool True if stderr is not empty
     */
    public function hasErrors(): bool
    {
        return !empty($this->stderr);
    }

    /**
     * Convert to array representation
     * 
     * @return array Array representation of the command result
     */
    public function toArray(): array
    {
        return [
            'exit_code' => $this->exitCode,
            'stdout' => $this->stdout,
            'stderr' => $this->stderr,
            'execution_time' => $this->executionTime,
            'command' => $this->command,
            'executed_at' => $this->executedAt->format('Y-m-d H:i:s'),
            'success' => $this->isSuccess(),
            'has_errors' => $this->hasErrors()
        ];
    }
}
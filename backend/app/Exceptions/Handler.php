<?php

namespace App\Exceptions;

use Illuminate\Foundation\Exceptions\Handler as ExceptionHandler;
use Illuminate\Auth\AuthenticationException;
use Illuminate\Validation\ValidationException;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Symfony\Component\HttpKernel\Exception\HttpException;
use Illuminate\Support\Facades\Log;
use Throwable;

class Handler extends ExceptionHandler
{
    /**
     * The list of the inputs that are never flashed to the session on validation exceptions.
     *
     * @var array<int, string>
     */
    protected $dontFlash = [
        'current_password',
        'password',
        'password_confirmation',
        'new_password',
    ];

    /**
     * Register the exception handling callbacks for the application.
     */
    public function register(): void
    {
        $this->reportable(function (Throwable $e) {
            $request = app()->bound('request') ? request() : null;
            $isProduction = (string) env('APP_ENV', 'production') === 'production';
            $context = [
                'exception' => get_class($e),
                'message' => $e->getMessage(),
                'url' => $request ? $request->fullUrl() : null,
                'method' => $request ? $request->method() : null,
                'ip' => $request ? $request->ip() : null,
                'user_id' => app()->bound('auth') ? auth()->id() : null,
            ];

            // Avoid leaking stack traces and full paths in production logs.
            if (!$isProduction) {
                $context['file'] = $e->getFile();
                $context['line'] = $e->getLine();
                $context['trace'] = $e->getTraceAsString();
            }

            if (app()->bound('log')) {
                app('log')->error('Exception occurred', $context);
            } else {
                error_log('Exception occurred: ' . ($context['message'] ?? 'unknown'));
            }
        });
    }
    
    /**
     * Render an exception into an HTTP response.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Throwable  $exception
     * @return \Symfony\Component\HttpFoundation\Response
     *
     * @throws \Throwable
     */
    public function render($request, Throwable $exception)
    {
        // Handle API requests with JSON responses
        if ($request->expectsJson() || $request->is('api/*')) {
            return $this->handleApiException($request, $exception);
        }

        return parent::render($request, $exception);
    }
    
    /**
     * Handle API exceptions with user-friendly messages
     */
    protected function handleApiException($request, Throwable $exception)
    {
        $statusCode = 500;
        $message = 'An unexpected error occurred. Please try again later.';
        $errors = null;
        
        // Authentication exceptions
        if ($exception instanceof AuthenticationException) {
            $statusCode = 401;
            $message = 'Authentication required. Please log in.';
        }
        
        // Validation exceptions
        elseif ($exception instanceof ValidationException) {
            $statusCode = 422;
            $message = 'The given data was invalid.';
            $errors = $exception->errors();
        }
        
        // Model not found exceptions
        elseif ($exception instanceof ModelNotFoundException) {
            $statusCode = 404;
            $message = 'The requested resource was not found.';
        }
        
        // Not found exceptions
        elseif ($exception instanceof NotFoundHttpException) {
            $statusCode = 404;
            $message = 'The requested endpoint was not found.';
        }
        
        // HTTP exceptions
        elseif ($exception instanceof HttpException) {
            $statusCode = $exception->getStatusCode();
            $message = $exception->getMessage() ?: 'An error occurred.';
        }
        
        // Database exceptions
        elseif ($this->isDatabaseException($exception)) {
            $statusCode = 500;
            $message = 'A database error occurred. Please try again.';
            
            // Log database errors with more detail
            Log::error('Database exception', [
                'message' => $exception->getMessage(),
                'sql' => method_exists($exception, 'getSql') ? $exception->getSql() : null,
            ]);
        }
        
        // Build response
        $response = [
            'message' => $message,
            'status' => 'error',
        ];
        
        if ($errors) {
            $response['errors'] = $errors;
        }
        
        // Include exception details in development
        if (config('app.debug') && !app()->environment('production')) {
            $response['debug'] = [
                'exception' => get_class($exception),
                'message' => $exception->getMessage(),
                'file' => $exception->getFile(),
                'line' => $exception->getLine(),
                'trace' => collect($exception->getTrace())->take(5)->toArray(),
            ];
        }
        
        return response()->json($response, $statusCode);
    }
    
    /**
     * Check if exception is database-related
     */
    protected function isDatabaseException(Throwable $exception): bool
    {
        $databaseExceptions = [
            \Illuminate\Database\QueryException::class,
            \PDOException::class,
        ];
        
        foreach ($databaseExceptions as $type) {
            if ($exception instanceof $type) {
                return true;
            }
        }
        
        return false;
    }
    
    /**
     * Convert an authentication exception into a response.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Illuminate\Auth\AuthenticationException  $exception
     * @return \Symfony\Component\HttpFoundation\Response
     */
    protected function unauthenticated($request, AuthenticationException $exception)
    {
        if ($request->expectsJson() || $request->is('api/*')) {
            return response()->json([
                'message' => 'Authentication required. Please log in.',
                'status' => 'error',
            ], 401);
        }

        return redirect()->guest(route('login'));
    }
}

<?php

namespace App\Services;

use App\Mail\RevieweeScoreSummaryMail;
use App\Models\User;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Config;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;
use InvalidArgumentException;
use Symfony\Component\Mailer\Exception\TransportExceptionInterface;
use Throwable;

class ScoreSummaryEmailService
{
    private bool $mailConfigurationChecked = false;

    public function __construct(private SimpleXlsxService $xlsxService)
    {
    }

    public function sendSingle(int $revieweeId, int $adminId): array
    {
        $summary = $this->buildSummary($revieweeId);
        $this->ensureMailIsConfigured();
        $spreadsheet = $this->buildSpreadsheetAttachment($summary);

        try {
            Mail::to($summary['student']['email'])->send(new RevieweeScoreSummaryMail(
                $summary,
                $spreadsheet['binary'],
                $spreadsheet['filename']
            ));
        } catch (TransportExceptionInterface $e) {
            throw new InvalidArgumentException($this->friendlyTransportMessage($e->getMessage()), 0, $e);
        }

        $this->logMailAction($adminId, $revieweeId, 'score_summary_email_sent', [
            'email' => $summary['student']['email'],
            'exams_taken' => $summary['overall']['exams_taken'],
        ]);

        return [
            'reviewee_id' => $revieweeId,
            'email' => $summary['student']['email'],
            'attachment' => $spreadsheet['filename'],
            'summary' => $summary,
        ];
    }

    public function sendBulk(array $userIds, ?string $search, int $adminId): array
    {
        $users = $this->resolveBulkUsers($userIds, $search);
        $result = [
            'total' => $users->count(),
            'sent' => 0,
            'skipped_no_email' => 0,
            'skipped_no_scores' => 0,
            'failed' => 0,
            'failures' => [],
        ];

        $this->ensureMailIsConfigured();

        foreach ($users as $user) {
            try {
                $this->sendSingle((int) $user->id, $adminId);
                $result['sent']++;
            } catch (InvalidArgumentException $e) {
                if ($e->getMessage() === 'Reviewee has no email address.') {
                    $result['skipped_no_email']++;
                    continue;
                }

                if ($e->getMessage() === 'Reviewee has no completed score records.') {
                    $result['skipped_no_scores']++;
                    continue;
                }

                $this->recordFailure($result, $user, $e);
            } catch (Throwable $e) {
                $this->recordFailure($result, $user, $e);
            }
        }

        $this->logMailAction($adminId, 0, 'score_summary_bulk_email_sent', $result);

        return $result;
    }

    public function buildSummary(int $revieweeId): array
    {
        $user = User::query()
            ->where('id', $revieweeId)
            ->where('role', 'reviewee')
            ->where('is_active', true)
            ->first();

        if (!$user) {
            throw new ModelNotFoundException('Active reviewee was not found.');
        }

        if (!trim((string) ($user->email ?? ''))) {
            throw new InvalidArgumentException('Reviewee has no email address.');
        }

        $attempts = DB::table('exam_attempts as ea')
            ->join('exams as e', 'ea.exam_id', '=', 'e.id')
            ->where('ea.reviewee_id', $revieweeId)
            ->whereIn('ea.status', ['completed', 'auto_submitted'])
            ->where('e.is_deleted', 0)
            ->select(
                'e.id as exam_id',
                'e.title as exam_title',
                'e.category',
                DB::raw('COALESCE(e.passing_score, 90) as passing_score'),
                'ea.id as attempt_id',
                'ea.attempt_number',
                'ea.score',
                'ea.total_questions',
                DB::raw('ROUND(COALESCE(ea.percentage, CASE WHEN ea.total_questions > 0 THEN (ea.score / ea.total_questions) * 100 ELSE 0 END), 2) as percentage'),
                'ea.start_time',
                'ea.end_time'
            )
            ->orderBy('e.category')
            ->orderBy('e.title')
            ->orderBy('ea.start_time')
            ->get();

        if ($attempts->isEmpty()) {
            throw new InvalidArgumentException('Reviewee has no completed score records.');
        }

        $examResults = $attempts
            ->groupBy('exam_id')
            ->map(function (Collection $examAttempts) {
                $best = $examAttempts->sortByDesc('percentage')->first();
                $passingScore = (float) $best->passing_score;
                $percentage = (float) $best->percentage;

                return [
                    'exam_id' => (int) $best->exam_id,
                    'title' => $best->exam_title,
                    'category' => $best->category ?: 'Uncategorized',
                    'best_score' => (int) $best->score,
                    'total_questions' => (int) $best->total_questions,
                    'best_percentage' => round($percentage, 2),
                    'passing_score' => round($passingScore, 2),
                    'status' => $percentage >= $passingScore ? 'Passed' : 'Failed',
                    'attempt_count' => $examAttempts->count(),
                    'latest_attempt_date' => optional($examAttempts->sortByDesc('start_time')->first())->start_time,
                ];
            })
            ->values();

        $categories = $examResults
            ->groupBy('category')
            ->map(function (Collection $items, string $category) {
                $passed = $items->where('status', 'Passed')->count();
                $total = $items->count();

                return [
                    'category' => $category,
                    'exams_taken' => $total,
                    'passed' => $passed,
                    'failed' => $total - $passed,
                    'average_percentage' => round((float) $items->avg('best_percentage'), 2),
                    'status' => $passed === $total ? 'All Passed' : ($passed > 0 ? "{$passed}/{$total} Passed" : 'Needs Review'),
                    'exams' => $items->values()->all(),
                ];
            })
            ->values();

        $examsTaken = $examResults->count();
        $passed = $examResults->where('status', 'Passed')->count();

        return [
            'student' => [
                'id' => (int) $user->id,
                'name' => trim(($user->first_name ?? '') . ' ' . ($user->last_name ?? '')) ?: $user->username,
                'username' => $user->username,
                'email' => $user->email,
            ],
            'overall' => [
                'exams_taken' => $examsTaken,
                'passed' => $passed,
                'failed' => $examsTaken - $passed,
                'pass_rate' => $examsTaken > 0 ? round(($passed / $examsTaken) * 100, 2) : 0,
                'average_percentage' => round((float) $examResults->avg('best_percentage'), 2),
                'attempts_count' => $attempts->count(),
            ],
            'categories' => $categories->all(),
            'generated_at' => now()->format('F j, Y g:i A'),
        ];
    }

    private function resolveBulkUsers(array $userIds, ?string $search): Collection
    {
        $query = User::query()
            ->where('role', 'reviewee')
            ->where('is_active', true)
            ->orderBy('last_name')
            ->orderBy('first_name');

        if (!empty($userIds)) {
            $query->whereIn('id', array_map('intval', $userIds));
        } elseif ($search !== null && trim($search) !== '') {
            $term = '%' . strtolower(trim($search)) . '%';
            $query->where(function ($inner) use ($term) {
                $inner->whereRaw('LOWER(username) LIKE ?', [$term])
                    ->orWhereRaw('LOWER(first_name) LIKE ?', [$term])
                    ->orWhereRaw('LOWER(last_name) LIKE ?', [$term])
                    ->orWhereRaw('LOWER(email) LIKE ?', [$term]);
            });
        }

        return $query->get(['id', 'username', 'first_name', 'last_name', 'email']);
    }

    private function recordFailure(array &$result, User $user, Throwable $e): void
    {
        $result['failed']++;
        if (count($result['failures']) < 10) {
            $result['failures'][] = [
                'reviewee_id' => (int) $user->id,
                'username' => $user->username,
                'message' => $e->getMessage(),
            ];
        }

        Log::warning('Score summary email failed', [
            'reviewee_id' => $user->id,
            'error' => $e->getMessage(),
        ]);
    }

    private function buildSpreadsheetAttachment(array $summary): array
    {
        $rows = $this->buildSpreadsheetRows($summary);

        return [
            'filename' => $this->buildSpreadsheetFilename($summary),
            'binary' => $this->xlsxService->build($rows, 'Score Summary'),
        ];
    }

    private function buildSpreadsheetRows(array $summary): array
    {
        $rows = [
            ['CFAS REVIEW HUB - SCORE SUMMARY'],
            ['Generated At', $summary['generated_at']],
            [],
            ['STUDENT INFORMATION'],
            ['Student Name', $summary['student']['name']],
            ['Username', $summary['student']['username']],
            ['Email', $summary['student']['email']],
            [],
            ['OVERALL PERFORMANCE'],
            ['Exams Taken', $summary['overall']['exams_taken']],
            ['Passed', $summary['overall']['passed']],
            ['Failed', $summary['overall']['failed']],
            ['Pass Rate', number_format((float) $summary['overall']['pass_rate'], 2) . '%'],
            ['Average Score', number_format((float) $summary['overall']['average_percentage'], 2) . '%'],
            ['Total Attempts', $summary['overall']['attempts_count']],
            [],
            ['CATEGORY SUMMARY'],
            ['Category', 'Exams Taken', 'Passed', 'Failed', 'Average Score', 'Status'],
        ];

        foreach ($summary['categories'] as $category) {
            $rows[] = [
                $category['category'],
                $category['exams_taken'],
                $category['passed'],
                $category['failed'],
                number_format((float) $category['average_percentage'], 2) . '%',
                $category['status'],
            ];
        }

        $rows[] = [];
        $rows[] = ['DETAILED EXAM RESULTS'];
        $rows[] = ['Category', 'Exam', 'Best Score', 'Total Questions', 'Best Percentage', 'Passing Score', 'Status', 'Attempts', 'Latest Attempt'];

        foreach ($summary['categories'] as $category) {
            foreach ($category['exams'] as $exam) {
                $rows[] = [
                    $category['category'],
                    $exam['title'],
                    $exam['best_score'],
                    $exam['total_questions'],
                    number_format((float) $exam['best_percentage'], 2) . '%',
                    number_format((float) $exam['passing_score'], 2) . '%',
                    $exam['status'],
                    $exam['attempt_count'],
                    $exam['latest_attempt_date'] ?? '',
                ];
            }
        }

        return $rows;
    }

    private function buildSpreadsheetFilename(array $summary): string
    {
        $studentName = preg_replace('/[^A-Za-z0-9 _-]+/', '', (string) $summary['student']['name']);
        $studentName = trim((string) $studentName);

        if ($studentName === '') {
            $studentName = 'reviewee';
        }

        return "CFAS Score Summary - {$studentName}.xlsx";
    }

    private function ensureMailIsConfigured(): void
    {
        if ($this->mailConfigurationChecked) {
            return;
        }

        $mailer = strtolower($this->mailConfigValue(Config::get('mail.default', 'smtp')));

        if (in_array($mailer, ['array', 'log'], true)) {
            $this->mailConfigurationChecked = true;
            return;
        }

        $smtp = (array) Config::get('mail.mailers.smtp', []);
        $host = strtolower($this->mailConfigValue($smtp['host'] ?? ''));
        $username = $this->mailConfigValue($smtp['username'] ?? '');
        $password = $this->mailConfigValue($smtp['password'] ?? '');
        $fromAddress = $this->mailConfigValue(Config::get('mail.from.address', ''));

        if (in_array($host, ['mailpit', 'mailhog'], true)) {
            throw new InvalidArgumentException(
                'Email is still configured for a local test inbox. For Gmail, set MAIL_HOST=smtp.gmail.com, MAIL_PORT=587, MAIL_ENCRYPTION=tls, MAIL_USERNAME to your Gmail address, MAIL_PASSWORD to a Google App Password, and restart the backend.'
            );
        }

        if ($host === '') {
            throw new InvalidArgumentException('Email is missing MAIL_HOST. For Gmail, use MAIL_HOST=smtp.gmail.com.');
        }

        if ($host === 'smtp.gmail.com') {
            if ($username === '' || $password === '') {
                throw new InvalidArgumentException('Gmail SMTP needs MAIL_USERNAME and MAIL_PASSWORD. Use your Gmail address for MAIL_USERNAME and a Google App Password for MAIL_PASSWORD.');
            }

            if ($fromAddress === '' || in_array(strtolower($fromAddress), ['hello@example.com', 'no-reply@example.com'], true)) {
                throw new InvalidArgumentException('Set MAIL_FROM_ADDRESS to the same Gmail address used in MAIL_USERNAME.');
            }
        }

        if ($fromAddress === '' || filter_var($fromAddress, FILTER_VALIDATE_EMAIL) === false) {
            throw new InvalidArgumentException('Email is missing a valid MAIL_FROM_ADDRESS.');
        }

        $this->mailConfigurationChecked = true;
    }

    private function friendlyTransportMessage(string $message): string
    {
        $lowerMessage = strtolower($message);

        if (str_contains($lowerMessage, 'mailpit') || str_contains($lowerMessage, 'mailhog') || str_contains($lowerMessage, 'getaddrinfo')) {
            return 'Email is still pointing at a local test mail server. Update MAIL_HOST to smtp.gmail.com and use Gmail SMTP credentials.';
        }

        if (str_contains($lowerMessage, '535') || str_contains($lowerMessage, 'authentication') || str_contains($lowerMessage, 'username and password')) {
            return 'Gmail rejected SMTP authentication. Use your Gmail address and a Google App Password, not your normal Gmail password.';
        }

        if (str_contains($lowerMessage, 'connection could not be established') || str_contains($lowerMessage, 'timed out')) {
            return 'Could not connect to the email server. Check MAIL_HOST, MAIL_PORT, MAIL_ENCRYPTION, and your internet connection.';
        }

        return 'Email server could not send the score summary. Check Gmail SMTP settings and try again.';
    }

    private function mailConfigValue(mixed $value): string
    {
        $normalized = trim((string) $value);

        return strtolower($normalized) === 'null' ? '' : $normalized;
    }

    private function logMailAction(int $adminId, int $revieweeId, string $action, array $details): void
    {
        DB::table('audit_logs')->insert([
            'user_id' => $adminId,
            'action' => $action,
            'entity_type' => 'user',
            'entity_id' => $revieweeId > 0 ? $revieweeId : null,
            'details' => json_encode($details),
            'ip_address' => request()->ip(),
            'created_at' => now(),
        ]);
    }
}

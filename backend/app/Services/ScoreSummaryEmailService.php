<?php

namespace App\Services;

use App\Mail\RevieweeScoreSummaryMail;
use App\Models\User;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;
use InvalidArgumentException;
use Throwable;

class ScoreSummaryEmailService
{
    public function sendSingle(int $revieweeId, int $adminId): array
    {
        $summary = $this->buildSummary($revieweeId);

        Mail::to($summary['student']['email'])->send(new RevieweeScoreSummaryMail($summary));

        $this->logMailAction($adminId, $revieweeId, 'score_summary_email_sent', [
            'email' => $summary['student']['email'],
            'exams_taken' => $summary['overall']['exams_taken'],
        ]);

        return [
            'reviewee_id' => $revieweeId,
            'email' => $summary['student']['email'],
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

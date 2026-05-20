<?php

namespace App\Services;

use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use RuntimeException;
use Symfony\Component\Process\Process;

class MlPredictiveService
{
    private array $pythonCommand;
    private string $scriptPath;

    public function __construct()
    {
        $this->pythonCommand = $this->resolvePythonCommand();
        $this->scriptPath = base_path('ml/predictive_model.py');
    }

    public function runPrediction(string $timeFilter = 'all', string $model = 'random_forest'): array
    {
        $dateRange = $this->getDateRangeFromFilter($timeFilter);
        $attempts = DB::table('exam_attempts as ea')
            ->join('exams as e', 'ea.exam_id', '=', 'e.id')
            ->join('users as u', 'ea.reviewee_id', '=', 'u.id')
            ->select(
                'ea.id',
                'ea.reviewee_id',
                'ea.exam_id',
                'ea.percentage',
                'ea.start_time',
                'e.passing_score',
                DB::raw("CONCAT(u.first_name, ' ', u.last_name) as student_name")
            )
            ->where('ea.status', 'completed')
            ->where('u.role', 'reviewee')
            ->where('u.is_active', 1)
            ->where('ea.start_time', '>=', $dateRange['start'])
            ->where('ea.start_time', '<=', $dateRange['end'])
            ->orderBy('ea.reviewee_id', 'ASC')
            ->orderBy('ea.start_time', 'ASC')
            ->get();

        $grouped = $attempts->groupBy('reviewee_id');
        $trainingSamples = [];
        $predictionSamples = [];
        $studentContext = [];

        foreach ($grouped as $studentId => $records) {
            $items = $records->values();
            $totalAttempts = $items->count();
            if ($totalAttempts === 0) {
                continue;
            }

            $studentName = (string)($items->first()->student_name ?? 'Unknown');

            if ($totalAttempts >= 2) {
                $history = $items->slice(0, $totalAttempts - 1)->values();
                $latest = $items->last();
                $trainingSamples[] = [
                    'student_id' => (int)$studentId,
                    'features' => $this->buildFeatures($history),
                    'label' => ((float)$latest->percentage >= (float)$latest->passing_score) ? 1 : 0
                ];
            }

            $features = $this->buildFeatures($items);
            $predictionSamples[] = [
                'student_id' => (int)$studentId,
                'student_name' => $studentName,
                'features' => $features
            ];

            $latestScore = (float)($items->last()->percentage ?? 0);
            $avgScore = round((float)$items->avg('percentage'), 2);
            $avgPassingScore = round((float)$items->avg('passing_score'), 2);
            $actualPassRate = $totalAttempts > 0
                ? round(($items->filter(fn($row) => (float)$row->percentage >= (float)$row->passing_score)->count() / $totalAttempts) * 100, 2)
                : 0.0;

            $studentContext[(int)$studentId] = [
                'studentId' => (int)$studentId,
                'studentName' => $studentName,
                'totalAttempts' => $totalAttempts,
                'latestScore' => round($latestScore, 2),
                'averageScore' => $avgScore,
                'actualPassRate' => $actualPassRate,
                'averagePassingScore' => $avgPassingScore
            ];
        }

        $payload = [
            'model' => $model,
            'training_samples' => $trainingSamples,
            'prediction_samples' => $predictionSamples
        ];

        if (!file_exists($this->scriptPath)) {
            Log::warning('ML script not found, using heuristic fallback', [
                'scriptPath' => $this->scriptPath
            ]);
            $rawResult = $this->buildFallbackResult($payload, $model, 'ml_script_not_found');
        } else {
            try {
                $rawResult = $this->runPythonModel($payload);
            } catch (\Throwable $error) {
                Log::warning('ML python execution failed, using heuristic fallback', [
                    'error' => $error->getMessage()
                ]);
                $rawResult = $this->buildFallbackResult($payload, $model, $error->getMessage());
            }
        }

        $predictions = collect($rawResult['predictions'] ?? [])
            ->map(function($prediction) use ($studentContext) {
                $studentId = (int)($prediction['student_id'] ?? 0);
                $context = $studentContext[$studentId] ?? [
                    'studentId' => $studentId,
                    'studentName' => 'Unknown',
                    'totalAttempts' => 0,
                    'latestScore' => 0,
                    'averageScore' => 0,
                    'actualPassRate' => 0,
                    'averagePassingScore' => 75
                ];

                return array_merge($context, [
                    'predictedPassProbability' => (float)($prediction['pass_probability'] ?? 0),
                    'predictedFailProbability' => (float)($prediction['fail_probability'] ?? 0),
                    'riskLevel' => (string)($prediction['risk_level'] ?? 'Medium'),
                    'modelUsed' => (string)($prediction['model_used'] ?? 'ensemble'),
                    'logisticProbability' => (float)($prediction['logistic_probability'] ?? 0),
                    'randomForestProbability' => (float)($prediction['random_forest_probability'] ?? 0)
                ]);
            })
            ->sortByDesc('predictedFailProbability')
            ->values()
            ->toArray();

        return [
            'model' => $rawResult['model'] ?? $model,
            'trainedAt' => now()->toIso8601String(),
            'timeFilter' => $timeFilter,
            'training' => [
                'samples' => count($trainingSamples),
                'studentsEvaluated' => count($predictionSamples)
            ],
            'metrics' => $rawResult['metrics'] ?? [],
            'students' => $predictions
        ];
    }

    private function buildFallbackResult(array $payload, string $requestedModel, string $reason): array
    {
        $trainingSamples = $payload['training_samples'] ?? [];
        $predictionSamples = $payload['prediction_samples'] ?? [];
        $labels = collect($trainingSamples)->map(fn($sample) => (int)($sample['label'] ?? 0));
        $totalLabels = $labels->count();
        $positiveLabels = $labels->sum();
        $baselineRate = $totalLabels > 0 ? ($positiveLabels / $totalLabels) * 100 : 50.0;
        $baselineProbability = $this->clampProbability($baselineRate);

        $predictions = collect($predictionSamples)->map(function ($sample) use ($baselineProbability) {
            $studentId = (int)($sample['student_id'] ?? 0);
            $features = $sample['features'] ?? [];
            $passRate = (float)($features['pass_rate'] ?? $baselineProbability);
            $avgScore = (float)($features['avg_score'] ?? $baselineProbability);
            $trend = (float)($features['score_trend'] ?? 0.0);
            $heuristic = (0.5 * $passRate) + (0.45 * $avgScore) + (0.05 * ($trend + 50));
            $probability = $this->clampProbability($heuristic);

            return [
                'student_id' => $studentId,
                'pass_probability' => $probability,
                'fail_probability' => $this->clampProbability(100 - $probability),
                'risk_level' => $this->riskLevelFromProbability($probability),
                'model_used' => 'heuristic',
                'logistic_probability' => $probability,
                'random_forest_probability' => $probability
            ];
        })->values()->toArray();

        return [
            'success' => true,
            'model' => $requestedModel,
            'metrics' => [
                'model_type' => 'heuristic_fallback',
                'training_samples' => $totalLabels,
                'class_balance_pass_rate' => $baselineProbability,
                'accuracy' => $baselineProbability,
                'precision' => $baselineProbability,
                'recall' => $baselineProbability,
                'f1' => $baselineProbability,
                'auc' => 50.0,
                'fallback_reason' => $reason
            ],
            'predictions' => $predictions
        ];
    }

    private function buildFeatures($records): array
    {
        $attemptCount = $records->count();
        $scores = $records->pluck('percentage')
            ->map(fn($value) => (float)$value)
            ->values();

        $avgScore = $attemptCount > 0 ? (float)$scores->avg() : 0.0;
        $minScore = $attemptCount > 0 ? (float)$scores->min() : 0.0;
        $maxScore = $attemptCount > 0 ? (float)$scores->max() : 0.0;
        $lastScore = $attemptCount > 0 ? (float)$scores->last() : 0.0;
        $recentSlice = $scores->slice(-3);
        $recentAvg = $recentSlice->count() > 0 ? (float)$recentSlice->avg() : $avgScore;
        $firstScore = $attemptCount > 0 ? (float)$scores->first() : 0.0;
        $trend = $lastScore - $firstScore;
        $avgPassingScore = $attemptCount > 0 ? (float)$records->avg('passing_score') : 75.0;
        $passCount = $records->filter(fn($row) => (float)$row->percentage >= (float)$row->passing_score)->count();
        $passRate = $attemptCount > 0 ? ($passCount / $attemptCount) * 100 : 0.0;
        $uniqueExamCount = (int)$records->pluck('exam_id')->unique()->count();

        $variance = 0.0;
        if ($attemptCount > 0) {
            foreach ($scores as $score) {
                $variance += pow($score - $avgScore, 2);
            }
            $variance /= $attemptCount;
        }
        $stdDev = sqrt($variance);

        $firstDate = $attemptCount > 0 ? Carbon::parse($records->first()->start_time) : now();
        $lastDate = $attemptCount > 0 ? Carbon::parse($records->last()->start_time) : now();
        $daysSpan = max(1, $firstDate->diffInDays($lastDate) + 1);

        return [
            'attempt_count' => (float)$attemptCount,
            'avg_score' => round($avgScore, 4),
            'min_score' => round($minScore, 4),
            'max_score' => round($maxScore, 4),
            'latest_score' => round($lastScore, 4),
            'recent_avg_score' => round($recentAvg, 4),
            'score_trend' => round($trend, 4),
            'score_stddev' => round($stdDev, 4),
            'pass_rate' => round($passRate, 4),
            'avg_passing_score' => round($avgPassingScore, 4),
            'unique_exam_count' => (float)$uniqueExamCount,
            'days_span' => (float)$daysSpan
        ];
    }

    private function runPythonModel(array $payload): array
    {
        $process = new Process([...$this->pythonCommand, $this->scriptPath]);
        $process->setInput(json_encode($payload, JSON_THROW_ON_ERROR));
        $process->setTimeout(180);
        $process->run();

        if (!$process->isSuccessful()) {
            throw new RuntimeException(trim($process->getErrorOutput()) ?: 'Python process failed');
        }

        $decoded = json_decode($process->getOutput(), true);
        if (!is_array($decoded)) {
            throw new RuntimeException('Invalid ML model output');
        }

        if (!($decoded['success'] ?? false)) {
            $message = (string)($decoded['message'] ?? 'ML model execution failed');
            throw new RuntimeException($message);
        }

        return $decoded;
    }

    private function resolvePythonCommand(): array
    {
        $configuredBinary = trim((string) env('ML_PYTHON_BIN', ''));
        if ($configuredBinary !== '') {
            return [$configuredBinary];
        }

        $candidates = [
            ['python'],
            ['python3'],
        ];

        if (PHP_OS_FAMILY === 'Windows') {
            $candidates[] = ['py', '-3'];

            $localAppData = getenv('LOCALAPPDATA');
            if ($localAppData) {
                $pythonHomes = glob($localAppData . DIRECTORY_SEPARATOR . 'Programs' . DIRECTORY_SEPARATOR . 'Python' . DIRECTORY_SEPARATOR . 'Python*' . DIRECTORY_SEPARATOR . 'python.exe') ?: [];
                rsort($pythonHomes, SORT_NATURAL);
                foreach ($pythonHomes as $pythonHome) {
                    array_unshift($candidates, [$pythonHome]);
                }
            }
        }

        foreach ($candidates as $candidate) {
            if ($this->isPythonUsable($candidate)) {
                return $candidate;
            }
        }

        return ['python'];
    }

    private function isPythonUsable(array $command): bool
    {
        try {
            $process = new Process([...$command, '--version']);
            $process->setTimeout(10);
            $process->run();

            return $process->isSuccessful();
        } catch (\Throwable) {
            return false;
        }
    }

    private function getDateRangeFromFilter(string $timeFilter): array
    {
        $end = now();
        
        $start = match($timeFilter) {
            '7days' => now()->subDays(7),
            '30days' => now()->subDays(30),
            '3months' => now()->subMonths(3),
            'all' => now()->subYears(10),
            default => now()->subYears(10)
        };
        
        return [
            'start' => $start->startOfDay(),
            'end' => $end->endOfDay()
        ];
    }

    private function clampProbability(float $value): float
    {
        return round(max(0, min(100, $value)), 2);
    }

    private function riskLevelFromProbability(float $passProbability): string
    {
        if ($passProbability >= 75) {
            return 'Low';
        }

        if ($passProbability >= 45) {
            return 'Medium';
        }

        return 'High';
    }
}

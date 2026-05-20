<?php

namespace App\Services;

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Carbon\Carbon;

class AnalyticsService
{
    /**
     * Calculate overview metrics
     *
     * @param string $timeFilter
     * @return array
     */
    public function calculateOverviewMetrics(string $timeFilter): array
    {
        $dateRange = $this->getDateRangeFromFilter($timeFilter);
        
        // Query 1: Total active exams
        $totalExams = DB::table('exams')
            ->where('status', 'active')
            ->where('is_deleted', 0)
            ->count();
        
        // Query 2: Total completed attempts within time filter
        $totalAttempts = DB::table('exam_attempts')
            ->where('status', 'completed')
            ->where('start_time', '>=', $dateRange['start'])
            ->where('start_time', '<=', $dateRange['end'])
            ->count();
        
        // Query 3: Active reviewees (distinct reviewee_id) within time filter
        $activeReviewees = DB::table('exam_attempts')
            ->where('status', 'completed')
            ->where('start_time', '>=', $dateRange['start'])
            ->where('start_time', '<=', $dateRange['end'])
            ->distinct('reviewee_id')
            ->count('reviewee_id');
        
        // Query 4: Overall average score within time filter
        $overallAverage = DB::table('exam_attempts')
            ->where('status', 'completed')
            ->where('start_time', '>=', $dateRange['start'])
            ->where('start_time', '<=', $dateRange['end'])
            ->avg('percentage');
        
        // Handle null average (no attempts)
        $overallAverage = $overallAverage !== null ? round($overallAverage, 2) : 0;
        
        return [
            'totalExams' => $totalExams,
            'totalAttempts' => $totalAttempts,
            'activeReviewees' => $activeReviewees,
            'overallAverage' => $overallAverage
        ];
    }

    /**
     * Get exam performance list with pagination and sorting
     *
     * @param string $timeFilter
     * @param string $sortBy
     * @param string $order
     * @param int $page
     * @return array
     */
    public function getExamPerformanceList(string $timeFilter, string $sortBy, string $order, int $page): array
    {
        $dateRange = $this->getDateRangeFromFilter($timeFilter);
        $perPage = 50;
        $offset = ($page - 1) * $perPage;
        
        // Validate sortBy parameter
        $validSortFields = ['attempts' => 'total_attempts', 'avgScore' => 'average_score', 'passRate' => 'pass_rate'];
        $sortField = $validSortFields[$sortBy] ?? 'total_attempts';
        
        // Validate order parameter
        $sortOrder = strtoupper($order) === 'ASC' ? 'ASC' : 'DESC';
        
        // Get total count for pagination
        $totalCount = DB::table('exams')
            ->where('status', 'active')
            ->where('is_deleted', 0)
            ->count();
        
        // Main query with exam performance metrics
        $exams = DB::table('exams as e')
            ->leftJoin('exam_attempts as ea', function($join) use ($dateRange) {
                $join->on('e.id', '=', 'ea.exam_id')
                     ->where('ea.status', '=', 'completed')
                     ->where('ea.start_time', '>=', $dateRange['start'])
                     ->where('ea.start_time', '<=', $dateRange['end']);
            })
            ->select(
                'e.id',
                'e.title',
                'e.category',
                'e.passing_score',
                DB::raw('COUNT(ea.id) as total_attempts'),
                DB::raw('COALESCE(AVG(ea.percentage), 0) as average_score'),
                DB::raw('COALESCE(
                    SUM(CASE WHEN ea.percentage >= e.passing_score THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(ea.id), 0),
                    0
                ) as pass_rate')
            )
            ->where('e.status', 'active')
            ->where('e.is_deleted', 0)
            ->groupBy('e.id', 'e.title', 'e.category', 'e.passing_score')
            ->orderByRaw("{$sortField} {$sortOrder}")
            ->limit($perPage)
            ->offset($offset)
            ->get();
        
        // Format results
        $formattedExams = $exams->map(function($exam) {
            return [
                'id' => $exam->id,
                'title' => $exam->title,
                'category' => $exam->category,
                'totalAttempts' => (int)$exam->total_attempts,
                'averageScore' => round($exam->average_score, 2),
                'passRate' => round($exam->pass_rate, 2),
                'passingScore' => (int)$exam->passing_score
            ];
        })->toArray();
        
        $totalPages = ceil($totalCount / $perPage);
        
        return [
            'exams' => $formattedExams,
            'pagination' => [
                'currentPage' => $page,
                'totalPages' => $totalPages,
                'perPage' => $perPage,
                'total' => $totalCount
            ]
        ];
    }

    /**
     * Get score distribution for an exam
     *
     * @param int $examId
     * @param string $timeFilter
     * @return array
     */
    public function getExamScoreDistribution(int $examId, string $timeFilter): array
    {
        $dateRange = $this->getDateRangeFromFilter($timeFilter);
        
        // Get exam details
        $exam = DB::table('exams')
            ->select('id', 'title', 'passing_score')
            ->where('id', $examId)
            ->where('is_deleted', 0)
            ->first();
        
        if (!$exam) {
            return [
                'examId' => $examId,
                'examTitle' => '',
                'passingScore' => 75,
                'scoreDistribution' => [],
                'averageScore' => 0
            ];
        }
        
        // Get average score for this exam
        $averageScore = DB::table('exam_attempts')
            ->where('exam_id', $examId)
            ->where('status', 'completed')
            ->where('start_time', '>=', $dateRange['start'])
            ->where('start_time', '<=', $dateRange['end'])
            ->whereNotNull('percentage')
            ->avg('percentage');
        
        $averageScore = $averageScore !== null ? round($averageScore, 2) : 0;
        
        // Get score distribution grouped into 10-point ranges
        $distribution = DB::table('exam_attempts')
            ->select(
                DB::raw("CASE 
                    WHEN percentage BETWEEN 0 AND 10 THEN '0-10'
                    WHEN percentage BETWEEN 11 AND 20 THEN '11-20'
                    WHEN percentage BETWEEN 21 AND 30 THEN '21-30'
                    WHEN percentage BETWEEN 31 AND 40 THEN '31-40'
                    WHEN percentage BETWEEN 41 AND 50 THEN '41-50'
                    WHEN percentage BETWEEN 51 AND 60 THEN '51-60'
                    WHEN percentage BETWEEN 61 AND 70 THEN '61-70'
                    WHEN percentage BETWEEN 71 AND 80 THEN '71-80'
                    WHEN percentage BETWEEN 81 AND 90 THEN '81-90'
                    WHEN percentage BETWEEN 91 AND 100 THEN '91-100'
                END as score_range"),
                DB::raw('COUNT(*) as count')
            )
            ->where('exam_id', $examId)
            ->where('status', 'completed')
            ->where('start_time', '>=', $dateRange['start'])
            ->where('start_time', '<=', $dateRange['end'])
            ->whereNotNull('percentage')
            ->groupBy('score_range')
            ->orderByRaw("FIELD(score_range, '0-10', '11-20', '21-30', '31-40', '41-50', '51-60', '61-70', '71-80', '81-90', '91-100')")
            ->get();
        
        // Ensure all ranges are present (even with 0 count)
        $allRanges = ['0-10', '11-20', '21-30', '31-40', '41-50', '51-60', '61-70', '71-80', '81-90', '91-100'];
        $distributionMap = [];
        
        foreach ($distribution as $item) {
            $distributionMap[$item->score_range] = (int)$item->count;
        }
        
        $formattedDistribution = [];
        foreach ($allRanges as $range) {
            $formattedDistribution[] = [
                'range' => $range,
                'count' => $distributionMap[$range] ?? 0
            ];
        }
        
        return [
            'examId' => $examId,
            'examTitle' => $exam->title,
            'passingScore' => (int)$exam->passing_score,
            'scoreDistribution' => $formattedDistribution,
            'averageScore' => $averageScore
        ];
    }

    /**
     * Get student performance list with filtering and pagination
     *
     * @param string $timeFilter
     * @param string $level
     * @param int $page
     * @return array
     */
    public function getStudentPerformanceList(string $timeFilter, string $level, int $page): array
    {
        $dateRange = $this->getDateRangeFromFilter($timeFilter);
        $perPage = 50;
        $offset = ($page - 1) * $perPage;
        
        // Calculate overall system average for classification
        $systemAverage = DB::table('exam_attempts')
            ->where('status', 'completed')
            ->where('start_time', '>=', $dateRange['start'])
            ->where('start_time', '<=', $dateRange['end'])
            ->avg('percentage') ?? 0;
        
        // Build base query
        $query = DB::table('users as u')
            ->leftJoin('exam_attempts as ea', function($join) use ($dateRange) {
                $join->on('u.id', '=', 'ea.reviewee_id')
                     ->where('ea.status', '=', 'completed')
                     ->where('ea.start_time', '>=', $dateRange['start'])
                     ->where('ea.start_time', '<=', $dateRange['end']);
            })
            ->leftJoin('exams as e', 'ea.exam_id', '=', 'e.id')
            ->select(
                'u.id',
                DB::raw("CONCAT(u.first_name, ' ', u.last_name) as name"),
                DB::raw('COUNT(ea.id) as total_attempts'),
                DB::raw('COALESCE(AVG(ea.percentage), 0) as average_score'),
                DB::raw('COALESCE(
                    SUM(CASE WHEN ea.percentage >= COALESCE(e.passing_score, 75) THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(ea.id), 0),
                    0
                ) as pass_rate')
            )
            ->where('u.role', 'reviewee')
            ->where('u.is_active', 1)
            ->groupBy('u.id', 'u.first_name', 'u.last_name');
        
        // Get all students with their metrics first
        $allStudents = $query->get();
        
        // Classify performance levels
        $students = $allStudents->map(function($student) use ($systemAverage) {
            $avgScore = $student->average_score ?? 0;
            
            if ($avgScore < $systemAverage) {
                $performanceLevel = 'struggling';
            } elseif ($avgScore >= $systemAverage * 1.2) {
                $performanceLevel = 'top';
            } else {
                $performanceLevel = 'average';
            }
            
            return [
                'id' => $student->id,
                'name' => $student->name,
                'totalAttempts' => (int)$student->total_attempts,
                'averageScore' => round($avgScore, 2),
                'passRate' => round($student->pass_rate ?? 0, 2),
                'completionRate' => round($student->pass_rate ?? 0, 2),
                'performanceLevel' => $performanceLevel
            ];
        });
        
        // Filter by performance level if specified
        if ($level !== 'all') {
            $students = $students->filter(function($student) use ($level) {
                return $student['performanceLevel'] === $level;
            })->values();
        }
        
        // Sort by average score descending
        $students = $students->sortByDesc('averageScore')->values();
        
        // Paginate
        $total = $students->count();
        $totalPages = ceil($total / $perPage);
        $paginatedStudents = $students->slice($offset, $perPage)->values()->toArray();
        
        return [
            'students' => $paginatedStudents,
            'pagination' => [
                'currentPage' => $page,
                'totalPages' => $totalPages,
                'perPage' => $perPage,
                'total' => $total
            ]
        ];
    }

    /**
     * Get student trend data over time
     *
     * @param int $studentId
     * @param string $timeFilter
     * @return array
     */
    public function getStudentTrendData(int $studentId, string $timeFilter): array
    {
        $dateRange = $this->getDateRangeFromFilter($timeFilter);
        $interval = $this->getGroupByInterval($timeFilter);
        
        // Get student name
        $student = DB::table('users')
            ->select(DB::raw("CONCAT(first_name, ' ', last_name) as name"))
            ->where('id', $studentId)
            ->where('role', 'reviewee')
            ->first();
        
        if (!$student) {
            return [
                'studentId' => $studentId,
                'studentName' => '',
                'trendData' => []
            ];
        }
        
        // Get trend data based on interval
        $dateFormat = match($interval) {
            'day' => '%Y-%m-%d',
            'week' => '%Y-%u',
            'month' => '%Y-%m',
            default => '%Y-%m-%d'
        };
        
        $trendData = DB::table('exam_attempts')
            ->select(
                DB::raw("DATE_FORMAT(start_time, '{$dateFormat}') as date"),
                DB::raw('AVG(percentage) as average_score')
            )
            ->where('reviewee_id', $studentId)
            ->where('status', 'completed')
            ->where('start_time', '>=', $dateRange['start'])
            ->where('start_time', '<=', $dateRange['end'])
            ->groupBy('date')
            ->orderBy('date', 'ASC')
            ->get();
        
        $formattedTrendData = $trendData->map(function($item) {
            return [
                'date' => $item->date,
                'score' => round($item->average_score, 2)
            ];
        })->toArray();

        $attempts = DB::table('exam_attempts as ea')
            ->join('exams as e', 'ea.exam_id', '=', 'e.id')
            ->select(
                'ea.id',
                'ea.exam_id',
                'ea.attempt_number',
                'ea.score',
                'ea.total_questions',
                'ea.percentage',
                'ea.status',
                'ea.start_time',
                'ea.end_time',
                'e.title as exam_title',
                'e.category as exam_category',
                'e.passing_score',
                DB::raw('CASE WHEN ea.percentage >= e.passing_score THEN 1 ELSE 0 END as is_passed')
            )
            ->where('ea.reviewee_id', $studentId)
            ->where('ea.status', 'completed')
            ->where('ea.start_time', '>=', $dateRange['start'])
            ->where('ea.start_time', '<=', $dateRange['end'])
            ->orderBy('ea.start_time', 'DESC')
            ->get();

        $totalAttempts = $attempts->count();
        $passedAttempts = $attempts->where('is_passed', 1)->count();
        $failedAttempts = $totalAttempts - $passedAttempts;
        $passRate = $totalAttempts > 0 ? round(($passedAttempts / $totalAttempts) * 100, 2) : 0;
        $averageScore = $totalAttempts > 0 ? round($attempts->avg('percentage') ?? 0, 2) : 0;
        $latestScore = $totalAttempts > 0 ? round($attempts->first()->percentage ?? 0, 2) : 0;
        $examsTaken = $attempts->pluck('exam_id')->unique()->count();
        $averagePassingScore = $totalAttempts > 0 ? round($attempts->avg('passing_score') ?? 75, 2) : 75;

        $orderedAttempts = $attempts->reverse()->values();
        $scores = $orderedAttempts->pluck('percentage')
            ->filter(fn($score) => $score !== null)
            ->map(fn($score) => (float)$score)
            ->values();

        $trendSlope = 0.0;
        $predictedNextScore = $latestScore;
        $confidence = 0.35;
        $passProbability = 0.5;

        if ($scores->count() >= 2) {
            $recentScores = $scores->slice(-min(5, $scores->count()))->values();
            $diffs = [];
            for ($i = 1; $i < $recentScores->count(); $i++) {
                $diffs[] = $recentScores[$i] - $recentScores[$i - 1];
            }

            $trendSlope = !empty($diffs) ? (array_sum($diffs) / count($diffs)) : 0.0;
            $predictedNextScore = max(0, min(100, round($latestScore + $trendSlope, 2)));

            $mean = $recentScores->avg();
            $variance = 0.0;
            foreach ($recentScores as $value) {
                $variance += pow($value - $mean, 2);
            }
            $variance = $recentScores->count() > 0 ? $variance / $recentScores->count() : 0.0;
            $stdDev = sqrt($variance);
            $stabilityFactor = max(0.2, min(1, 1 - ($stdDev / 35)));
            $sampleFactor = min(1, $scores->count() / 8);
            $confidence = round(max(0.2, min(0.95, (0.45 * $sampleFactor) + (0.55 * $stabilityFactor))), 2);

            $margin = $predictedNextScore - $averagePassingScore;
            $z = ($margin / 8) * max(0.65, $confidence);
            $passProbability = 1 / (1 + exp(-$z));
        } elseif ($scores->count() === 1) {
            $predictedNextScore = $latestScore;
            $margin = $predictedNextScore - $averagePassingScore;
            $passProbability = 1 / (1 + exp(-($margin / 10)));
            $confidence = 0.3;
        }

        $passProbabilityPct = round(max(0, min(100, $passProbability * 100)), 2);
        $failProbabilityPct = round(100 - $passProbabilityPct, 2);
        $riskLevel = $passProbabilityPct >= 75 ? 'Low' : ($passProbabilityPct >= 45 ? 'Medium' : 'High');

        $categoryProgress = $attempts
            ->groupBy('exam_category')
            ->map(function($items, $category) {
                $categoryTotal = $items->count();
                $categoryPassed = $items->where('is_passed', 1)->count();
                $categoryAverage = round($items->avg('percentage') ?? 0, 2);
                $categoryPassRate = $categoryTotal > 0 ? round(($categoryPassed / $categoryTotal) * 100, 2) : 0;

                return [
                    'category' => $category ?: 'Uncategorized',
                    'totalAttempts' => $categoryTotal,
                    'passedAttempts' => $categoryPassed,
                    'failedAttempts' => $categoryTotal - $categoryPassed,
                    'averageScore' => $categoryAverage,
                    'passRate' => $categoryPassRate
                ];
            })
            ->sortByDesc('totalAttempts')
            ->values()
            ->toArray();

        $recentAttempts = $attempts
            ->take(15)
            ->map(function($attempt) {
                return [
                    'attemptId' => (int)$attempt->id,
                    'examId' => (int)$attempt->exam_id,
                    'examTitle' => $attempt->exam_title,
                    'category' => $attempt->exam_category,
                    'attemptNumber' => (int)$attempt->attempt_number,
                    'score' => $attempt->score !== null ? (int)$attempt->score : null,
                    'totalQuestions' => (int)$attempt->total_questions,
                    'percentage' => round($attempt->percentage ?? 0, 2),
                    'passingScore' => (int)$attempt->passing_score,
                    'isPassed' => (bool)$attempt->is_passed,
                    'status' => $attempt->status,
                    'startTime' => $attempt->start_time,
                    'endTime' => $attempt->end_time
                ];
            })
            ->values()
            ->toArray();
        
        return [
            'studentId' => $studentId,
            'studentName' => $student->name,
            'trendData' => $formattedTrendData,
            'summary' => [
                'totalAttempts' => $totalAttempts,
                'examsTaken' => $examsTaken,
                'passedAttempts' => $passedAttempts,
                'failedAttempts' => $failedAttempts,
                'passRate' => $passRate,
                'averageScore' => $averageScore,
                'latestScore' => $latestScore
            ],
            'predictiveAnalysis' => [
                'predictedNextScore' => round($predictedNextScore, 2),
                'averagePassingScore' => $averagePassingScore,
                'trendSlope' => round($trendSlope, 2),
                'passProbability' => $passProbabilityPct,
                'failProbability' => $failProbabilityPct,
                'confidence' => round($confidence * 100, 2),
                'riskLevel' => $riskLevel
            ],
            'categoryProgress' => $categoryProgress,
            'recentAttempts' => $recentAttempts
        ];
    }

    /**
     * Get top 10 performers by average score
     *
     * @param string $timeFilter
     * @return array
     */
    public function getTopPerformers(string $timeFilter): array
    {
        $dateRange = $this->getDateRangeFromFilter($timeFilter);
        
        $topPerformers = DB::table('users as u')
            ->join('exam_attempts as ea', 'u.id', '=', 'ea.reviewee_id')
            ->select(
                'u.id',
                DB::raw("CONCAT(u.first_name, ' ', u.last_name) as name"),
                DB::raw('COUNT(ea.id) as total_attempts'),
                DB::raw('AVG(ea.percentage) as average_score')
            )
            ->where('u.role', 'reviewee')
            ->where('ea.status', 'completed')
            ->where('ea.start_time', '>=', $dateRange['start'])
            ->where('ea.start_time', '<=', $dateRange['end'])
            ->groupBy('u.id', 'u.first_name', 'u.last_name')
            ->orderBy('average_score', 'DESC')
            ->limit(10)
            ->get();
        
        return $topPerformers->map(function($student) {
            return [
                'id' => $student->id,
                'name' => $student->name,
                'totalAttempts' => (int)$student->total_attempts,
                'averageScore' => round($student->average_score, 2)
            ];
        })->toArray();
    }

    /**
     * Get question difficulty analysis for an exam
     *
     * @param int $examId
     * @param string $timeFilter
     * @return array
     */
    public function getQuestionDifficultyAnalysis(int $examId, string $timeFilter): array
    {
        $dateRange = $this->getDateRangeFromFilter($timeFilter);
        
        // Get exam details
        $exam = DB::table('exams')
            ->select('id', 'title')
            ->where('id', $examId)
            ->where('is_deleted', 0)
            ->first();
        
        if (!$exam) {
            return [
                'examId' => $examId,
                'examTitle' => '',
                'questions' => []
            ];
        }
        
        $questionQuery = DB::table('questions as q')
            ->join('exam_questions as eq', 'q.id', '=', 'eq.question_id')
            ->select('q.id', 'q.question_text')
            ->where('eq.exam_id', $examId);

        if (Schema::hasColumn('questions', 'is_deleted')) {
            $questionQuery->where('q.is_deleted', 0);
        }

        $questions = $questionQuery
            ->orderBy('eq.display_order', 'ASC')
            ->get();

        if ($questions->isEmpty()) {
            return [
                'examId' => $examId,
                'examTitle' => $exam->title,
                'questions' => []
            ];
        }

        $questionIds = $questions->pluck('id')->toArray();

        $attemptStats = DB::table('attempt_answers as aa')
            ->join('exam_attempts as ea', 'aa.attempt_id', '=', 'ea.id')
            ->select(
                'aa.question_id',
                DB::raw('COUNT(DISTINCT aa.id) as total_attempts'),
                DB::raw('COALESCE(
                    SUM(CASE WHEN aa.is_correct = 0 THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(DISTINCT aa.id), 0),
                    0
                ) as incorrect_rate')
            )
            ->whereIn('aa.question_id', $questionIds)
            ->where('ea.exam_id', $examId)
            ->where('ea.status', 'completed')
            ->where('ea.start_time', '>=', $dateRange['start'])
            ->where('ea.start_time', '<=', $dateRange['end'])
            ->groupBy('aa.question_id')
            ->get()
            ->keyBy('question_id');

        $choicesByQuestion = DB::table('answer_choices')
            ->select('id', 'question_id', 'choice_text', 'is_correct')
            ->whereIn('question_id', $questionIds)
            ->orderBy('question_id', 'ASC')
            ->orderBy('display_order', 'ASC')
            ->get()
            ->groupBy('question_id');

        $formattedQuestions = $questions->values()->map(function($question, $index) use ($attemptStats, $choicesByQuestion) {
            $stats = $attemptStats->get($question->id);
            $totalAttempts = $stats ? (int)$stats->total_attempts : 0;
            $incorrectRate = $stats ? (float)$stats->incorrect_rate : 0;

            if ($incorrectRate >= 75) {
                $difficultyLevel = 'difficult';
            } elseif ($incorrectRate <= 30) {
                $difficultyLevel = 'easy';
            } else {
                $difficultyLevel = 'medium';
            }

            $choices = collect($choicesByQuestion->get($question->id, collect()))
                ->values()
                ->map(function($choice, $choiceIndex) {
                    $choiceLetter = chr(65 + ($choiceIndex % 26));
                    return [
                        'id' => (int)$choice->id,
                        'choiceLetter' => $choiceLetter,
                        'choiceText' => $choice->choice_text,
                        'text' => $choice->choice_text,
                        'isCorrect' => (bool)$choice->is_correct
                    ];
                })
                ->values()
                ->toArray();

            return [
                'id' => $question->id,
                'questionNumber' => $index + 1,
                'questionText' => $question->question_text,
                'choices' => $choices,
                'totalAttempts' => $totalAttempts,
                'incorrectRate' => round($incorrectRate, 2),
                'difficultyLevel' => $difficultyLevel
            ];
        })
        ->sortByDesc('incorrectRate')
        ->values()
        ->map(function($question, $sortedIndex) {
            $question['questionNumber'] = $sortedIndex + 1;
            return $question;
        })
        ->toArray();

        $totalAttemptsAnalyzed = (int) collect($formattedQuestions)->sum('totalAttempts');
        
        return [
            'examId' => $examId,
            'examTitle' => $exam->title,
            'totalQuestions' => count($formattedQuestions),
            'totalAttempts' => $totalAttemptsAnalyzed,
            'questions' => $formattedQuestions
        ];
    }

    /**
     * Get trend analysis data with category comparison
     *
     * @param string $timeFilter
     * @param array $categories
     * @return array
     */
    public function getTrendAnalysis(string $timeFilter, array $categories): array
    {
        $dateRange = $this->getDateRangeFromFilter($timeFilter);
        $interval = $this->getGroupByInterval($timeFilter);
        
        // Get date format based on interval
        $dateFormat = match($interval) {
            'day' => '%Y-%m-%d',
            'week' => '%Y-%u',
            'month' => '%Y-%m',
            default => '%Y-%m-%d'
        };
        
        // Build base query
        $query = DB::table('exam_attempts as ea')
            ->join('exams as e', 'ea.exam_id', '=', 'e.id')
            ->select(
                DB::raw("DATE_FORMAT(ea.start_time, '{$dateFormat}') as period"),
                'e.category',
                DB::raw('AVG(ea.percentage) as average_score'),
                DB::raw('COUNT(ea.id) as total_attempts')
            )
            ->where('ea.status', 'completed')
            ->where('ea.start_time', '>=', $dateRange['start'])
            ->where('ea.start_time', '<=', $dateRange['end'])
            ->where('e.status', 'active')
            ->where('e.is_deleted', 0);
        
        // Apply category filter if specified
        if (!empty($categories) && !in_array('all', $categories)) {
            $query->whereIn('e.category', $categories);
        }
        
        $trendData = $query
            ->groupBy('period', 'e.category')
            ->orderBy('period', 'ASC')
            ->orderBy('e.category', 'ASC')
            ->get();
        
        // Get overall average for each period (across all categories)
        $overallQuery = DB::table('exam_attempts as ea')
            ->join('exams as e', 'ea.exam_id', '=', 'e.id')
            ->select(
                DB::raw("DATE_FORMAT(ea.start_time, '{$dateFormat}') as period"),
                DB::raw('AVG(ea.percentage) as overall_average'),
                DB::raw('COUNT(ea.id) as total_attempts')
            )
            ->where('ea.status', 'completed')
            ->where('ea.start_time', '>=', $dateRange['start'])
            ->where('ea.start_time', '<=', $dateRange['end'])
            ->where('e.status', 'active')
            ->where('e.is_deleted', 0);
        
        // Apply same category filter for overall average
        if (!empty($categories) && !in_array('all', $categories)) {
            $overallQuery->whereIn('e.category', $categories);
        }
        
        $overallData = $overallQuery
            ->groupBy('period')
            ->orderBy('period', 'ASC')
            ->get();
        
        // Format the data
        $formattedTrendData = [];
        $overallMap = [];
        
        // Create overall average map
        foreach ($overallData as $overall) {
            $overallMap[$overall->period] = [
                'overallAverage' => round($overall->overall_average, 2),
                'totalAttempts' => (int)$overall->total_attempts
            ];
        }
        
        // Group trend data by period
        $periodMap = [];
        foreach ($trendData as $item) {
            $period = $item->period;
            if (!isset($periodMap[$period])) {
                $periodMap[$period] = [
                    'period' => $period,
                    'overallAverage' => $overallMap[$period]['overallAverage'] ?? 0,
                    'totalAttempts' => $overallMap[$period]['totalAttempts'] ?? 0,
                    'categoryAverages' => []
                ];
            }
            
            $periodMap[$period]['categoryAverages'][$item->category] = [
                'averageScore' => round($item->average_score, 2),
                'attempts' => (int)$item->total_attempts
            ];
        }
        
        // Convert to indexed array and sort by period
        $formattedTrendData = array_values($periodMap);
        usort($formattedTrendData, function($a, $b) {
            return strcmp($a['period'], $b['period']);
        });
        
        // Get available categories for reference
        $availableCategories = DB::table('exams')
            ->select('category')
            ->where('status', 'active')
            ->where('is_deleted', 0)
            ->distinct()
            ->pluck('category')
            ->toArray();
        
        return [
            'trendData' => $formattedTrendData,
            'availableCategories' => $availableCategories,
            'selectedCategories' => $categories,
            'timeFilter' => $timeFilter,
            'interval' => $interval
        ];
    }

    /**
     * Get comprehensive dashboard summary with all key metrics
     *
     * @param string $timeFilter
     * @return array
     */
    public function getDashboardSummary(string $timeFilter): array
    {
        $dateRange = $this->getDateRangeFromFilter($timeFilter);

        // Overview metrics
        $overview = $this->calculateOverviewMetrics($timeFilter);

        // Pass rate across all exams
        $passRateData = DB::table('exam_attempts as ea')
            ->join('exams as e', 'ea.exam_id', '=', 'e.id')
            ->select(
                DB::raw('COUNT(ea.id) as total_attempts'),
                DB::raw('SUM(CASE WHEN ea.percentage >= e.passing_score THEN 1 ELSE 0 END) as passed_attempts')
            )
            ->where('ea.status', 'completed')
            ->where('ea.start_time', '>=', $dateRange['start'])
            ->where('ea.start_time', '<=', $dateRange['end'])
            ->where('e.status', 'active')
            ->where('e.is_deleted', 0)
            ->first();

        $overallPassRate = 0;
        if ($passRateData && $passRateData->total_attempts > 0) {
            $overallPassRate = round(($passRateData->passed_attempts / $passRateData->total_attempts) * 100, 2);
        }

        // Top 5 exams by attempts
        $topExams = DB::table('exams as e')
            ->leftJoin('exam_attempts as ea', function($join) use ($dateRange) {
                $join->on('e.id', '=', 'ea.exam_id')
                     ->where('ea.status', '=', 'completed')
                     ->where('ea.start_time', '>=', $dateRange['start'])
                     ->where('ea.start_time', '<=', $dateRange['end']);
            })
            ->select(
                'e.id',
                'e.title',
                'e.category',
                DB::raw('COUNT(ea.id) as total_attempts'),
                DB::raw('COALESCE(AVG(ea.percentage), 0) as average_score'),
                DB::raw('COALESCE(
                    SUM(CASE WHEN ea.percentage >= e.passing_score THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(ea.id), 0),
                    0
                ) as pass_rate')
            )
            ->where('e.status', 'active')
            ->where('e.is_deleted', 0)
            ->groupBy('e.id', 'e.title', 'e.category', 'e.passing_score')
            ->orderByRaw('total_attempts DESC')
            ->limit(5)
            ->get()
            ->map(function($exam) {
                return [
                    'id' => $exam->id,
                    'title' => $exam->title,
                    'category' => $exam->category,
                    'totalAttempts' => (int)$exam->total_attempts,
                    'averageScore' => round($exam->average_score, 2),
                    'passRate' => round($exam->pass_rate, 2)
                ];
            })->toArray();

        // Top 5 performers
        $topPerformers = $this->getTopPerformers($timeFilter);
        $topPerformers = array_slice($topPerformers, 0, 5);

        // Recent activity (last 7 days regardless of filter)
        $recentActivity = DB::table('exam_attempts as ea')
            ->join('users as u', 'ea.reviewee_id', '=', 'u.id')
            ->join('exams as e', 'ea.exam_id', '=', 'e.id')
            ->select(
                'ea.id',
                DB::raw("CONCAT(u.first_name, ' ', u.last_name) as student_name"),
                'e.title as exam_title',
                'ea.percentage',
                'ea.status',
                'ea.start_time'
            )
            ->where('ea.status', 'completed')
            ->where('ea.start_time', '>=', Carbon::now()->subDays(7))
            ->orderBy('ea.start_time', 'DESC')
            ->limit(10)
            ->get()
            ->map(function($activity) {
                return [
                    'id' => $activity->id,
                    'studentName' => $activity->student_name,
                    'examTitle' => $activity->exam_title,
                    'score' => round($activity->percentage, 2),
                    'status' => $activity->status,
                    'date' => $activity->start_time
                ];
            })->toArray();

        // Category performance breakdown - show ALL categories with attempts (regardless of exam status)
        // IMPORTANT: We don't filter by exam status here because we want to show historical data
        // even if the exam is now inactive. We only exclude deleted exams.
        $categoryBreakdown = DB::table('exam_attempts as ea')
            ->join('exams as e', 'ea.exam_id', '=', 'e.id')
            ->select(
                'e.category',
                DB::raw('COUNT(ea.id) as total_attempts'),
                DB::raw('AVG(ea.percentage) as average_score'),
                DB::raw('SUM(CASE WHEN ea.percentage >= e.passing_score THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(ea.id), 0) as pass_rate')
            )
            ->where('ea.status', 'completed')
            ->where('ea.start_time', '>=', $dateRange['start'])
            ->where('ea.start_time', '<=', $dateRange['end'])
            ->where('e.is_deleted', 0)
            ->whereNotNull('e.category')
            ->groupBy('e.category')
            ->having('total_attempts', '>', 0)  // Only include categories with at least 1 attempt
            ->orderByRaw('total_attempts DESC')
            ->get()
            ->map(function($cat) {
                return [
                    'category' => $cat->category,
                    'totalAttempts' => (int)$cat->total_attempts,
                    'averageScore' => round($cat->average_score, 2),
                    'passRate' => round($cat->pass_rate ?? 0, 2)
                ];
            })->toArray();

        return [
            'overview' => array_merge($overview, ['overallPassRate' => $overallPassRate]),
            'topExams' => $topExams,
            'topPerformers' => $topPerformers,
            'recentActivity' => $recentActivity,
            'categoryBreakdown' => $categoryBreakdown,
            'timeFilter' => $timeFilter
        ];
    }

    /**
     * Convert time filter string to date range
     *
     * @param string $timeFilter
     * @return array ['start' => Carbon, 'end' => Carbon]
     */
    private function getDateRangeFromFilter(string $timeFilter): array
    {
        $end = Carbon::now();
        
        switch ($timeFilter) {
            case '7days':
                $start = Carbon::now()->subDays(7);
                break;
            case '30days':
                $start = Carbon::now()->subDays(30);
                break;
            case '3months':
                $start = Carbon::now()->subMonths(3);
                break;
            case 'all':
            default:
                $start = Carbon::create(2000, 1, 1); // Far past date
                break;
        }
        
        return [
            'start' => $start,
            'end' => $end
        ];
    }

    /**
     * Get grouping interval based on time filter
     *
     * @param string $timeFilter
     * @return string 'day', 'week', or 'month'
     */
    private function getGroupByInterval(string $timeFilter): string
    {
        switch ($timeFilter) {
            case '7days':
                return 'day';
            case '30days':
                return 'week';
            case '3months':
            case 'all':
            default:
                return 'month';
        }
    }
}

<?php

namespace App\Http\Controllers;

use App\Services\SimpleXlsxService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Schema;

class ExportController extends Controller
{
    public function __construct(private SimpleXlsxService $xlsxService)
    {
    }

    /**
     * Export student results - simple format showing which attempt they passed
     * Separated by exam (not category) for easy reading
     *
     * @return JsonResponse
     */
    public function exportAllResults(Request $request): JsonResponse
    {
        try {
            $selectedCategory = trim((string) $request->query('category', ''));
            $selectedExamId = (int) $request->query('exam_id', 0);

            $students = DB::table('users')
                ->where('role', 'reviewee')
                ->where('is_active', true)
                ->orderBy('username')
                ->get();

            $examsQuery = DB::table('exams')
                ->select('id', 'title', 'category')
                ->where('is_deleted', 0)
                ->orderBy('category')
                ->orderBy('title');

            if ($selectedCategory !== '' && strtolower($selectedCategory) !== 'all') {
                $examsQuery->where('category', $selectedCategory);
            }

            if ($selectedExamId > 0) {
                $examsQuery->where('id', $selectedExamId);
            }

            $exams = $examsQuery->get();
            $examIds = $exams->pluck('id')->map(fn ($id) => (int) $id)->all();

            $studentIds = $students->pluck('id')->map(fn ($id) => (int) $id)->all();
            $attemptBuckets = $this->getAttemptBucketsByStudentExam($examIds, $studentIds);
            $exportData = [];

            foreach ($students as $student) {
                $row = [
                    'Student Name' => trim(($student->first_name ?? '') . ' ' . ($student->last_name ?? '')) ?: $student->username,
                    'Username' => $student->username
                ];

                foreach ($exams as $exam) {
                    $columnName = $exam->title;
                    $bucketKey = $this->makeStudentExamKey((int) $student->id, (int) $exam->id);
                    $attempts = $attemptBuckets[$bucketKey] ?? [];

                    if (empty($attempts)) {
                        $row[$columnName] = 'Not Taken';
                        continue;
                    }

                    $summary = $this->summarizeAttempts($attempts);
                    if ($summary['passedAttempt'] !== null) {
                        $row[$columnName] = "Passed on Try {$summary['passedAttempt']} ({$summary['bestPercentage']}%)";
                    } else {
                        $row[$columnName] = "Failed (Best: {$summary['bestPercentage']}%)";
                    }
                }

                $exportData[] = $row;
            }

            return response()->json([
                'success' => true,
                'data' => $exportData,
                'count' => count($exportData),
                'meta' => [
                    'category' => $selectedCategory === '' ? 'all' : $selectedCategory,
                    'exam_id' => $selectedExamId > 0 ? $selectedExamId : null,
                    'exam_count' => count($examIds),
                ]
            ]);
        } catch (\Exception $e) {
            Log::error('Export all results failed', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to export results'
            ], 500);
        }
    }

    /**
     * Get all exam attempts for ViewScores page
     * Returns detailed attempt data with student and exam info
     *
     * @return JsonResponse
     */
    public function getAllAttempts(): JsonResponse
    {
        try {
            $attempts = DB::table('exam_attempts')
                ->join('users', 'exam_attempts.reviewee_id', '=', 'users.id')
                ->join('exams', 'exam_attempts.exam_id', '=', 'exams.id')
                ->where('exam_attempts.status', 'completed')
                ->where('exams.is_deleted', 0)
                ->select(
                    'exam_attempts.id as attempt_id',
                    'users.id as user_id',
                    'users.username',
                    'users.first_name',
                    'users.last_name',
                    DB::raw('CONCAT(COALESCE(users.first_name, ""), " ", COALESCE(users.last_name, "")) as student_name'),
                    'exams.id as exam_id',
                    'exams.title as exam_title',
                    'exams.category',
                    DB::raw('ROW_NUMBER() OVER (PARTITION BY exam_attempts.reviewee_id, exam_attempts.exam_id ORDER BY exam_attempts.start_time) as attempt_number'),
                    'exam_attempts.score',
                    'exam_attempts.total_questions',
                    DB::raw('ROUND((exam_attempts.score / exam_attempts.total_questions) * 100, 2) as percentage'),
                    'exam_attempts.start_time',
                    'exam_attempts.end_time'
                )
                ->orderBy('users.username')
                ->orderBy('exams.title')
                ->orderBy('exam_attempts.start_time')
                ->get()
                ->map(function($attempt) {
                    return [
                        'attempt_id' => $attempt->attempt_id,
                        'user_id' => $attempt->user_id,
                        'username' => $attempt->username,
                        'student_name' => trim($attempt->student_name) ?: $attempt->username,
                        'exam_id' => $attempt->exam_id,
                        'exam_title' => $attempt->exam_title,
                        'category' => $attempt->category ?? 'N/A',
                        'attempt_number' => $attempt->attempt_number,
                        'score' => $attempt->score,
                        'total_questions' => $attempt->total_questions,
                        'percentage' => $attempt->percentage,
                        'start_time' => $attempt->start_time,
                        'end_time' => $attempt->end_time
                    ];
                });

            return response()->json([
                'success' => true,
                'data' => $attempts,
                'count' => $attempts->count()
            ]);
        } catch (\Exception $e) {
            Log::error('Get all attempts failed', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to get attempts'
            ], 500);
        }
    }

    /**
     * Export student list with all their information
     *
     * @return JsonResponse
     */
    public function exportUserPerformance(): JsonResponse
    {
        try {
            $hasEmailColumn = Schema::hasColumn('users', 'email');

            $selectColumns = [
                'users.id',
                'users.username',
                'users.first_name',
                'users.last_name',
                'users.is_active',
                'users.created_at',
                DB::raw('COUNT(exam_attempts.id) as total_attempts'),
                DB::raw('COUNT(DISTINCT exam_attempts.exam_id) as exams_taken'),
                DB::raw('AVG(CASE WHEN exam_attempts.total_questions > 0 THEN (exam_attempts.score / exam_attempts.total_questions) * 100 ELSE 0 END) as average_score'),
                DB::raw('MAX(CASE WHEN exam_attempts.total_questions > 0 THEN (exam_attempts.score / exam_attempts.total_questions) * 100 ELSE 0 END) as highest_score'),
                DB::raw('MIN(CASE WHEN exam_attempts.total_questions > 0 THEN (exam_attempts.score / exam_attempts.total_questions) * 100 ELSE 0 END) as lowest_score'),
                DB::raw('SUM(CASE WHEN exam_attempts.total_questions > 0 AND (exam_attempts.score / exam_attempts.total_questions) * 100 >= 90 THEN 1 ELSE 0 END) as passed_attempts'),
                DB::raw('SUM(CASE WHEN exam_attempts.total_questions > 0 AND (exam_attempts.score / exam_attempts.total_questions) * 100 < 90 THEN 1 ELSE 0 END) as failed_attempts'),
            ];

            if ($hasEmailColumn) {
                $selectColumns[] = 'users.email';
            } else {
                $selectColumns[] = DB::raw("'' as email");
            }

            $groupByColumns = [
                'users.id',
                'users.username',
                'users.first_name',
                'users.last_name',
                'users.is_active',
                'users.created_at',
            ];

            if ($hasEmailColumn) {
                $groupByColumns[] = 'users.email';
            }

            $students = DB::table('users')
                ->leftJoin('exam_attempts', function($join) {
                    $join->on('users.id', '=', 'exam_attempts.reviewee_id')
                         ->where('exam_attempts.status', '=', 'completed');
                })
                ->select($selectColumns)
                ->where('users.role', 'reviewee')
                ->groupBy($groupByColumns)
                ->orderBy('users.username')
                ->get()
                ->map(function($user) {
                    return [
                        'Username' => $user->username,
                        'First Name' => $user->first_name ?? '',
                        'Last Name' => $user->last_name ?? '',
                        'Full Name' => trim(($user->first_name ?? '') . ' ' . ($user->last_name ?? '')),
                        'Email' => $user->email ?? '',
                        'Status' => $user->is_active ? 'Active' : 'Inactive',
                        'Registration Date' => $user->created_at,
                        'Total Attempts' => $user->total_attempts,
                        'Exams Taken' => $user->exams_taken,
                        'Passed Attempts' => $user->passed_attempts,
                        'Failed Attempts' => $user->failed_attempts,
                        'Average Score' => $user->average_score ? round($user->average_score, 2) . '%' : '0%',
                        'Highest Score' => $user->highest_score ? round($user->highest_score, 2) . '%' : '0%',
                        'Lowest Score' => $user->lowest_score ? round($user->lowest_score, 2) . '%' : '0%'
                    ];
                });

            return response()->json([
                'success' => true,
                'data' => $students,
                'count' => $students->count()
            ]);
        } catch (\Exception $e) {
            Log::error('Export student list failed', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to export student list'
            ], 500);
        }
    }

    /**
     * Get all data organized by category first, then exams, then students
     * For the new interactive ViewScores and ExportReports pages
     *
     * @return JsonResponse
     */
    public function getCategoryExamData(): JsonResponse
    {
        try {
            $categories = DB::table('exams')
                ->select('category')
                ->where('is_deleted', 0)
                ->distinct()
                ->orderBy('category')
                ->pluck('category')
                ->filter()
                ->values();

            $examsByCategory = DB::table('exams')
                ->select('id', 'title', 'category')
                ->where('is_deleted', 0)
                ->orderBy('category')
                ->orderBy('title')
                ->get()
                ->groupBy('category');

            $studentSelect = ['id', 'username', 'first_name', 'last_name'];
            if (Schema::hasColumn('users', 'email')) {
                $studentSelect[] = 'email';
            }

            $students = DB::table('users')
                ->where('role', 'reviewee')
                ->where('is_active', true)
                ->select($studentSelect)
                ->orderBy('username')
                ->get();

            $studentIds = $students->pluck('id')->map(fn ($id) => (int) $id)->all();
            $attemptBuckets = $this->getAttemptBucketsByStudentExam([], $studentIds);
            $result = [];

            foreach ($categories as $category) {
                $categoryExams = $examsByCategory->get($category, collect());
                
                $categoryData = [
                    'category' => $category,
                    'category_icon' => $this->getCategoryIcon($category),
                    'exams' => []
                ];

                foreach ($categoryExams as $exam) {
                    $examData = [
                        'exam_id' => $exam->id,
                        'exam_title' => $exam->title,
                        'students' => []
                    ];

                    foreach ($students as $student) {
                        $bucketKey = $this->makeStudentExamKey((int) $student->id, (int) $exam->id);
                        $attempts = $attemptBuckets[$bucketKey] ?? [];

                        $studentName = trim(($student->first_name ?? '') . ' ' . ($student->last_name ?? '')) ?: $student->username;

                        if (empty($attempts)) {
                            $examData['students'][] = [
                                'student_id' => $student->id,
                                'username' => $student->username,
                                'email' => $student->email ?? null,
                                'name' => $studentName,
                                'status' => 'Not Taken',
                                'attempts' => []
                            ];
                        } else {
                            $attemptDetails = [];

                            foreach ($attempts as $index => $attempt) {
                                if ($attempt->total_questions > 0) {
                                    $percentage = round(($attempt->score / $attempt->total_questions) * 100, 2);

                                    $attemptDetails[] = [
                                        'attempt_id' => $attempt->id,
                                        'attempt_number' => $index + 1,
                                        'score' => $attempt->score,
                                        'total' => $attempt->total_questions,
                                        'percentage' => $percentage,
                                        'passed' => $percentage >= 90,
                                        'date' => $attempt->start_time
                                    ];
                                }
                            }

                            $summary = $this->summarizeAttempts($attempts);
                            $status = $summary['passedAttempt'] !== null
                                ? "Passed on Try {$summary['passedAttempt']} ({$summary['bestPercentage']}%)"
                                : "Failed (Best: {$summary['bestPercentage']}%)";

                            $examData['students'][] = [
                                'student_id' => $student->id,
                                'username' => $student->username,
                                'email' => $student->email ?? null,
                                'name' => $studentName,
                                'status' => $status,
                                'best_percentage' => $summary['bestPercentage'],
                                'best_score' => $summary['bestScore'],
                                'attempts' => $attemptDetails
                            ];
                        }
                    }

                    $categoryData['exams'][] = $examData;
                }

                $result[] = $categoryData;
            }

            return response()->json([
                'success' => true,
                'data' => $result,
                'count' => count($result)
            ]);
        } catch (\Exception $e) {
            Log::error('Get category exam data failed', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to get category exam data'
            ], 500);
        }
    }

    /**
     * Helper function to get category icon
     */
    private function getCategoryIcon(string $category): string
    {
        $category = strtolower($category);
        
        if (str_contains($category, 'aquaculture')) return '🐟';
        if (str_contains($category, 'capture')) return '🎣';
        if (str_contains($category, 'post')) return '📦';
        if (str_contains($category, 'aquatic')) return '🌊';
        
        return '📚';
    }

    /**
     * Export professional CSV format - organized like professional gradebooks
     * 
     * @return JsonResponse
     */
    public function exportProfessionalResults(): JsonResponse
    {
        try {
            $hasEmailColumn = Schema::hasColumn('users', 'email');
            $studentSelect = ['id', 'username', 'first_name', 'last_name', 'is_active', 'created_at'];
            if ($hasEmailColumn) {
                $studentSelect[] = 'email';
            }

            $students = DB::table('users')
                ->where('role', 'reviewee')
                ->select($studentSelect)
                ->orderBy('last_name')
                ->orderBy('first_name')
                ->get();

            $examsByCategory = DB::table('exams')
                ->select('id', 'title', 'category', 'total_questions')
                ->where('is_deleted', 0)
                ->orderBy('category')
                ->orderBy('title')
                ->get()
                ->groupBy('category');

            $categories = DB::table('exams')
                ->select('category')
                ->where('is_deleted', 0)
                ->distinct()
                ->orderBy('category')
                ->pluck('category')
                ->filter()
                ->values();

            $allExams = $examsByCategory->flatten(1)->values();
            $examTitleById = $allExams->pluck('title', 'id')->toArray();
            $studentIds = $students->pluck('id')->map(fn ($id) => (int) $id)->all();
            $attemptBuckets = $this->getAttemptBucketsByStudentExam([], $studentIds);
            $attemptsByStudent = $this->getAttemptBucketsByStudent($attemptBuckets);
            $exportData = [];

            $exportData[] = ['CFAS REVIEW CENTER - EXAM RESULTS REPORT'];
            $exportData[] = ['Export Date', now()->format('Y-m-d H:i:s')];
            $exportData[] = ['System Version', '1.0.0'];
            $exportData[] = [];

            $exportData[] = ['STUDENT INFORMATION'];
            $exportData[] = ['Student ID', 'Full Name', 'Username', 'Email', 'Status', 'Registration Date'];
            
            foreach ($students as $student) {
                $fullName = trim(($student->first_name ?? '') . ' ' . ($student->last_name ?? '')) ?: $student->username;
                $status = $student->is_active ? 'Active' : 'Inactive';
                
                $exportData[] = [
                    $student->id,
                    $fullName,
                    $student->username,
                    $student->email ?? '',
                    $status,
                    $student->created_at
                ];
            }

            $exportData[] = [];

            foreach ($categories as $category) {
                $categoryExams = $examsByCategory->get($category, collect());
                
                $exportData[] = [strtoupper($category) . ' EXAM RESULTS'];
                $exportData[] = ['Student Name', 'Username'];
                
                $examColumns = [];
                foreach ($categoryExams as $exam) {
                    $examColumns[] = $exam->title . ' [Score]';
                    $examColumns[] = $exam->title . ' [%]';
                    $examColumns[] = $exam->title . ' [Status]';
                    $examColumns[] = $exam->title . ' [Attempts]';
                }
                
                $examColumns[] = 'Category Avg %';
                $examColumns[] = 'Category Status';
                
                $exportData[] = array_merge(['', ''], $examColumns);
                
                foreach ($students as $student) {
                    $fullName = trim(($student->first_name ?? '') . ' ' . ($student->last_name ?? '')) ?: $student->username;
                    
                    $row = [$fullName, $student->username];
                    $categoryTotalPercentage = 0;
                    $categoryExamsTaken = 0;
                    
                    foreach ($categoryExams as $exam) {
                        $bucketKey = $this->makeStudentExamKey((int) $student->id, (int) $exam->id);
                        $attempts = $attemptBuckets[$bucketKey] ?? [];

                        if (empty($attempts)) {
                            $row = array_merge($row, ['', '0%', 'Not Taken', '0']);
                            continue;
                        }
                        
                        $summary = $this->summarizeAttempts($attempts);
                        
                        $categoryExamsTaken++;
                        $categoryTotalPercentage += $summary['bestPercentage'];
                        
                        $status = $summary['passedAttempt'] !== null
                            ? "Passed (Try {$summary['passedAttempt']})"
                            : "Failed";
                        
                        $row = array_merge($row, [
                            "{$summary['bestScore']}/{$exam->total_questions}",
                            "{$summary['bestPercentage']}%",
                            $status,
                            $summary['attemptCount']
                        ]);
                    }
                    
                    $categoryAverage = $categoryExamsTaken > 0 
                        ? round($categoryTotalPercentage / $categoryExamsTaken, 2)
                        : 0;
                        
                    $categoryStatus = $categoryExamsTaken === 0 ? 'Not Taken' : 
                                    ($categoryAverage >= 90 ? 'Passed' : 'Failed');
                    
                    $row = array_merge($row, [
                        "{$categoryAverage}%",
                        $categoryStatus
                    ]);
                    
                    $exportData[] = $row;
                }
                
                $exportData[] = [];
            }

            $exportData[] = ['OVERALL PERFORMANCE SUMMARY'];
            $exportData[] = ['Student Name', 'Username', 'Total Exams Taken', 'Exams Passed', 'Exams Failed', 'Overall Average %', 'Overall Status'];
            
            foreach ($students as $student) {
                $fullName = trim(($student->first_name ?? '') . ' ' . ($student->last_name ?? '')) ?: $student->username;
                $examResults = [];
                $studentPairs = $attemptsByStudent[$student->id] ?? [];

                foreach ($studentPairs as $examId => $attempts) {
                    $summary = $this->summarizeAttempts($attempts);
                    if ($summary['attemptCount'] > 0) {
                        $examResults[$examId] = [
                            'title' => $examTitleById[$examId] ?? '',
                            'best_score' => $summary['bestScore'],
                            'best_percentage' => $summary['bestPercentage']
                        ];
                    }
                }
                
                $totalExams = count($examResults);
                $examsPassed = 0;
                $examsFailed = 0;
                $totalPercentage = 0;
                
                foreach ($examResults as $exam) {
                    if ($exam['best_percentage'] >= 90) {
                        $examsPassed++;
                    } else {
                        $examsFailed++;
                    }
                    $totalPercentage += $exam['best_percentage'];
                }
                
                $overallAverage = $totalExams > 0 ? round($totalPercentage / $totalExams, 2) : 0;
                $overallStatus = $totalExams === 0 ? 'Not Taken' : 
                               ($overallAverage >= 90 ? 'Excellent' : 
                               ($overallAverage >= 75 ? 'Good' : 'Needs Improvement'));
                
                $exportData[] = [
                    $fullName,
                    $student->username,
                    $totalExams,
                    $examsPassed,
                    $examsFailed,
                    "{$overallAverage}%",
                    $overallStatus
                ];
            }
            
            $exportData[] = [];
            
            $totalStudents = $students->count();
            $activeStudents = $students->where('is_active', true)->count();
            
            $exportData[] = ['REPORT STATISTICS'];
            $exportData[] = ['Total Students', $totalStudents];
            $exportData[] = ['Active Students', $activeStudents];
            $exportData[] = ['Inactive Students', $totalStudents - $activeStudents];
            $exportData[] = ['Total Categories', count($categories)];
            $exportData[] = ['Total Exams', DB::table('exams')->where('is_deleted', 0)->count()];
            $exportData[] = ['Passing Threshold', '90%'];

            return response()->json([
                'success' => true,
                'data' => $exportData,
                'count' => count($exportData),
                'format' => 'professional'
            ]);
        } catch (\Exception $e) {
            Log::error('Export professional results failed', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to export professional results'
            ], 500);
        }
    }

    public function exportXlsx(Request $request)
    {
        try {
            $type = strtolower(trim((string) $request->query('type', 'detailed')));
            if (!in_array($type, ['detailed', 'students', 'professional'], true)) {
                $type = 'detailed';
            }

            $sourceResponse = match ($type) {
                'students' => $this->exportUserPerformance(),
                'professional' => $this->exportProfessionalResults(),
                default => $this->exportAllResults($request),
            };

            $payload = $sourceResponse->getData(true);
            if (!($payload['success'] ?? false)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Failed to prepare XLSX export'
                ], 500);
            }

            $data = $payload['data'] ?? [];
            $xlsxBinary = $this->xlsxService->build($data, 'Export');
            $fileName = $this->buildXlsxFilename($type, $request);

            return response($xlsxBinary, 200, [
                'Content-Type' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                'Content-Disposition' => 'attachment; filename="' . $fileName . '"',
                'Cache-Control' => 'no-cache, no-store, must-revalidate',
                'Pragma' => 'no-cache',
                'Expires' => '0',
            ]);
        } catch (\Exception $e) {
            Log::error('Export XLSX failed', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to export XLSX'
            ], 500);
        }
    }

    private function getAttemptBucketsByStudentExam(array $examIds = [], array $studentIds = []): array
    {
        $attemptsQuery = DB::table('exam_attempts')
            ->join('exams', 'exam_attempts.exam_id', '=', 'exams.id')
            ->where('exam_attempts.status', 'completed')
            ->where('exams.is_deleted', 0)
            ->select(
                'exam_attempts.id',
                'exam_attempts.reviewee_id',
                'exam_attempts.exam_id',
                'exam_attempts.score',
                'exam_attempts.total_questions',
                'exam_attempts.start_time'
            )
            ->orderBy('exam_attempts.start_time');

        if (!empty($examIds)) {
            $attemptsQuery->whereIn('exam_attempts.exam_id', $examIds);
        }

        if (!empty($studentIds)) {
            $attemptsQuery->whereIn('exam_attempts.reviewee_id', $studentIds);
        }

        $attempts = $attemptsQuery->get();

        $buckets = [];
        foreach ($attempts as $attempt) {
            $key = $this->makeStudentExamKey((int) $attempt->reviewee_id, (int) $attempt->exam_id);
            $buckets[$key][] = $attempt;
        }

        return $buckets;
    }

    private function getAttemptBucketsByStudent(array $attemptBuckets): array
    {
        $studentBuckets = [];
        foreach ($attemptBuckets as $attempts) {
            if (empty($attempts)) {
                continue;
            }

            $revieweeId = (int) $attempts[0]->reviewee_id;
            $examId = (int) $attempts[0]->exam_id;
            $studentBuckets[$revieweeId][$examId] = $attempts;
        }

        return $studentBuckets;
    }

    private function summarizeAttempts(array $attempts): array
    {
        $bestScore = 0;
        $bestPercentage = 0;
        $passedAttempt = null;

        foreach ($attempts as $index => $attempt) {
            if ((int) $attempt->total_questions <= 0) {
                continue;
            }

            $percentage = round(($attempt->score / $attempt->total_questions) * 100, 2);
            if ($percentage > $bestPercentage) {
                $bestPercentage = $percentage;
                $bestScore = $attempt->score;
            }

            if ($passedAttempt === null && $percentage >= 90) {
                $passedAttempt = $index + 1;
            }
        }

        return [
            'bestScore' => $bestScore,
            'bestPercentage' => $bestPercentage,
            'passedAttempt' => $passedAttempt,
            'attemptCount' => count($attempts)
        ];
    }

    private function makeStudentExamKey(int $studentId, int $examId): string
    {
        return $studentId . ':' . $examId;
    }

    private function buildXlsxFilename(string $type, Request $request): string
    {
        $date = now()->format('Y-m-d');

        if ($type === 'students') {
            return "cfas-student-summary-{$date}.xlsx";
        }

        if ($type === 'professional') {
            return "cfas-professional-results-{$date}.xlsx";
        }

        $category = trim((string) $request->query('category', 'all'));
        $categorySlug = preg_replace('/[^a-z0-9]+/i', '-', strtolower($category));
        $categorySlug = trim((string) $categorySlug, '-');
        if ($categorySlug === '') {
            $categorySlug = 'all';
        }

        $examId = (int) $request->query('exam_id', 0);
        $examSlug = $examId > 0 ? "exam-{$examId}" : 'all-exams';

        return "cfas-student-exam-results-{$categorySlug}-{$examSlug}-{$date}.xlsx";
    }

}

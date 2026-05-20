<?php

namespace App\Services;

use Illuminate\Support\Facades\Response;
use Illuminate\Http\Response as HttpResponse;

class CsvExportService
{
    /**
     * Generate CSV content from data array
     *
     * @param array $data
     * @param array $headers
     * @return string
     */
    public function generateCsv(array $data, array $headers): string
    {
        $output = fopen('php://temp', 'r+');
        
        // Write headers
        fputcsv($output, $headers);
        
        // Write data rows
        foreach ($data as $row) {
            // Ensure row has same number of columns as headers
            $csvRow = [];
            foreach ($headers as $header) {
                $csvRow[] = $row[$header] ?? '';
            }
            fputcsv($output, $csvRow);
        }
        
        rewind($output);
        $csvContent = stream_get_contents($output);
        fclose($output);
        
        return $csvContent;
    }
    
    /**
     * Format exam performance data for CSV export
     *
     * @param array $exams
     * @param string $timeFilter
     * @return array
     */
    public function formatExamPerformanceData(array $exams, string $timeFilter): array
    {
        $headers = [
            'Exam Title',
            'Category',
            'Total Attempts',
            'Average Score (%)',
            'Pass Rate (%)',
            'Passing Score (%)',
            'Date Range'
        ];
        
        $formattedData = [];
        foreach ($exams as $exam) {
            $formattedData[] = [
                'Exam Title' => $exam['title'],
                'Category' => $exam['category'],
                'Total Attempts' => $exam['totalAttempts'],
                'Average Score (%)' => $exam['averageScore'],
                'Pass Rate (%)' => $exam['passRate'],
                'Passing Score (%)' => $exam['passingScore'],
                'Date Range' => $this->getDateRangeLabel($timeFilter)
            ];
        }
        
        return [
            'headers' => $headers,
            'data' => $formattedData
        ];
    }
    
    /**
     * Format student performance data for CSV export
     *
     * @param array $students
     * @param string $timeFilter
     * @return array
     */
    public function formatStudentPerformanceData(array $students, string $timeFilter): array
    {
        $headers = [
            'Student Name',
            'Total Attempts',
            'Average Score (%)',
            'Completion Rate (%)',
            'Performance Level',
            'Date Range'
        ];
        
        $formattedData = [];
        foreach ($students as $student) {
            $formattedData[] = [
                'Student Name' => $student['name'],
                'Total Attempts' => $student['totalAttempts'],
                'Average Score (%)' => $student['averageScore'],
                'Completion Rate (%)' => $student['completionRate'],
                'Performance Level' => ucfirst($student['performanceLevel']),
                'Date Range' => $this->getDateRangeLabel($timeFilter)
            ];
        }
        
        return [
            'headers' => $headers,
            'data' => $formattedData
        ];
    }
    
    /**
     * Format question analysis data for CSV export
     *
     * @param array $questions
     * @param string $examTitle
     * @param string $timeFilter
     * @return array
     */
    public function formatQuestionAnalysisData(array $questions, string $examTitle, string $timeFilter): array
    {
        $headers = [
            'Question Text',
            'Total Attempts',
            'Incorrect Rate (%)',
            'Difficulty Level',
            'Correct Answer',
            'Exam Title',
            'Date Range'
        ];
        
        $formattedData = [];
        foreach ($questions as $question) {
            // Find correct answer
            $correctAnswer = '';
            foreach ($question['choices'] as $choice) {
                if ($choice['isCorrect']) {
                    $correctAnswer = $choice['text'];
                    break;
                }
            }
            
            $formattedData[] = [
                'Question Text' => $question['questionText'],
                'Total Attempts' => $question['totalAttempts'],
                'Incorrect Rate (%)' => $question['incorrectRate'],
                'Difficulty Level' => ucfirst($question['difficultyLevel']),
                'Correct Answer' => $correctAnswer,
                'Exam Title' => $examTitle,
                'Date Range' => $this->getDateRangeLabel($timeFilter)
            ];
        }
        
        return [
            'headers' => $headers,
            'data' => $formattedData
        ];
    }
    
    /**
     * Format trend analysis data for CSV export
     *
     * @param array $trendData
     * @param string $timeFilter
     * @return array
     */
    public function formatTrendAnalysisData(array $trendData, string $timeFilter): array
    {
        $headers = [
            'Period',
            'Overall Average (%)',
            'Total Attempts',
            'Categories',
            'Date Range'
        ];
        
        $formattedData = [];
        foreach ($trendData as $trend) {
            // Format categories data
            $categoriesText = '';
            if (!empty($trend['categoryAverages'])) {
                $categoryStrings = [];
                foreach ($trend['categoryAverages'] as $category => $data) {
                    $categoryStrings[] = "{$category}: {$data['averageScore']}%";
                }
                $categoriesText = implode('; ', $categoryStrings);
            }
            
            $formattedData[] = [
                'Period' => $trend['period'],
                'Overall Average (%)' => $trend['overallAverage'],
                'Total Attempts' => $trend['totalAttempts'],
                'Categories' => $categoriesText,
                'Date Range' => $this->getDateRangeLabel($timeFilter)
            ];
        }
        
        return [
            'headers' => $headers,
            'data' => $formattedData
        ];
    }
    
    /**
     * Create CSV download response
     *
     * @param string $csvContent
     * @param string $filename
     * @return HttpResponse
     */
    public function createDownloadResponse(string $csvContent, string $filename): HttpResponse
    {
        $filename = $this->sanitizeFilename($filename);
        
        return Response::make($csvContent, 200, [
            'Content-Type' => 'text/csv',
            'Content-Disposition' => "attachment; filename=\"{$filename}\"",
            'Cache-Control' => 'no-cache, no-store, must-revalidate',
            'Pragma' => 'no-cache',
            'Expires' => '0'
        ]);
    }
    
    /**
     * Get human-readable date range label
     *
     * @param string $timeFilter
     * @return string
     */
    private function getDateRangeLabel(string $timeFilter): string
    {
        return match($timeFilter) {
            '7days' => 'Last 7 days',
            '30days' => 'Last 30 days',
            '3months' => 'Last 3 months',
            'all' => 'All time',
            default => 'All time'
        };
    }
    
    /**
     * Sanitize filename for download
     *
     * @param string $filename
     * @return string
     */
    private function sanitizeFilename(string $filename): string
    {
        // Remove or replace invalid characters
        $filename = preg_replace('/[^a-zA-Z0-9_\-\.]/', '_', $filename);
        
        // Ensure .csv extension
        if (!str_ends_with(strtolower($filename), '.csv')) {
            $filename .= '.csv';
        }
        
        return $filename;
    }
}

# CSV Export Format Improvement

## Problem
The old CSV export was confusing and hard to read:
- Too many columns
- One row per attempt (scattered data)
- Hard to see all attempts for one student
- Difficult to compare performance

## New Format

### Student Exam Results (Organized by Student)
Each row represents ONE student taking ONE exam, with all attempts shown horizontally:

```
Student Name | Username | Exam Subject | Category | Total Attempts | Attempt 1 Score | Attempt 1 % | Attempt 1 Result | Attempt 1 Date | Attempt 2 Score | Attempt 2 % | Attempt 2 Result | Attempt 2 Date | Best Score
```

**Example:**
```csv
Student Name,Username,Exam Subject,Category,Total Attempts,Attempt 1 Score,Attempt 1 %,Attempt 1 Result,Attempt 1 Date,Attempt 2 Score,Attempt 2 %,Attempt 2 Result,Attempt 2 Date,Best Score
Juan Dela Cruz,student01,Aquaculture Basics,Aquaculture,2,45/50,90%,PASSED,2026-02-20 10:30,48/50,96%,PASSED,2026-02-21 14:15,96%
Maria Santos,student02,Capture Fisheries,Capture Fisheries,1,38/50,76%,FAILED,2026-02-20 11:00,,,,,76%
```

### Benefits:
1. **Easy to scan** - All student attempts in one row
2. **Excel-friendly** - Opens perfectly in Excel/Google Sheets
3. **Comparison ready** - Easy to compare attempts side-by-side
4. **Best score visible** - Shows highest achievement
5. **Organized** - Grouped by student, then by exam

### Student Summary (Overall Performance)
Shows overall statistics per student:

```
Username | Full Name | Email | Status | Total Attempts | Exams Taken | Passed | Failed | Average Score | Highest Score | Lowest Score
```

## Changes Made

### Backend (`ExportController.php`)
- Reorganized query to group by student first
- Added horizontal attempt columns (Attempt 1, Attempt 2, etc.)
- Calculate best score automatically
- Cleaner column names

### Frontend (`ExportReports.vue`)
- Updated export type labels with emojis
- Better filename generation
- Improved notification messages

## How to Use

1. Go to Admin Dashboard → Export Reports
2. Select "Student Exam Results" for detailed view
3. Filter by exam or category if needed
4. Preview the data
5. Click "Export to CSV"
6. Open in Excel/Google Sheets

## Deployment

Run:
```bash
.\DEPLOY-EXPORT-FIX.bat
```

Or manually:
```bash
cd frontend
npm run build
xcopy /E /I /Y dist\* C:\xampp\htdocs\exam-frontend\
```

## Example Use Cases

### Track Student Progress
- See all attempts for each exam
- Identify improvement trends
- Find students who need help

### Generate Reports
- Easy to create pivot tables
- Calculate class averages
- Identify difficult exams

### Performance Analysis
- Compare first vs. last attempt
- See which students improved
- Track passing rates

## CSV Column Explanation

| Column | Description |
|--------|-------------|
| Student Name | Full name or username |
| Username | Login username |
| Exam Subject | Name of the exam |
| Category | Exam category (Aquaculture, etc.) |
| Total Attempts | How many times taken |
| Attempt N Score | Score as "correct/total" |
| Attempt N % | Percentage score |
| Attempt N Result | PASSED or FAILED |
| Attempt N Date | When the attempt was taken |
| Best Score | Highest percentage achieved |

## Notes

- Only completed attempts are included
- Attempts are ordered chronologically
- Passing score is 90%
- Empty cells mean no attempt at that number
- Best score is calculated from all attempts

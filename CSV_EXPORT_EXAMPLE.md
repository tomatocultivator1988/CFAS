# CSV Export Format - Before & After

## OLD FORMAT (Confusing) ❌

Each attempt was a separate row, making it hard to see all attempts for one student:

```csv
Attempt ID,Username,First Name,Last Name,Full Name,Exam Title,Category,Attempt Number,Score,Total Questions,Percentage,Result,Duration (Minutes),Start Time,End Time,Status
1,student01,Juan,Dela Cruz,Juan Dela Cruz,Aquaculture Basics,Aquaculture,1,45,50,90%,PASSED,45,2026-02-20 10:30:00,2026-02-20 11:15:00,completed
2,student01,Juan,Dela Cruz,Juan Dela Cruz,Aquaculture Basics,Aquaculture,2,48,50,96%,PASSED,42,2026-02-21 14:15:00,2026-02-21 14:57:00,completed
3,student02,Maria,Santos,Maria Santos,Capture Fisheries,Capture Fisheries,1,38,50,76%,FAILED,50,2026-02-20 11:00:00,2026-02-20 11:50:00,completed
```

**Problems:**
- Hard to compare attempts side-by-side
- Too many rows for students with multiple attempts
- Difficult to see improvement trends
- Not Excel-friendly for analysis

---

## NEW FORMAT (Simple & Clear) ✅

Each row = ONE student + ONE exam, with all attempts shown horizontally:

```csv
Student Name,Username,Exam Subject,Category,Total Attempts,Attempt 1 Score,Attempt 1 Percentage,Attempt 1 Result,Attempt 1 Date,Attempt 2 Score,Attempt 2 Percentage,Attempt 2 Result,Attempt 2 Date,Best Score
Juan Dela Cruz,student01,Aquaculture Basics,Aquaculture,2,45/50,90%,PASSED,2026-02-20 10:30,48/50,96%,PASSED,2026-02-21 14:15,96%
Maria Santos,student02,Capture Fisheries,Capture Fisheries,1,38/50,76%,FAILED,2026-02-20 11:00,,,,,76%
Pedro Reyes,student03,Aquaculture Basics,Aquaculture,3,40/50,80%,FAILED,2026-02-19 09:00,45/50,90%,PASSED,2026-02-20 10:00,47/50,94%,PASSED,2026-02-21 11:00,94%
```

**Benefits:**
- ✅ All attempts in one row - easy to scan
- ✅ Compare attempts side-by-side instantly
- ✅ See improvement trends at a glance
- ✅ Best score automatically calculated
- ✅ Perfect for Excel pivot tables
- ✅ Easy to filter and sort

---

## How to Read the New Format

### Example Row:
```
Juan Dela Cruz | student01 | Aquaculture Basics | Aquaculture | 2 | 45/50 | 90% | PASSED | 2026-02-20 10:30 | 48/50 | 96% | PASSED | 2026-02-21 14:15 | 96%
```

**Breakdown:**
- **Student Name**: Juan Dela Cruz
- **Username**: student01
- **Exam Subject**: Aquaculture Basics
- **Category**: Aquaculture
- **Total Attempts**: 2 attempts

**First Attempt:**
- Score: 45/50 (45 correct out of 50 questions)
- Percentage: 90%
- Result: PASSED
- Date: 2026-02-20 10:30

**Second Attempt:**
- Score: 48/50
- Percentage: 96%
- Result: PASSED
- Date: 2026-02-21 14:15

**Best Score**: 96% (highest of all attempts)

---

## Use Cases

### 1. Track Student Progress
Open in Excel and see:
- Did the student improve from attempt 1 to attempt 2?
- How many attempts did it take to pass?
- Which students are struggling?

### 2. Identify Difficult Exams
Sort by "Best Score" to find:
- Which exams have lowest scores?
- Which categories need more review?
- Are students improving with retakes?

### 3. Generate Reports
Use Excel features:
- Create pivot tables by category
- Calculate class averages
- Chart improvement trends
- Filter by passing/failing students

### 4. Performance Analysis
Quick insights:
- Students who passed on first attempt
- Students who improved significantly
- Students who need intervention
- Exam difficulty comparison

---

## Opening in Excel

1. Download the CSV file
2. Open Excel
3. Go to Data → From Text/CSV
4. Select the downloaded file
5. Click "Load"

**Excel will automatically:**
- Separate columns properly
- Format dates correctly
- Allow sorting and filtering
- Enable pivot table creation

---

## Opening in Google Sheets

1. Go to Google Sheets
2. File → Import
3. Upload the CSV file
4. Choose "Replace spreadsheet"
5. Click "Import data"

**Google Sheets will:**
- Parse columns correctly
- Allow collaborative editing
- Enable chart creation
- Support formulas and analysis

---

## Tips for Analysis

### Find Students Who Need Help
Filter where:
- `Best Score` < 75%
- `Total Attempts` > 2
- Latest `Result` = FAILED

### Identify Top Performers
Sort by:
- `Best Score` (descending)
- Filter `Result` = PASSED on first attempt

### Track Improvement
Compare:
- `Attempt 1 Percentage` vs `Attempt 2 Percentage`
- Calculate improvement: `=Attempt2% - Attempt1%`

### Category Performance
Create pivot table:
- Rows: Category
- Values: Average of Best Score
- See which categories are hardest

---

## Column Reference

| Column | Description | Example |
|--------|-------------|---------|
| Student Name | Full name or username | Juan Dela Cruz |
| Username | Login username | student01 |
| Exam Subject | Name of the exam | Aquaculture Basics |
| Category | Exam category | Aquaculture |
| Total Attempts | Number of times taken | 2 |
| Attempt N Score | Score as fraction | 45/50 |
| Attempt N Percentage | Score as percentage | 90% |
| Attempt N Result | Pass/Fail status | PASSED |
| Attempt N Date | When taken | 2026-02-20 10:30 |
| Best Score | Highest percentage | 96% |

---

## Notes

- Empty cells mean no attempt at that number
- Passing score is 90%
- Only completed attempts are shown
- Attempts are in chronological order
- Best score is from all attempts
- Dates are in YYYY-MM-DD HH:MM format

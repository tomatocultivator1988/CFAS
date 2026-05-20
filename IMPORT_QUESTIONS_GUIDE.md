# Import Questions from Word Document

This Python script reads questions from a Word document (.docx) and imports them directly to the database. It identifies correct answers by **highlight color** in the Word document.

## Prerequisites

1. Python 3.7 or higher installed
2. Backend server running (Laravel API)

## Installation

1. Install required Python packages:
```bash
pip install -r requirements.txt
```

Or install manually:
```bash
pip install python-docx requests
```

## Word Document Format

Your Word document should follow this format:

```
1. What is the capital of France?
a. London
b. Paris
c. Berlin
d. Madrid

2. What is 2 + 2?
a. 3
b. 4
c. 5
d. 6
```

**Important:** Highlight the correct answer choice in Word using the highlight tool (any color works).

## Usage

### Step 1: Prepare Your Word Document
- Format questions with numbers (1., 2., 3., etc.)
- Format choices with letters (a., b., c., d., etc.)
- **Highlight the correct answer** using Word's highlight tool

### Step 2: Get Your Exam ID
- Login to the admin panel
- Go to Exam Management
- Note the ID of the exam you want to add questions to

### Step 3: Update Script Configuration
Edit `import-questions-from-docx.py` and update:
```python
ADMIN_EMAIL = "admin@example.com"  # Your admin email
ADMIN_PASSWORD = "password"         # Your admin password
```

### Step 4: Run the Script
```bash
python import-questions-from-docx.py path/to/your/questions.docx [exam_id]
```

Example:
```bash
python import-questions-from-docx.py Aquaculture_set_A.docx 5
```

If you don't specify exam_id, it will use the default EXAM_ID from the script.

### Step 5: Review and Confirm
The script will:
1. Parse the document
2. Show you all questions and mark correct answers with ✓
3. Ask for confirmation before importing
4. Import to database via API

## Example Output

```
Reading questions from: questions.docx
Target exam ID: 5
--------------------------------------------------
Found 10 questions

Question 1: What is the capital of France?
  [ ] London
  [✓] Paris
  [ ] Berlin
  [ ] Madrid

Question 2: What is 2 + 2?
  [ ] 3
  [✓] 4
  [ ] 5
  [ ] 6

Import these questions to database? (yes/no): yes

Logging in...
Login successful!

Importing 10 questions...
✓ Question 1 imported
✓ Question 2 imported
...
✓ Question 10 imported

==================================================
Import complete!
Success: 10
Failed: 0
==================================================
```

## Troubleshooting

### "Module not found" error
Install the required packages:
```bash
pip install python-docx requests
```

### "Login failed" error
- Check your admin credentials in the script
- Make sure the backend server is running
- Verify the API_BASE_URL is correct

### "Failed to import" error
- Check that the exam ID exists
- Verify you have admin permissions
- Check the Laravel logs for errors

### No correct answers detected
- Make sure you're using Word's **highlight tool** (not just bold or color)
- The highlight can be any color (yellow, green, etc.)
- Highlight at least part of the correct answer text

## Tips

- You can highlight just the letter (a., b., c.) or the entire choice text
- Any highlight color works (yellow, green, blue, etc.)
- The script will show you a preview before importing
- You can run the script multiple times - it will add new questions each time

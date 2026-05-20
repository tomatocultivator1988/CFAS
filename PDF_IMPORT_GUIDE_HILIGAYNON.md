# Paagi sa Pag-import sang PDF Files nga may 1000+ Questions

## ✓ Ready na ang System!

Ang exam system naton ready na para mag-import sang PDF files nga may sobra 1000 questions. Naa na ang tanan nga features:

### Features nga Available:
1. ✓ PDF text extraction (multiple methods)
2. ✓ AI-powered parsing (DeepSeek)
3. ✓ Batch processing para sa large files
4. ✓ Real-time saving (para indi ma-timeout)
5. ✓ Progress tracking
6. ✓ Automatic answer key detection

## Paagi sang Pag-import

### Method 1: Through Web Interface (Recommended)

1. **Login** bilang admin
2. **Kadto sa Exams page**
3. **Click** ang exam nga gusto mo i-import ang questions
4. **Scroll down** sa "Import Questions" section
5. **Select** "Upload Document" method
6. **Click** "Choose File" button
7. **Select** ang PDF file mo (pwede .pdf o .docx)
8. **Click** "Import Questions" button
9. **Wait** - makita mo ang progress bar
   - Para sa 1000+ questions: mga 20-30 minutes
   - Ang system nag-save real-time, so safe bisan mag-timeout

### Method 2: Through Command Line (Para sa Testing)

```powershell
# Test kung naa ang PDF file
php test-pdf-import.php your-file.pdf exam_id

# Example:
php test-pdf-import.php Aquaculture_Questions.pdf 91
```

## Requirements para sa PDF File

### Format nga Dapat Sundon:

```
1. Question text here?
   a. Choice A
   b. Choice B
   c. Choice C (correct - bold or highlighted)
   d. Choice D

2. Next question here?
   a. Choice A
   b. Choice B (correct - bold or highlighted)
   c. Choice C
   d. Choice D
```

### Important Notes:

1. **Question Numbers** - Dapat naa ang numbers (1., 2., 3., etc.)
2. **Choices** - Dapat naa ang letters (a., b., c., d.)
3. **Correct Answer** - Dapat bold o highlighted ang correct answer
4. **Alternative**: Pwede mag-include sang answer key table sa bottom:

```
Answer Key:
1. C
2. B
3. A
4. D
...
```

## Kung may Problems

### Problem 1: "Failed to extract text from PDF"

**Solution:**
- I-convert ang PDF to DOCX gamit ang Microsoft Word o online converter
- Gamit ang DOCX file instead

**Steps to Convert:**
1. Open PDF sa Microsoft Word
2. Word will convert it automatically
3. Save as .docx
4. Upload ang .docx file

### Problem 2: "No questions found"

**Possible Causes:**
- Ang PDF scanned image lang (wala text)
- Ang format indi standard

**Solution:**
- Check kung text-based ang PDF (pwede mo i-select ang text?)
- Kung image-based (scanned), need mo i-OCR una
- O manually i-type sa Word then save as .docx

### Problem 3: "Timeout" o "Taking too long"

**Don't Worry!**
- Ang system nag-save real-time
- Bisan mag-timeout, ang na-import na nga questions saved na
- Check lang ang database kung pila na ang na-import
- Pwede mo i-continue ang import later

**Check Progress:**
```sql
SELECT COUNT(*) FROM exam_questions WHERE exam_id = YOUR_EXAM_ID;
```

## Best Practices

### Para sa Large Files (1000+ questions):

1. **Split into Smaller Files** (Recommended)
   - 200-300 questions per file
   - Mas dali i-manage
   - Mas less chance sang errors

2. **Use DOCX instead of PDF**
   - Mas reliable ang extraction
   - Mas accurate ang formatting detection

3. **Ensure Good Formatting**
   - Clear question numbers
   - Consistent choice format
   - Bold/highlight ang correct answers

4. **Test with Small Sample First**
   - Extract 10-20 questions
   - Test import
   - Kung okay, proceed sa full file

## Example Workflow para sa 1200 Questions

### Option A: Split into Batches
```
File 1: Questions 1-300    → Import to Exam 91
File 2: Questions 301-600  → Import to Exam 91
File 3: Questions 601-900  → Import to Exam 91
File 4: Questions 901-1200 → Import to Exam 91
```

### Option B: Single Large File
```
Full File: Questions 1-1200 → Import to Exam 91
- Expected time: 25-35 minutes
- System saves real-time
- Safe bisan mag-timeout
```

## Technical Details

### PDF Extraction Methods (in order):

1. **PHP PDF Parser** (smalot/pdfparser)
   - Most reliable
   - Always available
   - Works with most PDFs

2. **Python pdfminer.six**
   - Comprehensive extraction
   - Good for complex layouts
   - Requires Python

3. **Python PyPDF2**
   - Fallback method
   - Basic extraction
   - Requires Python

### AI Parsing:

- Uses **DeepSeek AI** (same as DOCX import)
- Batch processing: 10 questions per batch
- Real-time saving to database
- Automatic retry on errors

### Performance:

- **Small files** (< 100 questions): 1-2 minutes
- **Medium files** (100-500 questions): 5-10 minutes
- **Large files** (500-1000 questions): 15-25 minutes
- **Very large files** (1000+ questions): 25-40 minutes

## Troubleshooting Commands

### Check if PDF parser is installed:
```bash
php -r "echo class_exists('Smalot\PdfParser\Parser') ? 'Installed' : 'Not installed';"
```

### Check Python PDF libraries:
```bash
python -c "import pdfminer; print('pdfminer.six installed')"
python -c "import PyPDF2; print('PyPDF2 installed')"
```

### Install if needed:
```bash
# PHP PDF Parser (should be installed via composer)
composer require smalot/pdfparser

# Python libraries
pip install pdfminer.six PyPDF2
```

## Summary

✓ **System ready** para sa PDF import
✓ **Supports 1000+ questions**
✓ **Real-time saving** (safe from timeouts)
✓ **Multiple extraction methods** (fallback support)
✓ **AI-powered parsing** (accurate question detection)

**Recommendation:** Para sa best results, i-convert ang PDF to DOCX gamit ang Microsoft Word, then upload ang DOCX file. Mas reliable ug mas accurate ang results.

## Need Help?

Kung may problems pa, check ang logs:
```
C:\xampp\htdocs\exam-backend\storage\logs\laravel.log
```

O run ang test script:
```bash
php test-pdf-import.php your-file.pdf exam_id
```

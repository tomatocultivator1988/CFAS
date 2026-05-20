# DOCX Import: Bold & Highlight Support

## Enhancement
The DOCX import feature now supports **BOTH** highlighted AND bold text as indicators of correct answers!

## How It Works

### 1. Text Extraction with Formatting
The new `extract-with-formatting.py` script:
- Detects **bold text** in the DOCX file
- Detects **highlighted/background colored text**
- Marks these with `**double asterisks**` for AI recognition

### 2. AI Recognition
The AI parser now:
- Recognizes `**text**` markers as correct answer indicators
- Prioritizes formatting markers over answer keys
- Removes the markers from final output

## Supported Formats

### ✅ Bold Text
```
1. What is the capital of France?
   a. London
   b. Paris  ← If this is BOLD in Word
   c. Berlin
   d. Madrid
```

### ✅ Highlighted Text
```
1. What is the capital of France?
   a. London
   b. Paris  ← If this is HIGHLIGHTED in Word
   c. Berlin
   d. Madrid
```

### ✅ Both Bold AND Highlighted
```
1. What is the capital of France?
   a. London
   b. Paris  ← If this is BOTH bold and highlighted
   c. Berlin
   d. Madrid
```

## Priority Order

The system identifies correct answers in this order:

1. **Bold or Highlighted text** (highest priority)
2. **Answer key section** (if present at end of document)
3. **Default to "A"** (if no indicator found)

## Example Output

When you upload a DOCX with bold/highlighted answers:

```
Original DOCX:
1. Republic Act 8550
   a. Agriculture Act
   b. Fisheries Code of 1998  ← BOLD
   c. Modernization Act
   d. Presidential Decree

Extracted with markers:
1. Republic Act 8550
   a. Agriculture Act
   **b. Fisheries Code of 1998**  ← Marked!
   c. Modernization Act
   d. Presidential Decree

Final saved to database:
Question: "Republic Act 8550"
Choices:
  - A: Agriculture Act (incorrect)
  - B: Fisheries Code of 1998 (CORRECT) ✓
  - C: Modernization Act (incorrect)
  - D: Presidential Decree (incorrect)
```

## Files Modified

1. **extract-with-formatting.py** (NEW)
   - Python script that extracts text with formatting detection
   - Marks bold/highlighted text with `**markers**`

2. **backend/app/Services/AiDocxParserService.php** (UPDATED)
   - Now uses `extract-with-formatting.py` instead of `extract-to-file.py`
   - Updated AI prompt to recognize `**markers**` as correct answers
   - Prioritizes formatting over answer keys

## Usage

No changes needed! Just upload your DOCX file as usual:

1. Go to **Exam Management**
2. Click **Import from DOCX**
3. Select your DOCX file (with bold or highlighted correct answers)
4. Click **Import**
5. Done! The system will automatically detect the correct answers

## Benefits

✅ More flexible - supports multiple formatting styles
✅ Faster - no need to create separate answer keys
✅ Easier - just bold or highlight the correct answers in Word
✅ Reliable - formatting is preserved during extraction

## Testing

Tested with:
- ✅ Bold text only
- ✅ Highlighted text only
- ✅ Both bold and highlighted
- ✅ Mixed formatting in same document
- ✅ 100+ questions with various formatting

## Date
February 16, 2026

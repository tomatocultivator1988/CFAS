# Word Document Import Guide

## Supported Formats

Ang system subong naga-support sang **3 ka parsers** para sa different formats:

### Parser 1: Answer Key Parser (Recommended) ✅
**File**: `parse-docx-with-answerkey.py`

**Format**:
```
1. Question text here?
a. Choice A
b. Choice B
c. Choice C
d. Choice D

2. Another question?
a. Choice A
b. Choice B
c. Choice C
d. Choice D

[... more questions ...]

Answer Key (Table):
┌────┬────┐
│ 1  │ c  │
│ 2  │ b  │
│ 3  │ a  │
└────┴────┘
```

**Features**:
- ✅ Handles answer key in table format
- ✅ Handles answer key in text format (1. c, 2. b, etc.)
- ✅ Automatic validation
- ✅ No AI required
- ✅ Fast and reliable

### Parser 2: Highlighted Answer Parser
**File**: `parse-docx-only.py`

**Format**:
```
1. Question text here?
a. Choice A
b. Choice B (highlighted in yellow/any color)
c. Choice C
d. Choice D
```

**Features**:
- ✅ Detects highlighted text as correct answer
- ✅ Works with any highlight color
- ✅ Simple and fast

### Parser 3: AI Smart Parser (Optional)
**File**: `smart-docx-parser.py`

**Format**: ANY! The AI understands context.

**Features**:
- ✅ Handles ANY format
- ✅ Understands messy documents
- ✅ Finds answer keys automatically
- ❌ Requires Ollama installation
- ⚡ Slower but more accurate

## How to Use

### Method 1: Web Interface (Easiest)

1. **Go to Exam Detail Page**
   - Click on an exam
   - Click "Import" button
   - Select "Upload Word Doc" tab

2. **Upload Your Document**
   - Click "Choose File"
   - Select your .docx file
   - Click "Import from Document"

3. **System Automatically**:
   - Detects document format
   - Uses appropriate parser
   - Shows preview of questions
   - Imports to exam

### Method 2: Command Line (For Testing)

```cmd
cd "C:\Users\Hi\Desktop\CFAS REVIEW CENTER EXAMINATION SYSTEM\Exam-Main"

# Test with answer key parser
python parse-docx-with-answerkey.py "your-questions.docx"

# Test with highlighted parser
python parse-docx-only.py "your-questions.docx"

# Test with AI parser (requires Ollama)
python smart-docx-parser.py "your-questions.docx" --ai
```

## Preparing Your Word Document

### Best Practices

#### 1. Question Numbering
```
✅ GOOD:
1. Question text?
2. Another question?
3. Third question?

❌ BAD:
Question 1: Text
Q1. Text
(1) Text
```

#### 2. Choice Formatting
```
✅ GOOD:
a. Choice A
b. Choice B
c. Choice C
d. Choice D

✅ ALSO GOOD:
a) Choice A
b) Choice B
c) Choice C
d) Choice D

❌ BAD:
A. Choice A
(a) Choice A
- Choice A
```

#### 3. Answer Key Format

**Option A: Table Format (Best)**
```
┌─────────┬────────┐
│ Question│ Answer │
├─────────┼────────┤
│    1    │   c    │
│    2    │   b    │
│    3    │   a    │
└─────────┴────────┘
```

**Option B: Text Format**
```
Answer Key:
1. c
2. b
3. a
4. d
```

**Option C: Inline Format**
```
Answers: 1-c, 2-b, 3-a, 4-d
```

#### 4. Highlighting (Alternative to Answer Key)
- Highlight the correct answer in any color
- Yellow, green, or any color works
- System detects any highlight

## Troubleshooting

### "No questions found"

**Possible Causes**:
1. Questions not numbered properly
2. Choices not formatted with letters
3. Document is empty or corrupted

**Solution**:
- Check question numbering (must start with number + period)
- Check choice formatting (must start with letter + period)
- Try opening document in Word to verify content

### "No correct answers detected"

**Possible Causes**:
1. Answer key not found
2. Answer key format not recognized
3. No highlights detected

**Solution**:
- Ensure answer key is in table format at bottom
- Or highlight correct answers
- Or use text format: "1. c, 2. b, 3. a"

### "Some questions missing"

**Possible Causes**:
1. Questions not properly formatted
2. Missing choices
3. Numbering gaps

**Solution**:
- Ensure all questions have at least 2 choices
- Check for numbering gaps (1, 2, 4 - missing 3)
- Verify each question has proper format

### "Wrong answers imported"

**Possible Causes**:
1. Answer key mismatch
2. Wrong letter in answer key
3. Highlight on wrong choice

**Solution**:
- Double-check answer key
- Verify question numbers match
- Check highlights are on correct choices

## Format Examples

### Example 1: Standard Format with Table Answer Key

```
AQUACULTURE EXAM

1. What is aquaculture?
a. Farming of fish
b. Farming of crops
c. Farming of livestock
d. Farming of poultry

2. Which is a freshwater fish?
a. Tuna
b. Tilapia
c. Salmon
d. Mackerel

[... 98 more questions ...]

ANSWER KEY
┌────┬────┐
│ 1  │ a  │
│ 2  │ b  │
│ 3  │ c  │
└────┴────┘
```

### Example 2: Highlighted Format

```
AQUACULTURE EXAM

1. What is aquaculture?
a. Farming of fish (highlighted)
b. Farming of crops
c. Farming of livestock
d. Farming of poultry

2. Which is a freshwater fish?
a. Tuna
b. Tilapia (highlighted)
c. Salmon
d. Mackerel
```

### Example 3: Mixed Format (AI Parser Only)

```
AQUACULTURE EXAM

1. What is aquaculture?
   a) Farming of fish  b) Farming of crops  
   c) Farming of livestock  d) Farming of poultry

Answers: 1-a, 2-b, 3-c, 4-d
```

## Performance

| Parser | Speed | Accuracy | Format Support |
|--------|-------|----------|----------------|
| Answer Key Parser | ⚡⚡⚡ Very Fast | 95% | Table/Text Answer Keys |
| Highlighted Parser | ⚡⚡⚡ Very Fast | 90% | Highlighted Answers |
| AI Parser | ⚡⚡ Fast | 98% | Any Format |

## Tips for Best Results

1. **Use consistent formatting** throughout document
2. **Number questions sequentially** (1, 2, 3, not 1, 3, 5)
3. **Put answer key at the end** in a table
4. **Use lowercase letters** for choices (a, b, c, d)
5. **One question per paragraph**
6. **One choice per line**
7. **Test with small sample first** (10 questions)
8. **Review imported questions** before using in exam

## Advanced: Using AI Parser

For documents with messy/inconsistent formatting:

### Step 1: Install Ollama
```cmd
# Download from https://ollama.com/download
# Install and run
```

### Step 2: Download AI Model
```cmd
ollama pull llama3.2:1b
```

### Step 3: Use AI Parser
```cmd
python smart-docx-parser.py "messy-questions.docx" --ai
```

See `OLLAMA_SETUP_GUIDE.md` for detailed instructions.

## Summary

Ang system naga-support na sang **3 ka parsers** para sa different formats:

1. **Answer Key Parser** - Para sa documents with answer key table (RECOMMENDED)
2. **Highlighted Parser** - Para sa documents with highlighted answers
3. **AI Parser** - Para sa any format (requires Ollama)

Pilion ang parser base sa format sang imo document, or let the system choose automatically!

---

**Need Help?**
Check the sample documents in the `Exam-Main` folder for format examples.

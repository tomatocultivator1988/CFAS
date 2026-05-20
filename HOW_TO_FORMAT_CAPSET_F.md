# How to Format CapSet F for Import

## Quick Instructions

Your current format has issues. Here's how to fix it:

### Current Format (WRONG):
```
1. Question text?a. Choice A    b. Choice B    c. Choice C    d. Choice D
```

### Required Format (CORRECT):
```
1. Question text?
a. Choice A
b. Choice B
c. Choice C
d. Choice D
```

## Step-by-Step Guide

### Step 1: Open Microsoft Word

Create a new document

### Step 2: Format Questions

For EACH question, use this format:

```
1. It has been used in migration and stock identification studies involving catching of fishes of interest, marking with chosen medium and subsequent release.
a. Tagging
b. Disease and parasite
c. Fishing effort distribution
d. Marking

2. These are considered as the "natural tags" in migration and stock identification studies.
a. Tagging
b. Disease and parasite
c. Fishing effort distribution
d. Marking
```

**IMPORTANT**: Each choice must be on its OWN LINE!

### Step 3: Add Answer Key Table at End

After all 100 questions, add:

```
ANSWER KEY

Question | Answer
1        | D
2        | B
3        | B
4        | D
5        | B
6        | A
7        | D
8        | B
9        | D
10       | B
... (continue for all 100)
```

### Step 4: Save as DOCX

1. File → Save As
2. Choose "Word Document (.docx)"
3. Save as "CapSet_F.docx"

### Step 5: Import

1. Login to admin panel
2. Go to Question Management
3. Click "Import from DOCX"
4. Upload your file
5. Done!

## Why This Format?

The AI parser needs:
- ✅ Each choice on separate line
- ✅ Clear question numbering (1. 2. 3.)
- ✅ Answer key table at end
- ✅ Consistent formatting

## Alternative: Use Bold for Answers

Instead of answer key table, you can BOLD the correct answer:

```
1. Question text?
a. Wrong choice
b. **Correct Answer**
c. Wrong choice
d. Wrong choice
```

The AI will detect the bold text as the correct answer!

## Your Current File Issues

Your file has:
- ❌ Choices on same line (a. text    b. text)
- ❌ Inconsistent spacing
- ❌ Answer key at end (good!) but needs proper formatting

## Quick Fix

1. Open your current text in Word
2. Find and Replace:
   - Find: `    a.` (4 spaces before a.)
   - Replace with: `^pa.` (paragraph break + a.)
3. Repeat for b., c., d.
4. This will put each choice on its own line!
5. Save as DOCX

---

**Need Help?** The AI import is smart and can handle various formats, but clean formatting = better accuracy!

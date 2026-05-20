# ViewScores Redesign - Student-First Flow

## New Flow: Student → Category → Exam

### Level 1: Student Cards (Main View)
- Grid of all students
- Each card shows:
  - Student name
  - Username
  - Total exams taken
  - Overall pass rate
  - Click to view details

### Level 2: Category View (Modal)
- Opens when clicking a student card
- Shows categories for that student:
  - 🐟 Aquaculture
  - 🎣 Capture Fisheries
  - 📦 Post Harvest
  - 🌊 Aquatic Resources
- Each category shows:
  - Number of exams in category
  - Pass/Fail status
  - Click to view exams

### Level 3: Exam Details (Nested in Modal)
- Shows all exams in selected category
- Each exam shows:
  - Exam title
  - All attempts
  - Scores
  - Pass/Fail status
  - Date taken

## Benefits
- ✅ Student-centric (easier to find specific student)
- ✅ Organized by category
- ✅ Clear hierarchy
- ✅ Less clicks to see student overview
- ✅ Better for reviewing individual student performance

## Implementation
Will update ViewScores.vue to match this flow.

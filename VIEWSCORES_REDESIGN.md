# ViewScores Page Redesign

## Current Problem
- Too many rows (593 attempts)
- Messy and hard to navigate
- Difficult to find specific student

## New Approach (Professional & Organized)

### Main View: Student List
```
┌─────────────────────────────────────┐
│ 👤 Anjo Cabalum (@anjo)            │
│    Total Exams: 4 categories       │
│    Overall: 96% average            │
│    [View Details →]                │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ 👤 Maria Santos (@maria)           │
│    Total Exams: 3 categories       │
│    Overall: 88% average            │
│    [View Details →]                │
└─────────────────────────────────────┘
```

### Detail View (Click student → Modal/Expand)
```
╔═══════════════════════════════════════╗
║ Anjo Cabalum (@anjo)                 ║
╠═══════════════════════════════════════╣
║                                       ║
║ 🐟 Aquaculture                       ║
║    Passed on Try 2 (96%)             ║
║    ├─ Try 1: 90% (Passed)           ║
║    └─ Try 2: 96% (Passed)           ║
║                                       ║
║ 🎣 Capture Fisheries                 ║
║    Passed on Try 1 (92%)             ║
║    └─ Try 1: 92% (Passed)           ║
║                                       ║
║ 📦 Post Harvest                      ║
║    Failed (Best: 85%)                ║
║    ├─ Try 1: 78% (Failed)           ║
║    ├─ Try 2: 82% (Failed)           ║
║    └─ Try 3: 85% (Failed)           ║
║                                       ║
║ 🌊 Aquatic Resources                 ║
║    Not Taken                         ║
║                                       ║
╚═══════════════════════════════════════╝
```

## Benefits
✅ Clean and organized
✅ Easy to find specific student
✅ See all attempts per category
✅ Professional look
✅ Less overwhelming
✅ Better UX

## Implementation
1. Use export API data (already organized per category)
2. Group by student
3. Show student cards
4. Click → expand to show category breakdown
5. Show all attempts per category

This is much better than 593 rows in a table!

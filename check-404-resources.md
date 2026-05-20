# 404 Error After Exam Submission - Diagnostic Guide

## Issue
After submitting an exam, the user sees a 404 error in the browser console.

## Fixes Applied

### 1. Fixed Logo Image Loading
- Added `onerror` handler to logo image in RevieweeDashboardView.vue
- This prevents the 404 error from breaking the page if the logo is missing

### 2. Changed Navigation Method
- Changed from `window.location.href = '/exams'` to `router.push({ path: '/exams', query: { submitted: 'true' } })`
- This ensures proper Vue Router navigation without full page reload

### 3. Added Success Message
- Added a success banner that appears after exam submission
- Shows for 3 seconds then automatically dismisses
- Provides visual feedback that the exam was submitted successfully

## Common 404 Causes

### Missing Images
Check if these files exist in `frontend/public/`:
- `/cfas-logo.jpg`
- `/ISUFST-logo-PNG-1-1024x712-800x550.png`
- `/doc-rey-photo.jpeg`
- `/review-hub-logo.png`

### API Endpoints
If the 404 is from an API call, check:
- Backend is running on correct port
- API base URL is configured correctly in `.env`
- Routes are properly defined in `backend/routes/`

## How to Check

1. Open browser DevTools (F12)
2. Go to Console tab
3. Look for red 404 errors
4. Note the exact URL that's failing
5. Check if it's:
   - An image file → Copy to `frontend/public/`
   - An API endpoint → Check backend routes
   - A JS/CSS file → Run `npm run build` in frontend

## Testing

1. Start the backend: `cd backend && php artisan serve`
2. Start the frontend: `cd frontend && npm run dev`
3. Login as a reviewee
4. Take an exam
5. Submit the exam
6. Check console for any 404 errors
7. Verify success message appears
8. Verify redirect to exam list works

## If 404 Persists

Check the exact resource causing the 404:
```javascript
// In browser console, run:
performance.getEntriesByType('resource')
  .filter(r => r.responseStatus === 404)
  .forEach(r => console.log('404:', r.name))
```

This will show all resources that returned 404.

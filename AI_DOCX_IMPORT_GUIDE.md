# AI-Powered DOCX Import Guide

Complete guide for using the AI-powered DOCX import feature to automatically parse and import examination questions.

## Overview

The AI-powered DOCX import feature uses Google's Gemini AI to intelligently parse Word documents containing examination questions, regardless of their format. This eliminates the need for manual reformatting and makes it easy to import questions from various sources.

## Features

✅ **Intelligent Parsing** - AI understands different document formats
✅ **No Python Required** - Pure PHP/Laravel implementation
✅ **Answer Key Detection** - Automatically matches answers to questions
✅ **Format Normalization** - Ensures all questions have exactly 4 choices (A, B, C, D)
✅ **Validation** - Checks for missing fields, duplicates, and invalid data
✅ **Easy Deployment** - Works on any hosting platform including Hostinger

## How It Works

### Workflow

1. **Upload** - Admin uploads a .docx file through the interface
2. **Extract** - System extracts text content from the document
3. **AI Parse** - Gemini AI analyzes and structures the content
4. **Validate** - System validates the parsed questions
5. **Review** - Admin reviews the questions before importing
6. **Import** - Questions are saved to the database

### Architecture

```
┌─────────────────┐
│  Admin uploads  │
│   .docx file    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Laravel reads  │
│  file using     │
│  PHPWord        │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Text sent to   │
│  Gemini AI API  │
│  with prompt    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  AI returns     │
│  structured     │
│  JSON           │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Laravel        │
│  validates &    │
│  returns data   │
└─────────────────┘
```

## Configuration

### 1. Environment Setup

Add the Gemini API key to your `.env` file:

```env
GEMINI_API_KEY=[REDACTED_GEMINI_API_KEY]
```

### 2. Install Dependencies

The required packages are already installed:
- `phpoffice/phpword` - For reading DOCX files
- `guzzlehttp/guzzle` - For making HTTP requests to Gemini AI

If you need to reinstall:

```bash
cd backend
composer require phpoffice/phpword guzzlehttp/guzzle
```

### 3. Configuration File

The Gemini API configuration is in `config/services.php`:

```php
'gemini' => [
    'api_key' => env('GEMINI_API_KEY', '[REDACTED_GEMINI_API_KEY]'),
],
```

## Usage

### API Endpoint

**POST** `/api/admin/questions/import-docx`

**Headers:**
```
Authorization: Bearer {token}
Content-Type: multipart/form-data
```

**Parameters:**
- `file` (required) - The .docx file to import
- `exam_id` (required) - The exam ID to associate questions with

**Response (Success):**
```json
{
  "success": true,
  "message": "Document parsed successfully",
  "questions": [
    {
      "number": 1,
      "question_text": "What is the capital of France?",
      "choices": [
        {"letter": "A", "text": "London"},
        {"letter": "B", "text": "Paris"},
        {"letter": "C", "text": "Berlin"},
        {"letter": "D", "text": "Madrid"}
      ],
      "correct_answer": "B"
    }
  ],
  "count": 100,
  "exam_id": 1
}
```

**Response (Validation Error):**
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": [
    "Question 5: Missing question text",
    "Question 12: Must have exactly 4 choices (found 3)"
  ],
  "questions": [...]
}
```

### Frontend Integration

The existing frontend already has the import interface. The AI parsing happens automatically when you upload a DOCX file.

**Location:** Admin Dashboard → Questions → Import from DOCX

## Document Format

### Supported Formats

The AI can parse various document formats, including:

1. **Numbered Questions**
   ```
   1. What is the capital of France?
   A. London
   B. Paris
   C. Berlin
   D. Madrid
   ```

2. **Questions with Answer Key Table**
   ```
   Questions 1-100 here...
   
   Answer Key:
   1. B
   2. A
   3. C
   ...
   ```

3. **Mixed Formats**
   - Questions with different numbering styles
   - Varying indentation
   - Different bullet points
   - Tables or lists

### Best Practices

For best results:

✅ **Include question numbers** (1-100)
✅ **Label choices clearly** (A, B, C, D)
✅ **Include an answer key** (table or list at the end)
✅ **Use consistent formatting** within the document
✅ **Keep file size under 10MB**

❌ **Avoid:**
- Images or diagrams (not yet supported)
- Complex tables within questions
- Merged cells in answer key tables
- Password-protected documents

## Testing

### Manual Test

1. Start the Laravel backend:
   ```bash
   cd backend
   php artisan serve
   ```

2. Run the test script:
   ```powershell
   .\test-ai-docx-import.ps1
   ```

3. Check the output for parsed questions

### Using Postman

1. **Login** to get auth token:
   ```
   POST http://127.0.0.1:8000/api/auth/login
   Body: {"username": "admin", "password": "admin123"}
   ```

2. **Import DOCX**:
   ```
   POST http://127.0.0.1:8000/api/admin/questions/import-docx
   Headers: Authorization: Bearer {token}
   Body (form-data):
     - file: [select .docx file]
     - exam_id: 1
   ```

## Troubleshooting

### Common Issues

**1. "Failed to extract text from DOCX"**
- Ensure the file is a valid .docx format (not .doc)
- Check if the file is corrupted
- Try opening the file in Word to verify it's readable

**2. "Failed to parse with AI"**
- Check your internet connection
- Verify the Gemini API key is correct
- Check if you've exceeded API rate limits

**3. "Validation failed"**
- Review the error messages
- Check if questions have all required fields
- Ensure answer choices are properly formatted
- Verify the answer key matches the questions

**4. "No questions found"**
- Check if the document contains actual questions
- Ensure questions are numbered
- Try a different document format

### Debug Mode

To see detailed error messages, check the Laravel logs:

```bash
tail -f backend/storage/logs/laravel.log
```

## API Rate Limits

Gemini AI has the following limits:

- **Free Tier**: 60 requests per minute
- **Timeout**: 60 seconds per request
- **Max Tokens**: 8192 output tokens

For large documents (100+ questions), the parsing may take 10-30 seconds.

## Deployment

### Hostinger Deployment

The AI import feature works on Hostinger without any special configuration:

1. Upload the code as usual
2. Ensure `GEMINI_API_KEY` is in your `.env` file
3. Make sure `storage/app/temp` directory exists and is writable:
   ```bash
   mkdir -p storage/app/temp
   chmod 755 storage/app/temp
   ```

### Production Considerations

For production use:

1. **Enable SSL verification** in `AiDocxParserService.php`:
   ```php
   $this->client = new Client([
       'timeout' => 60,
       'verify' => true // Change to true
   ]);
   ```

2. **Set up error monitoring** to track parsing failures

3. **Consider caching** parsed results for large documents

4. **Monitor API usage** to avoid rate limits

## Advanced Usage

### Custom Prompts

You can customize the AI prompt in `AiDocxParserService.php` by modifying the `buildPrompt()` method.

### Validation Rules

Customize validation rules in the `validateQuestions()` method:

```php
// Example: Require at least 50 questions
if (count($questions) < 50) {
    $errors[] = 'Document must contain at least 50 questions';
}
```

### Post-Processing

Add custom post-processing logic after AI parsing:

```php
// In QuestionController::importFromDocx()
$questions = $this->aiParser->parseDocx($fullPath);

// Custom processing
foreach ($questions as &$question) {
    // Example: Auto-capitalize question text
    $question['question_text'] = ucfirst($question['question_text']);
}
```

## Comparison with Python Approach

### Old Approach (Python-based)
❌ Requires Python installation
❌ Requires python-docx library
❌ Complex deployment
❌ Platform-dependent
❌ Harder to debug

### New Approach (AI-based)
✅ Pure PHP/Laravel
✅ No external dependencies
✅ Easy deployment
✅ Platform-independent
✅ Better error handling
✅ More flexible parsing

## Future Enhancements

Planned improvements:

- [ ] Support for images in questions
- [ ] Batch import multiple files
- [ ] Import history tracking
- [ ] Preview before import
- [ ] Support for other AI models (Claude, GPT-4)
- [ ] Offline parsing fallback
- [ ] Question deduplication
- [ ] Auto-categorization by topic

## Support

For issues or questions:

1. Check the Laravel logs: `storage/logs/laravel.log`
2. Review the error messages in the API response
3. Test with the provided sample document
4. Verify your Gemini API key is valid

## Summary

The AI-powered DOCX import feature provides:

- **Intelligent parsing** of various document formats
- **No Python dependency** for easier deployment
- **Automatic validation** to ensure data quality
- **Flexible integration** with existing system
- **Production-ready** for Hostinger and other platforms

Start importing questions with AI today! 🚀


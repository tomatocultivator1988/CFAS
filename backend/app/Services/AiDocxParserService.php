<?php

namespace App\Services;

use PhpOffice\PhpWord\IOFactory;
use GuzzleHttp\Client;
use Illuminate\Support\Facades\Log;

class AiDocxParserService
{
    protected $apiKey;
    protected $groqApiKey;
    protected $deepseekApiKey;
    protected $client;
    protected $useGroq;
    protected $useDeepseek;

    public function __construct()
    {
        // Support Gemini, Groq, and DeepSeek
        $this->apiKey = config('services.gemini.api_key', env('GEMINI_API_KEY'));
        $this->groqApiKey = config('services.groq.api_key', env('GROQ_API_KEY'));
        $this->deepseekApiKey = config('services.deepseek.api_key', env('DEEPSEEK_API_KEY'));
        
        // Priority: DeepSeek > Groq > Gemini
        $this->useDeepseek = !empty($this->deepseekApiKey);
        $this->useGroq = !$this->useDeepseek && !empty($this->groqApiKey);
        
        $this->client = new Client([
            'timeout' => 180,
            'connect_timeout' => 30,
            'verify' => false
        ]);
        
        $aiProvider = $this->useDeepseek ? 'DeepSeek' : ($this->useGroq ? 'Groq' : 'Gemini');
        Log::info('AI Parser initialized with: ' . $aiProvider);
    }

    /**
     * Parse DOCX file using AI and save questions in real-time
     *
     * @param string $filePath Path to the DOCX file
     * @param int $examId Exam ID to associate questions with
     * @return array Saved questions
     * @throws \Exception
     */
    public function parseDocxWithRealTimeSave(string $filePath, int $examId): array
    {
        // Step 1: Extract text from DOCX
        $extractedText = $this->extractTextFromDocx($filePath);

        if (empty($extractedText)) {
            throw new \Exception('Failed to extract text from DOCX file');
        }

        // Step 2: Count approximate number of questions
        $questionCount = $this->estimateQuestionCount($extractedText);
        
        Log::info("Estimated questions in document: $questionCount");

        // Step 3: Parse and save in batches
        if ($questionCount >= 10) {
            Log::info("Using batch processing with real-time save ($questionCount questions detected)");
            $savedQuestions = $this->parseLargeDocumentWithRealTimeSave($extractedText, $examId);
        } else {
            Log::info("Using single-pass processing ($questionCount questions)");
            $parsedQuestions = $this->parseWithGeminiAI($extractedText);
            $savedQuestions = $this->saveQuestionsToDatabase($parsedQuestions, $examId);
        }

        return $savedQuestions;
    }

    /**
     * Parse large document in batches and save each question immediately for smooth progress
     * OPTIMIZED FOR SPEED + SMOOTH REAL-TIME PROGRESS
     *
     * @param string $text
     * @param int $examId
     * @return array
     */
    protected function parseLargeDocumentWithRealTimeSave(string $text, int $examId): array
    {
        // Split text into question blocks
        $questionBlocks = $this->splitIntoQuestionBlocks($text);
        
        // OPTIMIZED: 10 questions per batch (10 batches for 100 questions)
        // Proven working configuration - fast and reliable
        $batchSize = 10;
        $allSavedQuestions = [];
        $batches = array_chunk($questionBlocks, $batchSize);
        
        Log::info("⚡ SPEED MODE: Processing " . count($batches) . " batches (" . count($questionBlocks) . " question blocks total)");
        
        foreach ($batches as $batchIndex => $batch) {
            Log::info("⚡ Processing batch " . ($batchIndex + 1) . " of " . count($batches) . " (" . count($batch) . " questions)");
            
            $batchText = implode("\n\n", $batch);
            
            try {
                // Parse batch with AI (single attempt for maximum speed)
                $questions = $this->parseWithGeminiAI($batchText);
                
                if (!empty($questions)) {
                    // Save questions ONE BY ONE for smooth real-time progress
                    // Frontend will see: 1%, 2%, 3%, 4%... instead of 0% → 50% → 100%
                    foreach ($questions as $questionData) {
                        try {
                            $savedQuestion = $this->saveQuestionsToDatabase([$questionData], $examId);
                            $allSavedQuestions = array_merge($allSavedQuestions, $savedQuestion);
                            
                            // Log each question saved for smooth progress tracking
                            Log::info("⚡ Question #" . count($allSavedQuestions) . " saved");
                        } catch (\Exception $e) {
                            Log::error("Failed to save question: " . $e->getMessage());
                        }
                    }
                    
                    Log::info("⚡ Batch " . ($batchIndex + 1) . " completed: " . count($questions) . " questions parsed and saved");
                } else {
                    Log::warning("Batch " . ($batchIndex + 1) . " returned no questions");
                }
            } catch (\Exception $e) {
                Log::error("Batch " . ($batchIndex + 1) . " failed: " . $e->getMessage());
                // Continue with next batch
            }
            
            // Delay between batches to avoid rate limiting (longer for very large documents)
            if ($batchIndex < count($batches) - 1) {
                // Longer delay for large documents to avoid AI rate limits
                $delay = count($batches) > 50 ? 5 : 3; // 5 seconds for 500+ questions, 3 seconds otherwise
                sleep($delay);
            }
        }
        
        Log::info("⚡ Batch processing complete. Total questions saved: " . count($allSavedQuestions));
        
        return $allSavedQuestions;
    }

    /**
     * Save parsed questions to database
     *
     * @param array $questions
     * @param int $examId
     * @return array Saved questions with IDs
     */
    protected function saveQuestionsToDatabase(array $questions, int $examId): array
    {
        $savedQuestions = [];
        
        // Get current max display_order for this exam
        $maxOrder = \DB::table('exam_questions')
            ->where('exam_id', $examId)
            ->max('display_order') ?? -1;
        
        foreach ($questions as $questionData) {
            try {
                // Create question (without exam_id - it's in pivot table)
                $question = \App\Models\Question::create([
                    'question_text' => $questionData['question_text'],
                    'topic' => null,
                    'difficulty' => 'medium'
                ]);
                
                // Link question to exam via pivot table
                $maxOrder++;
                \DB::table('exam_questions')->insert([
                    'exam_id' => $examId,
                    'question_id' => $question->id,
                    'display_order' => $maxOrder
                ]);
                
                // Create answer choices with display_order
                $displayOrder = 0;
                foreach ($questionData['choices'] as $choice) {
                    \App\Models\AnswerChoice::create([
                        'question_id' => $question->id,
                        'choice_text' => $choice['text'],
                        'is_correct' => $choice['letter'] === $questionData['correct_answer'],
                        'display_order' => $displayOrder++
                    ]);
                }
                
                // Reload with relationships
                $question->load('answerChoices');
                $savedQuestions[] = $question;
                
                Log::info("Saved question #{$questionData['number']}: " . substr($questionData['question_text'], 0, 50));
                
            } catch (\Exception $e) {
                Log::error("Failed to save question #{$questionData['number']}: " . $e->getMessage());
            }
        }
        
        return $savedQuestions;
    }

    /**
     * Parse DOCX file using AI
     *
     * @param string $filePath Path to the DOCX file
     * @return array Parsed questions
     * @throws \Exception
     */
    public function parseDocx(string $filePath): array
    {
        // Step 1: Extract text from DOCX
        $extractedText = $this->extractTextFromDocx($filePath);

        if (empty($extractedText)) {
            throw new \Exception('Failed to extract text from DOCX file');
        }

        // Step 2: Count approximate number of questions
        $questionCount = $this->estimateQuestionCount($extractedText);
        
        Log::info("Estimated questions in document: $questionCount");

        // Step 3: Always use batch processing for better results
        // Even if we only detect 10 questions, there might be more in the document
        if ($questionCount >= 10) {
            Log::info("Using batch processing for document ($questionCount questions detected, may have more)");
            $parsedQuestions = $this->parseLargeDocumentInBatches($extractedText);
        } else {
            Log::info("Using single-pass processing ($questionCount questions)");
            $parsedQuestions = $this->parseWithGeminiAI($extractedText);
        }

        return $parsedQuestions;
    }

    /**
     * Estimate the number of questions in the document
     *
     * @param string $text
     * @return int
     */
    protected function estimateQuestionCount(string $text): int
    {
        // Count lines that start with a number followed by a period, parenthesis, or dot
        // Matches: "1.", "1)", "1 .", etc.
        preg_match_all('/^[\s\t]*(\d+)[\.\)\s]/m', $text, $matches);
        
        if (empty($matches[1])) {
            return 0;
        }
        
        // Get the highest question number found
        $numbers = array_map('intval', $matches[1]);
        $maxNumber = max($numbers);
        
        Log::info("Question numbers found: " . count($numbers) . ", highest: $maxNumber");
        
        // Return the higher of the two (in case some questions are missing)
        return max(count($numbers), $maxNumber);
    }

    /**
     * Parse large document in batches
     *
     * @param string $text
     * @return array
     */
    protected function parseLargeDocumentInBatches(string $text): array
    {
        // Split text into question blocks
        $questionBlocks = $this->splitIntoQuestionBlocks($text);
        
        $batchSize = 10; // Process 10 questions at a time (optimal for Groq)
        $allQuestions = [];
        $batches = array_chunk($questionBlocks, $batchSize);
        
        Log::info("Processing " . count($batches) . " batches (" . count($questionBlocks) . " question blocks total)");
        
        foreach ($batches as $batchIndex => $batch) {
            Log::info("Processing batch " . ($batchIndex + 1) . " of " . count($batches) . " (" . count($batch) . " questions)");
            
            $batchText = implode("\n\n", $batch);
            
            // Retry logic for rate limiting
            $maxRetries = 3;
            $retryDelay = 5; // seconds
            $success = false;
            
            for ($attempt = 1; $attempt <= $maxRetries; $attempt++) {
                try {
                    $questions = $this->parseWithGeminiAI($batchText);
                    
                    if (!empty($questions)) {
                        $allQuestions = array_merge($allQuestions, $questions);
                        Log::info("Batch " . ($batchIndex + 1) . " completed: " . count($questions) . " questions parsed");
                        $success = true;
                        break;
                    } else {
                        Log::warning("Batch " . ($batchIndex + 1) . " returned no questions (attempt $attempt)");
                    }
                } catch (\Exception $e) {
                    $errorMsg = $e->getMessage();
                    
                    // Check if it's a rate limit error
                    if (strpos($errorMsg, '429') !== false || strpos($errorMsg, 'Rate limit') !== false) {
                        Log::warning("Batch " . ($batchIndex + 1) . " hit rate limit (attempt $attempt/$maxRetries)");
                        
                        if ($attempt < $maxRetries) {
                            $waitTime = $retryDelay * $attempt; // Exponential backoff
                            Log::info("Waiting $waitTime seconds before retry...");
                            sleep($waitTime);
                        }
                    } else {
                        Log::error("Batch " . ($batchIndex + 1) . " failed: " . $errorMsg);
                        break; // Don't retry for non-rate-limit errors
                    }
                }
            }
            
            if (!$success) {
                Log::error("Batch " . ($batchIndex + 1) . " failed after $maxRetries attempts");
            }
            
            // Delay between batches to avoid rate limiting (longer for Groq free tier)
            if ($batchIndex < count($batches) - 1) {
                sleep(3); // 3 seconds between batches
            }
        }
        
        Log::info("Batch processing complete. Total questions parsed: " . count($allQuestions));
        
        return $allQuestions;
    }

    /**
     * Split document text into question blocks
     *
     * @param string $text
     * @return array
     */
    protected function splitIntoQuestionBlocks(string $text): array
    {
        // First, remove the answer key section if present
        $text = preg_replace('/^(answer\s+key|answers?)\s*:?.*$/ims', '', $text);
        
        // PREPROCESSING: Split choices that are on the same line
        // This fixes the Q1-Q2 skip issue where choices like "a. Choice1    b. Choice2" are on one line
        // Process line by line to split multiple choices
        $lines = explode("\n", $text);
        $processedLines = [];
        
        foreach ($lines as $line) {
            // Skip empty lines
            if (trim($line) === '') {
                $processedLines[] = $line;
                continue;
            }
            
            // Check if line starts with a choice letter (with or without **)
            if (!preg_match('/^(\*\*)?[a-d]\.\s+/', $line)) {
                $processedLines[] = $line;
                continue;
            }
            
            // Split by 2+ spaces before a choice letter (with or without **)
            // This handles: "a. text    b. text" or "**c. text**    d. text"
            $parts = preg_split('/\s{2,}(?=(\*\*)?[a-d]\.\s+)/', $line);
            
            if (count($parts) > 1) {
                // Multiple choices on one line - split them
                foreach ($parts as $part) {
                    $trimmed = trim($part);
                    if ($trimmed !== '') {
                        $processedLines[] = $trimmed;
                    }
                }
            } else {
                // Single choice on line
                $processedLines[] = $line;
            }
        }
        
        $text = implode("\n", $processedLines);
        
        // Split by question numbers at the start of a line
        // Matches: "1.", "1)", "1 .", etc. at the beginning of a line
        $pattern = '/(?=^\s*\d+[\.\)]\s+)/m';
        $blocks = preg_split($pattern, $text, -1, PREG_SPLIT_NO_EMPTY);
        
        // Filter and clean blocks
        $questionBlocks = [];
        $seenNumbers = [];
        
        foreach ($blocks as $index => $block) {
            $block = trim($block);
            
            // Skip empty blocks
            if (empty($block)) {
                continue;
            }
            
            // Extract question number from the start
            if (preg_match('/^(\d+)[\.\)]\s+/', $block, $matches)) {
                $questionNum = (int)$matches[1];
                
                // Skip if we've already seen this question number (avoid duplicates)
                if (isset($seenNumbers[$questionNum])) {
                    Log::warning("Duplicate question number found: $questionNum - skipping");
                    continue;
                }
                
                $seenNumbers[$questionNum] = true;
                $questionBlocks[] = $block;
                
                // Log first few questions to verify we're not skipping
                if ($questionNum <= 5) {
                    Log::info("Found question #$questionNum at block index $index");
                }
            } else {
                // Log blocks that don't start with a question number
                if ($index < 3) {
                    Log::warning("Block $index doesn't start with question number: " . substr($block, 0, 100));
                }
            }
        }
        
        // Sort by question number to ensure correct order
        usort($questionBlocks, function($a, $b) {
            preg_match('/^(\d+)[\.\)]/', $a, $matchA);
            preg_match('/^(\d+)[\.\)]/', $b, $matchB);
            $numA = isset($matchA[1]) ? (int)$matchA[1] : 0;
            $numB = isset($matchB[1]) ? (int)$matchB[1] : 0;
            return $numA - $numB;
        });
        
        // Log question number range
        if (!empty($questionBlocks)) {
            preg_match('/^(\d+)[\.\)]/', $questionBlocks[0], $firstMatch);
            preg_match('/^(\d+)[\.\)]/', end($questionBlocks), $lastMatch);
            $firstNum = isset($firstMatch[1]) ? $firstMatch[1] : '?';
            $lastNum = isset($lastMatch[1]) ? $lastMatch[1] : '?';
            Log::info("Split into " . count($questionBlocks) . " unique question blocks (Q$firstNum to Q$lastNum)");
        } else {
            Log::warning("No question blocks found!");
        }
        
        return $questionBlocks;
    }

    /**
     * Extract text content from DOCX file
     * Uses Python script for complete extraction
     *
     * @param string $filePath
     * @return string
     */
    protected function extractTextFromDocx(string $filePath): string
    {
        try {
            // Use Python script to extract text with formatting markers
            $pythonPath = 'C:\\Users\\Hi\\AppData\\Local\\Programs\\Python\\Python312\\python.exe';
            $scriptPath = base_path('extract-with-formatting.py');
            $tempFile = storage_path('app/temp/extracted_' . uniqid() . '.txt');
            
            // Ensure temp directory exists
            $tempDir = dirname($tempFile);
            if (!is_dir($tempDir)) {
                mkdir($tempDir, 0755, true);
            }
            
            // Build command
            $command = sprintf(
                '"%s" "%s" "%s" "%s" 2>&1',
                $pythonPath,
                $scriptPath,
                $filePath,
                $tempFile
            );
            
            Log::info("Running Python extraction: $command");
            
            // Execute Python script
            exec($command, $output, $returnCode);
            
            Log::info("Python output: " . implode("\n", $output));
            
            if ($returnCode !== 0) {
                throw new \Exception("Python extraction failed with code $returnCode: " . implode("\n", $output));
            }
            
            // Read extracted text from file
            if (!file_exists($tempFile)) {
                throw new \Exception("Python extraction did not create output file");
            }
            
            $text = file_get_contents($tempFile);
            
            // Clean up temp file
            @unlink($tempFile);
            
            if (empty($text)) {
                throw new \Exception("Python extraction returned empty text");
            }
            
            $questionCount = $this->countQuestionsInText($text);
            
            Log::info("Python extraction complete. Length: " . strlen($text) . " chars, Questions detected: $questionCount");
            
            return $text;
            
        } catch (\Exception $e) {
            Log::error('Python extraction error: ' . $e->getMessage());
            
            // Fallback to ZIP/XML extraction
            Log::info("Falling back to ZIP/XML extraction");
            return $this->extractWithZipXml($filePath);
        }
    }
    
    /**
     * Extract using ZIP/XML parsing (fallback)
     *
     * @param string $filePath
     * @return string
     */
    protected function extractWithZipXml(string $filePath): string
    {
        try {
            $zip = new \ZipArchive();
            
            if ($zip->open($filePath) !== true) {
                throw new \Exception('Failed to open DOCX file as ZIP archive');
            }
            
            $xmlContent = $zip->getFromName('word/document.xml');
            
            if ($xmlContent === false) {
                $zip->close();
                throw new \Exception('Failed to extract document.xml from DOCX');
            }
            
            $zip->close();
            
            $text = $this->extractTextFromXML($xmlContent);
            
            $questionCount = $this->countQuestionsInText($text);
            
            Log::info("ZIP/XML extraction complete. Length: " . strlen($text) . " chars, Questions detected: $questionCount");
            
            return $text;
            
        } catch (\Exception $e) {
            Log::error('ZIP/XML extraction error: ' . $e->getMessage());
            
            // Last resort: PHPWord
            Log::info("Falling back to PHPWord extraction");
            return $this->extractWithPHPWord($filePath);
        }
    }

    /**
     * Extract text from Word XML content WITH BOLD MARKERS
     *
     * @param string $xmlContent
     * @return string
     */
    protected function extractTextFromXML(string $xmlContent): string
    {
        // Remove XML declaration and namespaces for easier parsing
        $xmlContent = preg_replace('/<\?xml[^>]*\?>/', '', $xmlContent);
        
        // Parse XML
        libxml_use_internal_errors(true);
        $dom = new \DOMDocument();
        $dom->loadXML($xmlContent);
        libxml_clear_errors();
        
        // Extract all text nodes (w:t elements contain the actual text)
        $xpath = new \DOMXPath($dom);
        
        // Register Word namespace
        $xpath->registerNamespace('w', 'http://schemas.openxmlformats.org/wordprocessingml/2006/main');
        
        // Get all paragraph nodes
        $paragraphs = $xpath->query('//w:p');
        
        $allText = [];
        
        foreach ($paragraphs as $paragraph) {
            // Get all run nodes (w:r) which contain formatting info
            $runs = $xpath->query('.//w:r', $paragraph);
            
            $paragraphText = '';
            foreach ($runs as $run) {
                // Check if this run is bold
                $isBold = false;
                $boldNodes = $xpath->query('.//w:b', $run);
                if ($boldNodes->length > 0) {
                    // Check if bold is not explicitly set to false
                    $boldNode = $boldNodes->item(0);
                    $valAttr = $boldNode->getAttribute('w:val');
                    $isBold = ($valAttr !== '0' && $valAttr !== 'false');
                }
                
                // Get text from this run
                $textNodes = $xpath->query('.//w:t', $run);
                foreach ($textNodes as $textNode) {
                    $text = $textNode->nodeValue;
                    // Mark bold text with **markers** for AI detection
                    if ($isBold && !empty(trim($text))) {
                        $text = '**' . $text . '**';
                    }
                    $paragraphText .= $text;
                }
            }
            
            // Only add non-empty paragraphs
            $paragraphText = trim($paragraphText);
            if (!empty($paragraphText)) {
                $allText[] = $paragraphText;
            }
        }
        
        // Also extract from tables WITH BOLD DETECTION
        $tables = $xpath->query('//w:tbl');
        foreach ($tables as $table) {
            $rows = $xpath->query('.//w:tr', $table);
            foreach ($rows as $row) {
                $cells = $xpath->query('.//w:tc', $row);
                $rowText = [];
                foreach ($cells as $cell) {
                    $cellRuns = $xpath->query('.//w:r', $cell);
                    $cellText = '';
                    foreach ($cellRuns as $run) {
                        // Check if bold
                        $isBold = false;
                        $boldNodes = $xpath->query('.//w:b', $run);
                        if ($boldNodes->length > 0) {
                            $boldNode = $boldNodes->item(0);
                            $valAttr = $boldNode->getAttribute('w:val');
                            $isBold = ($valAttr !== '0' && $valAttr !== 'false');
                        }
                        
                        $textNodes = $xpath->query('.//w:t', $run);
                        foreach ($textNodes as $textNode) {
                            $text = $textNode->nodeValue;
                            if ($isBold && !empty(trim($text))) {
                                $text = '**' . $text . '**';
                            }
                            $cellText .= $text;
                        }
                    }
                    $cellText = trim($cellText);
                    if (!empty($cellText)) {
                        $rowText[] = $cellText;
                    }
                }
                if (!empty($rowText)) {
                    // Use newline instead of tab for better AI parsing
                    // This ensures each cell content is on its own line
                    $allText[] = implode("\n", $rowText);
                }
            }
        }
        
        return implode("\n", $allText);
    }

    /**
     * Count questions in extracted text
     *
     * @param string $text
     * @return int
     */
    protected function countQuestionsInText(string $text): int
    {
        preg_match_all('/^\s*(\d+)[\.\)]\s+/m', $text, $matches);
        if (empty($matches[1])) {
            return 0;
        }
        $numbers = array_map('intval', $matches[1]);
        return max($numbers);
    }

    /**
     * Extract using PHPWord (fallback)
     *
     * @param string $filePath
     * @return string
     */
    protected function extractWithPHPWord(string $filePath): string
    {
        $phpWord = IOFactory::load($filePath);
        $allText = [];

        foreach ($phpWord->getSections() as $section) {
            foreach ($section->getElements() as $element) {
                $text = $this->extractElementText($element);
                if (!empty(trim($text))) {
                    $allText[] = trim($text);
                }
            }
        }

        $fullText = implode("\n", $allText);
        $questionCount = $this->countQuestionsInText($fullText);
        
        Log::info("PHPWord extraction complete. Length: " . strlen($fullText) . " chars, Lines: " . count($allText) . ", Questions detected: $questionCount");
        
        return $fullText;
    }

    /**
     * Recursively extract text from an element
     *
     * @param mixed $element
     * @return string
     */
    protected function extractElementText($element): string
    {
        $text = '';
        
        // Get element class name for debugging
        $className = get_class($element);
        
        // Handle TextRun elements
        if ($className === 'PhpOffice\PhpWord\Element\TextRun') {
            foreach ($element->getElements() as $child) {
                if (method_exists($child, 'getText')) {
                    $text .= $child->getText();
                } elseif (method_exists($child, 'getContent')) {
                    $text .= $child->getContent();
                }
            }
            return $text;
        }
        
        // Handle Text elements
        if (method_exists($element, 'getText')) {
            return $element->getText();
        }
        
        // Handle elements with getContent
        if (method_exists($element, 'getContent')) {
            return $element->getContent();
        }
        
        // Handle Table elements
        if ($className === 'PhpOffice\PhpWord\Element\Table') {
            $tableText = [];
            foreach ($element->getRows() as $row) {
                $rowText = [];
                foreach ($row->getCells() as $cell) {
                    $cellText = [];
                    foreach ($cell->getElements() as $cellElement) {
                        $cellText[] = $this->extractElementText($cellElement);
                    }
                    $rowText[] = implode(' ', $cellText);
                }
                $tableText[] = implode("\t", $rowText);
            }
            return implode("\n", $tableText);
        }
        
        // Handle ListItem elements
        if ($className === 'PhpOffice\PhpWord\Element\ListItem') {
            if (method_exists($element, 'getTextObject')) {
                $textObj = $element->getTextObject();
                if (method_exists($textObj, 'getText')) {
                    return $textObj->getText();
                }
            }
        }
        
        // Handle elements with nested elements
        if (method_exists($element, 'getElements')) {
            $parts = [];
            foreach ($element->getElements() as $child) {
                $childText = $this->extractElementText($child);
                if (!empty(trim($childText))) {
                    $parts[] = $childText;
                }
            }
            return implode(' ', $parts);
        }
        
        return $text;
    }

    /**
     * Parse extracted text using AI (DeepSeek, Groq, or Gemini)
     *
     * @param string $text
     * @return array
     */
    protected function parseWithGeminiAI(string $text): array
    {
        if ($this->useDeepseek) {
            return $this->parseWithDeepseek($text);
        } elseif ($this->useGroq) {
            return $this->parseWithGroq($text);
        } else {
            return $this->parseWithGemini($text);
        }
    }

    /**
     * Parse using DeepSeek API (deepseek-chat)
     * OPTIMIZED FOR SPEED with maximum token limit
     *
     * @param string $text
     * @return array
     */
    protected function parseWithDeepseek(string $text): array
    {
        $prompt = $this->buildPrompt($text);

        try {
            $response = $this->client->post(
                'https://api.deepseek.com/v1/chat/completions',
                [
                    'headers' => [
                        'Authorization' => 'Bearer ' . $this->deepseekApiKey,
                        'Content-Type' => 'application/json',
                    ],
                    'json' => [
                        'model' => 'deepseek-chat',
                        'messages' => [
                            [
                                'role' => 'system',
                                'content' => 'You are an expert exam question parser. You extract ALL questions from documents and return them as valid JSON. Always extract every single question from start to finish. Work FAST and ACCURATELY.'
                            ],
                            [
                                'role' => 'user',
                                'content' => $prompt
                            ]
                        ],
                        'temperature' => 0.1,
                        'max_tokens' => 8192, // ⚡ DeepSeek maximum: 8192 tokens
                        'response_format' => ['type' => 'json_object']
                    ]
                ]
            );

            $body = json_decode($response->getBody()->getContents(), true);
            
            if (isset($body['choices'][0]['message']['content'])) {
                $generatedText = $body['choices'][0]['message']['content'];
                
                Log::info('⚡ DeepSeek Raw Response: ' . substr($generatedText, 0, 500));
                
                $jsonText = $this->extractJsonFromText($generatedText);
                $jsonText = $this->cleanJsonString($jsonText);
                
                Log::info('⚡ Cleaned JSON: ' . substr($jsonText, 0, 500));
                
                $questions = json_decode($jsonText, true);
                
                if (json_last_error() !== JSON_ERROR_NONE) {
                    Log::error('JSON decode error: ' . json_last_error_msg());
                    Log::error('Generated text: ' . $generatedText);
                    throw new \Exception('Failed to parse AI response as JSON: ' . json_last_error_msg());
                }

                return $questions['questions'] ?? $questions;
            }

            throw new \Exception('Invalid response from DeepSeek API');
        } catch (\Exception $e) {
            Log::error('DeepSeek API error: ' . $e->getMessage());
            throw new \Exception('Failed to parse with AI: ' . $e->getMessage());
        }
    }

    /**
     * Parse using Groq API (Llama 3.3 70B)
     *
     * @param string $text
     * @return array
     */
    protected function parseWithGroq(string $text): array
    {
        $prompt = $this->buildPrompt($text);

        try {
            $response = $this->client->post(
                'https://api.groq.com/openai/v1/chat/completions',
                [
                    'headers' => [
                        'Authorization' => 'Bearer ' . $this->groqApiKey,
                        'Content-Type' => 'application/json',
                    ],
                    'json' => [
                        'model' => 'llama-3.3-70b-versatile',  // Fast and powerful
                        'messages' => [
                            [
                                'role' => 'system',
                                'content' => 'You are an expert exam question parser. You extract ALL questions from documents and return them as valid JSON. Always extract every single question from start to finish.'
                            ],
                            [
                                'role' => 'user',
                                'content' => $prompt
                            ]
                        ],
                        'temperature' => 0.1,
                        'max_tokens' => 32000,  // Groq supports up to 32k output tokens
                        'response_format' => ['type' => 'json_object']  // Force JSON output
                    ]
                ]
            );

            $body = json_decode($response->getBody()->getContents(), true);
            
            if (isset($body['choices'][0]['message']['content'])) {
                $generatedText = $body['choices'][0]['message']['content'];
                
                Log::info('Groq Raw Response: ' . substr($generatedText, 0, 500));
                
                $jsonText = $this->extractJsonFromText($generatedText);
                $jsonText = $this->cleanJsonString($jsonText);
                
                Log::info('Cleaned JSON: ' . substr($jsonText, 0, 500));
                
                $questions = json_decode($jsonText, true);
                
                if (json_last_error() !== JSON_ERROR_NONE) {
                    Log::error('JSON decode error: ' . json_last_error_msg());
                    Log::error('Generated text: ' . $generatedText);
                    throw new \Exception('Failed to parse AI response as JSON: ' . json_last_error_msg());
                }

                return $questions['questions'] ?? $questions;
            }

            throw new \Exception('Invalid response from Groq API');
        } catch (\Exception $e) {
            Log::error('Groq API error: ' . $e->getMessage());
            throw new \Exception('Failed to parse with AI: ' . $e->getMessage());
        }
    }

    /**
     * Parse using Gemini API (fallback)
     *
     * @param string $text
     * @return array
     */
    protected function parseWithGemini(string $text): array
    {
        $prompt = $this->buildPrompt($text);

        try {
            $response = $this->client->post(
                "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key={$this->apiKey}",
                [
                    'headers' => [
                        'Content-Type' => 'application/json',
                    ],
                    'json' => [
                        'contents' => [
                            [
                                'parts' => [
                                    ['text' => $prompt]
                                ]
                            ]
                        ],
                        'generationConfig' => [
                            'temperature' => 0.1,
                            'topP' => 0.8,
                            'topK' => 10,
                            'maxOutputTokens' => 32768,
                            'responseMimeType' => 'application/json',
                        ]
                    ]
                ]
            );

            $body = json_decode($response->getBody()->getContents(), true);
            
            if (isset($body['candidates'][0]['content']['parts'][0]['text'])) {
                $generatedText = $body['candidates'][0]['content']['parts'][0]['text'];
                
                Log::info('Gemini Raw Response: ' . substr($generatedText, 0, 500));
                
                $jsonText = $this->extractJsonFromText($generatedText);
                $jsonText = $this->cleanJsonString($jsonText);
                
                Log::info('Cleaned JSON: ' . substr($jsonText, 0, 500));
                
                $questions = json_decode($jsonText, true);
                
                if (json_last_error() !== JSON_ERROR_NONE) {
                    Log::error('JSON decode error: ' . json_last_error_msg());
                    Log::error('Generated text: ' . $generatedText);
                    throw new \Exception('Failed to parse AI response as JSON: ' . json_last_error_msg());
                }

                return $questions['questions'] ?? $questions;
            }

            throw new \Exception('Invalid response from Gemini AI');
        } catch (\Exception $e) {
            Log::error('Gemini AI error: ' . $e->getMessage());
            throw new \Exception('Failed to parse with AI: ' . $e->getMessage());
        }
    }

    /**
     * Extract JSON from text that might be wrapped in markdown code blocks
     *
     * @param string $text
     * @return string
     */
    protected function extractJsonFromText(string $text): string
    {
        // Remove markdown code blocks if present
        $text = preg_replace('/```json\s*/i', '', $text);
        $text = preg_replace('/```\s*$/i', '', $text);
        $text = trim($text);

        // If it starts with [ or {, it's likely JSON
        if (preg_match('/^[\[{]/', $text)) {
            return $text;
        }

        // Try to find JSON in the text
        if (preg_match('/(\[.*\]|\{.*\})/s', $text, $matches)) {
            return $matches[1];
        }

        return $text;
    }

    /**
     * Clean JSON string from problematic characters
     *
     * @param string $json
     * @return string
     */
    protected function cleanJsonString(string $json): string
    {
        // First, decode the JSON to work with the actual data
        // This handles control characters properly
        $decoded = json_decode($json);
        
        // If decoding succeeded, re-encode with proper formatting
        if ($decoded !== null && json_last_error() === JSON_ERROR_NONE) {
            return json_encode($decoded, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        }
        
        // If initial decode failed, try cleaning the string
        
        // Remove BOM (Byte Order Mark)
        $json = str_replace("\xEF\xBB\xBF", '', $json);
        
        // Fix smart quotes using Unicode codes
        $json = str_replace(["\u{201C}", "\u{201D}", "\u{2018}", "\u{2019}"], ['"', '"', "'", "'"], $json);
        
        // Also handle Windows-1252 encoded smart quotes
        $json = str_replace([chr(147), chr(148), chr(145), chr(146)], ['"', '"', "'", "'"], $json);
        
        // Remove ALL control characters including newlines and tabs
        // JSON strings should not have literal newlines - they should be escaped as \n
        $json = preg_replace('/[\x00-\x1F\x7F]/u', '', $json);
        
        // Try decoding again after cleaning
        $decoded = json_decode($json);
        if ($decoded !== null && json_last_error() === JSON_ERROR_NONE) {
            return json_encode($decoded, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        }
        
        // If still failing, return the cleaned string
        return $json;
    }

    /**
     * Build the AI prompt for question parsing
     *
     * @param string $documentText
     * @return string
     */
    protected function buildPrompt(string $documentText): string
    {
        return <<<PROMPT
You are an expert exam question parser. Extract and format ALL examination questions from the document.

CRITICAL EXTRACTION RULES:
1. You MUST extract ALL questions found in the document - Do not stop at 10 or 20
2. Start from the FIRST question (usually question 1) - Do NOT skip early questions
3. Continue until you reach the LAST question (could be 100+)
4. If you see questions 1, 2, 3... extract them ALL starting from 1
5. Do NOT skip questions at the beginning - they are the most important!

CRITICAL JSON FORMATTING RULES:
1. Return ONLY valid, compact JSON - NO markdown code blocks, NO explanations
2. ALL text must be on a SINGLE LINE - NO line breaks inside strings
3. Use spaces instead of newlines for readability in question text
4. Ensure proper JSON escaping for quotes and special characters
5. The response must be parseable by json_decode() without any preprocessing

EXTRACTION RULES:
1. Extract EVERY SINGLE question from start to finish - do not skip any
2. START FROM QUESTION 1 (or the first question number you see) - this is critical!
3. Each question MUST have exactly 4 answer choices labeled A, B, C, D
4. Continue processing until you reach the last question in the document
5. If the text starts with "1. Question text..." then question 1 MUST be in your output

CRITICAL ANSWER KEY DETECTION RULE (100% ACCURACY REQUIRED):
==================================================================================
THE CORRECT ANSWER IS **ALWAYS AND ONLY** THE CHOICE MARKED WITH **DOUBLE ASTERISKS**

RULE: Text surrounded by **double asterisks** like **this text** is the CORRECT ANSWER.

EXAMPLES:
- If you see: "a. Fish farming  b. **Aquaculture**  c. Fish capture  d. Fish processing"
  → The correct answer is "B" (because **Aquaculture** has the markers)

- If you see: "a. **Tilapia**  b. Tuna  c. Salmon  d. Mackerel"
  → The correct answer is "A" (because **Tilapia** has the markers)

- If you see: "a. Choice 1  b. Choice 2  c. Choice 3  d. **Choice 4**"
  → The correct answer is "D" (because **Choice 4** has the markers)

CRITICAL RULES FOR ANSWER DETECTION:
1. ONLY the text with **markers** is correct - IGNORE everything else
2. Do NOT use your knowledge to guess - ONLY follow the **markers**
3. Do NOT look at answer key tables - ONLY follow the **markers**
4. If NO choice has **markers**, then default to "A"
5. If MULTIPLE choices have **markers** (error), use the FIRST one
6. The **markers** are ALWAYS correct - trust them 100%

WRONG APPROACH (DO NOT DO THIS):
❌ Using your knowledge: "Aquaculture is fish farming, so B is correct"
❌ Looking at answer key: "The table says answer is C"
❌ Guessing: "This looks like the right answer"

CORRECT APPROACH (DO THIS):
✅ Find the choice with **markers**: "**Aquaculture** has markers, so B is correct"
✅ Match the letter: "**Aquaculture** is choice B, so correct_answer is B"
✅ Trust the markers: "The markers are always right, no exceptions"
==================================================================================

REQUIRED OUTPUT FORMAT:
{"questions":[{"number":1,"question_text":"Complete question text here?","choices":[{"letter":"A","text":"First choice"},{"letter":"B","text":"Second choice"},{"letter":"C","text":"Third choice"},{"letter":"D","text":"Fourth choice"}],"correct_answer":"B"}]}

FIELD REQUIREMENTS:
- "number": Original question number from document (integer)
- "question_text": Complete question as single-line text (string)
- "choices": Array of exactly 4 objects with "letter" and "text"
- "letter": Must be "A", "B", "C", or "D" (string)
- "text": Choice content as single-line text (string, WITHOUT the **markers**)
- "correct_answer": The letter (A/B/C/D) of the choice that had **markers** (string)

TEXT FORMATTING:
- Replace all newlines with spaces in question_text and choice text
- Remove bullet points, numbering, and formatting marks
- Remove **double asterisks** from the final text (they're just markers for detection)
- Preserve original wording but make it single-line
- The choice that HAD **markers** determines the correct_answer letter

STEP-BY-STEP PROCESS FOR EACH QUESTION:
1. Read the question text
2. Read all 4 choices (A, B, C, D)
3. Find which choice has **markers** around it
4. Note the letter of that choice (A, B, C, or D)
5. Remove the **markers** from the choice text
6. Set "correct_answer" to that letter
7. Output the JSON

DOCUMENT CONTENT:
$documentText

FINAL REMINDERS:
- Return ONLY the JSON object starting with { and ending with }
- No markdown, no code blocks, no explanations
- Extract ALL questions - do not stop early
- The document may contain 50-100+ questions - extract them all
- **MARKERS** = CORRECT ANSWER (100% of the time, no exceptions)
- Do NOT use your knowledge - ONLY follow the **markers**
PROMPT;
    }

    /**
     * Validate parsed questions
     *
     * @param array $questions
     * @return array Validation result with 'valid' boolean and 'errors' array
     */
    public function validateQuestions(array $questions): array
    {
        $errors = [];

        if (empty($questions)) {
            $errors[] = 'No questions found in the document';
            return ['valid' => false, 'errors' => $errors];
        }

        foreach ($questions as $index => $question) {
            $questionNum = $question['number'] ?? ($index + 1);

            // Check required fields
            if (empty($question['question_text'])) {
                $errors[] = "Question $questionNum: Missing question text";
            }

            if (empty($question['choices']) || !is_array($question['choices'])) {
                $errors[] = "Question $questionNum: Missing or invalid choices";
                continue;
            }

            // Check number of choices
            if (count($question['choices']) !== 4) {
                $errors[] = "Question $questionNum: Must have exactly 4 choices (found " . count($question['choices']) . ")";
            }

            // Check choice format
            $letters = ['A', 'B', 'C', 'D'];
            foreach ($question['choices'] as $choiceIndex => $choice) {
                if (!isset($choice['letter']) || !isset($choice['text'])) {
                    $errors[] = "Question $questionNum, Choice " . ($choiceIndex + 1) . ": Invalid format";
                }
                
                if (isset($choice['letter']) && !in_array($choice['letter'], $letters)) {
                    $errors[] = "Question $questionNum: Invalid choice letter '{$choice['letter']}'";
                }
            }

            // Check correct answer
            if (empty($question['correct_answer'])) {
                $errors[] = "Question $questionNum: Missing correct answer";
            } elseif (!in_array($question['correct_answer'], $letters)) {
                $errors[] = "Question $questionNum: Invalid correct answer '{$question['correct_answer']}'";
            }
        }

        return [
            'valid' => empty($errors),
            'errors' => $errors
        ];
    }
}


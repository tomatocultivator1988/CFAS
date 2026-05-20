<?php

namespace App\Services;

use Illuminate\Support\Facades\Log;
use GuzzleHttp\Client;

class AiPdfParserService extends AiDocxParserService
{
    /**
     * Parse PDF file using AI and save questions in real-time
     *
     * @param string $filePath Path to the PDF file
     * @param int $examId Exam ID to associate questions with
     * @return array Saved questions
     * @throws \Exception
     */
    public function parsePdfWithRealTimeSave(string $filePath, int $examId): array
    {
        // Step 1: Extract text from PDF
        $extractedText = $this->extractTextFromPdf($filePath);

        if (empty($extractedText)) {
            throw new \Exception('Failed to extract text from PDF file');
        }

        // Step 2: Count approximate number of questions
        $questionCount = $this->estimateQuestionCount($extractedText);
        
        Log::info("Estimated questions in PDF document: $questionCount");

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
     * Parse PDF file using AI
     *
     * @param string $filePath Path to the PDF file
     * @return array Parsed questions
     * @throws \Exception
     */
    public function parsePdf(string $filePath): array
    {
        // Step 1: Extract text from PDF
        $extractedText = $this->extractTextFromPdf($filePath);

        if (empty($extractedText)) {
            throw new \Exception('Failed to extract text from PDF file');
        }

        // Step 2: Count approximate number of questions
        $questionCount = $this->estimateQuestionCount($extractedText);
        
        Log::info("Estimated questions in PDF document: $questionCount");

        // Step 3: Always use batch processing for better results
        if ($questionCount >= 10) {
            Log::info("Using batch processing for PDF document ($questionCount questions detected, may have more)");
            $parsedQuestions = $this->parseLargeDocumentInBatches($extractedText);
        } else {
            Log::info("Using single-pass processing ($questionCount questions)");
            $parsedQuestions = $this->parseWithGeminiAI($extractedText);
        }

        return $parsedQuestions;
    }

    /**
     * Extract text content from PDF file
     * Uses multiple methods for best compatibility
     *
     * @param string $filePath
     * @return string
     */
    protected function extractTextFromPdf(string $filePath): string
    {
        // Method 1: Try using PHP PDF parser (most reliable and always available)
        try {
            Log::info('Trying PHP PDF parser (smalot/pdfparser)...');
            return $this->extractTextFromPdfWithPhp($filePath);
        } catch (\Exception $e) {
            Log::error('PHP PDF extraction failed: ' . $e->getMessage());
        }
        
        // Method 2: Try using Python script
        try {
            Log::info('Trying Python PDF extraction...');
            return $this->extractTextFromPdfWithPython($filePath);
        } catch (\Exception $e) {
            Log::error('Python PDF extraction failed: ' . $e->getMessage());
        }
        
        // Method 3: Fallback to shell command
        try {
            Log::info('Trying shell PDF extraction...');
            return $this->extractTextFromPdfWithShell($filePath);
        } catch (\Exception $e) {
            Log::error('Shell PDF extraction failed: ' . $e->getMessage());
        }
        
        throw new \Exception('All PDF extraction methods failed. Please ensure the PDF file is not corrupted or password-protected.');
    }

    /**
     * Extract text from PDF using Python script (most reliable)
     *
     * @param string $filePath
     * @return string
     */
    protected function extractTextFromPdfWithPython(string $filePath): string
    {
        $pythonPath = 'C:\\Users\\Hi\\AppData\\Local\\Programs\\Python\\Python312\\python.exe';
        $scriptPath = base_path('extract-pdf-text.py');
        $tempFile = storage_path('app/temp/extracted_pdf_' . uniqid() . '.txt');
        
        // Ensure temp directory exists
        $tempDir = dirname($tempFile);
        if (!is_dir($tempDir)) {
            mkdir($tempDir, 0755, true);
        }
        
        // Create Python script if it doesn't exist
        if (!file_exists($scriptPath)) {
            $this->createPdfExtractionScript($scriptPath);
        }
        
        // Build command
        $command = sprintf(
            '"%s" "%s" "%s" "%s" 2>&1',
            $pythonPath,
            $scriptPath,
            $filePath,
            $tempFile
        );
        
        Log::info("Running Python PDF extraction: $command");
        
        // Execute Python script
        exec($command, $output, $returnCode);
        
        Log::info("Python PDF extraction output: " . implode("\n", $output));
        
        if ($returnCode !== 0) {
            throw new \Exception("Python PDF extraction failed with code $returnCode: " . implode("\n", $output));
        }
        
        // Read extracted text from file
        if (!file_exists($tempFile)) {
            throw new \Exception("Python PDF extraction did not create output file");
        }
        
        $text = file_get_contents($tempFile);
        
        // Clean up temp file
        @unlink($tempFile);
        
        if (empty($text)) {
            throw new \Exception("Python PDF extraction returned empty text");
        }
        
        $questionCount = $this->countQuestionsInText($text);
        
        Log::info("Python PDF extraction complete. Length: " . strlen($text) . " chars, Questions detected: $questionCount");
        
        return $text;
    }

    /**
     * Create Python script for PDF text extraction
     *
     * @param string $scriptPath
     * @return void
     */
    protected function createPdfExtractionScript(string $scriptPath): void
    {
        $scriptContent = <<<'PYTHON'
#!/usr/bin/env python3
"""
PDF Text Extractor for Exam System
Extracts text from PDF files with basic formatting preservation
"""

import sys
import os
import re
from pathlib import Path

def extract_pdf_text(pdf_path, output_path):
    """
    Extract text from PDF using multiple methods for best results
    """
    try:
        # Try PyPDF2 first (lightweight)
        try:
            import PyPDF2
            text = extract_with_pypdf2(pdf_path)
            if text and len(text.strip()) > 100:
                save_text(text, output_path)
                return
        except ImportError:
            print("PyPDF2 not available, trying next method...")
        except Exception as e:
            print(f"PyPDF2 extraction failed: {e}")
        
        # Try pdfplumber (better for tables)
        try:
            import pdfplumber
            text = extract_with_pdfplumber(pdf_path)
            if text and len(text.strip()) > 100:
                save_text(text, output_path)
                return
        except ImportError:
            print("pdfplumber not available, trying next method...")
        except Exception as e:
            print(f"pdfplumber extraction failed: {e}")
        
        # Try pdfminer.six (most comprehensive)
        try:
            from pdfminer.high_level import extract_text
            text = extract_text(pdf_path)
            if text and len(text.strip()) > 100:
                save_text(text, output_path)
                return
        except ImportError:
            print("pdfminer.six not available, trying next method...")
        except Exception as e:
            print(f"pdfminer.six extraction failed: {e}")
        
        # Fallback: pdftotext command line tool
        text = extract_with_pdftotext(pdf_path)
        if text and len(text.strip()) > 100:
            save_text(text, output_path)
            return
        
        raise Exception("All PDF extraction methods failed")
        
    except Exception as e:
        print(f"PDF extraction error: {e}")
        # Create empty output file to indicate failure
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write("")
        sys.exit(1)

def extract_with_pypdf2(pdf_path):
    """Extract text using PyPDF2"""
    text = ""
    with open(pdf_path, 'rb') as file:
        pdf_reader = PyPDF2.PdfReader(file)
        for page_num in range(len(pdf_reader.pages)):
            page = pdf_reader.pages[page_num]
            text += page.extract_text() + "\n\n"
    return text

def extract_with_pdfplumber(pdf_path):
    """Extract text using pdfplumber (better for tables)"""
    text = ""
    with pdfplumber.open(pdf_path) as pdf:
        for page in pdf.pages:
            page_text = page.extract_text()
            if page_text:
                text += page_text + "\n\n"
            
            # Also extract tables
            tables = page.extract_tables()
            for table in tables:
                if table:
                    for row in table:
                        if row:
                            # Filter out None values and join with tabs
                            row_text = "\t".join([str(cell) for cell in row if cell])
                            text += row_text + "\n"
                    text += "\n"
    return text

def extract_with_pdftotext(pdf_path):
    """Extract text using pdftotext command line tool"""
    import subprocess
    import tempfile
    
    # Create temp file for output
    with tempfile.NamedTemporaryFile(mode='w', suffix='.txt', delete=False) as tmp:
        temp_output = tmp.name
    
    try:
        # Run pdftotext command
        cmd = ['pdftotext', pdf_path, temp_output]
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
        
        if result.returncode == 0:
            with open(temp_output, 'r', encoding='utf-8', errors='ignore') as f:
                text = f.read()
            os.unlink(temp_output)
            return text
        else:
            print(f"pdftotext failed: {result.stderr}")
            return ""
    except Exception as e:
        print(f"pdftotext error: {e}")
        if os.path.exists(temp_output):
            os.unlink(temp_output)
        return ""

def save_text(text, output_path):
    """Save extracted text to file with UTF-8 encoding"""
    # Clean up the text
    text = clean_extracted_text(text)
    
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(text)
    
    print(f"Text extracted successfully. Length: {len(text)} characters")

def clean_extracted_text(text):
    """Clean and normalize extracted text"""
    if not text:
        return ""
    
    # Replace multiple newlines with double newlines
    text = re.sub(r'\n\s*\n\s*\n+', '\n\n', text)
    
    # Replace multiple spaces with single space
    text = re.sub(r'[ \t]+', ' ', text)
    
    # Fix common OCR/PDF issues
    text = text.replace('�', '')  # Remove replacement characters
    
    # Ensure proper line endings
    text = text.replace('\r\n', '\n').replace('\r', '\n')
    
    return text.strip()

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python extract-pdf-text.py <pdf_file> <output_file>")
        sys.exit(1)
    
    pdf_file = sys.argv[1]
    output_file = sys.argv[2]
    
    if not os.path.exists(pdf_file):
        print(f"Error: PDF file not found: {pdf_file}")
        sys.exit(1)
    
    extract_pdf_text(pdf_file, output_file)
PYTHON;
        
        \Illuminate\Support\Facades\File::put($scriptPath, $scriptContent);
        Log::info("Created PDF extraction script at: $scriptPath");
    }

    /**
     * Extract text from PDF using PHP library (if available)
     *
     * @param string $filePath
     * @return string
     */
    protected function extractTextFromPdfWithPhp(string $filePath): string
    {
        // Check if smalot/pdfparser is available
        if (class_exists('Smalot\PdfParser\Parser')) {
            return $this->extractWithSmalotPdfParser($filePath);
        }
        
        // Check if spatie/pdf-to-text is available
        if (class_exists('Spatie\PdfToText\Pdf')) {
            return $this->extractWithSpatiePdfToText($filePath);
        }
        
        throw new \Exception('No PHP PDF parser library available');
    }

    /**
     * Extract text using smalot/pdfparser library
     *
     * @param string $filePath
     * @return string
     */
    protected function extractWithSmalotPdfParser(string $filePath): string
    {
        try {
            $parser = new \Smalot\PdfParser\Parser();
            $pdf = $parser->parseFile($filePath);
            $text = $pdf->getText();
            
            if (empty(trim($text))) {
                throw new \Exception('Smalot PDF parser returned empty text');
            }
            
            $questionCount = $this->countQuestionsInText($text);
            Log::info("Smalot PDF extraction complete. Length: " . strlen($text) . " chars, Questions detected: $questionCount");
            
            return $text;
        } catch (\Exception $e) {
            Log::error('Smalot PDF parser error: ' . $e->getMessage());
            throw new \Exception('Smalot PDF parser failed: ' . $e->getMessage());
        }
    }

    /**
     * Extract text using spatie/pdf-to-text library
     *
     * @param string $filePath
     * @return string
     */
    protected function extractWithSpatiePdfToText(string $filePath): string
    {
        $text = \Spatie\PdfToText\Pdf::getText($filePath);
        
        if (empty($text)) {
            throw new \Exception('Spatie PDF to text returned empty text');
        }
        
        return $text;
    }

    /**
     * Extract text from PDF using shell command (fallback)
     *
     * @param string $filePath
     * @return string
     */
    protected function extractTextFromPdfWithShell(string $filePath): string
    {
        // Try pdftotext command (common on Linux/Unix systems)
        $tempFile = storage_path('app/temp/extracted_shell_' . uniqid() . '.txt');
        
        $command = sprintf(
            'pdftotext "%s" "%s" 2>&1',
            $filePath,
            $tempFile
        );
        
        Log::info("Running shell PDF extraction: $command");
        
        exec($command, $output, $returnCode);
        
        Log::info("Shell PDF extraction output: " . implode("\n", $output));
        
        if ($returnCode === 0 && file_exists($tempFile)) {
            $text = file_get_contents($tempFile);
            @unlink($tempFile);
            
            if (!empty($text)) {
                $questionCount = $this->countQuestionsInText($text);
                Log::info("Shell PDF extraction complete. Length: " . strlen($text) . " chars, Questions detected: $questionCount");
                return $text;
            }
        }
        
        throw new \Exception('Shell PDF extraction failed. pdftotext command not available or PDF file is corrupted.');
    }

    /**
     * Extract text using PowerShell on Windows
     *
     * @param string $filePath
     * @return string
     */
    protected function extractWithPowerShell(string $filePath): string
    {
        $tempFile = storage_path('app/temp/extracted_ps_' . uniqid() . '.txt');
        $psScript = storage_path('app/temp/extract_pdf.ps1');
        
        // Create PowerShell script
        $psContent = <<<'POWERSHELL'
param(
    [string]$pdfPath,
    [string]$outputPath
)

try {
    # Try using iTextSharp via .NET
    Add-Type -Path "C:\Windows\Microsoft.NET\Framework\v4.0.30319\itextsharp.dll" -ErrorAction SilentlyContinue
    
    if (-not ([System.Management.Automation.PSTypeName]'iTextSharp.text.pdf.PdfReader').Type) {
        # iTextSharp not available, try alternative
        Write-Output "iTextSharp not available, trying text extraction..."
        
        # Simple text extraction using Windows COM (if available)
        $text = ""
        
        # Method 1: Try using Word automation
        try {
            $word = New-Object -ComObject Word.Application
            $word.Visible = $false
            $doc = $word.Documents.Open($pdfPath)
            $text = $doc.Content.Text
            $doc.Close()
            $word.Quit()
            
            if ($text -and $text.Trim().Length -gt 100) {
                $text | Out-File -FilePath $outputPath -Encoding UTF8
                Write-Output "Extraction successful via Word automation"
                exit 0
            }
        } catch {
            Write-Output "Word automation failed: $_"
        }
        
        # Method 2: Try using Adobe Reader if installed
        try {
            $acroExe = "C:\Program Files\Adobe\Acrobat DC\Acrobat\Acrobat.exe"
            if (Test-Path $acroExe) {
                $tempTxt = [System.IO.Path]::GetTempFileName() + ".txt"
                $args = "/t `"$pdfPath`" `"$tempTxt`""
                Start-Process -FilePath $acroExe -ArgumentList $args -Wait -NoNewWindow
                
                if (Test-Path $tempTxt) {
                    $text = Get-Content $tempTxt -Raw
                    Remove-Item $tempTxt
                    
                    if ($text -and $text.Trim().Length -gt 100) {
                        $text | Out-File -FilePath $outputPath -Encoding UTF8
                        Write-Output "Extraction successful via Adobe Reader"
                        exit 0
                    }
                }
            }
        } catch {
            Write-Output "Adobe Reader extraction failed: $_"
        }
        
        # If we get here, all methods failed
        Write-Output "All PDF extraction methods failed"
        "" | Out-File -FilePath $outputPath -Encoding UTF8
        exit 1
        
    } else {
        # Use iTextSharp
        $reader = New-Object iTextSharp.text.pdf.PdfReader($pdfPath)
        $text = ""
        
        for ($i = 1; $i -le $reader.NumberOfPages; $i++) {
            $strategy = New-Object iTextSharp.text.pdf.parser.SimpleTextExtractionStrategy
            $currentText = [iTextSharp.text.pdf.parser.PdfTextExtractor]::GetTextFromPage($reader, $i, $strategy)
            $text += [System.Text.Encoding]::UTF8.GetString([System.Text.ASCIIEncoding]::Convert([System.Text.Encoding]::Default, [System.Text.Encoding]::UTF8, [System.Text.Encoding]::Default.GetBytes($currentText)))
            $text += "`n`n"
        }
        
        $reader.Close()
        
        $text | Out-File -FilePath $outputPath -Encoding UTF8
        Write-Output "Extraction successful via iTextSharp"
        exit 0
    }
} catch {
    Write-Output "PowerShell extraction error: $_"
    "" | Out-File -FilePath $outputPath -Encoding UTF8
    exit 1
}
POWERSHELL;
        
        \Illuminate\Support\Facades\File::put($psScript, $psContent);
        
        $command = sprintf(
            'powershell -ExecutionPolicy Bypass -File "%s" -pdfPath "%s" -outputPath "%s" 2>&1',
            $psScript,
            $filePath,
            $tempFile
        );
        
        Log::info("Running PowerShell PDF extraction: $command");
        
        exec($command, $output, $returnCode);
        
        // Clean up PowerShell script
        @unlink($psScript);
        
        Log::info("PowerShell PDF extraction output: " . implode("\n", $output));
        
        if ($returnCode === 0 && file_exists($tempFile)) {
            $text = file_get_contents($tempFile);
            @unlink($tempFile);
            
            if (!empty(trim($text))) {
                $questionCount = $this->countQuestionsInText($text);
                Log::info("PowerShell PDF extraction complete. Length: " . strlen($text) . " chars, Questions detected: $questionCount");
                return $text;
            }
        }
        
        throw new \Exception('PowerShell PDF extraction failed');
    }
}
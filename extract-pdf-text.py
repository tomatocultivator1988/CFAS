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
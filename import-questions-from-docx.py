"""
Import questions from Word document to database
Reads .docx file and identifies correct answers by highlight color
"""

import re
import sys
import requests
from docx import Document

# Configuration
API_BASE_URL = "http://localhost:8000/api"
ADMIN_USERNAME = "admin"
ADMIN_PASSWORD = "admin123"

def login():
    """Login and get auth token"""
    try:
        response = requests.post(f"{API_BASE_URL}/auth/login", json={
            "username": ADMIN_USERNAME,
            "password": ADMIN_PASSWORD
        }, timeout=10)  # 10 second timeout
        
        if response.status_code == 200:
            data = response.json()
            return data.get('data', {}).get('token') or data.get('token')
        else:
            print(f"Login failed: {response.text}")
            return None
    except requests.exceptions.Timeout:
        print("Login request timed out")
        return None
    except Exception as e:
        print(f"Login error: {e}")
        return None

def is_highlighted(run):
    """Check if text run is highlighted (any color)"""
    if run.font.highlight_color:
        return True
    return False

def parse_docx(file_path):
    """Parse Word document and extract questions with choices"""
    doc = Document(file_path)
    questions = []
    
    current_question = None
    current_question_text = ""
    current_choices = []
    
    for para in doc.paragraphs:
        text = para.text.strip()
        if not text:
            continue
        
        # Check if this is a question (starts with number)
        question_match = re.match(r'^(\d+)\.\s*(.+)', text)
        
        if question_match:
            # Save previous question if exists
            if current_question_text and current_choices:
                questions.append({
                    'question_text': current_question_text,
                    'answer_choices': current_choices
                })
            
            # Start new question
            current_question_text = question_match.group(2).strip()
            current_choices = []
            continue
        
        # Check if this is a choice (starts with letter)
        choice_match = re.match(r'^([a-z])\.\s*(.+)', text, re.IGNORECASE)
        
        if choice_match and current_question_text:
            choice_letter = choice_match.group(1)
            choice_text = choice_match.group(2).strip()
            
            # Check if any part of this paragraph is highlighted
            is_correct = False
            for run in para.runs:
                if run.text.strip() and is_highlighted(run):
                    is_correct = True
                    break
            
            current_choices.append({
                'choice_text': choice_text,
                'is_correct': is_correct
            })
    
    # Don't forget the last question
    if current_question_text and current_choices:
        questions.append({
            'question_text': current_question_text,
            'answer_choices': current_choices
        })
    
    return questions

def create_question(token, exam_id, question_data):
    """Create a question via API"""
    headers = {
        'Authorization': f'Bearer {token}',
        'Content-Type': 'application/json'
    }
    
    data = {
        'question_text': question_data['question_text'],
        'answer_choices': question_data['answer_choices'],
        'exam_id': exam_id
    }
    
    try:
        response = requests.post(
            f"{API_BASE_URL}/admin/questions",
            json=data,
            headers=headers,
            timeout=30  # 30 second timeout per question
        )
        
        return response.status_code == 201
    except requests.exceptions.Timeout:
        print(f"Timeout creating question: {question_data['question_text'][:50]}...")
        return False
    except Exception as e:
        print(f"Error creating question: {e}")
        return False

def main():
    if len(sys.argv) < 3:
        print("Usage: python import-questions-from-docx.py <path-to-docx-file> <exam_id>")
        sys.exit(1)
    
    docx_file = sys.argv[1]
    exam_id = int(sys.argv[2])
    
    # Parse the document
    try:
        questions = parse_docx(docx_file)
    except Exception as e:
        print(f"Error reading document: {e}")
        sys.exit(1)
    
    # Login
    token = login()
    if not token:
        print("Failed to login")
        sys.exit(1)
    
    # Import questions
    success_count = 0
    fail_count = 0
    
    for question in questions:
        if create_question(token, exam_id, question):
            success_count += 1
        else:
            fail_count += 1
    
    # Output result (this will be parsed by PHP)
    if success_count > 0:
        print(f"Successfully imported {success_count} questions")
        sys.exit(0)
    else:
        print(f"Failed to import questions. Errors: {fail_count}")
        sys.exit(1)

if __name__ == "__main__":
    main()

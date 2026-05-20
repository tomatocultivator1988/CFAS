"""
Parse questions from Word document and output as JSON
No API calls - just parsing
"""

import re
import sys
import json
from docx import Document

def is_highlighted(run):
    """Check if text run is highlighted (any color)"""
    if run.font.highlight_color:
        return True
    return False

def parse_docx(file_path):
    """Parse Word document and extract questions with choices"""
    doc = Document(file_path)
    questions = []
    
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

def main():
    if len(sys.argv) < 2:
        print(json.dumps({"error": "Usage: python parse-docx-only.py <path-to-docx-file>"}))
        sys.exit(1)
    
    docx_file = sys.argv[1]
    
    # Parse the document
    try:
        questions = parse_docx(docx_file)
        # Output as JSON
        print(json.dumps(questions))
        sys.exit(0)
    except Exception as e:
        print(json.dumps({"error": str(e)}))
        sys.exit(1)

if __name__ == "__main__":
    main()

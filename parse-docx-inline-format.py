"""
Parse DOCX with Inline Format (2 choices per line)
Handles format where choices are on 2 lines with tabs/spaces

Format:
1. Question text
a. Choice A                    b. Choice B
c. Choice C                    d. Choice D

No answer key - uses Gemini AI to identify correct answers
"""

import sys
import json
import re
from docx import Document
import requests

# Gemini API Configuration
GEMINI_API_KEY = "[REDACTED_GEMINI_API_KEY]"
# Use gemini-pro instead of flash-latest
GEMINI_API_URL = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key={GEMINI_API_KEY}"

def extract_questions_from_docx(file_path):
    """Extract questions from inline format"""
    doc = Document(file_path)
    questions = []
    
    current_question = None
    current_choices = []
    
    for para in doc.paragraphs:
        text = para.text.strip()
        if not text:
            continue
        
        # Check if this is a question (starts with number)
        q_match = re.match(r'^(\d+)\.\s*(.+)', text)
        if q_match:
            # Save previous question
            if current_question and current_choices:
                questions.append({
                    'question_text': current_question,
                    'choices_raw': current_choices
                })
            
            # Start new question
            current_question = q_match.group(2).strip()
            current_choices = []
            continue
        
        # Check if this line has choices (starts with letter)
        if re.match(r'^[a-d]\.', text, re.IGNORECASE):
            current_choices.append(text)
    
    # Don't forget last question
    if current_question and current_choices:
        questions.append({
            'question_text': current_question,
            'choices_raw': current_choices
        })
    
    return questions

def parse_inline_choices(choices_raw):
    """Parse choices from inline format (2 per line)"""
    all_choices = []
    
    for line in choices_raw:
        # Split by multiple spaces/tabs (usually 2+ spaces or tabs)
        parts = re.split(r'\s{2,}|\t+', line)
        
        for part in parts:
            part = part.strip()
            if not part:
                continue
            
            # Extract choice letter and text
            match = re.match(r'^([a-d])\.\s*(.+)', part, re.IGNORECASE)
            if match:
                letter = match.group(1).lower()
                text = match.group(2).strip()
                all_choices.append({
                    'letter': letter,
                    'text': text,
                    'is_correct': False  # Will be determined by AI
                })
    
    return all_choices

def identify_correct_answers_with_ai(questions):
    """Use Gemini AI to identify correct answers"""
    
    # Prepare questions for AI
    questions_text = []
    for i, q in enumerate(questions, 1):
        q_text = f"{i}. {q['question_text']}\n"
        for choice in q['choices']:
            q_text += f"   {choice['letter']}. {choice['text']}\n"
        questions_text.append(q_text)
    
    prompt = f"""You are an aquaculture and fisheries expert. Below are exam questions. For each question, identify the CORRECT answer (a, b, c, or d).

Output ONLY a JSON array with question numbers and correct answers. No explanations.

Format:
[
  {{"question": 1, "answer": "c"}},
  {{"question": 2, "answer": "d"}},
  ...
]

QUESTIONS:
{chr(10).join(questions_text[:20])}

Output ONLY the JSON array, nothing else."""

    try:
        response = requests.post(
            GEMINI_API_URL,
            json={
                "contents": [{
                    "parts": [{
                        "text": prompt
                    }]
                }],
                "generationConfig": {
                    "temperature": 0.1,
                    "maxOutputTokens": 2000
                }
            },
            timeout=30
        )
        
        if response.status_code == 200:
            result = response.json()
            
            if 'candidates' in result and len(result['candidates']) > 0:
                candidate = result['candidates'][0]
                if 'content' in candidate and 'parts' in candidate['content']:
                    ai_output = candidate['content']['parts'][0]['text']
                    
                    # Clean up output
                    ai_output = re.sub(r'```json\s*', '', ai_output)
                    ai_output = re.sub(r'```\s*', '', ai_output)
                    ai_output = ai_output.strip()
                    
                    # Parse JSON
                    try:
                        answers = json.loads(ai_output)
                        return {a['question']: a['answer'].lower() for a in answers}
                    except:
                        # Try to extract JSON
                        json_match = re.search(r'\[.*\]', ai_output, re.DOTALL)
                        if json_match:
                            answers = json.loads(json_match.group(0))
                            return {a['question']: a['answer'].lower() for a in answers}
        
        print(f"AI response: {response.text[:500]}", file=sys.stderr)
        return {}
            
    except Exception as e:
        print(f"AI error: {e}", file=sys.stderr)
        return {}

def main():
    if len(sys.argv) < 2:
        print(json.dumps({"error": "Usage: python parse-docx-inline-format.py <docx-file> [--ai]"}))
        sys.exit(1)
    
    docx_file = sys.argv[1]
    use_ai = len(sys.argv) > 2 and sys.argv[2] == "--ai"
    
    try:
        # Step 1: Extract questions
        print("Extracting questions...", file=sys.stderr)
        questions = extract_questions_from_docx(docx_file)
        
        if not questions:
            print(json.dumps({"error": "No questions found"}))
            sys.exit(1)
        
        print(f"Found {len(questions)} questions", file=sys.stderr)
        
        # Step 2: Parse inline choices
        for q in questions:
            q['choices'] = parse_inline_choices(q['choices_raw'])
            del q['choices_raw']
        
        # Step 3: Use AI to identify correct answers (if requested)
        if use_ai:
            print("Using Gemini AI to identify correct answers...", file=sys.stderr)
            correct_answers = identify_correct_answers_with_ai(questions)
            
            if correct_answers:
                print(f"AI identified {len(correct_answers)} correct answers", file=sys.stderr)
                
                # Mark correct answers
                for i, q in enumerate(questions, 1):
                    correct_letter = correct_answers.get(i, '')
                    for choice in q['choices']:
                        if choice['letter'] == correct_letter:
                            choice['is_correct'] = True
        
        # Step 4: Format output
        output_questions = []
        for q in questions:
            output_questions.append({
                'question_text': q['question_text'],
                'answer_choices': [
                    {
                        'choice_text': c['text'],
                        'is_correct': c['is_correct']
                    }
                    for c in q['choices']
                ]
            })
        
        # Validate - ensure at least one correct answer per question
        for q in output_questions:
            has_correct = any(c['is_correct'] for c in q['answer_choices'])
            if not has_correct and q['answer_choices']:
                # Default first choice as correct if AI didn't identify one
                q['answer_choices'][0]['is_correct'] = True
        
        print(f"Outputting {len(output_questions)} questions", file=sys.stderr)
        print(json.dumps(output_questions, ensure_ascii=False))
        sys.exit(0)
        
    except Exception as e:
        print(json.dumps({"error": str(e)}))
        import traceback
        traceback.print_exc(file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()

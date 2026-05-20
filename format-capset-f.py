#!/usr/bin/env python3
"""
Format CapSet F questions into HTML for DOCX import
This creates a clean format that the AI parser can read with answer key table
"""

# Questions data (first 10 as example - you can add all 100)
questions = [
    {
        "num": 1,
        "text": "It has been used in migration and stock identification studies involving catching of fishes of interest, marking with chosen medium and subsequent release.",
        "choices": ["Tagging", "Disease and parasite", "Fishing effort distribution", "Marking"],
        "answer": "d"
    },
    {
        "num": 2,
        "text": "These are considered as the \"natural tags\" in migration and stock identification studies.",
        "choices": ["Tagging", "Disease and parasite", "Fishing effort distribution", "Marking"],
        "answer": "b"
    },
    # Add all 100 questions here...
]

# Generate HTML
html = """<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>CapSet F - Fisheries Questions</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        p { margin: 5px 0; }
        .question { margin-bottom: 20px; }
        table { border-collapse: collapse; margin-top: 40px; }
        th, td { border: 1px solid black; padding: 8px; text-align: left; }
    </style>
</head>
<body>

<h1>CapSet F - Fisheries Examination</h1>

"""

# Add questions
for q in questions:
    html += f'<div class="question">\n'
    html += f'<p><strong>{q["num"]}.</strong> {q["text"]}</p>\n'
    for i, choice in enumerate(q["choices"]):
        letter = chr(97 + i)  # a, b, c, d
        html += f'<p>{letter}. {choice}</p>\n'
    html += '</div>\n\n'

# Add answer key table
html += """
<h2>ANSWER KEY</h2>
<table>
    <tr>
        <th>Question</th>
        <th>Answer</th>
    </tr>
"""

for q in questions:
    html += f'    <tr><td>{q["num"]}</td><td>{q["answer"].upper()}</td></tr>\n'

html += """</table>

</body>
</html>"""

# Save to file
with open('CapSet_F_Formatted_Complete.html', 'w', encoding='utf-8') as f:
    f.write(html)

print("✅ HTML file created: CapSet_F_Formatted_Complete.html")
print("📝 Open this file in Microsoft Word")
print("💾 Save as DOCX format")
print("📤 Upload to the exam system!")

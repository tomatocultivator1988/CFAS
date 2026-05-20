# Access Database from External ML Project

## Overview

Kung may separate ML project ka kag gusto mo i-access ang database sang exam system, may 3 ka main approaches:

1. **Direct MySQL Connection** (EASIEST) ⭐
2. **API Endpoint** (RECOMMENDED for production)
3. **Shared Database Config** (SIMPLE)

---

## Approach 1: Direct MySQL Connection (EASIEST) ⭐

Ang imo separate ML project mag-connect directly sa MySQL database.

### Python Example:

```python
import mysql.connector
import pandas as pd

# Database connection
db_config = {
    'host': 'localhost',  # or '192.168.11.40' if remote
    'user': 'root',
    'password': '',  # your MySQL password
    'database': 'review_center_exam'
}

# Connect to database
conn = mysql.connector.connect(**db_config)

# Query data
query = """
SELECT 
    r.id as reviewee_id,
    r.name,
    ea.exam_id,
    ea.score,
    ea.total_questions,
    ea.time_taken,
    ea.completed_at
FROM reviewees r
LEFT JOIN exam_attempts ea ON r.id = ea.reviewee_id
WHERE ea.completed_at IS NOT NULL
"""

# Load into pandas DataFrame
df = pd.read_sql(query, conn)

# Close connection
conn.close()

# Now you can use df for ML training
print(df.head())
```

### Install Required Package:

```bash
pip install mysql-connector-python pandas
```

---

## Approach 2: API Endpoint (RECOMMENDED)

Create API endpoint sa Laravel backend para mag-serve sang data.

### Step 1: Create API Route

File: `backend/routes/api.php`

```php
// Add this route
Route::get('/ml/training-data', [MLDataController::class, 'getTrainingData']);
```

### Step 2: Create Controller

File: `backend/app/Http/Controllers/MLDataController.php`

```php
<?php

namespace App\Http\Controllers;

use App\Models\Reviewee;
use App\Models\ExamAttempt;
use Illuminate\Http\Request;

class MLDataController extends Controller
{
    public function getTrainingData()
    {
        $data = ExamAttempt::with('reviewee')
            ->whereNotNull('completed_at')
            ->select([
                'reviewee_id',
                'exam_id',
                'score',
                'total_questions',
                'time_taken',
                'completed_at'
            ])
            ->get()
            ->map(function($attempt) {
                return [
                    'reviewee_id' => $attempt->reviewee_id,
                    'reviewee_name' => $attempt->reviewee->name ?? 'Unknown',
                    'exam_id' => $attempt->exam_id,
                    'score' => $attempt->score,
                    'total_questions' => $attempt->total_questions,
                    'percentage' => ($attempt->score / $attempt->total_questions) * 100,
                    'time_taken' => $attempt->time_taken,
                    'completed_at' => $attempt->completed_at,
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $data
        ]);
    }
}
```

### Step 3: Access from ML Project

```python
import requests
import pandas as pd

# Fetch data from API
response = requests.get('http://localhost:8000/api/ml/training-data')
data = response.json()['data']

# Convert to DataFrame
df = pd.DataFrame(data)

# Use for ML training
print(df.head())
```

---

## Approach 3: Shared Database Config (SIMPLE)

Create shared config file nga pwede gamiton sang both projects.

### Step 1: Create Config File

File: `shared_config.py` (sa root or shared folder)

```python
# Database Configuration
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': '',
    'database': 'review_center_exam',
    'port': 3306
}

# Table names
TABLES = {
    'reviewees': 'reviewees',
    'exams': 'exams',
    'exam_attempts': 'exam_attempts',
    'questions': 'questions',
    'choices': 'choices',
    'answers': 'answers'
}
```

### Step 2: Use in ML Project

```python
from shared_config import DB_CONFIG, TABLES
import mysql.connector
import pandas as pd

# Connect
conn = mysql.connector.connect(**DB_CONFIG)

# Query using table names from config
query = f"""
SELECT * FROM {TABLES['exam_attempts']}
WHERE completed_at IS NOT NULL
"""

df = pd.read_sql(query, conn)
conn.close()
```

---

## Complete ML Project Example

### Project Structure:

```
my_ml_project/
├── config.py           # Database config
├── data_loader.py      # Load data from database
├── train_model.py      # Train ML model
├── predict.py          # Make predictions
└── requirements.txt    # Dependencies
```

### config.py

```python
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': '',
    'database': 'review_center_exam'
}
```

### data_loader.py

```python
import mysql.connector
import pandas as pd
from config import DB_CONFIG

class DataLoader:
    def __init__(self):
        self.conn = mysql.connector.connect(**DB_CONFIG)
    
    def get_training_data(self):
        """Get all exam attempts for training"""
        query = """
        SELECT 
            ea.reviewee_id,
            ea.exam_id,
            ea.score,
            ea.total_questions,
            ea.time_taken,
            ea.completed_at,
            COUNT(DISTINCT ea2.id) as previous_attempts,
            AVG(ea2.score) as avg_previous_score
        FROM exam_attempts ea
        LEFT JOIN exam_attempts ea2 ON ea.reviewee_id = ea2.reviewee_id 
            AND ea2.completed_at < ea.completed_at
        WHERE ea.completed_at IS NOT NULL
        GROUP BY ea.id
        """
        df = pd.read_sql(query, self.conn)
        return df
    
    def get_reviewee_history(self, reviewee_id):
        """Get specific reviewee's exam history"""
        query = f"""
        SELECT * FROM exam_attempts
        WHERE reviewee_id = {reviewee_id}
        AND completed_at IS NOT NULL
        ORDER BY completed_at DESC
        """
        df = pd.read_sql(query, self.conn)
        return df
    
    def close(self):
        self.conn.close()
```

### train_model.py

```python
from data_loader import DataLoader
from sklearn.ensemble import RandomForestClassifier
import pickle

# Load data
loader = DataLoader()
df = loader.get_training_data()
loader.close()

# Prepare features
X = df[['score', 'total_questions', 'time_taken', 'previous_attempts', 'avg_previous_score']]
y = (df['score'] / df['total_questions'] >= 0.75).astype(int)  # Pass/Fail

# Train model
model = RandomForestClassifier()
model.fit(X, y)

# Save model
with open('model.pkl', 'wb') as f:
    pickle.dump(model, f)

print("Model trained and saved!")
```

### predict.py

```python
from data_loader import DataLoader
import pickle

# Load model
with open('model.pkl', 'rb') as f:
    model = pickle.load(f)

# Get data for specific reviewee
loader = DataLoader()
reviewee_data = loader.get_reviewee_history(reviewee_id=1)
loader.close()

# Prepare features
X = reviewee_data[['score', 'total_questions', 'time_taken', 'previous_attempts', 'avg_previous_score']]

# Predict
predictions = model.predict(X)
probabilities = model.predict_proba(X)

print(f"Predictions: {predictions}")
print(f"Pass Probability: {probabilities[:, 1]}")
```

### requirements.txt

```
mysql-connector-python==8.0.33
pandas==2.0.3
scikit-learn==1.3.0
numpy==1.24.3
```

---

## Connection Details

### Local Connection:
```python
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': '',
    'database': 'review_center_exam',
    'port': 3306
}
```

### Remote Connection (if on different PC):
```python
DB_CONFIG = {
    'host': '192.168.11.40',  # Your server IP
    'user': 'root',  # or remote user
    'password': '',
    'database': 'review_center_exam',
    'port': 3306
}
```

---

## Security Best Practices

### 1. Use Environment Variables

```python
import os
from dotenv import load_dotenv

load_dotenv()

DB_CONFIG = {
    'host': os.getenv('DB_HOST', 'localhost'),
    'user': os.getenv('DB_USER', 'root'),
    'password': os.getenv('DB_PASSWORD', ''),
    'database': os.getenv('DB_NAME', 'review_center_exam')
}
```

### 2. Create .env File

```
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=
DB_NAME=review_center_exam
```

### 3. Add to .gitignore

```
.env
*.pkl
__pycache__/
```

---

## Common Queries for ML

### Get All Exam Attempts:
```sql
SELECT * FROM exam_attempts WHERE completed_at IS NOT NULL;
```

### Get Reviewee Performance:
```sql
SELECT 
    r.id,
    r.name,
    COUNT(ea.id) as total_attempts,
    AVG(ea.score) as avg_score,
    MAX(ea.score) as best_score
FROM reviewees r
LEFT JOIN exam_attempts ea ON r.id = ea.reviewee_id
GROUP BY r.id;
```

### Get Question Difficulty:
```sql
SELECT 
    q.id,
    q.question_text,
    COUNT(a.id) as total_answers,
    SUM(a.is_correct) as correct_answers,
    (SUM(a.is_correct) / COUNT(a.id)) * 100 as difficulty_percentage
FROM questions q
LEFT JOIN answers a ON q.id = a.question_id
GROUP BY q.id;
```

---

## Troubleshooting

### Connection Refused:
```python
# Check if MySQL is running
# Check if host/port is correct
# Check if firewall allows connection
```

### Access Denied:
```python
# Check username/password
# Check if user has permissions
# Grant permissions if needed:
# GRANT ALL PRIVILEGES ON review_center_exam.* TO 'user'@'localhost';
```

### Module Not Found:
```bash
pip install mysql-connector-python
```

---

## Summary

**Easiest:** Direct MySQL connection (Approach 1)
**Best:** API endpoint (Approach 2)
**Simplest:** Shared config (Approach 3)

**Recommended for your case:**
Use Approach 1 (Direct MySQL Connection) since both projects are on same machine. Simple kag straightforward!

```python
import mysql.connector
import pandas as pd

conn = mysql.connector.connect(
    host='localhost',
    user='root',
    password='',
    database='review_center_exam'
)

df = pd.read_sql("SELECT * FROM exam_attempts", conn)
conn.close()
```

Tapos na! Pwede na ka mag-access sang database from your ML project! 🎉

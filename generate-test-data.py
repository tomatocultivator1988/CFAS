"""
Generate Realistic Test Data for ML Model Training
Creates hundreds of exam attempts with realistic patterns
"""

import mysql.connector
from mysql.connector import Error
import random
from datetime import datetime, timedelta
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv('backend/.env')

def connect_database():
    """Connect to MySQL database"""
    try:
        connection = mysql.connector.connect(
            host=os.getenv('DB_HOST', 'localhost'),
            database=os.getenv('DB_DATABASE', 'exam_system'),
            user=os.getenv('DB_USERNAME', 'root'),
            password=os.getenv('DB_PASSWORD', '')
        )
        return connection
    except Error as e:
        print(f"Error connecting to database: {e}")
        return None

def get_existing_data(connection):
    """Get existing exams and reviewees"""
    cursor = connection.cursor(dictionary=True)
    
    # Get exams with their question counts
    cursor.execute("""
        SELECT 
            e.id,
            COUNT(eq.question_id) as total_questions
        FROM exams e
        LEFT JOIN exam_questions eq ON e.id = eq.exam_id
        WHERE e.is_deleted = 0
        GROUP BY e.id
        HAVING total_questions > 0
    """)
    exams = cursor.fetchall()
    
    # Get reviewees
    cursor.execute("SELECT id FROM users WHERE role = 'reviewee'")
    reviewees = cursor.fetchall()
    
    cursor.close()
    return exams, reviewees

def generate_student_profile():
    """Generate a realistic student performance profile"""
    profiles = [
        # Excellent students (20%)
        {
            'type': 'excellent',
            'base_score_range': (85, 100),
            'improvement_rate': 0.02,
            'consistency': 0.9,
            'violation_prob': 0.01
        },
        # Good students (30%)
        {
            'type': 'good',
            'base_score_range': (70, 85),
            'improvement_rate': 0.03,
            'consistency': 0.8,
            'violation_prob': 0.05
        },
        # Average students (30%)
        {
            'type': 'average',
            'base_score_range': (50, 70),
            'improvement_rate': 0.02,
            'consistency': 0.6,
            'violation_prob': 0.1
        },
        # Struggling students (15%)
        {
            'type': 'struggling',
            'base_score_range': (30, 50),
            'improvement_rate': 0.01,
            'consistency': 0.4,
            'violation_prob': 0.15
        },
        # At-risk students (5%)
        {
            'type': 'at-risk',
            'base_score_range': (0, 30),
            'improvement_rate': 0.0,
            'consistency': 0.2,
            'violation_prob': 0.25
        }
    ]
    
    # Weighted random selection
    weights = [20, 30, 30, 15, 5]
    return random.choices(profiles, weights=weights)[0]

def generate_exam_attempts(connection, num_attempts=500):
    """Generate realistic exam attempts"""
    exams, reviewees = get_existing_data(connection)
    
    if not exams or not reviewees:
        print("Error: No exams or reviewees found in database")
        return 0
    
    print(f"Found {len(exams)} exams and {len(reviewees)} reviewees")
    print(f"Generating {num_attempts} exam attempts...")
    print("=" * 60)
    
    cursor = connection.cursor()
    attempts_created = 0
    
    # Track attempts per student for realistic progression
    student_attempts = {}
    
    for i in range(num_attempts):
        # Select random reviewee and exam
        reviewee = random.choice(reviewees)
        exam = random.choice(exams)
        
        reviewee_id = reviewee['id']
        exam_id = exam['id']
        total_questions = exam['total_questions']
        
        # Initialize student profile if first attempt
        if reviewee_id not in student_attempts:
            student_attempts[reviewee_id] = {
                'profile': generate_student_profile(),
                'attempt_count': 0,
                'base_score': None
            }
        
        student = student_attempts[reviewee_id]
        student['attempt_count'] += 1
        attempt_number = student['attempt_count']
        
        profile = student['profile']
        
        # Calculate base score for this student
        if student['base_score'] is None:
            min_score, max_score = profile['base_score_range']
            student['base_score'] = random.uniform(min_score, max_score)
        
        # Calculate score with improvement and variance
        base_percentage = student['base_score']
        improvement = profile['improvement_rate'] * attempt_number * 100
        variance = random.uniform(-10, 10) * (1 - profile['consistency'])
        
        final_percentage = max(0, min(100, base_percentage + improvement + variance))
        score = int((final_percentage / 100) * total_questions)
        
        # Generate realistic duration (30-90 minutes)
        avg_time_per_question = random.uniform(1.0, 2.5)
        duration_minutes = int(total_questions * avg_time_per_question)
        
        # Generate timestamps (random date in last 3 months)
        days_ago = random.randint(1, 90)
        start_time = datetime.now() - timedelta(days=days_ago, hours=random.randint(0, 23))
        end_time = start_time + timedelta(minutes=duration_minutes)
        
        # Insert exam attempt
        try:
            insert_attempt = """
            INSERT INTO exam_attempts 
            (reviewee_id, exam_id, attempt_number, randomization_seed, start_time, end_time, 
             time_limit_seconds, violation_count, status, score, total_questions, percentage)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """
            
            # Calculate violation count
            violation_count = 1 if random.random() < profile['violation_prob'] else 0
            
            cursor.execute(insert_attempt, (
                reviewee_id,
                exam_id,
                attempt_number,
                random.randint(1000, 9999),  # randomization_seed
                start_time,
                end_time,
                duration_minutes * 60,  # time_limit_seconds
                violation_count,
                'completed',
                score,
                total_questions,
                final_percentage
            ))
            
            attempt_id = cursor.lastrowid
            
            # Generate answers for this attempt
            correct_answers = score
            incorrect_answers = total_questions - score
            
            # Create answer records (simplified - just track correct/incorrect)
            for q in range(total_questions):
                is_correct = q < correct_answers
                
                insert_answer = """
                INSERT INTO attempt_answers 
                (attempt_id, question_id, selected_choice_id, is_correct)
                VALUES (%s, %s, %s, %s)
                """
                
                cursor.execute(insert_answer, (
                    attempt_id,
                    q + 1,  # Dummy question ID
                    random.randint(1, 4),  # Dummy choice ID
                    1 if is_correct else 0
                ))
            
            # Generate security violations based on profile
            if random.random() < profile['violation_prob']:
                num_violations = random.randint(1, 3)
                for v in range(num_violations):
                    violation_types = ['tab_switch', 'window_blur', 'copy_paste', 'right_click']
                    violation_type = random.choice(violation_types)
                    
                    insert_violation = """
                    INSERT INTO security_violations 
                    (attempt_id, violation_type)
                    VALUES (%s, %s)
                    """
                    
                    cursor.execute(insert_violation, (
                        attempt_id,
                        violation_type
                    ))
            
            attempts_created += 1
            
            if (i + 1) % 50 == 0:
                connection.commit()
                print(f"Progress: {i + 1}/{num_attempts} attempts created...")
        
        except Error as e:
            print(f"Error creating attempt {i + 1}: {e}")
            continue
    
    connection.commit()
    cursor.close()
    
    return attempts_created

def show_statistics(connection):
    """Show database statistics"""
    cursor = connection.cursor(dictionary=True)
    
    # Total attempts
    cursor.execute("SELECT COUNT(*) as total FROM exam_attempts WHERE status = 'completed'")
    total = cursor.fetchone()['total']
    
    # Pass rate
    cursor.execute("""
        SELECT 
            COUNT(*) as total,
            SUM(CASE WHEN (score / total_questions * 100) >= 90 THEN 1 ELSE 0 END) as passed
        FROM exam_attempts 
        WHERE status = 'completed'
    """)
    stats = cursor.fetchone()
    pass_rate = (stats['passed'] / stats['total'] * 100) if stats['total'] > 0 else 0
    
    # Average score
    cursor.execute("""
        SELECT AVG(score / total_questions * 100) as avg_score
        FROM exam_attempts 
        WHERE status = 'completed'
    """)
    avg_score = cursor.fetchone()['avg_score']
    
    # Score distribution
    cursor.execute("""
        SELECT 
            CASE 
                WHEN (score / total_questions * 100) >= 90 THEN 'Excellent (90-100%)'
                WHEN (score / total_questions * 100) >= 70 THEN 'Good (70-89%)'
                WHEN (score / total_questions * 100) >= 50 THEN 'Average (50-69%)'
                WHEN (score / total_questions * 100) >= 30 THEN 'Struggling (30-49%)'
                ELSE 'At-Risk (0-29%)'
            END as category,
            COUNT(*) as count
        FROM exam_attempts 
        WHERE status = 'completed'
        GROUP BY category
        ORDER BY MIN(score / total_questions * 100) DESC
    """)
    distribution = cursor.fetchall()
    
    cursor.close()
    
    print("\n" + "=" * 60)
    print("DATABASE STATISTICS")
    print("=" * 60)
    print(f"Total Exam Attempts: {total}")
    print(f"Pass Rate: {pass_rate:.2f}%")
    print(f"Average Score: {avg_score:.2f}%")
    print("\nScore Distribution:")
    for dist in distribution:
        print(f"  {dist['category']}: {dist['count']} attempts")
    print("=" * 60)

def main():
    """Main function"""
    print("=" * 60)
    print("CFAS Exam System - Test Data Generator")
    print("=" * 60)
    print()
    
    # Connect to database
    connection = connect_database()
    if not connection:
        return
    
    print("Connected to database successfully!")
    print()
    
    # Use default or command line argument
    import sys
    if len(sys.argv) > 1:
        try:
            num_attempts = int(sys.argv[1])
        except ValueError:
            num_attempts = 500
    else:
        num_attempts = 500
    
    print(f"Generating {num_attempts} exam attempts...")
    print()
    
    # Generate data
    created = generate_exam_attempts(connection, num_attempts)
    
    print()
    print(f"✓ Successfully created {created} exam attempts!")
    
    # Show statistics
    show_statistics(connection)
    
    connection.close()
    
    print()
    print("Next step: Train the model with new data")
    print("Run: cd ml_model && python train_model.py")
    print()

if __name__ == "__main__":
    main()

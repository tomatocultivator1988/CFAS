# Review Center Examination System

A secure web-based platform for administering timed multiple-choice examinations with comprehensive security controls, automatic grading, performance analytics, and machine learning-based predictive analysis.

## Architecture

- **Backend**: Laravel 10.x (PHP) - RESTful API
- **Frontend**: Vue.js 3 with Composition API - Single Page Application
- **Database**: MySQL 8.0
- **ML Service**: Python (Flask/FastAPI with Scikit-learn)

## Prerequisites

### Backend Requirements
- PHP 8.1 or higher
- Composer
- MySQL 8.0 or higher
- OpenSSL PHP Extension
- PDO PHP Extension
- Mbstring PHP Extension

### Frontend Requirements
- Node.js 18.x or higher
- npm or yarn

### ML Service Requirements
- Python 3.9 or higher
- pip

## Installation

### 1. Backend Setup (Laravel)

```bash
cd backend

# Install dependencies
composer install

# Copy environment file
copy .env.example .env

# Generate application key
php artisan key:generate

# Configure database in .env file
# DB_DATABASE=review_center_exam
# DB_USERNAME=your_username
# DB_PASSWORD=your_password

# Run migrations
php artisan migrate

# Start development server
php artisan serve --host=localhost --port=8000
```

### 2. Frontend Setup (Vue.js)

```bash
cd frontend

# Install dependencies
npm install

# Copy environment file
copy .env.example .env

# Start development server
npm run dev
```

### 3. Database Setup

Create a MySQL database:

```sql
CREATE DATABASE review_center_exam CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

## Project Structure

```
Exam-Main/
├── backend/                 # Laravel backend
│   ├── app/                # Application code
│   ├── config/             # Configuration files
│   ├── database/           # Migrations and seeders
│   │   └── migrations/     # Database migrations
│   ├── routes/             # API routes
│   └── .env.example        # Environment template
│
├── frontend/               # Vue.js frontend
│   ├── src/
│   │   ├── assets/        # Static assets
│   │   ├── components/    # Vue components
│   │   ├── composables/   # Reusable composition functions
│   │   ├── router/        # Vue Router configuration
│   │   ├── stores/        # Pinia state management
│   │   ├── services/      # API services
│   │   └── views/         # Page components
│   ├── index.html         # HTML entry point
│   ├── vite.config.js     # Vite configuration
│   └── package.json       # Dependencies
│
└── README.md              # This file
```

## Database Schema

The system includes the following tables:

- **users** - User accounts (admin, reviewee)
- **exams** - Exam configurations
- **questions** - Question pool
- **answer_choices** - Answer options for questions
- **exam_questions** - Exam-question relationships
- **exam_assignments** - Exam assignments to reviewees
- **exam_attempts** - Exam attempt records
- **attempt_answers** - Individual answer submissions
- **security_violations** - Security event logs
- **auth_tokens** - Authentication tokens
- **audit_logs** - System audit trail
- **ml_predictions** - ML prediction results
- **ml_model_metrics** - ML model performance metrics

## Configuration

### Backend Configuration

Edit `backend/.env`:

```env
# Application
APP_NAME="Review Center Examination System"
APP_URL=https://localhost:8000
FORCE_HTTPS=true

# Database
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=review_center_exam
DB_USERNAME=root
DB_PASSWORD=

# Security
SESSION_TIMEOUT_MINUTES=30
VIOLATION_THRESHOLD=3
BCRYPT_ROUNDS=12
LAB_IP_RANGE=192.168.1.0/24

# ML Service
ML_SERVICE_URL=http://localhost:5000
```

### Frontend Configuration

Edit `frontend/.env`:

```env
VITE_API_URL=https://localhost:8000/api
```

## Security Features

- HTTPS/TLS encryption for all communications
- Bcrypt password hashing (work factor 12)
- AES-256 encryption for sensitive data at rest
- Token-based authentication with Laravel Sanctum
- Session timeout enforcement
- IP-based access control for lab environment
- Security violation detection and automatic submission
- Rate limiting on API endpoints
- SQL injection and XSS prevention

## Development

### Running Tests

Backend:
```bash
cd backend
php artisan test
```

Frontend:
```bash
cd frontend
npm run test
```

### Building for Production

Frontend:
```bash
cd frontend
npm run build
```

## Next Steps

After completing the infrastructure setup (Task 1), proceed with:

1. Task 2: Implement authentication and session management
2. Task 3: Implement exam and question management
3. Task 4: Implement question randomization service
4. And so on...

Refer to `.kiro/specs/review-center-examination-system/tasks.md` for the complete implementation plan.

## License

MIT License

# Project Structure

## Complete Directory Tree

```
Exam-Main/
│
├── backend/                                    # Laravel 10.x Backend
│   ├── config/
│   │   ├── cors.php                           # CORS configuration
│   │   └── sanctum.php                        # Authentication config
│   │
│   ├── database/
│   │   └── migrations/
│   │       ├── 2024_01_01_000001_create_users_table.php
│   │       ├── 2024_01_01_000002_create_exams_table.php
│   │       ├── 2024_01_01_000003_create_questions_table.php
│   │       ├── 2024_01_01_000004_create_answer_choices_table.php
│   │       ├── 2024_01_01_000005_create_exam_questions_table.php
│   │       ├── 2024_01_01_000006_create_exam_assignments_table.php
│   │       ├── 2024_01_01_000007_create_exam_attempts_table.php
│   │       ├── 2024_01_01_000008_create_attempt_answers_table.php
│   │       ├── 2024_01_01_000009_create_security_violations_table.php
│   │       ├── 2024_01_01_000010_create_auth_tokens_table.php
│   │       ├── 2024_01_01_000011_create_audit_logs_table.php
│   │       ├── 2024_01_01_000012_create_ml_predictions_table.php
│   │       └── 2024_01_01_000013_create_ml_model_metrics_table.php
│   │
│   ├── routes/
│   │   └── api.php                            # API route definitions
│   │
│   ├── .env.example                           # Environment template
│   ├── artisan                                # Laravel CLI
│   └── composer.json                          # PHP dependencies
│
├── frontend/                                   # Vue.js 3 Frontend
│   ├── src/
│   │   ├── assets/
│   │   │   └── main.css                       # Global styles
│   │   │
│   │   ├── composables/                       # Reusable composition functions
│   │   │   ├── useErrorHandler.js            # Error handling logic
│   │   │   ├── useSecurityMonitor.js         # Security monitoring
│   │   │   └── useTimer.js                   # Countdown timer
│   │   │
│   │   ├── router/
│   │   │   └── index.js                      # Vue Router config
│   │   │
│   │   ├── services/
│   │   │   └── api.js                        # Axios HTTP client
│   │   │
│   │   ├── stores/                           # Pinia state management
│   │   │   ├── admin.js                      # Admin operations
│   │   │   ├── auth.js                       # Authentication
│   │   │   └── exam.js                       # Exam operations
│   │   │
│   │   ├── views/                            # Page components
│   │   │   ├── AdminDashboardView.vue        # Admin dashboard
│   │   │   ├── ExamListView.vue              # Exam list
│   │   │   ├── ExamResultsView.vue           # Results page
│   │   │   ├── ExamTakingView.vue            # Exam interface
│   │   │   └── LoginView.vue                 # Login page
│   │   │
│   │   ├── App.vue                           # Root component
│   │   └── main.js                           # App initialization
│   │
│   ├── .env.example                          # Frontend env template
│   ├── index.html                            # HTML entry point
│   ├── package.json                          # Node dependencies
│   └── vite.config.js                        # Vite configuration
│
├── .gitignore                                # Git ignore rules
├── QUICK_START.md                            # Quick start guide
├── README.md                                 # Project documentation
├── SETUP_INSTRUCTIONS.md                     # Detailed setup guide
├── TASK_1_COMPLETION_SUMMARY.md              # Task completion summary
└── PROJECT_STRUCTURE.md                      # This file
```

## Database Schema (13 Tables)

### Core Tables
1. **users** - User accounts (admin, reviewee)
2. **exams** - Exam configurations
3. **questions** - Question pool
4. **answer_choices** - Answer options

### Relationship Tables
5. **exam_questions** - Links exams to questions
6. **exam_assignments** - Links exams to reviewees

### Attempt Tables
7. **exam_attempts** - Exam attempt records
8. **attempt_answers** - Individual answers

### Security Tables
9. **security_violations** - Security event logs
10. **auth_tokens** - Authentication tokens
11. **audit_logs** - System audit trail

### ML Tables
12. **ml_predictions** - ML prediction results
13. **ml_model_metrics** - Model performance metrics

## Technology Stack

### Backend
- **Framework**: Laravel 10.x
- **Language**: PHP 8.1+
- **Database**: MySQL 8.0+
- **Authentication**: Laravel Sanctum
- **Features**: Queue, Scheduler, Migrations

### Frontend
- **Framework**: Vue.js 3
- **Build Tool**: Vite
- **State Management**: Pinia
- **Routing**: Vue Router
- **HTTP Client**: Axios
- **Charts**: Chart.js
- **API**: Composition API

### Security
- **Encryption**: HTTPS/TLS, AES-256, Bcrypt
- **Authentication**: Token-based (Sanctum)
- **Protection**: CORS, Rate Limiting, Input Sanitization

## Key Features Configured

### Backend Features
✅ RESTful API structure
✅ Database migrations with indexes
✅ CORS policy configuration
✅ Token authentication setup
✅ Environment-based configuration
✅ Security settings (session timeout, violation threshold)

### Frontend Features
✅ SPA with Vue Router
✅ Centralized state management (Pinia)
✅ HTTP interceptors for auth
✅ Reusable composables
✅ Security monitoring logic
✅ Timer functionality
✅ Error handling
✅ Responsive design foundation

## Routes Configured

### API Routes (Backend)

#### Public Routes
- `POST /api/auth/login` - User login

#### Protected Routes (Require Authentication)
- `GET /api/auth/validate` - Validate session
- `POST /api/auth/logout` - User logout

#### Reviewee Routes
- `GET /api/reviewee/exams` - Get assigned exams
- `POST /api/reviewee/exams/{id}/start` - Start exam
- `GET /api/reviewee/attempts/{id}` - Get attempt details
- `POST /api/reviewee/attempts/{id}/answers` - Submit answer
- `POST /api/reviewee/attempts/{id}/submit` - Submit exam
- `GET /api/reviewee/attempts/{id}/time` - Get remaining time
- `POST /api/reviewee/attempts/{id}/violations` - Report violation
- `GET /api/reviewee/attempts/{id}/violations` - Get violations

#### Admin Routes (Require Admin Role)
- Exam Management: GET, POST, PUT, DELETE `/api/admin/exams`
- Question Management: GET, POST, PUT, DELETE `/api/admin/questions`
- User Management: GET, POST, PUT, DELETE `/api/admin/users`
- Analytics: GET `/api/admin/analytics/*`
- ML Predictions: GET, POST `/api/admin/ml/*`

### Frontend Routes

- `/` - Redirect to login
- `/login` - Login page
- `/exams` - Exam list (reviewee only)
- `/exams/:id/take` - Exam taking interface (reviewee only)
- `/exams/:id/results` - Exam results (reviewee only)
- `/admin` - Admin dashboard (admin only)

## State Management (Pinia Stores)

### Auth Store
- **State**: user, token, isAuthenticated
- **Actions**: login, logout, validateSession

### Exam Store
- **State**: assignedExams, currentExam, currentAttempt, examResult
- **Actions**: loadAssignedExams, startExam, submitAnswer, submitExam, getRemainingTime

### Admin Store
- **State**: exams, questions, users, analytics
- **Actions**: loadExams, createExam, updateExam, deleteExam, loadQuestions, createQuestion, loadUsers, createUser, loadAnalytics

## Composables (Reusable Logic)

### useSecurityMonitor
- Monitors window focus loss
- Detects Alt+Tab key combination
- Reports violations to backend
- Tracks violation count

### useTimer
- Countdown timer functionality
- Start/stop controls
- Time formatting
- Auto-cleanup on unmount

### useErrorHandler
- Centralized error handling
- Auto-clear after 5 seconds
- LocalStorage backup
- User-friendly error messages

## Next Steps

1. **Install Prerequisites** (see SETUP_INSTRUCTIONS.md)
2. **Run Setup Commands** (see QUICK_START.md)
3. **Proceed to Task 2**: Implement authentication and session management
4. **Follow Task List**: See `.kiro/specs/review-center-examination-system/tasks.md`

## Documentation Files

- **README.md** - Project overview and architecture
- **QUICK_START.md** - Fast setup guide
- **SETUP_INSTRUCTIONS.md** - Detailed setup with troubleshooting
- **TASK_1_COMPLETION_SUMMARY.md** - What was completed in Task 1
- **PROJECT_STRUCTURE.md** - This file (structure overview)

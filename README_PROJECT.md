# 🏥 MedicalProMax - Medical Education Platform
## آزمون‌یار پزشکی و دندانپزشکی

A comprehensive, production-ready Persian medical education platform for medical students, residents, and specialists preparing for board exams.

---

## 📋 Table of Contents

- [Project Overview](#project-overview)
- [Architecture](#architecture)
- [Technology Stack](#technology-stack)
- [Quick Start](#quick-start)
- [VPS Deployment](#vps-deployment)
- [Database Schema](#database-schema)
- [API Documentation](#api-documentation)
- [Frontend Structure](#frontend-structure)
- [Development Guide](#development-guide)

---

## 🎯 Project Overview

MedicalProMax is a full-featured medical examination and study platform designed specifically for Persian-speaking medical professionals.

### Key Features

✅ **Dual-Mode Learning**
- Exam Mode: Timed, scored examinations
- Study Mode: Interactive topic-based learning with detailed explanations

✅ **Comprehensive Question Bank**
- 15,000+ medical questions
- Multiple difficulty levels
- Detailed explanations and clinical notes

✅ **Multi-Specialty Support**
- Medicine (پزشکی) with 6 exam levels + 15 subspecialties
- Dentistry (دندانپزشکی) with 3 exam levels + 7 subspecialties
- Pharmacy (داروسازی)

✅ **Performance Analytics**
- Score tracking and history
- Weak topic identification
- Progress visualization
- Performance comparison

✅ **Modern Tech Stack**
- Django REST Framework backend
- Next.js React frontend with RTL support
- MySQL database
- Redis caching
- Nginx reverse proxy
- Let's Encrypt SSL/TLS

---

## 🏗️ Architecture

### 4-Level Hierarchical System

```
┌─────────────────────────────────────────┐
│ Level 1: Specialty                      │
│ (پزشکی, دندانپزشکی, داروسازی)            │
└────────────┬────────────────────────────┘
             │
┌────────────▼────────────────────────────┐
│ Level 2: Exam Level                     │
│ (پره، دستیاری، بورد، ملی، صلاحیت)       │
└────────────┬────────────────────────────┘
             │
┌────────────▼────────────────────────────┐
│ Level 3: Subspecialty (Optional)        │
│ (عفونی، قلب، گوارش، ...) - for board    │
└────────────┬────────────────────────────┘
             │
┌────────────▼────────────────────────────┐
│ Level 4: Content                        │
│ (Courses → Chapters → Topics)           │
└─────────────────────────────────────────┘
```

### 17 Database Tables

1. **specialties** - Main specialties
2. **exam_levels** - Exam classifications
3. **subspecialties** - Detailed specializations
4. **courses** - Study courses
5. **chapters** - Course chapters
6. **topics** - Topic content
7. **questions** - Question bank
8. **question_options** - Multiple choice options
9. **question_explanations** - Answer explanations
10. **exam_types_classification** - Exam type categories
11. **exams** - Exam instances
12. **exam_questions** - Questions in exams
13. **users** - User accounts
14. **user_exam_attempts** - Exam results
15. **user_answers** - Individual question answers
16. **user_study_progress** - Study tracking
17. **user_topic_question_attempts** - Topic question attempts

---

## 💻 Technology Stack

### Backend
- **Framework**: Django 4.2+
- **API**: Django REST Framework 3.14+
- **Database**: MySQL 8.0
- **Authentication**: JWT (djangorestframework-simplejwt)
- **Cache**: Redis 7.0
- **Process Manager**: Supervisor + Gunicorn
- **Language**: Python 3.11

### Frontend
- **Framework**: Next.js 14+ (App Router)
- **UI Library**: React 18+
- **Styling**: Tailwind CSS 3+
- **State Management**: Redux Toolkit + RTK Query
- **HTTP Client**: Axios
- **RTL Support**: next-intl
- **Form Validation**: React Hook Form + Yup
- **Language**: TypeScript

### Infrastructure
- **OS**: Ubuntu 22.04 LTS / 24.04 LTS
- **Web Server**: Nginx
- **SSL/TLS**: Let's Encrypt
- **DNS**: Cloudflare
- **VPS Specs**: 6 vCPU, 11GB RAM, 100GB+ SSD

---

## 🚀 Quick Start (Local Development)

### Prerequisites

- Python 3.11+
- Node.js 20+
- MySQL 8.0+
- Git

### Backend Setup

```bash
# Clone repository
git clone https://github.com/Hadiebrahimiseraji/medicalpromaxproject.git
cd medicalpromaxproject/backend

# Create virtual environment
python3.11 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Create .env file
cp .env.example .env
# Edit .env with your MySQL credentials

# Run migrations
python manage.py migrate

# Create superuser
python manage.py createsuperuser

# Run development server
python manage.py runserver
```

**Backend runs at**: http://localhost:8000

### Frontend Setup

```bash
# Navigate to frontend directory
cd ../frontend

# Install dependencies
npm install

# Create .env.local file
cp .env.example .env.local
# Update NEXT_PUBLIC_API_BASE_URL=http://localhost:8000/api

# Run development server
npm run dev
```

**Frontend runs at**: http://localhost:3000

---

## 🌐 VPS Deployment

### Complete VPS Setup (Automated)

We provide automated setup scripts for easy VPS deployment. See [VPS_SETUP_GUIDE.md](VPS_SETUP_GUIDE.md) for detailed instructions.

#### Quick Summary:

1. **Connect to VPS**
   ```bash
   ssh -i your_key.pem username@YOUR_VPS_IP
   ```

2. **Run VPS System Setup**
   ```bash
   sudo bash scripts/setup-vps.sh
   ```

3. **Initialize Database**
   ```bash
   sudo bash scripts/init-database.sh
   ```

4. **Setup Backend**
   ```bash
   sudo bash scripts/setup-backend.sh
   ```

5. **Setup Frontend**
   ```bash
   sudo bash scripts/setup-frontend.sh
   ```

6. **Configure Nginx**
   ```bash
   sudo cp config/nginx-medicalpromax.conf /etc/nginx/sites-available/medicalpromax
   sudo ln -s /etc/nginx/sites-available/medicalpromax /etc/nginx/sites-enabled/
   sudo nginx -t && sudo systemctl reload nginx
   ```

7. **Request SSL Certificate**
   ```bash
   sudo certbot --nginx -d medicalpromax.ir -d www.medicalpromax.ir
   ```

**That's it! Platform is now live.**

---

## 🗄️ Database Schema

### Specialties Table
```sql
id: INT (Primary Key)
slug: VARCHAR (unique) - medicine, dentistry, pharmacy
name_fa: VARCHAR - پزشکی, دندانپزشکی, داروسازی
name_en: VARCHAR - Medicine, Dentistry, Pharmacy
icon: VARCHAR - 🩺, 🦷, 💊
display_order: INT
is_active: BOOLEAN
```

### Questions Table (Full-Text Search)
```sql
id: INT (Primary Key)
specialty_id: INT (Foreign Key)
exam_level_id: INT (Foreign Key)
subspecialty_id: INT (Foreign Key)
course_id: INT (Foreign Key)
chapter_id: INT (Foreign Key)
topic_id: INT (Foreign Key)
question_text: LONGTEXT (Searchable)
question_html: LONGTEXT
image_url: VARCHAR
question_type: ENUM (multiple_choice, true_false, descriptive)
difficulty: ENUM (easy, medium, hard)
tags: JSON
source: VARCHAR
source_year: INT
is_active: BOOLEAN
created_at: TIMESTAMP
updated_at: TIMESTAMP
```

---

## 📡 API Documentation

### Authentication Endpoints

#### Register
```
POST /api/auth/register/
{
  "email": "user@example.com",
  "password": "SecurePass123!",
  "first_name": "علی",
  "last_name": "محمدی"
}
Response: {"user": {...}, "tokens": {"access": "...", "refresh": "..."}}
```

#### Login
```
POST /api/auth/login/
{
  "email": "user@example.com",
  "password": "SecurePass123!"
}
Response: {"tokens": {...}, "user": {...}}
```

#### Refresh Token
```
POST /api/auth/refresh/
{"refresh": "refresh_token_here"}
Response: {"access": "new_access_token"}
```

#### Get Current User
```
GET /api/auth/me/
Headers: Authorization: Bearer {access_token}
Response: {"id": 1, "email": "...", "first_name": "...", ...}
```

### Navigation Endpoints

#### List Specialties
```
GET /api/specialties/
Response: [{"id": 1, "slug": "medicine", "name_fa": "پزشکی", ...}]
```

#### List Exam Levels
```
GET /api/specialties/{specialty_slug}/levels/
Response: {"specialty": {...}, "levels": [...]}
```

#### List Subspecialties
```
GET /api/exam-levels/{level_slug}/subspecialties/?specialty=medicine
Response: {"level": {...}, "subspecialties": [...]}
```

### Content Endpoints

#### List Courses
```
GET /api/courses/?specialty_id=1&exam_level_id=3&subspecialty_id=1
Response: {"count": 3, "results": [...]}
```

#### Get Topics
```
GET /api/chapters/{chapter_slug}/topics/
Response: {"chapter": {...}, "topics": [...]}
```

#### Get Topic with Questions
```
GET /api/topics/{topic_id}/
Response: {"id": 1, "name_fa": "...", "questions": [...]}
```

### Exam Endpoints

#### List Exams
```
GET /api/exams/?specialty_id=1&exam_level_id=3
Response: [{"id": 1, "title": "...", "total_questions": 100}]
```

#### Start Exam
```
POST /api/exams/{exam_id}/start/
Response: {"attempt_id": 123, "exam": {...}, "current_question": {...}}
```

#### Submit Answer
```
POST /api/exam-attempts/{attempt_id}/submit-answer/
{
  "question_id": 1,
  "selected_option_id": 2,
  "time_spent_seconds": 45
}
Response: {"submitted": true, "next_question": {...}}
```

#### Complete Exam
```
POST /api/exam-attempts/{attempt_id}/complete/
Response: {"attempt": {"status": "completed", "score": 75, "percentage": 75}}
```

#### Get Results
```
GET /api/exam-attempts/{attempt_id}/results/
Response: {"attempt": {...}, "summary": {...}, "detailed_review": [...]}
```

---

## 🎨 Frontend Structure

### Page Hierarchy

```
home (/)
├── [specialty]/
│   ├── page.tsx (Exam Levels)
│   ├── [level]/
│   │   ├── page.tsx (Dashboard)
│   │   ├── subspecialties/
│   │   │   └── page.tsx (Subspecialty Grid)
│   │   ├── exams/
│   │   │   └── page.tsx (Exams List)
│   │   └── courses/
│   │       └── page.tsx (Courses List)
│   ├── exam/[examId]/
│   │   ├── take/page.tsx (Exam Interface)
│   │   └── results/[attemptId]/page.tsx (Results)
│   └── topics/[topicId]/
│       └── study/page.tsx (Study Mode)
├── dashboard/
│   └── page.tsx (User Dashboard)
├── auth/
│   ├── login/page.tsx
│   └── register/page.tsx
└── admin/
    └── page.tsx (Admin Panel)
```

### Key Components

- **ExamInterface** - Main exam taking component with timer
- **QuestionCard** - Individual question display
- **ProgressTracker** - Study progress visualization
- **ResultsPanel** - Exam results display
- **TopicStudy** - Topic content with practice questions

---

## 🛠️ Development Guide

### Adding a New Feature

1. **Database Schema** (if needed)
   ```sql
   ALTER TABLE your_table ADD COLUMN new_field ...;
   ```

2. **Django Model Update**
   ```python
   class YourModel(models.Model):
       new_field = models.CharField(...)
   ```

3. **Create Migration**
   ```bash
   python manage.py makemigrations
   python manage.py migrate
   ```

4. **API Serializer**
   ```python
   class YourSerializer(serializers.ModelSerializer):
       class Meta:
           model = YourModel
           fields = ['id', 'new_field', ...]
   ```

5. **ViewSet/View**
   ```python
   class YourViewSet(viewsets.ModelViewSet):
       queryset = YourModel.objects.all()
       serializer_class = YourSerializer
   ```

6. **Frontend Component** (React)
   ```typescript
   export const YourComponent = () => {
       const [data, setData] = useState([]);
       useEffect(() => {
           api.get('/your-endpoint/').then(res => setData(res.data));
       }, []);
       return <div>{/* JSX */}</div>;
   };
   ```

### Running Tests

```bash
# Backend tests
python manage.py test

# Frontend tests
npm test

# End-to-end tests
npm run test:e2e
```

### Code Style

**Backend**: PEP 8
```bash
pip install flake8 black
black apps/
flake8 apps/
```

**Frontend**: Prettier + ESLint
```bash
npm run lint
npm run format
```

---

## 📊 Project Statistics

- **Database Tables**: 17
- **API Endpoints**: 25+
- **Frontend Pages**: 15+
- **Supported Specialties**: 3
- **Exam Levels**: 9
- **Medical Subspecialties**: 22
- **Code Lines**: 10,000+
- **Bilingual Support**: Persian (RTL) + English

---

## 📞 Support & Contributing

### Documentation
- [VPS Setup Guide](VPS_SETUP_GUIDE.md)
- [API Testing Guide](api_testing_guide.md)
- [Implementation Summary](implementation_summary.md)
- [Detailed Specification](detailed_spec_v1.md)

### Contact
- **Email**: support@medicalpromax.ir
- **GitHub Issues**: [Report Issues](https://github.com/Hadiebrahimiseraji/medicalpromaxproject/issues)
- **GitHub Discussions**: [Community](https://github.com/Hadiebrahimiseraji/medicalpromaxproject/discussions)

### Contributing
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📝 License

This project is proprietary software developed for MedicalProMax. All rights reserved.

---

## 🎓 Educational Purpose

MedicalProMax is designed to support medical education and professional development for medical students, residents, and specialists preparing for examinations in Iran and Persian-speaking regions.

---

**Built with ❤️ for the medical community**

*Last Updated: February 2026*
*Version: 1.0.0*

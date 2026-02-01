# COMPLETE DEPLOYMENT & IMPLEMENTATION GUIDE

## 🔧 Backend Setup (Django)

### Step 1: Create Virtual Environment

```bash
cd backend/medicalpromax_backend

# Create virtual environment
python3.11 -m venv venv

# Activate it
source venv/bin/activate  # Linux/Mac
# or
venv\Scripts\activate  # Windows
```

### Step 2: Install Dependencies

```bash
pip install -r requirements.txt
```

### Step 3: Environment Configuration

Create `.env` file:

```env
# Database
DATABASE_NAME=medicalpromax_db
DATABASE_USER=medicalpromax_user
DATABASE_PASSWORD=YOUR_STRONG_PASSWORD_HERE
DATABASE_HOST=localhost
DATABASE_PORT=3306

# Django
SECRET_KEY=django-insecure-GENERATE_WITH_get_random_secret_key()
DEBUG=True
ALLOWED_HOSTS=localhost,127.0.0.1,medicalpromax.ir

# CORS
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://127.0.0.1:3000,https://medicalpromax.ir

# JWT
JWT_SECRET_KEY=your-jwt-secret-key

# Email
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-app-password
```

### Step 4: Database Setup

```bash
# Create database and user (run as root)
mysql -u root -p < scripts/init-database.sql

# Run Django migrations (creates additional tables)
python manage.py makemigrations
python manage.py migrate

# Create superuser
python manage.py createsuperuser
# Email: admin@medicalpromax.ir
# Password: secure_password

# Load seed data
python manage.py loaddata scripts/seed-data.json
```

### Step 5: Run Development Server

```bash
python manage.py runserver
# Server at http://localhost:8000
# Admin panel at http://localhost:8000/admin/
```

### Step 6: Test API Endpoints

Using curl or Postman:

```bash
# Get specialties
curl http://localhost:8000/api/specialties/

# Get exam levels
curl http://localhost:8000/api/specialties/medicine/exam-levels/

# Register user
curl -X POST http://localhost:8000/api/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{
    "email": "student@medicalpromax.ir",
    "password": "SecurePassword123!",
    "first_name": "علی",
    "last_name": "احمدی"
  }'

# Login
curl -X POST http://localhost:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{
    "email": "student@medicalpromax.ir",
    "password": "SecurePassword123!"
  }'
```

---

## 🚀 Frontend Setup (Next.js)

### Step 1: Install Dependencies

```bash
cd frontend/medicalpromax_frontend

npm install
# or
yarn install
```

### Step 2: Environment Configuration

Create `.env.local`:

```env
NEXT_PUBLIC_API_BASE_URL=http://localhost:8000/api
NEXT_PUBLIC_SITE_URL=http://localhost:3000
```

### Step 3: Run Development Server

```bash
npm run dev
# or
yarn dev

# Server at http://localhost:3000
```

### Step 4: Build for Production

```bash
npm run build
npm start

# or for static export
npm run export
```

---

## 🗄️ Database Data Seeding

Create `backend/medicalpromax_backend/scripts/seed-data.py`:

```python
"""
Seed sample data for MedicalProMax
Usage: python manage.py shell < scripts/seed-data.py
"""

from apps.core.models import (
    Specialty, ExamLevel, Subspecialty, Course, Chapter, Topic, Question, QuestionOption, QuestionExplanation
)
from apps.exams.models import ExamTypeClassification, Exam, ExamQuestion
import json

def seed_sample_courses():
    """Seed sample courses"""
    
    # Get medicine specialty
    medicine = Specialty.objects.get(slug='medicine')
    pre_residency = ExamLevel.objects.get(specialty=medicine, slug='pre_residency')
    
    # Create sample course
    course, created = Course.objects.get_or_create(
        slug='pathology-101',
        defaults={
            'specialty': medicine,
            'exam_level': pre_residency,
            'name_fa': 'آسیب‌شناسی 101',
            'name_en': 'Pathology 101',
            'author': 'دکتر احمدی',
            'difficulty_level': 'intermediate',
        }
    )
    
    if created:
        print(f"✅ Created course: {course.name_fa}")
    
    return course


def seed_sample_questions(course):
    """Seed sample questions"""
    
    # Create chapter
    chapter, _ = Chapter.objects.get_or_create(
        course=course,
        slug='inflammation',
        defaults={
            'name_fa': 'التهاب',
            'name_en': 'Inflammation',
            'chapter_number': 1,
        }
    )
    
    # Create topic
    topic, _ = Topic.objects.get_or_create(
        chapter=chapter,
        slug='acute-inflammation',
        defaults={
            'name_fa': 'التهاب حاد',
            'name_en': 'Acute Inflammation',
            'summary_content': '<h3>التهاب حاد و دلایل آن</h3><p>التهاب حاد یک پاسخ محلی است...</p>',
        }
    )
    
    # Create question
    question, created = Question.objects.get_or_create(
        specialty=course.specialty,
        exam_level=course.exam_level,
        topic=topic,
        question_text='کدام‌یک از موارد زیر از علایم التهاب حاد است؟',
        defaults={
            'question_type': 'multiple_choice',
            'difficulty': 'medium',
            'source': 'منابع درسی',
            'tags': ['inflammation', 'pathology', 'acute'],
        }
    )
    
    if created:
        print(f"✅ Created question: {question.id}")
        
        # Add options
        options_data = [
            {'number': 1, 'text': 'قرمزی و گرمی', 'correct': True},
            {'number': 2, 'text': 'رطوبت', 'correct': False},
            {'number': 3, 'text': 'سفیدی', 'correct': False},
            {'number': 4, 'text': 'کدورت', 'correct': False},
        ]
        
        for opt in options_data:
            QuestionOption.objects.create(
                question=question,
                option_number=opt['number'],
                option_text=opt['text'],
                is_correct=opt['correct'],
            )
        
        # Add explanation
        QuestionExplanation.objects.create(
            question=question,
            explanation_text='علایم کلاسیک التهاب حاد شامل قرمزی، گرمی، درد و ورم است...',
            clinical_notes='در کلینیک باید به تفریق التهاب حاد از مزمن توجه کرد',
            exam_tips='این سوال اغلب در آزمون ملی تکرار می‌شود',
        )
    
    return topic


def seed_sample_exam(course):
    """Seed sample exam"""
    
    exam_type = ExamTypeClassification.objects.get(slug='past_year')
    
    exam, created = Exam.objects.get_or_create(
        slug='past-year-1400',
        defaults={
            'specialty': course.specialty,
            'exam_level': course.exam_level,
            'exam_type_classification': exam_type,
            'title': 'آزمون سال 1400',
            'exam_year': 1400,
            'total_questions': 10,
            'duration_minutes': 120,
            'passing_score': 60,
            'is_published': True,
        }
    )
    
    if created:
        print(f"✅ Created exam: {exam.title}")
    
    return exam


if __name__ == '__main__':
    print("🌱 Starting data seeding...")
    
    course = seed_sample_courses()
    topic = seed_sample_questions(course)
    exam = seed_sample_exam(course)
    
    print("✅ Data seeding completed!")
```

---

## 🧪 Testing the Complete Application

### Backend API Testing

```python
# tests/test_api.py

from django.test import TestCase
from django.contrib.auth import get_user_model
from rest_framework.test import APIClient
from rest_framework import status

User = get_user_model()

class AuthenticationTestCase(TestCase):
    """Test authentication endpoints"""
    
    def setUp(self):
        self.client = APIClient()
        self.user_data = {
            'email': 'test@medicalpromax.ir',
            'password': 'TestPassword123!',
            'first_name': 'تست',
            'last_name': 'کاربر',
        }
    
    def test_user_registration(self):
        """Test user registration"""
        response = self.client.post('/api/auth/register/', self.user_data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertIn('tokens', response.data)
        self.assertIn('access', response.data['tokens'])
    
    def test_user_login(self):
        """Test user login"""
        # First register
        self.client.post('/api/auth/register/', self.user_data)
        
        # Then login
        login_data = {
            'email': self.user_data['email'],
            'password': self.user_data['password'],
        }
        response = self.client.post('/api/auth/login/', login_data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('access', response.data)


class ExamTestCase(TestCase):
    """Test exam endpoints"""
    
    def setUp(self):
        self.client = APIClient()
        # Create test user
        self.user = User.objects.create_user(
            email='student@medicalpromax.ir',
            password='SecurePass123!'
        )
    
    def test_get_specialties(self):
        """Test getting specialties"""
        response = self.client.get('/api/specialties/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(len(response.data) > 0)
    
    def test_start_exam(self):
        """Test starting an exam"""
        self.client.force_authenticate(user=self.user)
        
        # Assuming exam with id=1 exists
        response = self.client.post('/api/exams/1/start/')
        self.assertIn(response.status_code, [status.HTTP_201_CREATED, status.HTTP_400_BAD_REQUEST])


class ContentNavigationTestCase(TestCase):
    """Test content navigation endpoints"""
    
    def test_get_exam_levels(self):
        """Test getting exam levels"""
        response = self.client.get('/api/specialties/medicine/exam-levels/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(len(response.data) > 0)
    
    def test_get_courses(self):
        """Test getting courses"""
        response = self.client.get('/api/courses/?specialty_id=1&exam_level_id=1')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
```

### Frontend Component Testing

```typescript
// tests/ExamInterface.test.tsx

import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import ExamInterface from '@/components/exam/ExamInterface';

const mockExam = {
  id: 1,
  title: 'آزمون نمونه',
  duration_minutes: 120,
  total_questions: 10,
  is_timed: true,
};

const mockQuestion = {
  id: 1,
  order: 1,
  question_text: 'این یک سوال نمونه است؟',
  options: [
    { id: 1, option_number: 1, option_text: 'گزینه الف' },
    { id: 2, option_number: 2, option_text: 'گزینه ب' },
  ],
};

describe('ExamInterface Component', () => {
  it('renders exam title', () => {
    render(
      <ExamInterface
        attemptId={1}
        exam={mockExam}
        initialQuestion={mockQuestion}
      />
    );
    
    expect(screen.getByText(mockExam.title)).toBeInTheDocument();
  });

  it('renders question text', () => {
    render(
      <ExamInterface
        attemptId={1}
        exam={mockExam}
        initialQuestion={mockQuestion}
      />
    );
    
    expect(screen.getByText(mockQuestion.question_text)).toBeInTheDocument();
  });

  it('allows selecting an option', () => {
    render(
      <ExamInterface
        attemptId={1}
        exam={mockExam}
        initialQuestion={mockQuestion}
      />
    );
    
    const optionButton = screen.getByText('گزینه الف');
    fireEvent.click(optionButton);
    
    expect(optionButton.closest('button')).toHaveClass('bg-blue-50');
  });
});
```

---

## 📊 Performance Optimization

### Database Query Optimization

```python
# apps/exams/views.py - Add select_related and prefetch_related

class ExamListView(generics.ListAPIView):
    def get_queryset(self):
        return Exam.objects.filter(
            is_active=True, 
            is_published=True
        ).select_related(
            'specialty', 'exam_level', 'subspecialty', 'exam_type_classification'
        ).prefetch_related(
            'exam_questions__question__options'
        )
```

### Frontend Caching

```typescript
// src/lib/api.ts

import axios from 'axios';

const api = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_BASE_URL,
  timeout: 10000,
});

// Request interceptor for auth token
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('access_token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Response interceptor for token refresh
api.interceptors.response.use(
  (response) => response,
  async (error) => {
    if (error.response?.status === 401) {
      // Refresh token logic
    }
    return Promise.reject(error);
  }
);

export default api;
```

---

## 🚀 Production Deployment

### Step 1: VPS Setup

```bash
# SSH into VPS
ssh root@YOUR_VPS_IP

# Update system
apt update && apt upgrade -y

# Install dependencies
apt install -y python3.11 python3.11-venv python3-pip mysql-server nodejs npm nginx certbot python3-certbot-nginx

# Create application directory
mkdir -p /var/www/medicalpromax
cd /var/www/medicalpromax
```

### Step 2: Backend Deployment

```bash
# Clone repository
git clone https://github.com/Hadiebrahimiseraji/medicalpromaxproject.git
cd medicalpromaxproject/backend

# Create venv and install
python3.11 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Run migrations
python manage.py migrate --settings=config.settings.production

# Collect static files
python manage.py collectstatic --noinput --settings=config.settings.production

# Create superuser
python manage.py createsuperuser --settings=config.settings.production
```

### Step 3: Setup Gunicorn & Supervisor

```bash
# Create supervisor config
sudo nano /etc/supervisor/conf.d/medicalpromax-backend.conf
```

Add:

```ini
[program:medicalpromax-backend]
command=/var/www/medicalpromax/backend/venv/bin/gunicorn \
    --workers 4 \
    --bind 127.0.0.1:8000 \
    --timeout 120 \
    config.wsgi:application
directory=/var/www/medicalpromax/backend
user=www-data
autostart=true
autorestart=true
redirect_stderr=true
stdout_logfile=/var/log/medicalpromax/backend.log
```

### Step 4: Configure Nginx

```bash
sudo nano /etc/nginx/sites-available/medicalpromax
```

Nginx config:

```nginx
server {
    listen 80;
    server_name medicalpromax.ir www.medicalpromax.ir;
    
    # Redirect to HTTPS
    return 301 https://medicalpromax.ir$request_uri;
}

server {
    listen 443 ssl http2;
    server_name medicalpromax.ir www.medicalpromax.ir;
    
    ssl_certificate /etc/letsencrypt/live/medicalpromax.ir/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/medicalpromax.ir/privkey.pem;
    
    # Frontend
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
    
    # Backend API
    location /api/ {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Enable site and get SSL:

```bash
sudo ln -s /etc/nginx/sites-available/medicalpromax /etc/nginx/sites-enabled/
sudo certbot certonly -a nginx -d medicalpromax.ir -d www.medicalpromax.ir
sudo systemctl restart nginx
```

---

## ✅ Final Checklist

- [ ] Database migrations complete
- [ ] Superuser created
- [ ] API endpoints tested locally
- [ ] Frontend components render correctly
- [ ] RTL support verified
- [ ] Git repository initialized with branches
- [ ] Environment variables configured
- [ ] Dependencies installed (Python & Node)
- [ ] Development servers running (backend + frontend)
- [ ] Sample data seeded
- [ ] Tests passing
- [ ] Production configuration ready
- [ ] SSL certificate installed
- [ ] Nginx configured and running
- [ ] Supervisor managing processes
- [ ] Domain pointing to VPS
- [ ] Monitoring and logging setup
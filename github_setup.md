# GITHUB REPOSITORY SETUP & PROJECT STRUCTURE

## 🚀 Quick Start: Setting Up the MedicalProMax Repository

### Step 1: Clone Repository

```bash
git clone https://github.com/Hadiebrahimiseraji/medicalpromaxproject.git
cd medicalpromaxproject
```

### Step 2: Initialize Repository Structure

```bash
# Create branch strategy
git checkout -b develop
git push -u origin develop

# Create feature branches for initial setup
git checkout -b feature/backend-models
git checkout -b feature/frontend-components
git checkout -b feature/database-setup
```

---

## 📁 Complete Project Structure

```
medicalpromaxproject/
├── backend/
│   ├── medicalpromax_backend/
│   │   ├── config/
│   │   │   ├── settings/
│   │   │   │   ├── base.py                    # Base settings
│   │   │   │   ├── development.py             # Dev settings
│   │   │   │   ├── production.py              # Production settings
│   │   │   │   └── __init__.py
│   │   │   ├── urls.py                        # Main URL routing
│   │   │   ├── wsgi.py                        # WSGI config
│   │   │   └── __init__.py
│   │   ├── apps/
│   │   │   ├── core/                          # Specialties, Levels, Content
│   │   │   │   ├── migrations/
│   │   │   │   ├── models.py                  # ✅ CREATED
│   │   │   │   ├── serializers.py             # ✅ CREATED
│   │   │   │   ├── views.py                   # ✅ CREATED
│   │   │   │   ├── urls.py                    # To create
│   │   │   │   ├── admin.py
│   │   │   │   └── __init__.py
│   │   │   ├── exams/                         # Exams, Attempts, Results
│   │   │   │   ├── migrations/
│   │   │   │   ├── models.py                  # ✅ CREATED
│   │   │   │   ├── serializers.py             # To create
│   │   │   │   ├── views.py                   # ✅ CREATED
│   │   │   │   ├── urls.py                    # To create
│   │   │   │   ├── admin.py
│   │   │   │   └── __init__.py
│   │   │   ├── users/                         # Authentication, Profiles
│   │   │   │   ├── migrations/
│   │   │   │   ├── models.py                  # ✅ CREATED
│   │   │   │   ├── serializers.py             # To create
│   │   │   │   ├── views.py                   # ✅ CREATED
│   │   │   │   ├── urls.py                    # To create
│   │   │   │   ├── admin.py
│   │   │   │   └── __init__.py
│   │   │   └── analytics/                     # Reports, Statistics
│   │   │       ├── models.py
│   │   │       ├── views.py
│   │   │       └── __init__.py
│   │   ├── manage.py                          # Django management
│   │   ├── requirements.txt                   # Python dependencies
│   │   ├── .env.example                       # Environment template
│   │   └── __init__.py
│   ├── scripts/
│   │   ├── init-database.sql                  # ✅ CREATED
│   │   ├── setup-server.sh
│   │   ├── create-superuser.sh
│   │   └── seed-data.py
│   └── .dockerignore
├── frontend/
│   ├── medicalpromax_frontend/
│   │   ├── src/
│   │   │   ├── app/
│   │   │   │   ├── layout.tsx                 # Root layout (RTL)
│   │   │   │   ├── page.tsx                   # Home page
│   │   │   │   ├── [specialty]/
│   │   │   │   │   ├── page.tsx               # Exam levels selection
│   │   │   │   │   └── [level]/
│   │   │   │   │       ├── page.tsx           # Subspecialty/Dashboard
│   │   │   │   │       └── [subspecialty]/
│   │   │   │   │           ├── page.tsx       # Main dashboard
│   │   │   │   │           ├── exams/
│   │   │   │   │           │   └── page.tsx
│   │   │   │   │           └── courses/
│   │   │   │   │               └── page.tsx
│   │   │   │   ├── exam/
│   │   │   │   │   └── [examId]/
│   │   │   │   │       ├── take/
│   │   │   │   │       │   └── page.tsx       # Exam interface
│   │   │   │   │       └── results/
│   │   │   │   │           └── [attemptId]/
│   │   │   │   │               └── page.tsx
│   │   │   │   ├── topics/
│   │   │   │   │   └── [topicId]/
│   │   │   │   │       └── study/
│   │   │   │   │           └── page.tsx
│   │   │   │   ├── dashboard/
│   │   │   │   │   └── page.tsx               # User dashboard
│   │   │   │   ├── auth/
│   │   │   │   │   ├── login/
│   │   │   │   │   │   └── page.tsx
│   │   │   │   │   └── register/
│   │   │   │   │       └── page.tsx
│   │   │   │   └── admin/
│   │   │   │       └── page.tsx
│   │   │   ├── components/
│   │   │   │   ├── exam/
│   │   │   │   │   ├── ExamInterface.tsx      # ✅ CREATED
│   │   │   │   │   ├── QuestionCard.tsx       # ✅ CREATED
│   │   │   │   │   ├── ExamTimer.tsx          # ✅ CREATED
│   │   │   │   │   ├── ProgressBar.tsx        # ✅ CREATED
│   │   │   │   │   ├── ResultsPanel.tsx
│   │   │   │   │   └── ExamList.tsx
│   │   │   │   ├── specialty/
│   │   │   │   │   ├── SpecialtyCard.tsx
│   │   │   │   │   ├── LevelCard.tsx
│   │   │   │   │   └── SubspecialtyCard.tsx
│   │   │   │   ├── study/
│   │   │   │   │   ├── TopicSummary.tsx
│   │   │   │   │   ├── TopicQuestions.tsx
│   │   │   │   │   └── StudyProgress.tsx
│   │   │   │   ├── layout/
│   │   │   │   │   ├── Header.tsx
│   │   │   │   │   ├── Footer.tsx
│   │   │   │   │   └── Sidebar.tsx
│   │   │   │   └── ui/
│   │   │   │       ├── Button.tsx
│   │   │   │       ├── Card.tsx
│   │   │   │       ├── Input.tsx
│   │   │   │       └── Modal.tsx
│   │   │   ├── lib/
│   │   │   │   ├── api.ts                     # Axios instance
│   │   │   │   ├── auth.ts                    # Auth utilities
│   │   │   │   └── utils.ts
│   │   │   ├── store/
│   │   │   │   ├── index.ts                   # Redux store
│   │   │   │   └── slices/
│   │   │   │       ├── authSlice.ts
│   │   │   │       ├── examSlice.ts
│   │   │   │       └── progressSlice.ts
│   │   │   ├── styles/
│   │   │   │   └── globals.css
│   │   │   └── middleware.ts
│   │   ├── public/
│   │   │   └── images/
│   │   ├── .env.local                         # Local env
│   │   ├── next.config.js                     # Next.js config
│   │   ├── tailwind.config.js                 # Tailwind config
│   │   ├── tsconfig.json
│   │   ├── package.json
│   │   └── .gitignore
│   └── Dockerfile
├── nginx/
│   ├── medicalpromax.conf                     # Nginx config
│   └── ssl/                                   # SSL certificates
├── docker/
│   ├── Dockerfile.backend
│   ├── Dockerfile.frontend
│   └── docker-compose.yml
├── docs/
│   ├── API_DOCUMENTATION.md                   # API endpoints
│   ├── DATABASE_SCHEMA.md                     # DB structure
│   ├── DEPLOYMENT_GUIDE.md                    # Deployment steps
│   └── ARCHITECTURE.md                        # System architecture
├── scripts/
│   ├── deploy.sh                              # Deployment script
│   ├── backup-database.sh                     # Database backup
│   └── health-check.sh
├── .github/
│   └── workflows/
│       ├── ci-backend.yml                     # Backend CI/CD
│       ├── ci-frontend.yml                    # Frontend CI/CD
│       └── deploy-production.yml              # Production deployment
├── .gitignore
├── README.md
├── CONTRIBUTING.md
└── LICENSE

```

---

## 📝 Backend Requirements (Python)

**File:** `backend/medicalpromax_backend/requirements.txt`

```
# Core Django
Django==4.2.0
djangorestframework==3.14.0
django-cors-headers==4.0.0
python-decouple==3.8

# Database
mysqlclient==2.2.0
django-mysql==4.10.0

# Authentication & Security
djangorestframework-simplejwt==5.2.2
cryptography==41.0.0

# Caching & Performance
redis==5.0.0
django-redis==5.2.0

# Production Server
gunicorn==21.2.0
whitenoise==6.5.0

# Utilities
Pillow==10.0.0
python-dateutil==2.8.2
pytz==2023.3

# API Documentation
drf-spectacular==0.26.2
```

---

## 📝 Frontend Dependencies (Node.js)

**File:** `frontend/medicalpromax_frontend/package.json`

```json
{
  "name": "medicalpromax-frontend",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "export": "next export"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "next": "^14.0.0",
    "axios": "^1.5.0",
    "redux": "^4.2.1",
    "@reduxjs/toolkit": "^1.9.5",
    "react-redux": "^8.1.2",
    "react-hook-form": "^7.45.0",
    "yup": "^1.2.0",
    "next-intl": "^2.17.0",
    "tailwindcss": "^3.3.0",
    "postcss": "^8.4.28"
  },
  "devDependencies": {
    "typescript": "^5.1.0",
    "@types/react": "^18.2.0",
    "@types/node": "^20.3.0"
  }
}
```

---

## 🔧 Git Workflow & Initial Commits

### Phase 1: Backend Setup

```bash
# Switch to feature branch
git checkout -b feature/backend-setup

# Add Django project files
git add backend/
git commit -m "feat: Initialize Django backend with models and serializers

- Add core models (Specialty, ExamLevel, Subspecialty, Course, Chapter, Topic)
- Add exam models (Exam, ExamQuestion, UserExamAttempt, UserAnswer)
- Add user models (User with custom manager)
- Add DRF serializers for all models
- Add API views for navigation, content, and exams"

# Push to remote
git push -u origin feature/backend-setup
```

### Phase 2: Database

```bash
git checkout -b feature/database-setup

git add backend/scripts/init-database.sql
git commit -m "feat: Add complete MySQL database schema

- Create 17 tables with proper relationships
- Add seed data for specialties, levels, and types
- Include indexes for performance
- Support RTL Persian and LTR English"

git push -u origin feature/database-setup
```

### Phase 3: Frontend Components

```bash
git checkout -b feature/frontend-components

git add frontend/src/components/
git commit -m "feat: Add React components for exam interface

- Add ExamInterface main component
- Add QuestionCard for question display
- Add ExamTimer for countdown
- Add ProgressBar for progress tracking
- Add RTL support for Farsi UI"

git push -u origin feature/frontend-components
```

### Phase 4: Merge to Develop

```bash
git checkout develop

# Merge all features
git merge feature/backend-setup
git merge feature/database-setup
git merge feature/frontend-components

# Resolve conflicts if any
git push origin develop
```

---

## 🚀 Next Steps: Creating Pull Requests

### PR Template

Create `.github/pull_request_template.md`:

```markdown
## Description
Brief description of changes

## Type of change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change

## Testing
- [ ] Unit tests added
- [ ] Integration tests added
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Documentation updated
- [ ] No new warnings generated
```

---

## 📦 Docker Setup

**backend/Dockerfile**

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "4", "config.wsgi:application"]
```

**frontend/Dockerfile**

```dockerfile
FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

EXPOSE 3000

CMD ["npm", "start"]
```

---

## ✅ Verification Checklist

- [ ] Repository cloned successfully
- [ ] All dependencies installed
- [ ] Database initialized
- [ ] Django migrations created: `python manage.py makemigrations && migrate`
- [ ] API endpoints tested with Postman/Thunder Client
- [ ] Frontend components render without errors
- [ ] RTL support verified in browser
- [ ] git branches created and pushed
- [ ] Initial commits completed
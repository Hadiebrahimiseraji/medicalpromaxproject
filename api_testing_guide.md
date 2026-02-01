# 🧪 API TESTING GUIDE - Postman/cURL Examples

## 📌 Base URL
```
Development: http://localhost:8000/api
Production: https://medicalpromax.ir/api
```

---

## 🔐 AUTHENTICATION ENDPOINTS

### 1. Register New User
```bash
curl -X POST http://localhost:8000/api/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{
    "email": "student@medicalpromax.ir",
    "password": "SecurePassword123!",
    "first_name": "علی",
    "last_name": "احمدی"
  }'
```

**Response:**
```json
{
  "user": {
    "id": 1,
    "email": "student@medicalpromax.ir",
    "first_name": "علی",
    "last_name": "احمدی"
  },
  "tokens": {
    "access": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
    "refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
  }
}
```

### 2. Login User
```bash
curl -X POST http://localhost:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{
    "email": "student@medicalpromax.ir",
    "password": "SecurePassword123!"
  }'
```

### 3. Get Current User Profile
```bash
curl -X GET http://localhost:8000/api/auth/me/ \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

### 4. Update User Preferences
```bash
curl -X PATCH http://localhost:8000/api/auth/me/preferences/ \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "primary_specialty_id": 1,
    "primary_exam_level_id": 2,
    "primary_subspecialty_id": 5
  }'
```

### 5. Logout User
```bash
curl -X POST http://localhost:8000/api/auth/logout/ \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "refresh": "<REFRESH_TOKEN>"
  }'
```

---

## 🏥 NAVIGATION ENDPOINTS (PUBLIC)

### 1. Get All Specialties
```bash
curl http://localhost:8000/api/specialties/
```

**Response:**
```json
[
  {
    "id": 1,
    "slug": "medicine",
    "name_fa": "پزشکی",
    "name_en": "Medicine",
    "icon": "🩺",
    "display_order": 1
  },
  {
    "id": 2,
    "slug": "dentistry",
    "name_fa": "دندانپزشکی",
    "name_en": "Dentistry",
    "icon": "🦷",
    "display_order": 2
  }
]
```

### 2. Get Exam Levels for Specialty
```bash
curl "http://localhost:8000/api/specialties/medicine/exam-levels/"
```

**Response:**
```json
[
  {
    "id": 1,
    "slug": "pre_residency",
    "name_fa": "آزمون پره",
    "name_en": "Pre-Residency",
    "specialty": {...},
    "requires_subspecialty": false,
    "display_order": 1
  },
  ...
]
```

### 3. Get Subspecialties for Level
```bash
curl "http://localhost:8000/api/exam-levels/board_promotion/subspecialties/?specialty=medicine"
```

**Response:**
```json
[
  {
    "id": 1,
    "slug": "infectious",
    "name_fa": "عفونی",
    "name_en": "Infectious Diseases",
    "display_order": 1
  },
  ...
]
```

---

## 📚 CONTENT ENDPOINTS

### 1. Get Courses
```bash
# All courses
curl "http://localhost:8000/api/courses/"

# Filtered by specialty, level, subspecialty
curl "http://localhost:8000/api/courses/?specialty_id=1&exam_level_id=2"

# With subspecialty
curl "http://localhost:8000/api/courses/?specialty_id=1&exam_level_id=3&subspecialty_id=5"
```

### 2. Get Course Details
```bash
curl "http://localhost:8000/api/courses/pathology-101/"
```

**Response:**
```json
{
  "id": 1,
  "slug": "pathology-101",
  "name_fa": "آسیب‌شناسی 101",
  "name_en": "Pathology 101",
  "description": "...",
  "specialty": {...},
  "exam_level": {...},
  "author": "دکتر احمدی",
  "difficulty_level": "intermediate",
  "display_order": 1
}
```

### 3. Get Chapters
```bash
curl "http://localhost:8000/api/courses/pathology-101/chapters/"
```

### 4. Get Topics
```bash
curl "http://localhost:8000/api/chapters/inflammation/topics/"
```

### 5. Get Topic with Progress (Authenticated)
```bash
curl "http://localhost:8000/api/topics/1/" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

**Response:**
```json
{
  "id": 1,
  "slug": "acute-inflammation",
  "name_fa": "التهاب حاد",
  "name_en": "Acute Inflammation",
  "summary_content": "<h3>التهاب حاد و دلایل آن</h3>...",
  "estimated_study_time": 45,
  "standard_questions_count": 15,
  "user_progress": {
    "status": "in_progress",
    "completion_percentage": 60,
    "study_time_minutes": 27,
    "last_studied_at": "2024-02-01T10:30:00Z"
  }
}
```

### 6. Get Topic Questions
```bash
curl "http://localhost:8000/api/topics/1/questions/"
```

**Response:**
```json
[
  {
    "id": 1,
    "question_text": "کدام‌یک از موارد زیر از علایم التهاب حاد است؟",
    "question_html": null,
    "image_url": null,
    "question_type": "multiple_choice",
    "difficulty": "medium",
    "tags": ["inflammation", "pathology"],
    "options": [
      {
        "id": 1,
        "option_number": 1,
        "option_text": "قرمزی و گرمی",
        "option_html": null
      },
      ...
    ],
    "explanation": {
      "id": 1,
      "explanation_text": "علایم کلاسیک التهاب حاد شامل...",
      "clinical_notes": "در کلینیک باید...",
      "exam_tips": "این سوال اغلب..."
    }
  }
]
```

---

## 🎓 EXAM ENDPOINTS

### 1. Get Exams (Grouped by Type)
```bash
# All exams for a path
curl "http://localhost:8000/api/exams/?specialty_id=1&exam_level_id=1"

# With subspecialty
curl "http://localhost:8000/api/exams/?specialty_id=1&exam_level_id=3&subspecialty_id=5"
```

**Response:**
```json
{
  "exam_types": [
    {
      "type": "آزمون سال‌های قبل",
      "exams": [
        {
          "id": 1,
          "title": "آزمون سال 1400",
          "slug": "past-year-1400",
          "exam_year": 1400,
          "total_questions": 60,
          "duration_minutes": 120,
          "passing_score": 60
        }
      ]
    },
    {
      "type": "سوالات تألیفی",
      "exams": [...]
    }
  ]
}
```

### 2. Get Exam Details
```bash
curl "http://localhost:8000/api/exams/1/"
```

### 3. Start Exam (Authenticated)
```bash
curl -X POST "http://localhost:8000/api/exams/1/start/" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{}'
```

**Response:**
```json
{
  "attempt_id": 123,
  "exam": {
    "id": 1,
    "title": "آزمون سال 1400",
    "duration_minutes": 120,
    "total_questions": 60
  },
  "current_question": {
    "id": 1,
    "order": 1,
    "question_text": "...",
    "options": [...]
  }
}
```

### 4. Submit Answer (Authenticated)
```bash
curl -X POST "http://localhost:8000/api/exam-attempts/123/submit-answer/" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "question_id": 1,
    "selected_option_id": 2,
    "time_spent_seconds": 45
  }'
```

**Response:**
```json
{
  "submitted": true,
  "is_correct": true,
  "progress": {
    "answered": 5,
    "correct": 4,
    "wrong": 1,
    "unanswered": 55
  },
  "next_question": {
    "id": 2,
    "order": 2,
    "question_text": "...",
    "options": [...]
  }
}
```

### 5. Complete Exam (Authenticated)
```bash
curl -X POST "http://localhost:8000/api/exam-attempts/123/complete/" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{}'
```

**Response:**
```json
{
  "attempt": {
    "id": 123,
    "exam_id": 1,
    "status": "completed",
    "started_at": "2024-02-01T10:00:00Z",
    "completed_at": "2024-02-01T12:15:00Z",
    "total_questions": 60,
    "correct_answers": 48,
    "wrong_answers": 10,
    "unanswered": 2,
    "score": 80.0,
    "percentage": 80.0,
    "time_spent_seconds": 7500
  },
  "summary": {
    "total_questions": 60,
    "correct_answers": 48,
    "score": 80.0,
    "passing_score": 60.0,
    "passed": true
  }
}
```

### 6. Get Exam Results (Authenticated)
```bash
curl "http://localhost:8000/api/exam-attempts/123/results/" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

---

## 🎯 STUDY MODE ENDPOINTS

### 1. Update Topic Progress (Authenticated)
```bash
curl -X POST "http://localhost:8000/api/users/me/study-progress/" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "topic_id": 1,
    "status": "in_progress",
    "completion_percentage": 50,
    "study_time_minutes": 30
  }'
```

### 2. Answer Topic Question (Authenticated)
```bash
curl -X POST "http://localhost:8000/api/users/me/topic-questions/1/answer/" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "topic_id": 1,
    "selected_option_id": 2
  }'
```

**Response:**
```json
{
  "answered": true,
  "is_correct": true,
  "explanation": {
    "explanation_text": "علایم کلاسیک التهاب حاد...",
    "clinical_notes": "در کلینیک...",
    "exam_tips": "این سوال..."
  }
}
```

### 3. Get User Progress (Authenticated)
```bash
curl "http://localhost:8000/api/users/me/progress/" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

**Response:**
```json
{
  "exam_stats": {
    "total_attempts": 5,
    "completed_attempts": 4,
    "average_score": 75.5,
    "highest_score": 85.0
  },
  "study_stats": {
    "total_study_time": 450,
    "completed_topics": 12,
    "in_progress_topics": 3,
    "not_started_topics": 8
  },
  "weak_topics": [
    {
      "id": 5,
      "name_fa": "عفونی حاد",
      "success_rate": 35.0
    }
  ]
}
```

---

## 🔑 Using Authentication Token

### Store Token from Login Response
```bash
# Extract access token
TOKEN=$(curl -s -X POST http://localhost:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{
    "email": "student@medicalpromax.ir",
    "password": "SecurePassword123!"
  }' | jq -r '.tokens.access')

echo $TOKEN
```

### Use Token in Requests
```bash
# All authenticated requests need Authorization header
curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:8000/api/auth/me/
```

---

## 🛠️ Postman Collection Template

```json
{
  "info": {
    "name": "MedicalProMax API",
    "description": "API endpoints for MedicalProMax platform"
  },
  "auth": {
    "type": "bearer",
    "bearer": [
      {
        "key": "token",
        "value": "{{access_token}}",
        "type": "string"
      }
    ]
  },
  "item": [
    {
      "name": "Auth",
      "item": [
        {
          "name": "Register",
          "request": {
            "method": "POST",
            "url": "{{base_url}}/auth/register/",
            "body": {
              "mode": "raw",
              "raw": "{ \"email\": \"\", \"password\": \"\", \"first_name\": \"\", \"last_name\": \"\" }"
            }
          }
        },
        {
          "name": "Login",
          "request": {
            "method": "POST",
            "url": "{{base_url}}/auth/login/",
            "body": {
              "mode": "raw",
              "raw": "{ \"email\": \"\", \"password\": \"\" }"
            }
          }
        }
      ]
    },
    {
      "name": "Navigation",
      "item": [
        {
          "name": "Get Specialties",
          "request": {
            "method": "GET",
            "url": "{{base_url}}/specialties/"
          }
        }
      ]
    }
  ],
  "variable": [
    {
      "key": "base_url",
      "value": "http://localhost:8000/api"
    }
  ]
}
```

---

## ✅ Testing Workflow

1. **Register & Login**
   - POST /api/auth/register/
   - POST /api/auth/login/
   - Save access_token

2. **Explore Content**
   - GET /api/specialties/
   - GET /api/specialties/{specialty}/exam-levels/
   - GET /api/courses/
   - GET /api/topics/{id}/questions/

3. **Take Exam**
   - POST /api/exams/{id}/start/
   - POST /api/exam-attempts/{attempt_id}/submit-answer/ (multiple times)
   - POST /api/exam-attempts/{attempt_id}/complete/
   - GET /api/exam-attempts/{attempt_id}/results/

4. **Study Mode**
   - GET /api/topics/{id}/
   - POST /api/users/me/topic-questions/{id}/answer/
   - GET /api/users/me/progress/

---

## 🐛 Error Handling

### Common Responses

**401 Unauthorized**
```json
{
  "detail": "Authentication credentials were not provided."
}
```

**404 Not Found**
```json
{
  "detail": "Not found."
}
```

**400 Bad Request**
```json
{
  "email": ["Email is required"],
  "password": ["Ensure this field has at least 8 characters"]
}
```

**500 Server Error**
```json
{
  "error": "Internal server error"
}
```

---

## 📝 Environment Variables

Save these in `.env.postman`:
```
base_url=http://localhost:8000/api
access_token=
refresh_token=
specialty_id=1
exam_level_id=1
exam_id=1
attempt_id=123
```

Set in Postman:
- Click Environments → Create New
- Add variables
- Select environment before running requests

---

**Last Updated:** February 1, 2026
**API Version:** v1
**Status:** Production Ready
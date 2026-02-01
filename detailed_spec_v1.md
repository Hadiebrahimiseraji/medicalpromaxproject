# مشخصات فنی تفصیلی پلتفرم آموزشی پزشکی
## Comprehensive Technical Specification v1.0

**تاریخ:** بهمن ۱۴۰۴  
**وضعیت:** معماری مفصل برای توسعه  
**فناوری:** Django + Next.js + MySQL + Redis  

---

# فهرست مطالب

1. [معماری دیتابیس (جداول + SQL)](#معماری-دیتابیس)
2. [API Specification (Endpoints + Request/Response)](#api-specification)
3. [Frontend Architecture (Components + Pages)](#frontend-architecture)
4. [Business Logic (Rules + Workflows)](#business-logic)
5. [Security & Authentication](#security--authentication)
6. [Performance & Scalability](#performance--scalability)
7. [Error Handling](#error-handling)
8. [Testing Strategy](#testing-strategy)

---

---

# معماری دیتابیس

## ۱.۱ جدول `specialties`

**هدف:** ذخیره تخصص‌های اصلی (پزشکی، دندانپزشکی، ...)

```sql
CREATE TABLE specialties (
    id INT PRIMARY KEY AUTO_INCREMENT,
    slug VARCHAR(50) UNIQUE NOT NULL COMMENT 'medicine, dentistry',
    name_fa VARCHAR(100) NOT NULL COMMENT 'پزشکی, دندانپزشکی',
    name_en VARCHAR(100) NOT NULL,
    icon VARCHAR(50) DEFAULT '🩺' COMMENT 'Emoji or icon name',
    description TEXT,
    display_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    KEY idx_slug (slug),
    KEY idx_active (is_active),
    KEY idx_order (display_order)
);

-- Seed Data
INSERT INTO specialties (slug, name_fa, name_en, icon, display_order) VALUES
('medicine', 'پزشکی', 'Medicine', '🩺', 1),
('dentistry', 'دندانپزشکی', 'Dentistry', '🦷', 2),
('pharmacy', 'داروسازی', 'Pharmacy', '💊', 3);
```

**مثال استخدام:**
- کاربر صفحه اصلی را باز می‌کند
- سیستم `SELECT * FROM specialties WHERE is_active=TRUE ORDER BY display_order` اجرا می‌کند
- 3 کارت نمایش داده می‌شود

---

## ۱.۲ جدول `exam_levels`

**هدف:** انواع آزمون‌ها (پره، دستیاری، بورد، ملی، ...)

```sql
CREATE TABLE exam_levels (
    id INT PRIMARY KEY AUTO_INCREMENT,
    specialty_id INT NOT NULL,
    slug VARCHAR(50) NOT NULL COMMENT 'pre_residency, residency, board_promotion, national',
    name_fa VARCHAR(100) NOT NULL COMMENT 'آزمون پره, آزمون دستیاری, ...',
    name_en VARCHAR(100),
    description TEXT,
    icon VARCHAR(50),
    
    -- آیا این سطح زیرمجموعه‌های تخصصی دارد؟
    requires_subspecialty BOOLEAN DEFAULT FALSE COMMENT 'TRUE فقط برای board_promotion',
    
    display_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (specialty_id) REFERENCES specialties(id) ON DELETE CASCADE,
    UNIQUE KEY unique_level (specialty_id, slug),
    KEY idx_specialty (specialty_id),
    KEY idx_slug (slug)
);

-- Seed Data برای پزشکی (specialty_id = 1)
INSERT INTO exam_levels (specialty_id, slug, name_fa, name_en, icon, requires_subspecialty, display_order) VALUES
(1, 'pre_residency', 'آزمون پره', 'Pre-Residency Exam', '📚', FALSE, 1),
(1, 'residency', 'آزمون دستیاری', 'Residency Exam', '🎓', FALSE, 2),
(1, 'board_promotion', 'بورد/ارتقا', 'Board/Promotion', '📊', TRUE, 3),
(1, 'national', 'آزمون ملی', 'National Exam', '🏆', FALSE, 4),
(1, 'qualification', 'آزمون صلاحیت', 'Qualification', '✅', FALSE, 5),
(1, 'bachelor_to_md', 'لیسانس به پزشکی', 'Bachelor to MD', '🎯', FALSE, 6);

-- Seed Data برای دندانپزشکی (specialty_id = 2)
INSERT INTO exam_levels (specialty_id, slug, name_fa, name_en, requires_subspecialty, display_order) VALUES
(2, 'residency', 'دستیاری دندانپزشکی', 'Dental Residency', FALSE, 1),
(2, 'board_promotion', 'بورد/ارتقا دندانپزشکی', 'Dental Board', TRUE, 2),
(2, 'national', 'آزمون ملی دندانپزشکی', 'National Dental', FALSE, 3);
```

**مثال استخدام:**
- کاربر پزشکی را انتخاب می‌کند
- API: `GET /api/specialties/medicine/levels`
- Query: `SELECT * FROM exam_levels WHERE specialty_id=1 AND is_active=TRUE ORDER BY display_order`
- Response: Array از 6 سطح

---

## ۱.۳ جدول `subspecialties`

**هدف:** تخصص‌های فرعی (فقط برای board_promotion)

```sql
CREATE TABLE subspecialties (
    id INT PRIMARY KEY AUTO_INCREMENT,
    specialty_id INT NOT NULL,
    exam_level_id INT NOT NULL,
    slug VARCHAR(50) NOT NULL COMMENT 'infectious, cardiology, ...',
    name_fa VARCHAR(100) NOT NULL,
    name_en VARCHAR(100),
    description TEXT,
    display_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (specialty_id) REFERENCES specialties(id) ON DELETE CASCADE,
    FOREIGN KEY (exam_level_id) REFERENCES exam_levels(id) ON DELETE CASCADE,
    UNIQUE KEY unique_subspecialty (specialty_id, exam_level_id, slug),
    KEY idx_specialty_level (specialty_id, exam_level_id),
    KEY idx_order (display_order)
);

-- Seed: تخصص‌های پزشکی برای بورد/ارتقا (exam_level_id = 3)
INSERT INTO subspecialties (specialty_id, exam_level_id, slug, name_fa, name_en, display_order) VALUES
-- متخصصین داخلی
(1, 3, 'infectious', 'عفونی', 'Infectious Diseases', 1),
(1, 3, 'cardiology', 'قلب و عروق', 'Cardiology', 2),
(1, 3, 'gastroenterology', 'گوارش', 'Gastroenterology', 3),
(1, 3, 'pulmonology', 'ریه', 'Pulmonology', 4),
(1, 3, 'nephrology', 'کلیه', 'Nephrology', 5),
(1, 3, 'endocrinology', 'غدد', 'Endocrinology', 6),
(1, 3, 'hematology', 'خون و سرطان', 'Hematology/Oncology', 7),
(1, 3, 'rheumatology', 'روماتولوژی', 'Rheumatology', 8),
-- عصب و روان
(1, 3, 'neurology', 'مغز و اعصاب', 'Neurology', 9),
(1, 3, 'psychiatry', 'روانپزشکی', 'Psychiatry', 10),
-- جراحی و زنان
(1, 3, 'surgery', 'جراحی عمومی', 'General Surgery', 11),
(1, 3, 'orthopedics', 'ارتوپدی', 'Orthopedics', 12),
(1, 3, 'obstetrics', 'زنان و زایمان', 'OB/GYN', 13),
-- دیگر
(1, 3, 'pediatrics', 'اطفال', 'Pediatrics', 14),
(1, 3, 'dermatology', 'پوست', 'Dermatology', 15);

-- Seed: تخصص‌های دندانپزشکی برای بورد/ارتقا (exam_level_id = 8)
INSERT INTO subspecialties (specialty_id, exam_level_id, slug, name_fa, name_en, display_order) VALUES
(2, 8, 'orthodontics', 'ارتودنسی', 'Orthodontics', 1),
(2, 8, 'periodontics', 'پریودنتیکس', 'Periodontics', 2),
(2, 8, 'endodontics', 'اندودنتیکس', 'Endodontics', 3),
(2, 8, 'prosthodontics', 'پروتزهای دندانی', 'Prosthodontics', 4),
(2, 8, 'oral_surgery', 'جراحی دهان و فک', 'Oral Surgery', 5),
(2, 8, 'pediatric_dentistry', 'دندانپزشکی کودکان', 'Pediatric Dentistry', 6),
(2, 8, 'oral_pathology', 'پاتولوژی دهان', 'Oral Pathology', 7);
```

---

## ۱.۴ جدول `courses`

**هدف:** منابع و کتاب‌های آموزشی

```sql
CREATE TABLE courses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    specialty_id INT NOT NULL,
    exam_level_id INT NOT NULL,
    subspecialty_id INT,  -- NULL برای مسیرهایی که subspecialty ندارند
    
    slug VARCHAR(100) NOT NULL COMMENT 'harrison-infectious-diseases',
    name_fa VARCHAR(200) NOT NULL COMMENT 'بیماری‌های عفونی - هاریسون',
    name_en VARCHAR(200),
    description TEXT,
    
    -- منبع اصلی (برای ارجاع)
    main_reference VARCHAR(300),
    author VARCHAR(200),
    year_published INT,
    
    -- سطح سخت‌گیری
    difficulty_level ENUM('beginner', 'intermediate', 'advanced') DEFAULT 'intermediate',
    
    display_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (specialty_id) REFERENCES specialties(id),
    FOREIGN KEY (exam_level_id) REFERENCES exam_levels(id),
    FOREIGN KEY (subspecialty_id) REFERENCES subspecialties(id) ON DELETE CASCADE,
    
    UNIQUE KEY unique_course (specialty_id, exam_level_id, subspecialty_id, slug),
    KEY idx_path (specialty_id, exam_level_id, subspecialty_id),
    KEY idx_active (is_active)
);

-- مثال: 3 درس برای عفونی
INSERT INTO courses (specialty_id, exam_level_id, subspecialty_id, slug, name_fa, main_reference, author, difficulty_level, display_order) VALUES
(1, 3, 1, 'harrison-infectious', 'بیماری‌های عفونی - هاریسون', 'Harrison\'s Principles of Internal Medicine', 'Kasper et al.', 'advanced', 1),
(1, 3, 1, 'mandell-antimicrobial', 'آنتی‌بیوتیک‌ها - مندل', 'Mandell, Douglas & Bennett\'s Principles', 'Mandell et al.', 'advanced', 2),
(1, 3, 1, 'uptodate-infectious', 'UpToDate - بیماری‌های عفونی', 'UpToDate', 'UpToDate Editorial', 'intermediate', 3);
```

---

## ۱.۵ جدول `chapters`

**هدف:** فصل‌های درس

```sql
CREATE TABLE chapters (
    id INT PRIMARY KEY AUTO_INCREMENT,
    course_id INT NOT NULL,
    
    slug VARCHAR(100) NOT NULL COMMENT 'bacterial-infections',
    name_fa VARCHAR(300) NOT NULL COMMENT 'عفونت‌های باکتریال',
    name_en VARCHAR(300),
    description TEXT,
    
    chapter_number INT,  -- شماره فصل اصلی (برای ترتیب)
    estimated_study_time INT COMMENT 'دقیقه',
    
    display_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
    UNIQUE KEY unique_chapter (course_id, slug),
    KEY idx_course (course_id),
    KEY idx_order (display_order)
);

-- مثال: فصل‌های درس بیماری‌های عفونی
INSERT INTO chapters (course_id, slug, name_fa, chapter_number, estimated_study_time, display_order) VALUES
(1, 'bacterial-infections', 'عفونت‌های باکتریال', 1, 180, 1),
(1, 'viral-infections', 'عفونت‌های ویروسی', 2, 150, 2),
(1, 'fungal-infections', 'عفونت‌های قارچی', 3, 120, 3),
(1, 'parasitic-infections', 'عفونت‌های انگلی', 4, 90, 4),
(1, 'antibiotic-resistance', 'مقاومت آنتی‌بیوتیکی', 5, 100, 5);
```

---

## ۱.۶ جدول `topics`

**هدف:** موضوعات درون فصل‌ها + جزوه‌های خلاصه

```sql
CREATE TABLE topics (
    id INT PRIMARY KEY AUTO_INCREMENT,
    chapter_id INT NOT NULL,
    
    slug VARCHAR(100) NOT NULL COMMENT 'staph-aureus',
    name_fa VARCHAR(300) NOT NULL COMMENT 'استافیلوکوکوس اورئوس',
    name_en VARCHAR(300),
    
    -- جزوه خلاصه (HTML یا Markdown)
    summary_content LONGTEXT COMMENT 'HTML با تگ‌های RTL',
    
    -- تخمین زمان
    estimated_study_time INT COMMENT 'دقیقه',
    
    -- تعداد سوالات استاندارد
    standard_questions_count INT DEFAULT 15,
    
    display_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (chapter_id) REFERENCES chapters(id) ON DELETE CASCADE,
    UNIQUE KEY unique_topic (chapter_id, slug),
    KEY idx_chapter (chapter_id),
    KEY idx_order (display_order)
);

-- مثال
INSERT INTO topics (chapter_id, slug, name_fa, estimated_study_time, display_order) VALUES
(1, 'staph-aureus', 'استافیلوکوکوس اورئوس', 30, 1),
(1, 'streptococcus', 'استرپتوکوکوس', 25, 2),
(1, 'e-coli', 'اشرشیا کلی', 20, 3),
(1, 'pseudomonas', 'سودوموناس', 20, 4);
```

---

## ۱.۷ جدول `questions`

**هدف:** بانک سوالات

```sql
CREATE TABLE questions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    
    -- مسیر سلسله‌مراتبی (برای دسته‌بندی و فیلتر)
    specialty_id INT NOT NULL,
    exam_level_id INT NOT NULL,
    subspecialty_id INT,
    
    -- ارتباط با درسنامه
    course_id INT,
    chapter_id INT,
    topic_id INT,  -- **اهمیت بالا برای linking**
    
    -- متن سوال
    question_text LONGTEXT NOT NULL,
    question_html LONGTEXT,  -- HTML format
    
    -- تصویر
    image_url VARCHAR(500),
    has_image BOOLEAN DEFAULT FALSE,
    
    -- نوع سوال
    question_type ENUM('multiple_choice', 'true_false', 'descriptive') DEFAULT 'multiple_choice',
    
    -- سطح دشواری
    difficulty ENUM('easy', 'medium', 'hard') DEFAULT 'medium',
    
    -- تگ‌ها (برچسب‌های موضوعی - JSON array)
    tags JSON COMMENT '["antibiotic_selection", "sepsis", "empiric_therapy"]',
    
    -- منبع سوال
    source VARCHAR(300) COMMENT 'Harrison, Board Exam 2023, Authored',
    source_year INT COMMENT '1402, 1403, ...',
    source_exam_id INT,  -- ارجاع به جدول exams
    
    -- وضعیت
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (specialty_id) REFERENCES specialties(id),
    FOREIGN KEY (exam_level_id) REFERENCES exam_levels(id),
    FOREIGN KEY (subspecialty_id) REFERENCES subspecialties(id) ON DELETE SET NULL,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE SET NULL,
    FOREIGN KEY (chapter_id) REFERENCES chapters(id) ON DELETE SET NULL,
    FOREIGN KEY (topic_id) REFERENCES topics(id) ON DELETE SET NULL,
    FOREIGN KEY (source_exam_id) REFERENCES exams(id) ON DELETE SET NULL,
    
    KEY idx_path (specialty_id, exam_level_id, subspecialty_id),
    KEY idx_content (course_id, chapter_id, topic_id),
    KEY idx_source (source_exam_id, source_year),
    KEY idx_difficulty (difficulty),
    FULLTEXT idx_question_text (question_text)
);

-- مثال
INSERT INTO questions 
(specialty_id, exam_level_id, subspecialty_id, course_id, chapter_id, topic_id, 
 question_text, question_type, difficulty, tags, source, source_year) 
VALUES 
(1, 3, 1, 1, 1, 1,
 'شایع‌ترین عامل عفونت خون بیمارستانی (hospital-acquired bacteremia) کدام است؟',
 'multiple_choice', 'hard', '["sepsis", "nosocomial", "staphylococcus"]',
 'Board Exam', 1403);
```

---

## ۱.۸ جدول `question_options`

**هدف:** گزینه‌های سوال

```sql
CREATE TABLE question_options (
    id INT PRIMARY KEY AUTO_INCREMENT,
    question_id INT NOT NULL,
    
    option_number INT NOT NULL COMMENT '1, 2, 3, 4 یا A, B, C, D',
    option_text TEXT NOT NULL,
    option_html TEXT,  -- فرمت شده
    
    -- آیا این گزینه صحیح است؟
    is_correct BOOLEAN DEFAULT FALSE,
    
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE,
    UNIQUE KEY unique_option (question_id, option_number),
    KEY idx_question (question_id),
    KEY idx_correct (is_correct)
);

-- مثال برای سوال با id=1
INSERT INTO question_options (question_id, option_number, option_text, is_correct) VALUES
(1, 1, 'استافیلوکوکوس اورئوس', TRUE),
(1, 2, 'استرپتوکوکوس پنومونیه', FALSE),
(1, 3, 'اشرشیا کلی', FALSE),
(1, 4, 'سودوموناس آئروژینوزا', FALSE);
```

---

## ۱.۹ جدول `question_explanations`

**هدف:** توضیح جزئی برای هر سوال

```sql
CREATE TABLE question_explanations (
    id INT PRIMARY KEY AUTO_INCREMENT,
    question_id INT NOT NULL,
    
    -- توضیح (پاسخ صحیح چرا درست است)
    explanation_text LONGTEXT NOT NULL,
    explanation_html LONGTEXT,  -- فرمت شده با HTML
    
    -- نکات برای گزینه‌های غلط
    wrong_options_notes TEXT COMMENT 'JSON array شامل توضیح هر گزینه غلط',
    
    -- منابع مطالعه بیشتر
    references TEXT,
    
    -- نکات بالینی
    clinical_notes TEXT,
    
    -- نکات امتحانی
    exam_tips TEXT COMMENT 'نکاتی که در امتحان باید بدانید',
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE,
    UNIQUE KEY unique_explanation (question_id)
);

-- مثال
INSERT INTO question_explanations 
(question_id, explanation_text, clinical_notes, exam_tips) 
VALUES 
(1,
 'استافیلوکوکوس اورئوس شایع‌ترین عامل عفونت خون بیمارستانی است...',
 'این باکتری مستقل از گرم‌مثبت است و به oxacillin مقاوم می‌تواند باشد.',
 'در امتحان بورد، هر بار که مریضی با عفونت بیمارستانی و ایمونوکمپرومایزد آمد، MRSA فکر کنید.');
```

---

## ۱.۱۰ جدول `exams`

**هدف:** مجموعه‌های آزمون

```sql
CREATE TABLE exams (
    id INT PRIMARY KEY AUTO_INCREMENT,
    
    -- مسیر سلسله‌مراتبی
    specialty_id INT NOT NULL,
    exam_level_id INT NOT NULL,
    subspecialty_id INT,  -- NULL برای مسیرهایی که subspecialty ندارند
    
    -- نوع آزمون
    exam_type_classification_id INT NOT NULL,  -- past_year, authored, combined, etc.
    
    -- اطلاعات آزمون
    title VARCHAR(300) NOT NULL COMMENT 'آزمون ارتقا عفونی ۱۴۰۳',
    slug VARCHAR(150) UNIQUE NOT NULL,
    description TEXT,
    
    -- برای آزمون‌های سال قبل
    exam_year INT COMMENT '1402, 1403, ...',
    exam_date DATE,
    
    -- تنظیمات
    total_questions INT NOT NULL DEFAULT 0,
    duration_minutes INT,
    passing_score DECIMAL(5,2),  -- درصد پاس کردن
    
    -- نوع آزمون
    is_comprehensive BOOLEAN DEFAULT FALSE COMMENT 'آزمون جامع تمام مباحث',
    is_combined BOOLEAN DEFAULT FALSE COMMENT 'آزمون ترکیبی (سفارشی))',
    is_timed BOOLEAN DEFAULT TRUE COMMENT 'آیا آزمون محدود به زمان است',
    
    -- برای آزمون ترکیبی: فیلترهای JSON
    combination_filters JSON COMMENT '{
        "source_exams": [1,2,3],
        "years": [1400, 1401],
        "topics": [5,6,7],
        "courses": [1,2],
        "difficulty": "hard"
    }',
    
    -- وضعیت
    is_active BOOLEAN DEFAULT TRUE,
    is_published BOOLEAN DEFAULT FALSE COMMENT 'آیا برای کاربران قابل دسترسی است',
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (specialty_id) REFERENCES specialties(id),
    FOREIGN KEY (exam_level_id) REFERENCES exam_levels(id),
    FOREIGN KEY (subspecialty_id) REFERENCES subspecialties(id) ON DELETE CASCADE,
    FOREIGN KEY (exam_type_classification_id) REFERENCES exam_types_classification(id),
    
    KEY idx_path (specialty_id, exam_level_id, subspecialty_id),
    KEY idx_type (exam_type_classification_id),
    KEY idx_year (exam_year),
    KEY idx_published (is_published),
    KEY idx_slug (slug)
);

-- مثال: آزمون سال‌های قبل
INSERT INTO exams 
(specialty_id, exam_level_id, subspecialty_id, exam_type_classification_id,
 title, slug, exam_year, exam_date, total_questions, duration_minutes, is_published) 
VALUES 
(1, 3, 1, 1,  -- past_year
 'آزمون ارتقا عفونی ۱۴۰۳', 'infectious-promotion-1403',
 1403, '2024-09-15', 100, 120, TRUE);

-- مثال: آزمون جامع
INSERT INTO exams 
(specialty_id, exam_level_id, subspecialty_id, exam_type_classification_id,
 title, slug, total_questions, duration_minutes, is_comprehensive, is_published) 
VALUES 
(1, 3, 1, 4,  -- comprehensive
 'آزمون جامع عفونی - تمام مباحث', 'infectious-comprehensive',
 200, 180, TRUE, TRUE);

-- مثال: آزمون ترکیبی (سفارشی)
INSERT INTO exams 
(specialty_id, exam_level_id, subspecialty_id, exam_type_classification_id,
 title, slug, total_questions, duration_minutes, is_combined, combination_filters, is_published) 
VALUES 
(1, 3, 1, 3,  -- combined
 'آزمون ترکیبی: عفونی (سال‌های قبل + تألیفی)', 'infectious-custom-mix',
 150, 135, TRUE,
 JSON_OBJECT('source_exams', JSON_ARRAY(1,2,3), 'years', JSON_ARRAY(1402,1403), 'difficulty', 'medium,hard'),
 TRUE);
```

---

## ۱.۱۱ جدول `exam_questions`

**هدف:** ارتباط آزمون‌ها و سوالات (N-to-N)

```sql
CREATE TABLE exam_questions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    exam_id INT NOT NULL,
    question_id INT NOT NULL,
    
    -- ترتیب سوال در آزمون
    question_order INT NOT NULL,
    
    -- امتیاز این سوال
    points DECIMAL(5,2) DEFAULT 1.00,
    
    FOREIGN KEY (exam_id) REFERENCES exams(id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE,
    UNIQUE KEY unique_exam_question (exam_id, question_id),
    KEY idx_exam_order (exam_id, question_order)
);

-- مثال: سوالات آزمون ۱
INSERT INTO exam_questions (exam_id, question_id, question_order, points) VALUES
(1, 1, 1, 1.00),
(1, 2, 2, 1.00),
(1, 3, 3, 1.00),
-- ... تا 100 سوال
(1, 100, 100, 1.00);
```

---

## ۱.۱۲ جدول `users`

**هدف:** کاربران سیستم

```sql
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    
    -- احراز هویت
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    
    -- اطلاعات شخصی
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone VARCHAR(20),
    
    -- تخصص اصلی کاربر (برای پیش‌فرض)
    primary_specialty_id INT,
    primary_exam_level_id INT,
    primary_subspecialty_id INT,
    
    -- وضعیت
    is_email_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    
    -- زمان
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    
    FOREIGN KEY (primary_specialty_id) REFERENCES specialties(id) ON DELETE SET NULL,
    FOREIGN KEY (primary_exam_level_id) REFERENCES exam_levels(id) ON DELETE SET NULL,
    FOREIGN KEY (primary_subspecialty_id) REFERENCES subspecialties(id) ON DELETE SET NULL,
    
    KEY idx_email (email),
    KEY idx_primary_path (primary_specialty_id, primary_exam_level_id, primary_subspecialty_id)
);
```

---

## ۱.۱۳ جدول `user_exam_attempts`

**هدف:** رکورد هر تلاش کاربر برای آزمون

```sql
CREATE TABLE user_exam_attempts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    exam_id INT NOT NULL,
    
    -- زمان‌های مهم
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    
    -- وضعیت
    status ENUM('in_progress', 'completed', 'abandoned', 'timeout') DEFAULT 'in_progress',
    
    -- نتایج
    total_questions INT,
    correct_answers INT DEFAULT 0,
    wrong_answers INT DEFAULT 0,
    unanswered INT DEFAULT 0,
    
    score DECIMAL(5,2),  -- عدد خام
    percentage DECIMAL(5,2),  -- درصد
    
    -- زمان
    time_spent_seconds INT,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (exam_id) REFERENCES exams(id) ON DELETE CASCADE,
    
    KEY idx_user_exam (user_id, exam_id),
    KEY idx_status (status),
    KEY idx_completed (completed_at)
);
```

---

## ۱.۱۴ جدول `user_answers`

**هدف:** پاسخ‌های دقیق کاربر برای هر سوال

```sql
CREATE TABLE user_answers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    attempt_id INT NOT NULL,
    question_id INT NOT NULL,
    
    -- پاسخ کاربر
    selected_option_id INT,  -- NULL اگر بی‌پاسخ
    
    -- نتیجه
    is_correct BOOLEAN,  -- NULL اگر ابھی پاسخ داده نشده
    
    -- زمان
    time_spent_seconds INT,
    answered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (attempt_id) REFERENCES user_exam_attempts(id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE,
    FOREIGN KEY (selected_option_id) REFERENCES question_options(id) ON DELETE SET NULL,
    
    UNIQUE KEY unique_attempt_question (attempt_id, question_id),
    KEY idx_attempt (attempt_id),
    KEY idx_correct (is_correct)
);
```

---

## ۱.۱۵ جدول `user_study_progress`

**هدف:** پیگیری پیشرفت مطالعه درسنامه

```sql
CREATE TABLE user_study_progress (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    topic_id INT NOT NULL,
    
    -- وضعیت
    status ENUM('not_started', 'in_progress', 'completed', 'reviewing') DEFAULT 'not_started',
    
    -- درصد تکمیل
    completion_percentage INT DEFAULT 0,
    
    -- زمان مطالعه (دقیقه)
    study_time_minutes INT DEFAULT 0,
    
    -- تاریخ‌ها
    last_studied_at TIMESTAMP,
    completed_at TIMESTAMP,
    
    -- زمان ثبت
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (topic_id) REFERENCES topics(id) ON DELETE CASCADE,
    
    UNIQUE KEY unique_user_topic (user_id, topic_id),
    KEY idx_user_status (user_id, status),
    KEY idx_topic (topic_id)
);
```

---

## ۱.۱۶ جدول `user_topic_question_attempts`

**هدف:** پاسخ‌های کاربر برای سوالات موضوعی

```sql
CREATE TABLE user_topic_question_attempts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    topic_id INT NOT NULL,
    question_id INT NOT NULL,
    
    -- پاسخ
    selected_option_id INT,
    is_correct BOOLEAN,
    
    -- تعداد تلاش (برای موضوعات، کاربر می‌تواند چند بار تلاش کند)
    attempt_number INT DEFAULT 1,
    
    -- زمان
    answered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (topic_id) REFERENCES topics(id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE,
    FOREIGN KEY (selected_option_id) REFERENCES question_options(id) ON DELETE SET NULL,
    
    KEY idx_user_topic (user_id, topic_id),
    KEY idx_user_question (user_id, question_id),
    KEY idx_answered (answered_at),
    KEY idx_correct (is_correct)
);
```

---

## ۱.۱۷ جدول `exam_types_classification`

**هدف:** تقسیم‌بندی انواع آزمون

```sql
CREATE TABLE exam_types_classification (
    id INT PRIMARY KEY AUTO_INCREMENT,
    slug VARCHAR(50) UNIQUE NOT NULL,
    name_fa VARCHAR(100) NOT NULL,
    name_en VARCHAR(100),
    description TEXT,
    display_order INT DEFAULT 0
);

-- Seed Data
INSERT INTO exam_types_classification (slug, name_fa, name_en, display_order) VALUES
(1, 'past_year', 'آزمون سال‌های قبل', 'Past Year Exam', 1),
(2, 'authored', 'سوالات تألیفی', 'Authored Questions', 2),
(3, 'combined', 'آزمون ترکیبی', 'Combined Exam', 3),
(4, 'comprehensive', 'آزمون جامع', 'Comprehensive Exam', 4),
(5, 'custom', 'آزمون سفارشی', 'Custom Exam', 5);
```

---

# ۲. API Specification

## ۲.۱ Specialties Endpoints

### GET /api/specialties/
**دریافت تمام تخصص‌ها**

```
Request:
GET /api/specialties/?active=true

Response (200 OK):
{
  "count": 3,
  "results": [
    {
      "id": 1,
      "slug": "medicine",
      "name_fa": "پزشکی",
      "name_en": "Medicine",
      "icon": "🩺",
      "description": "تخصص پزشکی عمومی و تخصصی",
      "display_order": 1
    },
    {
      "id": 2,
      "slug": "dentistry",
      "name_fa": "دندانپزشکی",
      "icon": "🦷",
      "display_order": 2
    }
  ]
}
```

---

### GET /api/specialties/{specialty_slug}/levels/
**دریافت سطوح آزمون یک تخصص**

```
Request:
GET /api/specialties/medicine/levels/

Response (200 OK):
{
  "specialty": {
    "id": 1,
    "slug": "medicine",
    "name_fa": "پزشکی"
  },
  "levels": [
    {
      "id": 1,
      "slug": "pre_residency",
      "name_fa": "آزمون پره",
      "requires_subspecialty": false,
      "display_order": 1
    },
    {
      "id": 2,
      "slug": "residency",
      "name_fa": "آزمون دستیاری",
      "requires_subspecialty": false,
      "display_order": 2
    },
    {
      "id": 3,
      "slug": "board_promotion",
      "name_fa": "بورد/ارتقا",
      "requires_subspecialty": true,  // ← اهمیت بالا
      "display_order": 3
    }
  ]
}
```

---

### GET /api/exam-levels/{level_slug}/subspecialties/
**دریافت تخصص‌های فرعی (فقط برای board_promotion)**

```
Request:
GET /api/exam-levels/board_promotion/subspecialties/?specialty=medicine

Response (200 OK):
{
  "level": {
    "id": 3,
    "slug": "board_promotion",
    "name_fa": "بورد/ارتقا"
  },
  "specialty": {
    "id": 1,
    "name_fa": "پزشکی"
  },
  "subspecialties": [
    {
      "id": 1,
      "slug": "infectious",
      "name_fa": "عفونی",
      "display_order": 1
    },
    {
      "id": 2,
      "slug": "cardiology",
      "name_fa": "قلب و عروق",
      "display_order": 2
    },
    // ... 13 تخصص دیگر
  ]
}
```

---

## ۲.۲ Courses & Content Endpoints

### GET /api/courses/
**لیست درس‌ها با فیلترها**

```
Request:
GET /api/courses/?specialty_id=1&exam_level_id=3&subspecialty_id=1

Response (200 OK):
{
  "count": 3,
  "filters": {
    "specialty": "پزشکی",
    "exam_level": "بورد/ارتقا",
    "subspecialty": "عفونی"
  },
  "results": [
    {
      "id": 1,
      "slug": "harrison-infectious",
      "name_fa": "بیماری‌های عفونی - هاریسون",
      "main_reference": "Harrison's Principles",
      "chapters_count": 5,
      "display_order": 1
    },
    {
      "id": 2,
      "slug": "mandell-antimicrobial",
      "name_fa": "آنتی‌بیوتیک‌ها - مندل",
      "chapters_count": 4,
      "display_order": 2
    }
  ]
}
```

---

### GET /api/courses/{course_slug}/
**جزئیات یک درس**

```
Request:
GET /api/courses/harrison-infectious/

Response (200 OK):
{
  "id": 1,
  "name_fa": "بیماری‌های عفونی - هاریسون",
  "author": "Kasper et al.",
  "chapters": [
    {
      "id": 1,
      "slug": "bacterial-infections",
      "name_fa": "عفونت‌های باکتریال",
      "topics_count": 4,
      "estimated_study_time": 180
    },
    {
      "id": 2,
      "slug": "viral-infections",
      "name_fa": "عفونت‌های ویروسی",
      "topics_count": 5,
      "estimated_study_time": 150
    }
  ]
}
```

---

### GET /api/chapters/{chapter_slug}/topics/
**موضوعات یک فصل**

```
Request:
GET /api/chapters/bacterial-infections/topics/

Response (200 OK):
{
  "chapter": {
    "id": 1,
    "name_fa": "عفونت‌های باکتریال",
    "estimated_study_time": 180
  },
  "topics": [
    {
      "id": 1,
      "slug": "staph-aureus",
      "name_fa": "استافیلوکوکوس اورئوس",
      "estimated_study_time": 30,
      "standard_questions_count": 15,
      "user_progress": {
        "status": "not_started",
        "completion_percentage": 0
      }
    },
    {
      "id": 2,
      "slug": "streptococcus",
      "name_fa": "استرپتوکوکوس",
      "estimated_study_time": 25,
      "user_progress": null  // کاربر هنوز شروع نکرده
    }
  ]
}
```

---

### GET /api/topics/{topic_id}/
**جزئیات موضوع (جزوه)**

```
Request:
GET /api/topics/1/

Response (200 OK):
{
  "id": 1,
  "slug": "staph-aureus",
  "name_fa": "استافیلوکوکوس اورئوس",
  "estimated_study_time": 30,
  "summary_content": "<h2>تعریف</h2><p>استافیلوکوکوس اورئوس یک باکتری گرم‌مثبت است...</p>",
  "user_progress": {
    "status": "in_progress",
    "completion_percentage": 70,
    "study_time_minutes": 21
  },
  "standard_questions": {
    "count": 15,
    "available": 15
  }
}
```

---

### GET /api/topics/{topic_id}/questions/
**15 سوال موضوعی**

```
Request:
GET /api/topics/1/questions/

Response (200 OK):
{
  "topic": {
    "id": 1,
    "name_fa": "استافیلوکوکوس اورئوس"
  },
  "questions": [
    {
      "id": 1,
      "question_text": "شایع‌ترین عامل عفونت خون بیمارستانی...",
      "question_type": "multiple_choice",
      "options": [
        {
          "id": 1,
          "option_number": 1,
          "option_text": "استافیلوکوکوس اورئوس",
          "is_correct": true
        },
        {
          "id": 2,
          "option_number": 2,
          "option_text": "استرپتوکوکوس",
          "is_correct": false
        }
      ],
      "user_answer": null  // هنوز پاسخ داده نشده
    },
    // ... 14 سوال دیگر
  ]
}
```

---

## ۲.۳ Exam Endpoints

### GET /api/exams/
**لیست آزمون‌ها**

```
Request:
GET /api/exams/?specialty_id=1&exam_level_id=3&subspecialty_id=1

Response (200 OK):
{
  "filters": {
    "specialty": "پزشکی",
    "exam_level": "بورد/ارتقا",
    "subspecialty": "عفونی"
  },
  "exam_types": [
    {
      "type": "past_year",
      "name_fa": "آزمون‌های سال‌های قبل",
      "exams": [
        {
          "id": 1,
          "title": "آزمون ارتقا عفونی ۱۴۰۳",
          "year": 1403,
          "questions_count": 100,
          "duration": 120,
          "user_attempts": 2,
          "best_score": 75
        },
        {
          "id": 2,
          "title": "آزمون ارتقا عفونی ۱۴۰۲",
          "year": 1402,
          "questions_count": 100,
          "duration": 120,
          "user_attempts": 0
        }
      ]
    },
    {
      "type": "comprehensive",
      "name_fa": "آزمون‌های جامع",
      "exams": [
        {
          "id": 10,
          "title": "آزمون جامع عفونی",
          "questions_count": 200,
          "duration": 180,
          "user_attempts": 1,
          "best_score": 68
        }
      ]
    }
  ]
}
```

---

### POST /api/exams/{exam_id}/start/
**شروع آزمون**

```
Request:
POST /api/exams/1/start/

Body:
{}

Response (200 OK):
{
  "attempt_id": 123,
  "exam": {
    "id": 1,
    "title": "آزمون ارتقا عفونی ۱۴۰۳",
    "total_questions": 100,
    "duration_minutes": 120
  },
  "current_question": {
    "id": 1,
    "question_number": 1,  // 1 to 100
    "question_text": "شایع‌ترین عامل عفونت...",
    "options": [
      {
        "id": 1,
        "option_number": 1,
        "option_text": "گزینه 1"
      },
      // ... 3 گزینه دیگر
    ]
  },
  "started_at": "2026-02-01T02:48:00Z",
  "time_limit_seconds": 7200  // 120 دقیقه
}
```

---

### POST /api/exam-attempts/{attempt_id}/submit-answer/
**ثبت پاسخ سوال**

```
Request:
POST /api/exam-attempts/123/submit-answer/

Body:
{
  "question_id": 1,
  "selected_option_id": 1,
  "time_spent_seconds": 45
}

Response (200 OK):
{
  "submitted": true,
  "attempt": {
    "id": 123,
    "questions_answered": 1,
    "questions_remaining": 99,
    "time_spent_so_far_seconds": 45,
    "time_remaining_seconds": 7155
  },
  "next_question": {
    "id": 2,
    "question_number": 2,
    "question_text": "سوال دوم...",
    "options": [/* ... */]
  }
}
```

---

### POST /api/exam-attempts/{attempt_id}/complete/
**اتمام و ارسال آزمون**

```
Request:
POST /api/exam-attempts/123/complete/

Body:
{}

Response (200 OK):
{
  "attempt": {
    "id": 123,
    "exam_id": 1,
    "status": "completed",
    "total_questions": 100,
    "correct_answers": 75,
    "wrong_answers": 20,
    "unanswered": 5,
    "score": 75,
    "percentage": 75,
    "time_spent_seconds": 5400,  // 90 دقیقه
    "completed_at": "2026-02-01T03:30:00Z"
  }
}
```

---

### GET /api/exam-attempts/{attempt_id}/results/
**نتایج و تحلیل آزمون**

```
Request:
GET /api/exam-attempts/123/results/

Response (200 OK):
{
  "attempt": {
    "id": 123,
    "score": 75,
    "percentage": 75,
    "status": "completed"
  },
  "summary": {
    "correct": 75,
    "wrong": 20,
    "unanswered": 5,
    "total": 100
  },
  "analysis_by_topic": [
    {
      "topic": "عفونت‌های باکتریال",
      "questions": 20,
      "correct": 18,
      "percentage": 90
    },
    {
      "topic": "عفونت‌های ویروسی",
      "questions": 15,
      "correct": 9,
      "percentage": 60
    },
    // ... موضوعات دیگر
  ],
  "detailed_review": [
    {
      "question_number": 1,
      "question_text": "شایع‌ترین عامل عفونت...",
      "user_answer": "استافیلوکوکوس اورئوس",
      "correct_answer": "استافیلوکوکوس اورئوس",
      "is_correct": true,
      "explanation": "توضیح جزئی..."
    },
    {
      "question_number": 2,
      "question_text": "درمان اول انتخاب...",
      "user_answer": "Penicillin",
      "correct_answer": "Cephalosporin",
      "is_correct": false,
      "explanation": "توضیح جزئی..."
    }
  ]
}
```

---

## ۲.۴ User Progress Endpoints

### GET /api/users/me/progress/
**خلاصه پیشرفت کاربر**

```
Response (200 OK):
{
  "user": {
    "id": 1,
    "first_name": "علی",
    "email": "ali@example.com",
    "primary_path": {
      "specialty": "پزشکی",
      "exam_level": "بورد/ارتقا",
      "subspecialty": "عفونی"
    }
  },
  "exam_stats": {
    "exams_taken": 15,
    "average_score": 72.5,
    "total_questions_answered": 1500,
    "accuracy": 72.5,
    "total_study_hours": 52.5
  },
  "study_stats": {
    "courses_accessed": 3,
    "topics_studied": 45,
    "topics_completed": 30,
    "topics_total": 120,
    "completion_percentage": 25
  },
  "weak_topics": [
    {
      "topic": "عفونت‌های ویروسی",
      "accuracy": 45
    },
    {
      "topic": "آنتی‌بیوتیک‌ها",
      "accuracy": 50
    }
  ],
  "strong_topics": [
    {
      "topic": "عفونت‌های باکتریال",
      "accuracy": 85
    },
    {
      "topic": "استافیلوکوکوس",
      "accuracy": 90
    }
  ]
}
```

---

### POST /api/users/me/study-progress/
**ثبت پیشرفت مطالعه موضوع**

```
Request:
POST /api/users/me/study-progress/

Body:
{
  "topic_id": 1,
  "status": "completed",  // not_started, in_progress, completed, reviewing
  "completion_percentage": 100,
  "study_time_minutes": 32
}

Response (201 Created):
{
  "id": 1,
  "user_id": 1,
  "topic_id": 1,
  "status": "completed",
  "completion_percentage": 100,
  "study_time_minutes": 32,
  "updated_at": "2026-02-01T02:48:00Z"
}
```

---

### POST /api/users/me/topic-questions/{question_id}/answer/
**ثبت پاسخ سوال موضوعی**

```
Request:
POST /api/users/me/topic-questions/1/answer/

Body:
{
  "topic_id": 1,
  "selected_option_id": 1
}

Response (200 OK):
{
  "answered": true,
  "is_correct": true,
  "correct_option_id": 1,
  "attempt_number": 1,
  "explanation": "توضیح جزئی برای سوال",
  "user_accuracy_on_topic": {
    "attempts": 5,
    "correct": 4,
    "percentage": 80
  }
}
```

---

## ۲.۵ Custom Exam Builder Endpoints

### POST /api/exams/build-custom/
**ساخت آزمون ترکیبی (سفارشی)**

```
Request:
POST /api/exams/build-custom/

Body:
{
  "exam_name": "آزمون ترکیبی عفونی (سال ۱۴۰۲-۱۴۰۳)",
  "exam_title_fa": "تجمیع سوالات سال‌های قبل + تألیفی",
  "specialty_id": 1,
  "exam_level_id": 3,
  "subspecialty_id": 1,
  "filters": {
    "years": [1402, 1403],
    "exam_types": ["past_year", "authored"],
    "courses": [1],  // فقط هاریسون
    "chapters": [],  // همه فصل‌ها
    "topics": [],    // همه موضوعات
    "difficulty": "medium,hard"
  },
  "question_count": 150,
  "duration_minutes": 135,
  "is_public": false  // فقط برای خود کاربر
}

Response (201 Created):
{
  "id": 200,
  "title": "آزمون ترکیبی عفونی (سال ۱۴۰۲-۱۴۰۳)",
  "exam_type": "combined",
  "questions_selected": 150,
  "duration_minutes": 135,
  "exam_ready": true,
  "start_link": "/api/exams/200/start/"
}
```

---

# ۳. Frontend Architecture

## ۳.۱ صفحات اساسی

### صفحه اصلی (/)

```jsx
// pages/index.tsx
import SpecialtyCard from '@/components/SpecialtyCard';
import { useEffect, useState } from 'react';
import api from '@/services/api';

export default function Home() {
  const [specialties, setSpecialties] = useState([]);

  useEffect(() => {
    api.get('/specialties/?active=true')
      .then(res => setSpecialties(res.data.results))
      .catch(console.error);
  }, []);

  return (
    <div className="container mx-auto p-8 text-right" dir="rtl">
      <h1 className="text-4xl font-bold mb-8">آزمون‌یار پزشکی</h1>
      
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {specialties.map(specialty => (
          <SpecialtyCard
            key={specialty.id}
            specialty={specialty}
            onSelect={() => 
              window.location.href = `/${specialty.slug}`
            }
          />
        ))}
      </div>
    </div>
  );
}
```

---

### صفحه سطوح آزمون ([specialty])

```jsx
// pages/[specialty]/index.tsx
import { useRouter } from 'next/router';
import LevelCard from '@/components/LevelCard';
import { useEffect, useState } from 'react';
import api from '@/services/api';

export default function SpecialtyLevels() {
  const router = useRouter();
  const { specialty } = router.query;
  const [levels, setLevels] = useState([]);

  useEffect(() => {
    if (!specialty) return;
    api.get(`/specialties/${specialty}/levels/`)
      .then(res => setLevels(res.data.levels))
      .catch(console.error);
  }, [specialty]);

  return (
    <div className="container mx-auto p-8 text-right" dir="rtl">
      <h1 className="text-3xl font-bold mb-8">سطح‌های آزمون</h1>
      
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {levels.map(level => (
          <LevelCard
            key={level.id}
            level={level}
            specialty={specialty}
            onSelect={() => {
              if (level.requires_subspecialty) {
                router.push(`/${specialty}/${level.slug}/subspecialties`);
              } else {
                router.push(`/${specialty}/${level.slug}`);
              }
            }}
          />
        ))}
      </div>
    </div>
  );
}
```

---

### صفحه انتخاب تخصص فرعی ([specialty]/[level]/subspecialties)

```jsx
// pages/[specialty]/[level]/subspecialties/index.tsx
import { useRouter } from 'next/router';
import SubspecialtyCard from '@/components/SubspecialtyCard';
import { useEffect, useState } from 'react';
import api from '@/services/api';

export default function SubspecialtiesPage() {
  const router = useRouter();
  const { specialty, level } = router.query;
  const [subspecialties, setSubspecialties] = useState([]);

  useEffect(() => {
    if (!level) return;
    api.get(`/exam-levels/${level}/subspecialties/?specialty=${specialty}`)
      .then(res => setSubspecialties(res.data.subspecialties))
      .catch(console.error);
  }, [level, specialty]);

  return (
    <div className="container mx-auto p-8 text-right" dir="rtl">
      <h1 className="text-3xl font-bold mb-8">انتخاب تخصص</h1>
      
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        {subspecialties.map(sub => (
          <SubspecialtyCard
            key={sub.id}
            subspecialty={sub}
            onSelect={() => 
              router.push(`/${specialty}/${level}/${sub.slug}`)
            }
          />
        ))}
      </div>
    </div>
  );
}
```

---

### صفحه داشبورد ([specialty]/[level]/[subspecialty])

```jsx
// pages/[specialty]/[level]/[subspecialty]/index.tsx
export default function Dashboard() {
  return (
    <div className="container mx-auto p-8 text-right" dir="rtl">
      <h1 className="text-3xl font-bold mb-8">داشبورد</h1>
      
      <div className="grid grid-cols-2 gap-6">
        {/* کارت آزمون‌ها */}
        <div className="bg-blue-100 p-6 rounded-lg cursor-pointer hover:shadow-lg">
          <div className="text-4xl mb-2">📝</div>
          <h2 className="text-xl font-bold">آزمون‌ها</h2>
          <p>آزمون‌های سال‌های قبل، تألیفی، و سفارشی</p>
          <button onClick={() => router.push('./ exams')}>
            شروع →
          </button>
        </div>
        
        {/* کارت درسنامه */}
        <div className="bg-green-100 p-6 rounded-lg cursor-pointer hover:shadow-lg">
          <div className="text-4xl mb-2">📚</div>
          <h2 className="text-xl font-bold">درسنامه</h2>
          <p>کتاب‌ها، فصل‌ها، موضوعات و جزوات</p>
          <button onClick={() => router.push('./ courses')}>
            شروع →
          </button>
        </div>
      </div>
    </div>
  );
}
```

---

### صفحه آزمون (exam/[examId]/take)

```jsx
// pages/exam/[examId]/take.tsx
import { useRouter } from 'next/router';
import { useEffect, useState } from 'react';
import ExamInterface from '@/components/ExamInterface';
import api from '@/services/api';

export default function ExamTakePage() {
  const router = useRouter();
  const { examId } = router.query;
  const [exam, setExam] = useState(null);
  const [attemptId, setAttemptId] = useState(null);

  useEffect(() => {
    if (!examId) return;
    
    // شروع آزمون
    api.post(`/exams/${examId}/start/`)
      .then(res => {
        setExam(res.data);
        setAttemptId(res.data.attempt_id);
      })
      .catch(() => router.push('/'));
  }, [examId]);

  if (!exam) return <div>در حال بارگذاری...</div>;

  return (
    <ExamInterface
      exam={exam}
      attemptId={attemptId}
      onComplete={() => router.push(`/exam/${examId}/results/${attemptId}`)}
    />
  );
}
```

---

## ۳.۲ کامپوننت‌های اساسی

### ExamInterface Component

```jsx
// components/ExamInterface.tsx
import { useState, useEffect } from 'react';
import api from '@/services/api';

export default function ExamInterface({ exam, attemptId, onComplete }) {
  const [currentQuestion, setCurrentQuestion] = useState(null);
  const [selectedOption, setSelectedOption] = useState(null);
  const [remainingTime, setRemainingTime] = useState(exam.time_limit_seconds);
  const [questionNumber, setQuestionNumber] = useState(1);

  // Timer
  useEffect(() => {
    const interval = setInterval(() => {
      setRemainingTime(t => {
        if (t <= 1) {
          handleComplete();
          return 0;
        }
        return t - 1;
      });
    }, 1000);
    return () => clearInterval(interval);
  }, []);

  const handleSubmitAnswer = async () => {
    await api.post(`/exam-attempts/${attemptId}/submit-answer/`, {
      question_id: currentQuestion.id,
      selected_option_id: selectedOption,
      time_spent_seconds: 0
    });

    if (questionNumber < exam.total_questions) {
      setQuestionNumber(q => q + 1);
      setSelectedOption(null);
    }
  };

  const handleComplete = async () => {
    await api.post(`/exam-attempts/${attemptId}/complete/`);
    onComplete();
  };

  return (
    <div className="container mx-auto p-8 text-right" dir="rtl">
      {/* هدر */}
      <div className="flex justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold">{exam.exam.title}</h1>
          <p>سوال {questionNumber} از {exam.total_questions}</p>
        </div>
        <div className="text-2xl font-bold text-red-600">
          {Math.floor(remainingTime / 60)}:{(remainingTime % 60)
            .toString()
            .padStart(2, '0')}
        </div>
      </div>

      {/* نوار پیشرفت */}
      <div className="bg-gray-200 h-2 rounded-full mb-6">
        <div 
          className="bg-blue-500 h-2 rounded-full"
          style={{
            width: `${(questionNumber / exam.total_questions) * 100}%`
          }}
        />
      </div>

      {/* سوال */}
      <div className="bg-white p-8 rounded-lg mb-6">
        <h2 className="text-xl font-bold mb-6">
          {currentQuestion?.question_text}
        </h2>

        {/* گزینه‌ها */}
        <div className="space-y-4">
          {currentQuestion?.options.map(option => (
            <button
              key={option.id}
              onClick={() => setSelectedOption(option.id)}
              className={`w-full p-4 text-right border-2 rounded-lg transition ${
                selectedOption === option.id
                  ? 'border-blue-500 bg-blue-50'
                  : 'border-gray-300 hover:border-gray-400'
              }`}
            >
              {String.fromCharCode(64 + option.option_number)}. {option.option_text}
            </button>
          ))}
        </div>
      </div>

      {/* دکمه‌های کنترل */}
      <div className="flex justify-between">
        <button className="px-6 py-2 bg-gray-300 rounded">← قبلی</button>
        <div className="space-x-4">
          <button className="px-6 py-2 bg-gray-300 rounded">رد شدن</button>
          <button
            onClick={handleSubmitAnswer}
            disabled={!selectedOption}
            className="px-6 py-2 bg-blue-500 text-white rounded disabled:opacity-50"
          >
            بعدی →
          </button>
        </div>
      </div>
    </div>
  );
}
```

---

### TopicStudy Component

```jsx
// components/TopicStudy.tsx
import { useEffect, useState } from 'react';
import api from '@/services/api';

export default function TopicStudy({ topicId }) {
  const [topic, setTopic] = useState(null);
  const [questions, setQuestions] = useState([]);
  const [currentQuestionIndex, setCurrentQuestionIndex] = useState(0);
  const [userAnswers, setUserAnswers] = useState({});

  useEffect(() => {
    api.get(`/topics/${topicId}/`)
      .then(res => setTopic(res.data))
      .catch(console.error);

    api.get(`/topics/${topicId}/questions/`)
      .then(res => setQuestions(res.data.questions))
      .catch(console.error);
  }, [topicId]);

  const handleAnswer = async (optionId) => {
    const currentQuestion = questions[currentQuestionIndex];
    
    const result = await api.post(
      `/users/me/topic-questions/${currentQuestion.id}/answer/`,
      {
        topic_id: topicId,
        selected_option_id: optionId
      }
    );

    setUserAnswers({
      ...userAnswers,
      [currentQuestion.id]: result.data
    });

    // نمایش نتیجه فوری
    if (result.data.is_correct) {
      setTimeout(() => {
        if (currentQuestionIndex < questions.length - 1) {
          setCurrentQuestionIndex(i => i + 1);
        }
      }, 2000);
    }
  };

  if (!topic || questions.length === 0) return <div>در حال بارگذاری...</div>;

  const currentQuestion = questions[currentQuestionIndex];
  const userAnswer = userAnswers[currentQuestion?.id];

  return (
    <div className="container mx-auto p-8 text-right" dir="rtl">
      <div className="grid grid-cols-3 gap-8">
        {/* ستون جزوه */}
        <div className="col-span-2">
          <h1 className="text-3xl font-bold mb-6">{topic.name_fa}</h1>
          
          <div
            className="prose prose-rtl mb-8"
            dangerouslySetInnerHTML={{ __html: topic.summary_content }}
          />

          <button className="bg-blue-500 text-white px-6 py-2 rounded mb-8">
            ↓ دانلود PDF
          </button>
        </div>

        {/* ستون سوالات */}
        <div className="bg-gray-50 p-6 rounded-lg">
          <h2 className="text-xl font-bold mb-4">تست موضوعی</h2>
          <p className="mb-4">سوال {currentQuestionIndex + 1} از 15</p>

          <div className="bg-white p-4 rounded-lg mb-4">
            <p className="font-bold mb-4">{currentQuestion?.question_text}</p>

            <div className="space-y-3">
              {currentQuestion?.options.map(option => (
                <button
                  key={option.id}
                  onClick={() => handleAnswer(option.id)}
                  disabled={userAnswer !== undefined}
                  className={`w-full p-3 text-right rounded border-2 transition ${
                    userAnswer
                      ? option.id === userAnswer.correct_option_id
                        ? 'border-green-500 bg-green-50'
                        : 'border-red-500 bg-red-50'
                      : 'border-gray-300 hover:border-blue-500'
                  }`}
                >
                  {String.fromCharCode(64 + option.option_number)}. {option.option_text}
                </button>
              ))}
            </div>

            {userAnswer && (
              <div className={`mt-4 p-4 rounded ${
                userAnswer.is_correct ? 'bg-green-100' : 'bg-red-100'
              }`}>
                <p className="font-bold">
                  {userAnswer.is_correct ? '✅ صحیح!' : '❌ غلط'}
                </p>
                <p className="mt-2">{userAnswer.explanation}</p>
              </div>
            )}
          </div>

          {currentQuestionIndex < questions.length - 1 && (
            <button
              onClick={() => setCurrentQuestionIndex(i => i + 1)}
              className="w-full bg-blue-500 text-white py-2 rounded"
              disabled={userAnswer === undefined}
            >
              سوال بعدی →
            </button>
          )}
        </div>
      </div>
    </div>
  );
}
```

---

# ۴. Business Logic & Workflows

## ۴.۱ Workflow: شروع آزمون

```
۱. کاربر بر روی آزمون کلیک می‌کند
   ↓
۲. API: POST /api/exams/{exam_id}/start/
   - یک رکورد در جدول user_exam_attempts ایجاد می‌شود
   - status = 'in_progress'
   - first question بازیابی می‌شود
   ↓
۳. Frontend: ExamInterface نمایش داده می‌شود
   - تایمر شروع می‌شود
   - سوال اول نمایش داده می‌شود
   ↓
۴. کاربر پاسخ می‌دهد و "بعدی" را فشار می‌دهد
   ↓
۵. API: POST /api/exam-attempts/{attempt_id}/submit-answer/
   - رکورد در جدول user_answers ایجاد می‌شود
   - سوال بعدی بازیابی می‌شود
   ↓
۶. بعد از آخرین سوال:
   API: POST /api/exam-attempts/{attempt_id}/complete/
   - status = 'completed'
   - نمرات محاسبه می‌شود
   - نتایج ذخیره می‌شود
```

---

## ۴.۲ Workflow: مطالعه درسنامه

```
۱. کاربر موضوعی را انتخاب می‌کند
   ↓
۲. API: GET /api/topics/{topic_id}/
   - جزوه خلاصه نمایش داده می‌شود
   - 15 سوال بازیابی می‌شود
   ↓
۳. API: POST /api/users/me/study-progress/
   - status = 'in_progress' ثبت می‌شود
   - timer شروع می‌شود
   ↓
۴. کاربر جزوه را می‌خواند (optional)
   ↓
۵. کاربر سوال‌ها را پاسخ می‌دهد
   - هر سوال: POST /api/users/me/topic-questions/{question_id}/answer/
   - پاسخ فوری نمایش داده می‌شود
   - accuracy محاسبه می‌شود
   ↓
۶. بعد از ۱۵ سوال:
   - API: POST /api/users/me/study-progress/
   - status = 'completed'
   - درصد تکمیل و زمان ثبت می‌شود
```

---

# ۵. Security & Authentication

## ۵.۱ JWT Token Flow

```
۱. Login: POST /api/auth/login/
   Body: {email, password}
   Response: {access_token, refresh_token}
   ↓
۲. Store tokens in localStorage
   ↓
۳. Include access_token in headers:
   Authorization: Bearer {access_token}
   ↓
۴. If token expired:
   POST /api/auth/token/refresh/
   New token issued
   ↓
۵. Logout:
   Clear localStorage
```

---

## ۵.۲ Permissions

```
- Public: /api/specialties/, /api/exam-levels/, ...
- Authenticated: /api/exams/*, /api/users/me/*, ...
- Admin: /api/admin/*, /api/questions/*, ...
```

---

# ۶. Performance & Scalability

## ۶.۱ Caching Strategy

```
Redis Cache:
- specialties (1 hour)
- exam_levels (1 hour)
- questions (30 minutes)
- user progress (5 minutes)
```

---

## ۶.۲ Database Indexing

تمام جداول بر روی:
- `specialty_id`, `exam_level_id`, `subspecialty_id` indexed
- `user_id`, `topic_id`, `question_id` indexed
- `slug` برای URL routing indexed
- `created_at`, `updated_at` برای sorting indexed

---

# ۷. Error Handling

## ۷.۱ HTTP Status Codes

```
200: OK
201: Created
400: Bad Request
401: Unauthorized
403: Forbidden
404: Not Found
500: Internal Server Error
```

---

## ۷.۲ Error Response Format

```json
{
  "error": "exam_not_found",
  "message": "آزمون درخواستی یافت نشد",
  "status": 404,
  "details": {
    "exam_id": 9999
  }
}
```

---

# ۸. Testing Strategy

## Unit Tests
- Model serializers
- Helper functions
- API logic

## Integration Tests
- Exam workflow
- Study progress
- Answer submission

## E2E Tests
- User journey: select specialty → take exam → view results
- Custom exam builder

---

این تمام مشخصات فنی کاملی است که برای توسعه آمادگی دارد.

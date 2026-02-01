-- medicalpromax_backend/scripts/init-database.sql
-- Complete database schema for MedicalProMax platform
-- Run this script to initialize the MySQL database

-- ============================================
-- Database Creation
-- ============================================

CREATE DATABASE IF NOT EXISTS medicalpromax_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE medicalpromax_db;

-- Create user and grant privileges
CREATE USER IF NOT EXISTS 'medicalpromax_user'@'localhost'
    IDENTIFIED BY 'STRONG_PASSWORD_HERE';

GRANT ALL PRIVILEGES ON medicalpromax_db.* TO 'medicalpromax_user'@'localhost';
FLUSH PRIVILEGES;

-- ============================================
-- TABLE 1: specialties
-- ============================================

CREATE TABLE IF NOT EXISTS specialties (
    id INT PRIMARY KEY AUTO_INCREMENT,
    slug VARCHAR(50) UNIQUE NOT NULL,
    name_fa VARCHAR(100) NOT NULL,
    name_en VARCHAR(100) NOT NULL,
    icon VARCHAR(50) DEFAULT '🩺',
    description TEXT,
    display_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    KEY idx_slug (slug),
    KEY idx_active (is_active),
    KEY idx_order (display_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Seed Specialties
INSERT IGNORE INTO specialties (slug, name_fa, name_en, icon, display_order) VALUES
    ('medicine', 'پزشکی', 'Medicine', '🩺', 1),
    ('dentistry', 'دندانپزشکی', 'Dentistry', '🦷', 2),
    ('pharmacy', 'داروسازی', 'Pharmacy', '💊', 3);

-- ============================================
-- TABLE 2: exam_levels
-- ============================================

CREATE TABLE IF NOT EXISTS exam_levels (
    id INT PRIMARY KEY AUTO_INCREMENT,
    specialty_id INT NOT NULL,
    slug VARCHAR(50) NOT NULL,
    name_fa VARCHAR(100) NOT NULL,
    name_en VARCHAR(100),
    description TEXT,
    icon VARCHAR(50),
    requires_subspecialty BOOLEAN DEFAULT FALSE,
    display_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (specialty_id) REFERENCES specialties(id) ON DELETE CASCADE,
    UNIQUE KEY unique_level (specialty_id, slug),
    KEY idx_specialty (specialty_id),
    KEY idx_requires_sub (requires_subspecialty)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Seed Exam Levels for Medicine
INSERT IGNORE INTO exam_levels (specialty_id, slug, name_fa, name_en, requires_subspecialty, display_order) VALUES
    (1, 'pre_residency', 'آزمون پره', 'Pre-Residency', FALSE, 1),
    (1, 'residency', 'آزمون دستیاری', 'Residency', FALSE, 2),
    (1, 'board_promotion', 'بورد/ارتقا', 'Board/Promotion', TRUE, 3),
    (1, 'national', 'آزمون ملی', 'National Exam', FALSE, 4),
    (1, 'qualification', 'آزمون صلاحیت', 'Qualification', FALSE, 5),
    (1, 'bachelor_to_md', 'لیسانس به پزشکی', 'Bachelor to MD', FALSE, 6);

-- Seed Exam Levels for Dentistry
INSERT IGNORE INTO exam_levels (specialty_id, slug, name_fa, name_en, requires_subspecialty, display_order) VALUES
    (2, 'residency', 'دستیاری دندانپزشکی', 'Dentistry Residency', FALSE, 1),
    (2, 'board_promotion', 'بورد/ارتقا دندانپزشکی', 'Board/Promotion', TRUE, 2),
    (2, 'national', 'آزمون ملی دندانپزشکی', 'National Dentistry', FALSE, 3);

-- ============================================
-- TABLE 3: subspecialties
-- ============================================

CREATE TABLE IF NOT EXISTS subspecialties (
    id INT PRIMARY KEY AUTO_INCREMENT,
    specialty_id INT NOT NULL,
    exam_level_id INT NOT NULL,
    slug VARCHAR(50) NOT NULL,
    name_fa VARCHAR(100) NOT NULL,
    name_en VARCHAR(100),
    description TEXT,
    display_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (specialty_id) REFERENCES specialties(id) ON DELETE CASCADE,
    FOREIGN KEY (exam_level_id) REFERENCES exam_levels(id) ON DELETE CASCADE,
    UNIQUE KEY unique_subspecialty (specialty_id, exam_level_id, slug),
    KEY idx_specialty_level (specialty_id, exam_level_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Seed: 15 Medical Subspecialties (board_promotion = exam_level_id 3)
INSERT IGNORE INTO subspecialties (specialty_id, exam_level_id, slug, name_fa, name_en, display_order) VALUES
    (1, 3, 'infectious', 'عفونی', 'Infectious Diseases', 1),
    (1, 3, 'cardiology', 'قلب و عروق', 'Cardiology', 2),
    (1, 3, 'gastroenterology', 'گوارش', 'Gastroenterology', 3),
    (1, 3, 'pulmonology', 'ریه', 'Pulmonology', 4),
    (1, 3, 'nephrology', 'کلیه', 'Nephrology', 5),
    (1, 3, 'endocrinology', 'غدد', 'Endocrinology', 6),
    (1, 3, 'hematology', 'خون و سرطان', 'Hematology/Oncology', 7),
    (1, 3, 'rheumatology', 'روماتولوژی', 'Rheumatology', 8),
    (1, 3, 'neurology', 'مغز و اعصاب', 'Neurology', 9),
    (1, 3, 'psychiatry', 'روانپزشکی', 'Psychiatry', 10),
    (1, 3, 'surgery', 'جراحی عمومی', 'General Surgery', 11),
    (1, 3, 'orthopedics', 'ارتوپدی', 'Orthopedics', 12),
    (1, 3, 'obstetrics', 'زنان و زایمان', 'OB/GYN', 13),
    (1, 3, 'pediatrics', 'اطفال', 'Pediatrics', 14),
    (1, 3, 'dermatology', 'پوست', 'Dermatology', 15);

-- Seed: 7 Dental Subspecialties (board_promotion = exam_level_id 8)
INSERT IGNORE INTO subspecialties (specialty_id, exam_level_id, slug, name_fa, name_en, display_order) VALUES
    (2, 8, 'orthodontics', 'ارتودنسی', 'Orthodontics', 1),
    (2, 8, 'periodontics', 'پریودنتیکس', 'Periodontics', 2),
    (2, 8, 'endodontics', 'اندودنتیکس', 'Endodontics', 3),
    (2, 8, 'prosthodontics', 'پروتزهای دندانی', 'Prosthodontics', 4),
    (2, 8, 'oral_surgery', 'جراحی دهان و فک', 'Oral Surgery', 5),
    (2, 8, 'pediatric_dentistry', 'دندانپزشکی کودکان', 'Pediatric Dentistry', 6),
    (2, 8, 'oral_pathology', 'پاتولوژی دهان', 'Oral Pathology', 7);

-- ============================================
-- TABLE 4: courses
-- ============================================

CREATE TABLE IF NOT EXISTS courses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    specialty_id INT NOT NULL,
    exam_level_id INT NOT NULL,
    subspecialty_id INT NULL,
    
    slug VARCHAR(100) UNIQUE NOT NULL,
    name_fa VARCHAR(200) NOT NULL,
    name_en VARCHAR(200),
    description TEXT,
    main_reference VARCHAR(300),
    author VARCHAR(200),
    year_published INT,
    difficulty_level ENUM('beginner', 'intermediate', 'advanced') DEFAULT 'intermediate',
    
    display_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (specialty_id) REFERENCES specialties(id),
    FOREIGN KEY (exam_level_id) REFERENCES exam_levels(id),
    FOREIGN KEY (subspecialty_id) REFERENCES subspecialties(id) ON DELETE CASCADE,
    
    KEY idx_path (specialty_id, exam_level_id, subspecialty_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLE 5: chapters
-- ============================================

CREATE TABLE IF NOT EXISTS chapters (
    id INT PRIMARY KEY AUTO_INCREMENT,
    course_id INT NOT NULL,
    
    slug VARCHAR(100) NOT NULL,
    name_fa VARCHAR(300) NOT NULL,
    name_en VARCHAR(300),
    description TEXT,
    chapter_number INT,
    estimated_study_time INT,
    
    display_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
    UNIQUE KEY unique_chapter (course_id, slug),
    KEY idx_course (course_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLE 6: topics
-- ============================================

CREATE TABLE IF NOT EXISTS topics (
    id INT PRIMARY KEY AUTO_INCREMENT,
    chapter_id INT NOT NULL,
    
    slug VARCHAR(100) NOT NULL,
    name_fa VARCHAR(300) NOT NULL,
    name_en VARCHAR(300),
    summary_content LONGTEXT,
    estimated_study_time INT,
    standard_questions_count INT DEFAULT 15,
    
    display_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (chapter_id) REFERENCES chapters(id) ON DELETE CASCADE,
    UNIQUE KEY unique_topic (chapter_id, slug),
    KEY idx_chapter (chapter_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLE 7: questions
-- ============================================

CREATE TABLE IF NOT EXISTS questions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    
    specialty_id INT NOT NULL,
    exam_level_id INT NOT NULL,
    subspecialty_id INT NULL,
    course_id INT NULL,
    chapter_id INT NULL,
    topic_id INT NULL,
    
    question_text LONGTEXT NOT NULL,
    question_html LONGTEXT,
    image_url VARCHAR(500),
    has_image BOOLEAN DEFAULT FALSE,
    
    question_type ENUM('multiple_choice', 'true_false', 'descriptive') DEFAULT 'multiple_choice',
    difficulty ENUM('easy', 'medium', 'hard') DEFAULT 'medium',
    tags JSON,
    
    source VARCHAR(300),
    source_year INT,
    
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (specialty_id) REFERENCES specialties(id),
    FOREIGN KEY (exam_level_id) REFERENCES exam_levels(id),
    FOREIGN KEY (subspecialty_id) REFERENCES subspecialties(id) ON DELETE SET NULL,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE SET NULL,
    FOREIGN KEY (chapter_id) REFERENCES chapters(id) ON DELETE SET NULL,
    FOREIGN KEY (topic_id) REFERENCES topics(id) ON DELETE SET NULL,
    
    KEY idx_path (specialty_id, exam_level_id, subspecialty_id),
    KEY idx_content (course_id, chapter_id, topic_id),
    KEY idx_difficulty (difficulty),
    FULLTEXT idx_question_text (question_text)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLE 8: question_options
-- ============================================

CREATE TABLE IF NOT EXISTS question_options (
    id INT PRIMARY KEY AUTO_INCREMENT,
    question_id INT NOT NULL,
    
    option_number INT NOT NULL,
    option_text TEXT NOT NULL,
    option_html TEXT,
    is_correct BOOLEAN DEFAULT FALSE,
    
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE,
    UNIQUE KEY unique_option (question_id, option_number),
    KEY idx_question (question_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLE 9: question_explanations
-- ============================================

CREATE TABLE IF NOT EXISTS question_explanations (
    id INT PRIMARY KEY AUTO_INCREMENT,
    question_id INT NOT NULL,
    
    explanation_text LONGTEXT NOT NULL,
    explanation_html LONGTEXT,
    wrong_options_notes TEXT,
    references TEXT,
    clinical_notes TEXT,
    exam_tips TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE,
    UNIQUE KEY unique_explanation (question_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLE 10: exam_types_classification
-- ============================================

CREATE TABLE IF NOT EXISTS exam_types_classification (
    id INT PRIMARY KEY AUTO_INCREMENT,
    slug VARCHAR(50) UNIQUE NOT NULL,
    name_fa VARCHAR(100) NOT NULL,
    name_en VARCHAR(100),
    description TEXT,
    display_order INT DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Seed Exam Types
INSERT IGNORE INTO exam_types_classification (slug, name_fa, name_en, display_order) VALUES
    ('past_year', 'آزمون سال‌های قبل', 'Past Year Exam', 1),
    ('authored', 'سوالات تألیفی', 'Authored Questions', 2),
    ('combined', 'آزمون ترکیبی', 'Combined Exam', 3),
    ('comprehensive', 'آزمون جامع', 'Comprehensive Exam', 4),
    ('custom', 'آزمون سفارشی', 'Custom Exam', 5);

-- ============================================
-- TABLE 11: exams
-- ============================================

CREATE TABLE IF NOT EXISTS exams (
    id INT PRIMARY KEY AUTO_INCREMENT,
    
    specialty_id INT NOT NULL,
    exam_level_id INT NOT NULL,
    subspecialty_id INT NULL,
    exam_type_classification_id INT NOT NULL,
    
    title VARCHAR(300) NOT NULL,
    slug VARCHAR(150) UNIQUE NOT NULL,
    description TEXT,
    
    exam_year INT,
    exam_date DATE,
    total_questions INT NOT NULL DEFAULT 0,
    duration_minutes INT,
    passing_score DECIMAL(5,2) DEFAULT 60.00,
    
    is_comprehensive BOOLEAN DEFAULT FALSE,
    is_combined BOOLEAN DEFAULT FALSE,
    is_timed BOOLEAN DEFAULT TRUE,
    combination_filters JSON,
    
    is_active BOOLEAN DEFAULT TRUE,
    is_published BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (specialty_id) REFERENCES specialties(id),
    FOREIGN KEY (exam_level_id) REFERENCES exam_levels(id),
    FOREIGN KEY (subspecialty_id) REFERENCES subspecialties(id) ON DELETE CASCADE,
    FOREIGN KEY (exam_type_classification_id) REFERENCES exam_types_classification(id),
    
    KEY idx_path (specialty_id, exam_level_id, subspecialty_id),
    KEY idx_published (is_published)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLE 12: exam_questions
-- ============================================

CREATE TABLE IF NOT EXISTS exam_questions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    exam_id INT NOT NULL,
    question_id INT NOT NULL,
    question_order INT NOT NULL,
    points DECIMAL(5,2) DEFAULT 1.00,
    
    FOREIGN KEY (exam_id) REFERENCES exams(id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE,
    UNIQUE KEY unique_exam_question (exam_id, question_id),
    KEY idx_exam_order (exam_id, question_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLE 13: users
-- ============================================

CREATE TABLE IF NOT EXISTS users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone VARCHAR(20),
    
    primary_specialty_id INT NULL,
    primary_exam_level_id INT NULL,
    primary_subspecialty_id INT NULL,
    
    is_email_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    is_staff BOOLEAN DEFAULT FALSE,
    is_superuser BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    
    FOREIGN KEY (primary_specialty_id) REFERENCES specialties(id) ON DELETE SET NULL,
    FOREIGN KEY (primary_exam_level_id) REFERENCES exam_levels(id) ON DELETE SET NULL,
    FOREIGN KEY (primary_subspecialty_id) REFERENCES subspecialties(id) ON DELETE SET NULL,
    
    KEY idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLE 14: user_exam_attempts
-- ============================================

CREATE TABLE IF NOT EXISTS user_exam_attempts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    exam_id INT NOT NULL,
    
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL,
    status ENUM('in_progress', 'completed', 'abandoned', 'timeout') DEFAULT 'in_progress',
    
    total_questions INT,
    correct_answers INT DEFAULT 0,
    wrong_answers INT DEFAULT 0,
    unanswered INT DEFAULT 0,
    score DECIMAL(5,2),
    percentage DECIMAL(5,2),
    time_spent_seconds INT,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (exam_id) REFERENCES exams(id) ON DELETE CASCADE,
    
    KEY idx_user_exam (user_id, exam_id),
    KEY idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLE 15: user_answers
-- ============================================

CREATE TABLE IF NOT EXISTS user_answers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    attempt_id INT NOT NULL,
    question_id INT NOT NULL,
    selected_option_id INT NULL,
    is_correct BOOLEAN NULL,
    time_spent_seconds INT,
    answered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (attempt_id) REFERENCES user_exam_attempts(id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE,
    FOREIGN KEY (selected_option_id) REFERENCES question_options(id) ON DELETE SET NULL,
    
    UNIQUE KEY unique_attempt_question (attempt_id, question_id),
    KEY idx_attempt (attempt_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLE 16: user_study_progress
-- ============================================

CREATE TABLE IF NOT EXISTS user_study_progress (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    topic_id INT NOT NULL,
    
    status ENUM('not_started', 'in_progress', 'completed', 'reviewing') DEFAULT 'not_started',
    completion_percentage INT DEFAULT 0,
    study_time_minutes INT DEFAULT 0,
    
    last_studied_at TIMESTAMP NULL,
    completed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (topic_id) REFERENCES topics(id) ON DELETE CASCADE,
    
    UNIQUE KEY unique_user_topic (user_id, topic_id),
    KEY idx_user_status (user_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLE 17: user_topic_question_attempts
-- ============================================

CREATE TABLE IF NOT EXISTS user_topic_question_attempts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    topic_id INT NOT NULL,
    question_id INT NOT NULL,
    selected_option_id INT NULL,
    is_correct BOOLEAN NULL,
    attempt_number INT DEFAULT 1,
    answered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (topic_id) REFERENCES topics(id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE,
    FOREIGN KEY (selected_option_id) REFERENCES question_options(id) ON DELETE SET NULL,
    
    KEY idx_user_topic (user_id, topic_id),
    KEY idx_user_question (user_id, question_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Final: Enable indexes and optimize
-- ============================================

OPTIMIZE TABLE specialties;
OPTIMIZE TABLE exam_levels;
OPTIMIZE TABLE subspecialties;
OPTIMIZE TABLE courses;
OPTIMIZE TABLE chapters;
OPTIMIZE TABLE topics;
OPTIMIZE TABLE questions;
OPTIMIZE TABLE question_options;
OPTIMIZE TABLE question_explanations;
OPTIMIZE TABLE exam_types_classification;
OPTIMIZE TABLE exams;
OPTIMIZE TABLE exam_questions;
OPTIMIZE TABLE users;
OPTIMIZE TABLE user_exam_attempts;
OPTIMIZE TABLE user_answers;
OPTIMIZE TABLE user_study_progress;
OPTIMIZE TABLE user_topic_question_attempts;
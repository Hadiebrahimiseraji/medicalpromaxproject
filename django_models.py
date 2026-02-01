# medicalpromax_backend/apps/core/models.py
"""
Core models for MedicalProMax platform
Specialties, Exam Levels, Subspecialties, Courses, Chapters, Topics
"""

from django.db import models
from django.utils.text import slugify
from django.core.validators import MinValueValidator, MaxValueValidator


class Specialty(models.Model):
    """Medical specialties: Medicine, Dentistry, Pharmacy"""
    
    SPECIALTY_CHOICES = (
        ('medicine', 'پزشکی'),
        ('dentistry', 'دندانپزشکی'),
        ('pharmacy', 'داروسازی'),
    )
    
    id = models.AutoField(primary_key=True)
    slug = models.SlugField(max_length=50, unique=True)
    name_fa = models.CharField(max_length=100)
    name_en = models.CharField(max_length=100)
    icon = models.CharField(max_length=50, default='🩺')
    description = models.TextField(blank=True, null=True)
    display_order = models.IntegerField(default=0)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'specialties'
        ordering = ['display_order']
        verbose_name = 'تخصص'
        verbose_name_plural = 'تخصص‌ها'
    
    def __str__(self):
        return self.name_fa


class ExamLevel(models.Model):
    """Exam levels: Pre-Residency, Residency, Board, National, etc."""
    
    specialty = models.ForeignKey(Specialty, on_delete=models.CASCADE, related_name='exam_levels')
    slug = models.SlugField(max_length=50)
    name_fa = models.CharField(max_length=100)
    name_en = models.CharField(max_length=100, blank=True)
    description = models.TextField(blank=True, null=True)
    icon = models.CharField(max_length=50, blank=True)
    requires_subspecialty = models.BooleanField(default=False, help_text='TRUE only for board_promotion')
    display_order = models.IntegerField(default=0)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'exam_levels'
        unique_together = ['specialty', 'slug']
        ordering = ['display_order']
        verbose_name = 'سطح آزمون'
        verbose_name_plural = 'سطح‌های آزمون'
    
    def __str__(self):
        return f"{self.specialty.name_fa} - {self.name_fa}"


class Subspecialty(models.Model):
    """Subspecialties: 15 for Medicine, 7 for Dentistry (board_promotion only)"""
    
    specialty = models.ForeignKey(Specialty, on_delete=models.CASCADE, related_name='subspecialties')
    exam_level = models.ForeignKey(ExamLevel, on_delete=models.CASCADE, related_name='subspecialties')
    slug = models.SlugField(max_length=50)
    name_fa = models.CharField(max_length=100)
    name_en = models.CharField(max_length=100, blank=True)
    description = models.TextField(blank=True, null=True)
    display_order = models.IntegerField(default=0)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'subspecialties'
        unique_together = ['specialty', 'exam_level', 'slug']
        ordering = ['display_order']
        verbose_name = 'تخصص فرعی'
        verbose_name_plural = 'تخصص‌های فرعی'
    
    def __str__(self):
        return f"{self.specialty.name_fa} - {self.name_fa}"


class Course(models.Model):
    """Courses: organized by specialty, exam level, subspecialty"""
    
    DIFFICULTY_CHOICES = (
        ('beginner', 'ابتدایی'),
        ('intermediate', 'متوسط'),
        ('advanced', 'پیشرفته'),
    )
    
    specialty = models.ForeignKey(Specialty, on_delete=models.CASCADE, related_name='courses')
    exam_level = models.ForeignKey(ExamLevel, on_delete=models.CASCADE, related_name='courses')
    subspecialty = models.ForeignKey(Subspecialty, on_delete=models.CASCADE, related_name='courses', null=True, blank=True)
    
    slug = models.SlugField(max_length=100, unique=True)
    name_fa = models.CharField(max_length=200)
    name_en = models.CharField(max_length=200, blank=True)
    description = models.TextField(blank=True, null=True)
    main_reference = models.CharField(max_length=300, blank=True, null=True)
    author = models.CharField(max_length=200, blank=True, null=True)
    year_published = models.IntegerField(blank=True, null=True)
    
    difficulty_level = models.CharField(
        max_length=20,
        choices=DIFFICULTY_CHOICES,
        default='intermediate'
    )
    
    display_order = models.IntegerField(default=0)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'courses'
        ordering = ['display_order']
        verbose_name = 'درس'
        verbose_name_plural = 'درسنامه‌ها'
        indexes = [
            models.Index(fields=['specialty', 'exam_level', 'subspecialty']),
        ]
    
    def __str__(self):
        return self.name_fa


class Chapter(models.Model):
    """Chapters within courses"""
    
    course = models.ForeignKey(Course, on_delete=models.CASCADE, related_name='chapters')
    
    slug = models.SlugField(max_length=100)
    name_fa = models.CharField(max_length=300)
    name_en = models.CharField(max_length=300, blank=True)
    description = models.TextField(blank=True, null=True)
    chapter_number = models.IntegerField(blank=True, null=True)
    estimated_study_time = models.IntegerField(blank=True, null=True, help_text='Minutes')
    
    display_order = models.IntegerField(default=0)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'chapters'
        unique_together = ['course', 'slug']
        ordering = ['display_order']
        verbose_name = 'فصل'
        verbose_name_plural = 'فصل‌ها'
    
    def __str__(self):
        return self.name_fa


class Topic(models.Model):
    """Topics within chapters - base unit for study mode"""
    
    chapter = models.ForeignKey(Chapter, on_delete=models.CASCADE, related_name='topics')
    
    slug = models.SlugField(max_length=100)
    name_fa = models.CharField(max_length=300)
    name_en = models.CharField(max_length=300, blank=True)
    summary_content = models.TextField(blank=True, null=True, help_text='HTML or Markdown summary')
    estimated_study_time = models.IntegerField(blank=True, null=True, help_text='Minutes')
    standard_questions_count = models.IntegerField(default=15)
    
    display_order = models.IntegerField(default=0)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'topics'
        unique_together = ['chapter', 'slug']
        ordering = ['display_order']
        verbose_name = 'موضوع'
        verbose_name_plural = 'موضوعات'
    
    def __str__(self):
        return self.name_fa


class Question(models.Model):
    """Medical exam questions - core content unit"""
    
    QUESTION_TYPE_CHOICES = (
        ('multiple_choice', 'چندگزینه‌ای'),
        ('true_false', 'صحیح/غلط'),
        ('descriptive', 'تشریحی'),
    )
    
    DIFFICULTY_CHOICES = (
        ('easy', 'آسان'),
        ('medium', 'متوسط'),
        ('hard', 'سخت'),
    )
    
    # Hierarchical path
    specialty = models.ForeignKey(Specialty, on_delete=models.CASCADE, related_name='questions')
    exam_level = models.ForeignKey(ExamLevel, on_delete=models.CASCADE, related_name='questions')
    subspecialty = models.ForeignKey(Subspecialty, on_delete=models.CASCADE, related_name='questions', null=True, blank=True)
    course = models.ForeignKey(Course, on_delete=models.SET_NULL, related_name='questions', null=True, blank=True)
    chapter = models.ForeignKey(Chapter, on_delete=models.SET_NULL, related_name='questions', null=True, blank=True)
    topic = models.ForeignKey(Topic, on_delete=models.SET_NULL, related_name='questions', null=True, blank=True)
    
    # Content
    question_text = models.TextField()
    question_html = models.TextField(blank=True, null=True)
    image_url = models.URLField(blank=True, null=True)
    has_image = models.BooleanField(default=False)
    
    # Metadata
    question_type = models.CharField(
        max_length=20,
        choices=QUESTION_TYPE_CHOICES,
        default='multiple_choice'
    )
    difficulty = models.CharField(
        max_length=10,
        choices=DIFFICULTY_CHOICES,
        default='medium'
    )
    tags = models.JSONField(default=list, blank=True, help_text='["antibiotic", "sepsis"]')
    
    # Source
    source = models.CharField(max_length=300, blank=True, null=True)
    source_year = models.IntegerField(blank=True, null=True)
    
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'questions'
        ordering = ['-created_at']
        verbose_name = 'سوال'
        verbose_name_plural = 'سوالات'
        indexes = [
            models.Index(fields=['specialty', 'exam_level', 'subspecialty']),
            models.Index(fields=['course', 'chapter', 'topic']),
            models.Index(fields=['difficulty']),
        ]
    
    def __str__(self):
        return f"[{self.get_difficulty_display()}] {self.question_text[:50]}"


class QuestionOption(models.Model):
    """Answer options for multiple choice questions"""
    
    question = models.ForeignKey(Question, on_delete=models.CASCADE, related_name='options')
    
    option_number = models.IntegerField(validators=[MinValueValidator(1), MaxValueValidator(6)])
    option_text = models.TextField()
    option_html = models.TextField(blank=True, null=True)
    is_correct = models.BooleanField(default=False)
    
    class Meta:
        db_table = 'question_options'
        unique_together = ['question', 'option_number']
        ordering = ['option_number']
        verbose_name = 'گزینه سوال'
        verbose_name_plural = 'گزینه‌های سوال'
    
    def __str__(self):
        return f"Option {self.option_number} - {self.option_text[:30]}"


class QuestionExplanation(models.Model):
    """Detailed explanations for questions"""
    
    question = models.OneToOneField(Question, on_delete=models.CASCADE, related_name='explanation')
    
    explanation_text = models.TextField()
    explanation_html = models.TextField(blank=True, null=True)
    wrong_options_notes = models.TextField(blank=True, null=True)
    references = models.TextField(blank=True, null=True)
    clinical_notes = models.TextField(blank=True, null=True)
    exam_tips = models.TextField(blank=True, null=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'question_explanations'
        verbose_name = 'توضیح سوال'
        verbose_name_plural = 'توضیح‌های سوال'
    
    def __str__(self):
        return f"Explanation for Q{self.question.id}"
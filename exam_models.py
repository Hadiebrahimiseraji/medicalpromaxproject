# medicalpromax_backend/apps/exams/models.py
"""
Exam models for MedicalProMax platform
Exams, Exam Questions, Exam Attempts, User Answers
"""

from django.db import models
from django.utils import timezone
from datetime import timedelta


class ExamTypeClassification(models.Model):
    """Classification of exam types: Past Year, Authored, Combined, etc."""
    
    slug = models.SlugField(max_length=50, unique=True)
    name_fa = models.CharField(max_length=100)
    name_en = models.CharField(max_length=100, blank=True)
    description = models.TextField(blank=True, null=True)
    display_order = models.IntegerField(default=0)
    
    class Meta:
        db_table = 'exam_types_classification'
        ordering = ['display_order']
        verbose_name = 'نوع آزمون'
        verbose_name_plural = 'انواع آزمون'
    
    def __str__(self):
        return self.name_fa


class Exam(models.Model):
    """Complete exam/test configuration"""
    
    from apps.core.models import Specialty, ExamLevel, Subspecialty
    
    specialty = models.ForeignKey(Specialty, on_delete=models.CASCADE, related_name='exams')
    exam_level = models.ForeignKey(ExamLevel, on_delete=models.CASCADE, related_name='exams')
    subspecialty = models.ForeignKey(Subspecialty, on_delete=models.CASCADE, related_name='exams', null=True, blank=True)
    exam_type_classification = models.ForeignKey(ExamTypeClassification, on_delete=models.PROTECT)
    
    title = models.CharField(max_length=300)
    slug = models.SlugField(max_length=150, unique=True)
    description = models.TextField(blank=True, null=True)
    
    exam_year = models.IntegerField(blank=True, null=True)
    exam_date = models.DateField(blank=True, null=True)
    total_questions = models.IntegerField(default=0)
    duration_minutes = models.IntegerField(blank=True, null=True, help_text='Minutes')
    passing_score = models.DecimalField(max_digits=5, decimal_places=2, default=60.00)
    
    is_comprehensive = models.BooleanField(default=False)
    is_combined = models.BooleanField(default=False)
    is_timed = models.BooleanField(default=True)
    combination_filters = models.JSONField(default=dict, blank=True)
    
    is_active = models.BooleanField(default=True)
    is_published = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'exams'
        ordering = ['-created_at']
        verbose_name = 'آزمون'
        verbose_name_plural = 'آزمون‌ها'
        indexes = [
            models.Index(fields=['specialty', 'exam_level', 'subspecialty']),
            models.Index(fields=['is_published']),
        ]
    
    def __str__(self):
        return self.title


class ExamQuestion(models.Model):
    """N-to-N relationship between Exams and Questions"""
    
    from apps.core.models import Question
    
    exam = models.ForeignKey(Exam, on_delete=models.CASCADE, related_name='exam_questions')
    question = models.ForeignKey(Question, on_delete=models.CASCADE, related_name='exam_questions')
    question_order = models.IntegerField()
    points = models.DecimalField(max_digits=5, decimal_places=2, default=1.00)
    
    class Meta:
        db_table = 'exam_questions'
        unique_together = ['exam', 'question']
        ordering = ['question_order']
        verbose_name = 'سوال آزمون'
        verbose_name_plural = 'سوالات آزمون'
    
    def __str__(self):
        return f"{self.exam.title} - Q{self.question_order}"


class UserExamAttempt(models.Model):
    """User's attempt to take an exam"""
    
    STATUS_CHOICES = (
        ('in_progress', 'در حال انجام'),
        ('completed', 'تکمیل شده'),
        ('abandoned', 'رها شده'),
        ('timeout', 'زمان به پایان رسید'),
    )
    
    user = models.ForeignKey('users.User', on_delete=models.CASCADE, related_name='exam_attempts')
    exam = models.ForeignKey(Exam, on_delete=models.CASCADE, related_name='user_attempts')
    
    started_at = models.DateTimeField(auto_now_add=True)
    completed_at = models.DateTimeField(blank=True, null=True)
    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default='in_progress'
    )
    
    total_questions = models.IntegerField()
    correct_answers = models.IntegerField(default=0)
    wrong_answers = models.IntegerField(default=0)
    unanswered = models.IntegerField(default=0)
    score = models.DecimalField(max_digits=5, decimal_places=2, blank=True, null=True)
    percentage = models.DecimalField(max_digits=5, decimal_places=2, blank=True, null=True)
    time_spent_seconds = models.IntegerField(default=0)
    
    class Meta:
        db_table = 'user_exam_attempts'
        ordering = ['-started_at']
        verbose_name = 'تلاش کاربر در آزمون'
        verbose_name_plural = 'تلاش‌های کاربران در آزمون‌ها'
        indexes = [
            models.Index(fields=['user', 'exam']),
            models.Index(fields=['status']),
        ]
    
    def __str__(self):
        return f"{self.user.email} - {self.exam.title} ({self.status})"
    
    def is_timed_out(self):
        if not self.exam.is_timed or not self.exam.duration_minutes:
            return False
        elapsed = timezone.now() - self.started_at
        return elapsed > timedelta(minutes=self.exam.duration_minutes)


class UserAnswer(models.Model):
    """User's answer to a specific question during exam"""
    
    attempt = models.ForeignKey(UserExamAttempt, on_delete=models.CASCADE, related_name='answers')
    question = models.ForeignKey('core.Question', on_delete=models.CASCADE)
    selected_option = models.ForeignKey('core.QuestionOption', on_delete=models.SET_NULL, null=True, blank=True)
    
    is_correct = models.BooleanField(null=True, blank=True)
    time_spent_seconds = models.IntegerField(default=0)
    answered_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'user_answers'
        unique_together = ['attempt', 'question']
        ordering = ['answered_at']
        verbose_name = 'پاسخ کاربر'
        verbose_name_plural = 'پاسخ‌های کاربران'
        indexes = [
            models.Index(fields=['attempt']),
        ]
    
    def __str__(self):
        return f"Answer to Q{self.question.id} by {self.attempt.user.email}"


class UserStudyProgress(models.Model):
    """User's progress in study mode (topics)"""
    
    STATUS_CHOICES = (
        ('not_started', 'شروع نشده'),
        ('in_progress', 'در حال مطالعه'),
        ('completed', 'تکمیل شده'),
        ('reviewing', 'مرور'),
    )
    
    user = models.ForeignKey('users.User', on_delete=models.CASCADE, related_name='study_progress')
    topic = models.ForeignKey('core.Topic', on_delete=models.CASCADE, related_name='user_progress')
    
    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default='not_started'
    )
    completion_percentage = models.IntegerField(default=0, validators=[MinValueValidator(0), MaxValueValidator(100)])
    study_time_minutes = models.IntegerField(default=0)
    
    last_studied_at = models.DateTimeField(blank=True, null=True)
    completed_at = models.DateTimeField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'user_study_progress'
        unique_together = ['user', 'topic']
        ordering = ['-updated_at']
        verbose_name = 'پیشرفت مطالعه کاربر'
        verbose_name_plural = 'پیشرفت‌های مطالعه کاربران'
        indexes = [
            models.Index(fields=['user', 'status']),
        ]
    
    def __str__(self):
        return f"{self.user.email} - {self.topic.name_fa} ({self.get_status_display()})"


class UserTopicQuestionAttempt(models.Model):
    """User's answer to a specific question in study mode (topic)"""
    
    user = models.ForeignKey('users.User', on_delete=models.CASCADE)
    topic = models.ForeignKey('core.Topic', on_delete=models.CASCADE)
    question = models.ForeignKey('core.Question', on_delete=models.CASCADE)
    selected_option = models.ForeignKey('core.QuestionOption', on_delete=models.SET_NULL, null=True, blank=True)
    
    is_correct = models.BooleanField(null=True, blank=True)
    attempt_number = models.IntegerField(default=1)
    answered_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'user_topic_question_attempts'
        ordering = ['-answered_at']
        verbose_name = 'تلاش کاربر در سوال موضوع'
        verbose_name_plural = 'تلاش‌های کاربران در سوالات موضوعات'
        indexes = [
            models.Index(fields=['user', 'topic']),
            models.Index(fields=['user', 'question']),
        ]
    
    def __str__(self):
        return f"{self.user.email} - Topic {self.topic.id} - Q{self.question.id}"


from django.core.validators import MinValueValidator, MaxValueValidator
# medicalpromax_backend/apps/core/serializers.py
"""
Django REST Framework serializers for core models
"""

from rest_framework import serializers
from .models import (
    Specialty, ExamLevel, Subspecialty, Course, Chapter, Topic,
    Question, QuestionOption, QuestionExplanation
)


class SpecialtySerializer(serializers.ModelSerializer):
    """Serialize Specialty model"""
    
    class Meta:
        model = Specialty
        fields = ['id', 'slug', 'name_fa', 'name_en', 'icon', 'description', 'display_order']
        read_only_fields = ['id']


class ExamLevelSerializer(serializers.ModelSerializer):
    """Serialize ExamLevel model with nested specialty"""
    
    specialty = SpecialtySerializer(read_only=True)
    
    class Meta:
        model = ExamLevel
        fields = ['id', 'slug', 'name_fa', 'name_en', 'specialty', 'requires_subspecialty', 'display_order', 'icon']
        read_only_fields = ['id']


class SubspecialtySerializer(serializers.ModelSerializer):
    """Serialize Subspecialty model"""
    
    class Meta:
        model = Subspecialty
        fields = ['id', 'slug', 'name_fa', 'name_en', 'display_order']
        read_only_fields = ['id']


class TopicSerializer(serializers.ModelSerializer):
    """Serialize Topic model"""
    
    class Meta:
        model = Topic
        fields = ['id', 'slug', 'name_fa', 'name_en', 'summary_content', 
                  'estimated_study_time', 'standard_questions_count', 'display_order']
        read_only_fields = ['id']


class ChapterSerializer(serializers.ModelSerializer):
    """Serialize Chapter model with topics"""
    
    topics = TopicSerializer(many=True, read_only=True)
    
    class Meta:
        model = Chapter
        fields = ['id', 'slug', 'name_fa', 'name_en', 'chapter_number', 
                  'estimated_study_time', 'display_order', 'topics']
        read_only_fields = ['id']


class CourseSerializer(serializers.ModelSerializer):
    """Serialize Course model"""
    
    specialty = SpecialtySerializer(read_only=True)
    exam_level = ExamLevelSerializer(read_only=True)
    subspecialty = SubspecialtySerializer(read_only=True)
    
    class Meta:
        model = Course
        fields = ['id', 'slug', 'name_fa', 'name_en', 'description', 'specialty',
                  'exam_level', 'subspecialty', 'main_reference', 'author', 
                  'year_published', 'difficulty_level', 'display_order']
        read_only_fields = ['id']


class QuestionOptionSerializer(serializers.ModelSerializer):
    """Serialize QuestionOption model"""
    
    class Meta:
        model = QuestionOption
        fields = ['id', 'option_number', 'option_text', 'option_html']
        read_only_fields = ['id']


class QuestionExplanationSerializer(serializers.ModelSerializer):
    """Serialize QuestionExplanation model"""
    
    class Meta:
        model = QuestionExplanation
        fields = ['id', 'explanation_text', 'explanation_html', 'wrong_options_notes',
                  'references', 'clinical_notes', 'exam_tips']
        read_only_fields = ['id']


class QuestionSerializer(serializers.ModelSerializer):
    """Serialize Question model with options and explanation"""
    
    options = QuestionOptionSerializer(many=True, read_only=True, source='options')
    explanation = QuestionExplanationSerializer(read_only=True)
    
    class Meta:
        model = Question
        fields = ['id', 'question_text', 'question_html', 'image_url', 'has_image',
                  'question_type', 'difficulty', 'tags', 'source', 'source_year',
                  'options', 'explanation']
        read_only_fields = ['id']


class QuestionListSerializer(serializers.ModelSerializer):
    """Lightweight serializer for question lists"""
    
    class Meta:
        model = Question
        fields = ['id', 'question_text', 'difficulty', 'tags', 'question_type']
        read_only_fields = ['id']
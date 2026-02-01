# medicalpromax_backend/apps/core/views.py
"""
Django REST Framework views for core endpoints
Navigation: Specialties, Exam Levels, Subspecialties, Courses
"""

from rest_framework import generics, viewsets, status
from rest_framework.response import Response
from rest_framework.decorators import action
from rest_framework.permissions import AllowAny
from django.shortcuts import get_object_or_404

from .models import Specialty, ExamLevel, Subspecialty, Course, Chapter, Topic, Question
from .serializers import (
    SpecialtySerializer, ExamLevelSerializer, SubspecialtySerializer,
    CourseSerializer, ChapterSerializer, TopicSerializer, QuestionSerializer
)


class SpecialtyListView(generics.ListAPIView):
    """
    GET /api/specialties/
    Returns all active specialties
    """
    queryset = Specialty.objects.filter(is_active=True)
    serializer_class = SpecialtySerializer
    permission_classes = [AllowAny]
    pagination_class = None


class ExamLevelListView(generics.ListAPIView):
    """
    GET /api/specialties/{specialty_slug}/exam-levels/
    Returns exam levels for a specific specialty
    """
    serializer_class = ExamLevelSerializer
    permission_classes = [AllowAny]
    pagination_class = None
    
    def get_queryset(self):
        specialty_slug = self.kwargs.get('specialty_slug')
        return ExamLevel.objects.filter(
            specialty__slug=specialty_slug,
            is_active=True
        ).select_related('specialty')


class SubspecialtyListView(generics.ListAPIView):
    """
    GET /api/exam-levels/{level_slug}/subspecialties/?specialty=medicine
    Returns subspecialties for a specific exam level
    """
    serializer_class = SubspecialtySerializer
    permission_classes = [AllowAny]
    pagination_class = None
    
    def get_queryset(self):
        level_slug = self.kwargs.get('level_slug')
        specialty_slug = self.request.query_params.get('specialty')
        
        return Subspecialty.objects.filter(
            exam_level__slug=level_slug,
            specialty__slug=specialty_slug,
            is_active=True
        ).select_related('specialty', 'exam_level')


class CourseListView(generics.ListAPIView):
    """
    GET /api/courses/?specialty_id=1&exam_level_id=3&subspecialty_id=1
    Returns courses filtered by specialty, exam level, and subspecialty
    """
    serializer_class = CourseSerializer
    permission_classes = [AllowAny]
    
    def get_queryset(self):
        specialty_id = self.request.query_params.get('specialty_id')
        exam_level_id = self.request.query_params.get('exam_level_id')
        subspecialty_id = self.request.query_params.get('subspecialty_id')
        
        queryset = Course.objects.filter(is_active=True)
        
        if specialty_id:
            queryset = queryset.filter(specialty_id=specialty_id)
        if exam_level_id:
            queryset = queryset.filter(exam_level_id=exam_level_id)
        if subspecialty_id:
            queryset = queryset.filter(subspecialty_id=subspecialty_id)
        
        return queryset.select_related('specialty', 'exam_level', 'subspecialty')


class CourseDetailView(generics.RetrieveAPIView):
    """
    GET /api/courses/{course_slug}/
    Returns course details with chapters and topics
    """
    serializer_class = CourseSerializer
    permission_classes = [AllowAny]
    lookup_field = 'slug'
    lookup_url_kwarg = 'course_slug'
    
    def get_queryset(self):
        return Course.objects.filter(is_active=True).select_related('specialty', 'exam_level', 'subspecialty')


class ChapterListView(generics.ListAPIView):
    """
    GET /api/courses/{course_slug}/chapters/
    Returns chapters for a specific course
    """
    serializer_class = ChapterSerializer
    permission_classes = [AllowAny]
    
    def get_queryset(self):
        course_slug = self.kwargs.get('course_slug')
        course = get_object_or_404(Course, slug=course_slug, is_active=True)
        return Chapter.objects.filter(course=course, is_active=True)


class TopicListView(generics.ListAPIView):
    """
    GET /api/chapters/{chapter_slug}/topics/
    Returns topics for a specific chapter
    """
    serializer_class = TopicSerializer
    permission_classes = [AllowAny]
    
    def get_queryset(self):
        chapter_slug = self.kwargs.get('chapter_slug')
        chapter = get_object_or_404(Chapter, slug=chapter_slug, is_active=True)
        return Topic.objects.filter(chapter=chapter, is_active=True)


class TopicDetailView(generics.RetrieveAPIView):
    """
    GET /api/topics/{topic_id}/
    Returns topic details with summary and user progress (if authenticated)
    """
    serializer_class = TopicSerializer
    permission_classes = [AllowAny]
    lookup_field = 'id'
    lookup_url_kwarg = 'topic_id'
    
    def get_queryset(self):
        return Topic.objects.filter(is_active=True)
    
    def retrieve(self, request, *args, **kwargs):
        instance = self.get_object()
        serializer = self.get_serializer(instance)
        data = serializer.data
        
        # Add user progress if authenticated
        if request.user.is_authenticated:
            from apps.exams.models import UserStudyProgress
            try:
                progress = UserStudyProgress.objects.get(user=request.user, topic=instance)
                data['user_progress'] = {
                    'status': progress.status,
                    'completion_percentage': progress.completion_percentage,
                    'study_time_minutes': progress.study_time_minutes,
                    'last_studied_at': progress.last_studied_at,
                }
            except UserStudyProgress.DoesNotExist:
                data['user_progress'] = None
        
        return Response(data)


class TopicQuestionsView(generics.ListAPIView):
    """
    GET /api/topics/{topic_id}/questions/
    Returns questions for a specific topic
    """
    serializer_class = QuestionSerializer
    permission_classes = [AllowAny]
    
    def get_queryset(self):
        topic_id = self.kwargs.get('topic_id')
        topic = get_object_or_404(Topic, id=topic_id, is_active=True)
        return Question.objects.filter(topic=topic, is_active=True).prefetch_related('options', 'explanation')
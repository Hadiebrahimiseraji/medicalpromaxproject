# medicalpromax_backend/apps/exams/views.py
"""
Django REST Framework views for exam endpoints
Exams list, start exam, submit answers, complete exam, results
"""

from rest_framework import generics, status, viewsets
from rest_framework.response import Response
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated, AllowAny
from django.shortcuts import get_object_or_404
from django.utils import timezone
from datetime import timedelta

from .models import (
    Exam, ExamQuestion, UserExamAttempt, UserAnswer, UserStudyProgress
)
from .serializers import (
    ExamSerializer, ExamDetailSerializer, UserExamAttemptSerializer,
    UserAnswerSerializer, UserExamResultsSerializer
)
from apps.core.models import Question


class ExamListView(generics.ListAPIView):
    """
    GET /api/exams/?specialty_id=1&exam_level_id=3&subspecialty_id=1
    Returns exams filtered by specialty, exam level, and subspecialty
    Groups by exam type
    """
    serializer_class = ExamSerializer
    permission_classes = [AllowAny]
    
    def get_queryset(self):
        specialty_id = self.request.query_params.get('specialty_id')
        exam_level_id = self.request.query_params.get('exam_level_id')
        subspecialty_id = self.request.query_params.get('subspecialty_id')
        
        queryset = Exam.objects.filter(is_active=True, is_published=True)
        
        if specialty_id:
            queryset = queryset.filter(specialty_id=specialty_id)
        if exam_level_id:
            queryset = queryset.filter(exam_level_id=exam_level_id)
        if subspecialty_id:
            queryset = queryset.filter(subspecialty_id=subspecialty_id)
        
        return queryset.select_related(
            'specialty', 'exam_level', 'subspecialty', 'exam_type_classification'
        ).prefetch_related('exam_questions')
    
    def list(self, request, *args, **kwargs):
        """Override to group by exam type"""
        queryset = self.filter_queryset(self.get_queryset())
        
        # Group by exam type
        from collections import defaultdict
        exam_types = defaultdict(list)
        
        for exam in queryset:
            exam_data = ExamSerializer(exam).data
            exam_types[exam.exam_type_classification.name_fa].append(exam_data)
        
        return Response({
            'exam_types': [
                {
                    'type': key,
                    'exams': exams
                }
                for key, exams in exam_types.items()
            ]
        })


class ExamDetailView(generics.RetrieveAPIView):
    """
    GET /api/exams/{exam_id}/
    Returns exam details with full question list
    """
    serializer_class = ExamDetailSerializer
    permission_classes = [AllowAny]
    lookup_field = 'id'
    lookup_url_kwarg = 'exam_id'
    
    def get_queryset(self):
        return Exam.objects.filter(is_active=True, is_published=True)


class ExamStartView(generics.CreateAPIView):
    """
    POST /api/exams/{exam_id}/start/
    Creates a new exam attempt for the user
    Response: attempt_id, exam details, first question
    """
    permission_classes = [IsAuthenticated]
    
    def post(self, request, exam_id):
        exam = get_object_or_404(Exam, id=exam_id, is_active=True, is_published=True)
        
        # Check if user already has in-progress attempt
        existing_attempt = UserExamAttempt.objects.filter(
            user=request.user,
            exam=exam,
            status='in_progress'
        ).first()
        
        if existing_attempt:
            attempt = existing_attempt
        else:
            # Create new attempt
            exam_questions = ExamQuestion.objects.filter(exam=exam).count()
            attempt = UserExamAttempt.objects.create(
                user=request.user,
                exam=exam,
                total_questions=exam_questions,
                status='in_progress'
            )
        
        # Get first unanswered question
        answered_questions = UserAnswer.objects.filter(attempt=attempt).values_list('question_id', flat=True)
        first_question = ExamQuestion.objects.filter(
            exam=exam
        ).exclude(
            question_id__in=answered_questions
        ).first()
        
        if not first_question:
            first_question = ExamQuestion.objects.filter(exam=exam).first()
        
        response_data = {
            'attempt_id': attempt.id,
            'exam': ExamDetailSerializer(exam).data,
            'current_question': {
                'id': first_question.question.id,
                'order': first_question.question_order,
                'question_text': first_question.question.question_text,
                'question_html': first_question.question.question_html,
                'image_url': first_question.question.image_url,
                'options': [
                    {
                        'id': opt.id,
                        'option_number': opt.option_number,
                        'option_text': opt.option_text,
                        'option_html': opt.option_html,
                    }
                    for opt in first_question.question.options.all()
                ]
            }
        }
        
        return Response(response_data, status=status.HTTP_201_CREATED)


class ExamAnswerSubmitView(generics.CreateAPIView):
    """
    POST /api/exam-attempts/{attempt_id}/submit-answer/
    Submit user answer to a question
    Request: {question_id, selected_option_id, time_spent_seconds}
    Response: {submitted: true, next_question: {...}}
    """
    permission_classes = [IsAuthenticated]
    
    def post(self, request, attempt_id):
        attempt = get_object_or_404(UserExamAttempt, id=attempt_id, user=request.user)
        
        if attempt.status != 'in_progress':
            return Response(
                {'error': 'Exam attempt is not in progress'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        question_id = request.data.get('question_id')
        selected_option_id = request.data.get('selected_option_id')
        time_spent_seconds = request.data.get('time_spent_seconds', 0)
        
        question = get_object_or_404(Question, id=question_id)
        
        # Check if option is correct
        is_correct = False
        selected_option = None
        
        if selected_option_id:
            selected_option = question.options.filter(id=selected_option_id).first()
            if selected_option:
                is_correct = selected_option.is_correct
        
        # Save answer
        user_answer, created = UserAnswer.objects.update_or_create(
            attempt=attempt,
            question=question,
            defaults={
                'selected_option': selected_option,
                'is_correct': is_correct,
                'time_spent_seconds': time_spent_seconds,
            }
        )
        
        # Update attempt stats
        attempt.time_spent_seconds += time_spent_seconds
        
        answered_count = UserAnswer.objects.filter(attempt=attempt).count()
        correct_count = UserAnswer.objects.filter(attempt=attempt, is_correct=True).count()
        wrong_count = UserAnswer.objects.filter(attempt=attempt, is_correct=False).count()
        
        attempt.correct_answers = correct_count
        attempt.wrong_answers = wrong_count
        attempt.unanswered = attempt.total_questions - answered_count
        
        # Get next unanswered question
        answered_questions = UserAnswer.objects.filter(attempt=attempt).values_list('question_id', flat=True)
        next_exam_question = ExamQuestion.objects.filter(
            exam=attempt.exam
        ).exclude(
            question_id__in=answered_questions
        ).first()
        
        response_data = {
            'submitted': True,
            'is_correct': is_correct,
            'progress': {
                'answered': answered_count,
                'correct': correct_count,
                'wrong': wrong_count,
                'unanswered': attempt.unanswered,
            }
        }
        
        if next_exam_question:
            response_data['next_question'] = {
                'id': next_exam_question.question.id,
                'order': next_exam_question.question_order,
                'question_text': next_exam_question.question.question_text,
                'options': [
                    {
                        'id': opt.id,
                        'option_number': opt.option_number,
                        'option_text': opt.option_text,
                    }
                    for opt in next_exam_question.question.options.all()
                ]
            }
        
        attempt.save()
        
        return Response(response_data)


class ExamCompleteView(generics.CreateAPIView):
    """
    POST /api/exam-attempts/{attempt_id}/complete/
    Mark exam as completed and calculate final score
    """
    permission_classes = [IsAuthenticated]
    
    def post(self, request, attempt_id):
        attempt = get_object_or_404(UserExamAttempt, id=attempt_id, user=request.user)
        
        if attempt.status != 'in_progress':
            return Response(
                {'error': 'Exam attempt is not in progress'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Calculate final score
        correct_answers = UserAnswer.objects.filter(attempt=attempt, is_correct=True).count()
        total_questions = attempt.total_questions
        
        score = (correct_answers / total_questions * 100) if total_questions > 0 else 0
        
        # Update attempt
        attempt.status = 'completed'
        attempt.completed_at = timezone.now()
        attempt.correct_answers = correct_answers
        attempt.percentage = score
        attempt.score = score
        attempt.save()
        
        response_data = {
            'attempt': UserExamAttemptSerializer(attempt).data,
            'summary': {
                'total_questions': total_questions,
                'correct_answers': correct_answers,
                'score': score,
                'passing_score': float(attempt.exam.passing_score),
                'passed': score >= float(attempt.exam.passing_score),
            }
        }
        
        return Response(response_data)


class ExamResultsView(generics.RetrieveAPIView):
    """
    GET /api/exam-attempts/{attempt_id}/results/
    Returns detailed results of a completed exam
    """
    permission_classes = [IsAuthenticated]
    serializer_class = UserExamResultsSerializer
    lookup_field = 'id'
    lookup_url_kwarg = 'attempt_id'
    
    def get_queryset(self):
        return UserExamAttempt.objects.filter(user=self.request.user, status='completed')
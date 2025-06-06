# analytics/views.py

from rest_framework import viewsets, status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated, IsAdminUser
from django.db.models import Avg, Sum, Count
from django.utils import timezone
from datetime import timedelta
from .models import (
    InstitutionAnalytic,
    SubjectAnalytic,
    TutorPerformanceMetric,
    StudentProgressMetric,
    StudentRiskAssessment,
    RecommendedAction,
    PredictiveModel
)
from .serializers import (
    InstitutionAnalyticSerializer,
    SubjectAnalyticSerializer,
    TutorPerformanceMetricSerializer,
    StudentProgressMetricSerializer,
    StudentRiskAssessmentSerializer,
    RecommendedActionSerializer,
    PredictiveModelSerializer
)
from tutoring.models import TutoringSession, Subject
from users.models import User
from tutoring.serializers import SubjectSerializer

class AnalyticsDashboardView(APIView):
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        # Get basic statistics for the dashboard
        thirty_days_ago = timezone.now() - timedelta(days=30)
        
        data = {
            'institution_stats': self.get_institution_stats(),
            'recent_subject_stats': self.get_subject_stats(),
            'tutor_performance': self.get_top_tutors(),
            'at_risk_students': self.get_at_risk_students(),
            'recent_recommendations': self.get_recent_recommendations(),
        }
        
        return Response(data)
    
    def get_institution_stats(self):
        # Get the most recent institution analytics
        try:
            stats = InstitutionAnalytic.objects.latest('period_end')
            serializer = InstitutionAnalyticSerializer(stats)
            return serializer.data
        except InstitutionAnalytic.DoesNotExist:
            return None
    
    def get_subject_stats(self):
        # Get stats for top 5 subjects by session count
        subjects = SubjectAnalytic.objects.filter(
            period_end__gte=timezone.now() - timedelta(days=30)
        ).order_by('-total_sessions')[:5]
        serializer = SubjectAnalyticSerializer(subjects, many=True)
        return serializer.data
    
    def get_top_tutors(self):
        # Get top 5 tutors by average rating
        tutors = TutorPerformanceMetric.objects.filter(
            period_end__gte=timezone.now() - timedelta(days=30)
        ).order_by('-average_rating')[:5]
        serializer = TutorPerformanceMetricSerializer(tutors, many=True)
        return serializer.data
    
    def get_at_risk_students(self):
        # Get high risk students
        students = StudentRiskAssessment.objects.filter(
            risk_level='high',
            assessed_at__gte=timezone.now() - timedelta(days=7)
        ).select_related('student', 'subject')[:10]
        serializer = StudentRiskAssessmentSerializer(students, many=True)
        return serializer.data
    
    def get_recent_recommendations(self):
        # Get recent high priority recommendations
        recommendations = RecommendedAction.objects.filter(
            is_completed=False,
            priority__lte=2
        ).order_by('priority', 'created_at')[:10]
        serializer = RecommendedActionSerializer(recommendations, many=True)
        return serializer.data

class GenerateReportsView(APIView):
    permission_classes = [IsAdminUser]
    
    def post(self, request):
        report_type = request.data.get('type')
        start_date = request.data.get('start_date')
        end_date = request.data.get('end_date')
        
        if not report_type or not start_date or not end_date:
            return Response(
                {'error': 'Missing required parameters: type, start_date, end_date'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        if report_type == 'institution':
            data = self.generate_institution_report(start_date, end_date)
        elif report_type == 'subject':
            subject_id = request.data.get('subject_id')
            if not subject_id:
                return Response(
                    {'error': 'Missing subject_id for subject report'},
                    status=status.HTTP_400_BAD_REQUEST
                )
            data = self.generate_subject_report(subject_id, start_date, end_date)
        elif report_type == 'tutor':
            tutor_id = request.data.get('tutor_id')
            if not tutor_id:
                return Response(
                    {'error': 'Missing tutor_id for tutor report'},
                    status=status.HTTP_400_BAD_REQUEST
                )
            data = self.generate_tutor_report(tutor_id, start_date, end_date)
        else:
            return Response(
                {'error': 'Invalid report type'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        return Response(data)
    
    def generate_institution_report(self, start_date, end_date):
        # Generate institution-wide report
        analytics = InstitutionAnalytic.objects.filter(
            period_start__gte=start_date,
            period_end__lte=end_date
        ).order_by('period_start')
        
        # Calculate summary statistics
        summary = {
            'total_sessions': sum(a.total_sessions for a in analytics),
            'total_hours': sum(float(a.total_tutoring_hours) for a in analytics),
            'avg_session_rating': analytics.aggregate(avg=Avg('average_session_rating'))['avg'],
            'active_students': max(a.active_students for a in analytics) if analytics else 0,
            'active_tutors': max(a.active_tutors for a in analytics) if analytics else 0,
        }
        
        serializer = InstitutionAnalyticSerializer(analytics, many=True)
        return {
            'summary': summary,
            'period_data': serializer.data
        }
    
    def generate_subject_report(self, subject_id, start_date, end_date):
        # Generate subject-specific report
        subject = Subject.objects.get(pk=subject_id)
        analytics = SubjectAnalytic.objects.filter(
            subject=subject,
            period_start__gte=start_date,
            period_end__lte=end_date
        ).order_by('period_start')
        
        # Calculate summary statistics
        summary = {
            'total_sessions': sum(a.total_sessions for a in analytics),
            'total_hours': sum(float(a.total_tutoring_hours) for a in analytics),
            'avg_session_rating': analytics.aggregate(avg=Avg('average_session_rating'))['avg'],
            'avg_student_to_tutor_ratio': analytics.aggregate(avg=Avg('student_to_tutor_ratio'))['avg'],
        }
        
        serializer = SubjectAnalyticSerializer(analytics, many=True)
        return {
            'subject': SubjectSerializer(subject).data,
            'summary': summary,
            'period_data': serializer.data
        }
    
    def generate_tutor_report(self, tutor_id, start_date, end_date):
        # Generate tutor-specific report
        tutor = User.objects.get(pk=tutor_id)
        metrics = TutorPerformanceMetric.objects.filter(
            tutor=tutor,
            period_start__gte=start_date,
            period_end__lte=end_date
        ).order_by('period_start')
        
        # Calculate summary statistics
        summary = {
            'total_sessions': sum(m.sessions_conducted for m in metrics),
            'total_hours': sum(float(m.total_tutoring_hours) for m in metrics),
            'avg_rating': metrics.aggregate(avg=Avg('average_rating'))['avg'],
            'unique_students': sum(m.unique_students_helped for m in metrics),
        }
        
        serializer = TutorPerformanceMetricSerializer(metrics, many=True)
        return {
            'tutor': {
                'id': tutor.id,
                'name': tutor.get_full_name(),
                'email': tutor.email
            },
            'summary': summary,
            'period_data': serializer.data
        }

# ViewSets for the models
class InstitutionAnalyticsViewSet(viewsets.ModelViewSet):
    queryset = InstitutionAnalytic.objects.all().order_by('-period_end')
    serializer_class = InstitutionAnalyticSerializer
    permission_classes = [IsAdminUser]

class SubjectAnalyticsViewSet(viewsets.ModelViewSet):
    queryset = SubjectAnalytic.objects.all().order_by('-period_end')
    serializer_class = SubjectAnalyticSerializer
    permission_classes = [IsAuthenticated]

class TutorPerformanceViewSet(viewsets.ModelViewSet):
    serializer_class = TutorPerformanceMetricSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        # Tutors can only see their own metrics
        if self.request.user.role == 'tutor':
            return TutorPerformanceMetric.objects.filter(
                tutor=self.request.user
            ).order_by('-period_end')
        # Admins can see all
        elif self.request.user.is_staff:
            return TutorPerformanceMetric.objects.all().order_by('-period_end')
        # Others see none
        return TutorPerformanceMetric.objects.none()

class StudentProgressViewSet(viewsets.ModelViewSet):
    serializer_class = StudentProgressMetricSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        # Students can only see their own metrics
        if self.request.user.role == 'student':
            return StudentProgressMetric.objects.filter(
                student=self.request.user
            ).order_by('-period_end')
        # Instructors can see their students' metrics
        elif self.request.user.role == 'instructor':
            # Assuming you have a way to get students for an instructor
            student_ids = self.request.user.instructor.students.values_list('id', flat=True)
            return StudentProgressMetric.objects.filter(
                student_id__in=student_ids
            ).order_by('-period_end')
        # Admins can see all
        elif self.request.user.is_staff:
            return StudentProgressMetric.objects.all().order_by('-period_end')
        # Others see none
        return StudentProgressMetric.objects.none()

class RiskAssessmentViewSet(viewsets.ModelViewSet):
    serializer_class = StudentRiskAssessmentSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        # Students can only see their own assessments
        if self.request.user.role == 'student':
            return StudentRiskAssessment.objects.filter(
                student=self.request.user
            ).order_by('-assessed_at')
        # Instructors can see their students' assessments
        elif self.request.user.role == 'instructor':
            student_ids = self.request.user.instructor.students.values_list('id', flat=True)
            return StudentRiskAssessment.objects.filter(
                student_id__in=student_ids
            ).order_by('-assessed_at')
        # Admins can see all
        elif self.request.user.is_staff:
            return StudentRiskAssessment.objects.all().order_by('-assessed_at')
        # Others see none
        return StudentRiskAssessment.objects.none()

class RecommendedActionViewSet(viewsets.ModelViewSet):
    serializer_class = RecommendedActionSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        # Students can only see their own recommendations
        if self.request.user.role == 'student':
            return RecommendedAction.objects.filter(
                student=self.request.user
            ).order_by('priority', '-created_at')
        # Instructors can see their students' recommendations
        elif self.request.user.role == 'instructor':
            student_ids = self.request.user.instructor.students.values_list('id', flat=True)
            return RecommendedAction.objects.filter(
                student_id__in=student_ids
            ).order_by('priority', '-created_at')
        # Admins can see all
        elif self.request.user.is_staff:
            return RecommendedAction.objects.all().order_by('priority', '-created_at')
        # Others see none
        return RecommendedAction.objects.none()

class PredictiveModelViewSet(viewsets.ModelViewSet):
    queryset = PredictiveModel.objects.all().order_by('-updated_at')
    serializer_class = PredictiveModelSerializer
    permission_classes = [IsAdminUser]
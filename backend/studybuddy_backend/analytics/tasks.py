# analytics/tasks.py

from celery import shared_task
from datetime import datetime, timedelta
from django.utils import timezone
from .models import (
    InstitutionAnalytic,
    SubjectAnalytic,
    TutorPerformanceMetric,
    StudentProgressMetric
)
from tutoring.models import Subject, TutoringSession
from users.models import User

@shared_task
def generate_monthly_analytics():
    """Generate analytics for the previous month"""
    today = timezone.now().date()
    first_day_last_month = (today.replace(day=1) - timedelta(days=1)).replace(day=1)
    last_day_last_month = today.replace(day=1) - timedelta(days=1)
    
    # Generate subject analytics for all subjects with sessions
    subjects_with_sessions = Subject.objects.filter(
        tutoring_sessions__scheduled_time__date__gte=first_day_last_month,
        tutoring_sessions__scheduled_time__date__lte=last_day_last_month
    ).distinct()
    
    for subject in subjects_with_sessions:
        # This will trigger the signals to create/update analytics
        TutoringSession.objects.filter(
            subject=subject,
            scheduled_time__date__gte=first_day_last_month,
            scheduled_time__date__lte=last_day_last_month
        ).first()  # Just need to trigger for one session
    
    # Generate institution analytics
    InstitutionAnalytic.objects.get_or_create(
        period_start=first_day_last_month,
        period_end=last_day_last_month
    )
    
    return f"Generated analytics for {first_day_last_month} to {last_day_last_month}"

@shared_task
def generate_student_risk_assessments():
    """Generate risk assessments for students based on their progress"""
    # This would be more complex in a real implementation, using ML models
    # Here's a simplified version
    
    # Get students with below average progress in the last month
    today = timezone.now().date()
    first_day_last_month = (today.replace(day=1) - timedelta(days=1)).replace(day=1)
    last_day_last_month = today.replace(day=1) - timedelta(days=1)
    
    # Get average progress metrics
    avg_metrics = StudentProgressMetric.objects.filter(
        period_start=first_day_last_month,
        period_end=last_day_last_month
    ).aggregate(
        avg_sessions=Avg('sessions_attended'),
        avg_hours=Avg('total_learning_hours')
    )
    
    if not avg_metrics['avg_sessions']:
        return "No student progress metrics found for risk assessment"
    
    # Find students below average
    at_risk_students = StudentProgressMetric.objects.filter(
        period_start=first_day_last_month,
        period_end=last_day_last_month,
        sessions_attended__lt=avg_metrics['avg_sessions'] * 0.5,  # 50% below average
        total_learning_hours__lt=avg_metrics['avg_hours'] * 0.5
    )
    
    # Create risk assessments (simplified)
    for metric in at_risk_students:
        StudentRiskAssessment.objects.update_or_create(
            student=metric.student,
            subject=metric.subject,
            assessed_at__date=today,
            defaults={
                'risk_level': 'high',
                'risk_score': 0.8,  # Simplified
                'contributing_factors': {
                    'low_session_attendance': True,
                    'low_learning_hours': True
                },
                'model': PredictiveModel.objects.filter(
                    model_type='at_risk'
                ).first()
            }
        )
    
    return f"Generated risk assessments for {at_risk_students.count()} students"
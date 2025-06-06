# analytics/signals.py

from django.db.models.signals import post_save
from django.dispatch import receiver
from django.utils import timezone
from datetime import timedelta
from tutoring.models import TutoringSession, SessionFeedback
from .models import (
    InstitutionAnalytic,
    SubjectAnalytic,
    TutorPerformanceMetric,
    StudentProgressMetric
)

@receiver(post_save, sender=TutoringSession)
def update_analytics_on_session(sender, instance, created, **kwargs):
    if created:
        # Update subject analytics
        update_subject_analytics(instance.subject)
        
        # Update tutor performance metrics
        update_tutor_metrics(instance.tutor, instance.subject)
        
        # Update institution analytics
        update_institution_analytics()

@receiver(post_save, sender=SessionFeedback)
def update_analytics_on_feedback(sender, instance, created, **kwargs):
    if created:
        session = instance.session
        # Update subject analytics with new feedback
        update_subject_analytics(session.subject)
        
        # Update tutor metrics with new feedback
        update_tutor_metrics(session.tutor, session.subject)
        
        # Update student progress with feedback given
        update_student_progress(session.student, session.subject)

def update_subject_analytics(subject):
    # Get or create current month's analytics for the subject
    today = timezone.now().date()
    first_day = today.replace(day=1)
    last_day = (first_day + timedelta(days=32)).replace(day=1) - timedelta(days=1)
    
    analytic, created = SubjectAnalytic.objects.get_or_create(
        subject=subject,
        period_start=first_day,
        period_end=last_day,
        defaults={
            'total_sessions': 0,
            'total_tutoring_hours': 0,
            'active_tutors': 0,
            'active_students': 0,
        }
    )
    
    # Update session counts and hours
    sessions = TutoringSession.objects.filter(
        subject=subject,
        scheduled_time__date__gte=first_day,
        scheduled_time__date__lte=last_day
    )
    
    analytic.total_sessions = sessions.count()
    analytic.total_tutoring_hours = sum(
        float(s.duration_hours) for s in sessions if s.duration_hours
    )
    
    # Update active participants
    analytic.active_tutors = sessions.values('tutor').distinct().count()
    analytic.active_students = sessions.values('student').distinct().count()
    
    # Calculate student to tutor ratio
    if analytic.active_tutors > 0:
        analytic.student_to_tutor_ratio = analytic.active_students / analytic.active_tutors
    
    # Update feedback metrics if available
    feedbacks = SessionFeedback.objects.filter(
        session__subject=subject,
        created_at__date__gte=first_day,
        created_at__date__lte=last_day
    )
    
    if feedbacks.exists():
        analytic.average_session_rating = feedbacks.aggregate(
            avg=Avg('overall_rating')
        )['avg']
        analytic.feedback_response_rate = (
            feedbacks.count() / analytic.total_sessions * 100
            if analytic.total_sessions > 0 else 0
        )
    
    analytic.save()

def update_tutor_metrics(tutor, subject):
    # Get or create current month's metrics for the tutor
    today = timezone.now().date()
    first_day = today.replace(day=1)
    last_day = (first_day + timedelta(days=32)).replace(day=1) - timedelta(days=1)
    
    metric, created = TutorPerformanceMetric.objects.get_or_create(
        tutor=tutor,
        subject=subject,
        period_start=first_day,
        period_end=last_day,
        defaults={
            'sessions_conducted': 0,
            'total_tutoring_hours': 0,
            'average_rating': 0,
            'feedback_count': 0,
            'unique_students_helped': 0,
            'repeat_students': 0,
        }
    )
    
    # Update session counts and hours
    sessions = TutoringSession.objects.filter(
        tutor=tutor,
        subject=subject,
        scheduled_time__date__gte=first_day,
        scheduled_time__date__lte=last_day,
        status='completed'
    )
    
    metric.sessions_conducted = sessions.count()
    metric.total_tutoring_hours = sum(
        float(s.duration_hours) for s in sessions if s.duration_hours
    )
    
    # Update student counts
    student_counts = sessions.values('student').annotate(count=Count('id'))
    metric.unique_students_helped = student_counts.count()
    metric.repeat_students = sum(1 for sc in student_counts if sc['count'] > 1)
    
    # Update feedback metrics
    feedbacks = SessionFeedback.objects.filter(
        session__tutor=tutor,
        session__subject=subject,
        created_at__date__gte=first_day,
        created_at__date__lte=last_day
    )
    
    if feedbacks.exists():
        metric.feedback_count = feedbacks.count()
        metric.average_rating = feedbacks.aggregate(
            avg=Avg('overall_rating')
        )['avg']
    
    metric.save()

def update_student_progress(student, subject):
    # Get or create current month's progress for the student
    today = timezone.now().date()
    first_day = today.replace(day=1)
    last_day = (first_day + timedelta(days=32)).replace(day=1) - timedelta(days=1)
    
    progress, created = StudentProgressMetric.objects.get_or_create(
        student=student,
        subject=subject,
        period_start=first_day,
        period_end=last_day,
        defaults={
            'sessions_attended': 0,
            'total_learning_hours': 0,
            'questions_asked': 0,
            'feedback_given_count': 0,
            'self_reported_confidence': 0,
            'self_reported_understanding': 0,
        }
    )
    
    # Update session attendance and hours
    sessions = TutoringSession.objects.filter(
        student=student,
        subject=subject,
        scheduled_time__date__gte=first_day,
        scheduled_time__date__lte=last_day,
        status='completed'
    )
    
    progress.sessions_attended = sessions.count()
    progress.total_learning_hours = sum(
        float(s.duration_hours) for s in sessions if s.duration_hours
    )
    
    # Update feedback given count
    feedbacks = SessionFeedback.objects.filter(
        student=student,
        created_at__date__gte=first_day,
        created_at__date__lte=last_day
    )
    progress.feedback_given_count = feedbacks.count()
    
    # TODO: Update questions asked from forum or Q&A features
    
    progress.save()

def update_institution_analytics():
    # Get or create current month's institution analytics
    today = timezone.now().date()
    first_day = today.replace(day=1)
    last_day = (first_day + timedelta(days=32)).replace(day=1) - timedelta(days=1)
    
    analytic, created = InstitutionAnalytic.objects.get_or_create(
        period_start=first_day,
        period_end=last_day,
        defaults={
            'active_subjects': 0,
            'total_sessions': 0,
            'total_tutoring_hours': 0,
            'active_instructors': 0,
            'active_tutors': 0,
            'active_students': 0,
            'student_participation_rate': 0,
        }
    )
    
    # Update subject counts
    analytic.active_subjects = SubjectAnalytic.objects.filter(
        period_start=first_day,
        period_end=last_day,
        total_sessions__gt=0
    ).count()
    
    # Update session counts and hours from subject analytics
    subject_analytics = SubjectAnalytic.objects.filter(
        period_start=first_day,
        period_end=last_day
    ).aggregate(
        total_sessions=Sum('total_sessions'),
        total_hours=Sum('total_tutoring_hours'),
        avg_rating=Avg('average_session_rating')
    )
    
    analytic.total_sessions = subject_analytics['total_sessions'] or 0
    analytic.total_tutoring_hours = subject_analytics['total_hours'] or 0
    analytic.average_session_rating = subject_analytics['avg_rating'] or 0
    
    # TODO: Update active user counts from user models
    
    analytic.save()
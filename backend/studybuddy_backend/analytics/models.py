# analytics/models.py

from django.db import models
from django.conf import settings
from django.utils import timezone

User = settings.AUTH_USER_MODEL

class TutorPerformanceMetric(models.Model):
    """Model for tracking tutor performance metrics."""
    
    tutor = models.ForeignKey(User, on_delete=models.CASCADE, related_name='performance_metrics')
    subject = models.ForeignKey('tutoring.Subject', on_delete=models.CASCADE, related_name='tutor_metrics')
    
    # Time period
    period_start = models.DateField()
    period_end = models.DateField()
    
    # Sessions metrics
    sessions_conducted = models.IntegerField(default=0)
    total_tutoring_hours = models.DecimalField(max_digits=6, decimal_places=2, default=0)
    
    # Feedback metrics
    average_rating = models.DecimalField(max_digits=3, decimal_places=2, default=0)
    feedback_count = models.IntegerField(default=0)
    
    # Student metrics
    unique_students_helped = models.IntegerField(default=0)
    repeat_students = models.IntegerField(default=0)
    
    # Timestamps
    last_updated = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name = 'Tutor Performance Metric'
        verbose_name_plural = 'Tutor Performance Metrics'
        unique_together = ['tutor', 'subject', 'period_start', 'period_end']
    
    def __str__(self):
        return f"{self.tutor} - {self.subject} ({self.period_start} to {self.period_end})"


class StudentProgressMetric(models.Model):
    """Model for tracking student progress metrics."""
    
    student = models.ForeignKey(User, on_delete=models.CASCADE, related_name='progress_metrics')
    subject = models.ForeignKey('tutoring.Subject', on_delete=models.CASCADE, related_name='student_metrics')
    
    # Time period
    period_start = models.DateField()
    period_end = models.DateField()
    
    # Session metrics
    sessions_attended = models.IntegerField(default=0)
    total_learning_hours = models.DecimalField(max_digits=6, decimal_places=2, default=0)
    
    # Engagement metrics
    questions_asked = models.IntegerField(default=0)
    feedback_given_count = models.IntegerField(default=0)
    
    # Progress indicators
    self_reported_confidence = models.DecimalField(max_digits=3, decimal_places=2, default=0)
    self_reported_understanding = models.DecimalField(max_digits=3, decimal_places=2, default=0)
    
    # Timestamps
    last_updated = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name = 'Student Progress Metric'
        verbose_name_plural = 'Student Progress Metrics'
        unique_together = ['student', 'subject', 'period_start', 'period_end']
    
    def __str__(self):
        return f"{self.student} - {self.subject} ({self.period_start} to {self.period_end})"


class SubjectAnalytic(models.Model):
    """Model for tracking analytics at the subject level."""
    
    subject = models.ForeignKey('tutoring.Subject', on_delete=models.CASCADE, related_name='analytics')
    
    # Time period
    period_start = models.DateField()
    period_end = models.DateField()
    
    # Session metrics
    total_sessions = models.IntegerField(default=0)
    total_tutoring_hours = models.DecimalField(max_digits=8, decimal_places=2, default=0)
    average_session_duration = models.DecimalField(max_digits=5, decimal_places=2, default=0)
    
    # Participation metrics
    active_tutors = models.IntegerField(default=0)
    active_students = models.IntegerField(default=0)
    student_to_tutor_ratio = models.DecimalField(max_digits=5, decimal_places=2, default=0)
    
    # Feedback metrics
    average_session_rating = models.DecimalField(max_digits=3, decimal_places=2, default=0)
    feedback_response_rate = models.DecimalField(max_digits=5, decimal_places=2, default=0)
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    last_updated = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name = 'Subject Analytic'
        verbose_name_plural = 'Subject Analytics'
        unique_together = ['subject', 'period_start', 'period_end']
    
    def __str__(self):
        return f"{self.subject} Analytics ({self.period_start} to {self.period_end})"


class InstitutionAnalytic(models.Model):
    """Model for tracking analytics at the institution level."""
    
    # Time period
    period_start = models.DateField()
    period_end = models.DateField()
    
    # Program metrics
    active_subjects = models.IntegerField(default=0)
    total_sessions = models.IntegerField(default=0)
    total_tutoring_hours = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    
    # Participation metrics
    active_instructors = models.IntegerField(default=0)
    active_tutors = models.IntegerField(default=0)
    active_students = models.IntegerField(default=0)
    student_participation_rate = models.DecimalField(max_digits=5, decimal_places=2, default=0)
    
    # Feedback metrics
    average_session_rating = models.DecimalField(max_digits=3, decimal_places=2, default=0)
    average_tutor_rating = models.DecimalField(max_digits=3, decimal_places=2, default=0)
    average_content_rating = models.DecimalField(max_digits=3, decimal_places=2, default=0)
    
    # Gamification metrics
    points_awarded = models.IntegerField(default=0)
    achievements_unlocked = models.IntegerField(default=0)
    rewards_redeemed = models.IntegerField(default=0)
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    last_updated = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name = 'Institution Analytic'
        verbose_name_plural = 'Institution Analytics'
        unique_together = ['period_start', 'period_end']
    
    def __str__(self):
        return f"Institution Analytics ({self.period_start} to {self.period_end})"


class PredictiveModel(models.Model):
    """Model for storing and tracking predictive models for student outcomes."""
    
    MODEL_TYPES = (
        ('at_risk', 'At-Risk Student Identification'),
        ('subject_performance', 'Subject Performance Prediction'),
        ('tutor_matching', 'Optimal Tutor Matching'),
        ('session_recommendation', 'Session Recommendation'),
        ('other', 'Other'),
    )
    
    name = models.CharField(max_length=100)
    model_type = models.CharField(max_length=30, choices=MODEL_TYPES)
    description = models.TextField()
    
    # Model parameters (stored as JSON)
    parameters = models.JSONField(default=dict)
    
    # Model performance metrics
    accuracy = models.DecimalField(max_digits=5, decimal_places=4, null=True, blank=True)
    f1_score = models.DecimalField(max_digits=5, decimal_places=4, null=True, blank=True)
    precision = models.DecimalField(max_digits=5, decimal_places=4, null=True, blank=True)
    recall = models.DecimalField(max_digits=5, decimal_places=4, null=True, blank=True)
    
    # Timestamps
    trained_on = models.DateTimeField()
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name = 'Predictive Model'
        verbose_name_plural = 'Predictive Models'
    
    def __str__(self):
        return f"{self.name} ({self.model_type})"


class StudentRiskAssessment(models.Model):
    """Model for storing risk assessments for students."""
    
    RISK_LEVELS = (
        ('low', 'Low Risk'),
        ('medium', 'Medium Risk'),
        ('high', 'High Risk'),
    )
    
    student = models.ForeignKey(User, on_delete=models.CASCADE, related_name='risk_assessments')
    subject = models.ForeignKey('tutoring.Subject', on_delete=models.CASCADE, related_name='risk_assessments')
    
    # Risk assessment
    risk_level = models.CharField(max_length=10, choices=RISK_LEVELS)
    risk_score = models.DecimalField(max_digits=5, decimal_places=2)
    
    # Contributing factors (stored as JSON)
    contributing_factors = models.JSONField(default=dict)
    
    # Model used
    model = models.ForeignKey(PredictiveModel, on_delete=models.CASCADE, related_name='assessments')
    
    # Timestamps
    assessed_at = models.DateTimeField(default=timezone.now)
    
    class Meta:
        verbose_name = 'Student Risk Assessment'
        verbose_name_plural = 'Student Risk Assessments'
    
    def __str__(self):
        return f"{self.student} - {self.subject}: {self.risk_level}"


class RecommendedAction(models.Model):
    """Model for recommended actions based on analytics."""
    
    ACTION_TYPES = (
        ('tutoring_session', 'Attend Tutoring Session'),
        ('tutor_assignment', 'Assign as Tutor'),
        ('material_review', 'Review Learning Material'),
        ('instructor_meeting', 'Meet with Instructor'),
        ('peer_collaboration', 'Collaborate with Peers'),
        ('other', 'Other'),
    )
    
    student = models.ForeignKey(User, on_delete=models.CASCADE, related_name='recommended_actions')
    subject = models.ForeignKey('tutoring.Subject', on_delete=models.CASCADE, related_name='recommended_actions')
    
    # Action details
    action_type = models.CharField(max_length=30, choices=ACTION_TYPES)
    description = models.TextField()
    priority = models.IntegerField(default=1)  # 1 = highest priority
    
    # Related resources
    related_session = models.ForeignKey('tutoring.TutoringSession', on_delete=models.SET_NULL, null=True, blank=True)
    related_tutor = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name='tutor_recommendations')
    related_material = models.ForeignKey('tutoring.LearningMaterial', on_delete=models.SET_NULL, null=True, blank=True)
    
    # Source of recommendation
    based_on_risk_assessment = models.ForeignKey(StudentRiskAssessment, on_delete=models.SET_NULL, null=True, blank=True)
    
    # Status
    is_completed = models.BooleanField(default=False)
    completed_at = models.DateTimeField(null=True, blank=True)
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField(null=True, blank=True)
    
    class Meta:
        verbose_name = 'Recommended Action'
        verbose_name_plural = 'Recommended Actions'
    
    def __str__(self):
        return f"{self.student} - {self.subject}: {self.action_type}"
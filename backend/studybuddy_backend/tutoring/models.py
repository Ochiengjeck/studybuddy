# tutoring/models.py

from django.db import models
from django.conf import settings
from django.utils import timezone

User = settings.AUTH_USER_MODEL

class Subject(models.Model):
    """Model for academic subjects."""
    
    name = models.CharField(max_length=100)
    code = models.CharField(max_length=20, unique=True)
    description = models.TextField(blank=True)
    
    class Meta:
        verbose_name = 'Subject'
        verbose_name_plural = 'Subjects'
        ordering = ['name']
    
    def __str__(self):
        return f"{self.code} - {self.name}"


class TutorApplication(models.Model):
    """Model for tutor applications submitted by students."""
    
    STATUS_CHOICES = (
        ('pending', 'Pending'),
        ('approved', 'Approved'),
        ('rejected', 'Rejected'),
    )
    
    student = models.ForeignKey(User, on_delete=models.CASCADE, related_name='tutor_applications')
    subject = models.ForeignKey(Subject, on_delete=models.CASCADE, related_name='tutor_applications')
    instructor = models.ForeignKey(User, on_delete=models.CASCADE, related_name='received_tutor_applications')
    
    # Application details
    motivation = models.TextField()
    qualifications = models.TextField()
    grade = models.CharField(max_length=10, help_text="Previous grade in this subject")
    
    # Status and review
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    instructor_feedback = models.TextField(blank=True)
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name = 'Tutor Application'
        verbose_name_plural = 'Tutor Applications'
        unique_together = ['student', 'subject']
    
    def __str__(self):
        return f"{self.student} - {self.subject} ({self.status})"


class Tutor(models.Model):
    """Model for approved tutors."""
    
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='tutor_roles')
    subject = models.ForeignKey(Subject, on_delete=models.CASCADE, related_name='tutors')
    approved_by = models.ForeignKey(User, on_delete=models.CASCADE, related_name='approved_tutors')
    
    # Tutor details
    bio = models.TextField(blank=True)
    expertise_level = models.CharField(max_length=50, blank=True)
    hourly_availability = models.IntegerField(default=5, help_text="Hours available per week")
    
    # Rating
    average_rating = models.DecimalField(max_digits=3, decimal_places=2, default=0.0)
    rating_count = models.IntegerField(default=0)
    
    # Status
    is_active = models.BooleanField(default=True)
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name = 'Tutor'
        verbose_name_plural = 'Tutors'
        unique_together = ['user', 'subject']
    
    def __str__(self):
        return f"{self.user} - {self.subject}"


class LearningMaterial(models.Model):
    """Model for standardized learning materials uploaded by instructors."""
    
    TYPE_CHOICES = (
        ('document', 'Document'),
        ('video', 'Video'),
        ('quiz', 'Quiz'),
        ('assignment', 'Assignment'),
        ('other', 'Other'),
    )
    
    subject = models.ForeignKey(Subject, on_delete=models.CASCADE, related_name='learning_materials')
    instructor = models.ForeignKey(User, on_delete=models.CASCADE, related_name='uploaded_materials')
    
    # Material details
    title = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    material_type = models.CharField(max_length=20, choices=TYPE_CHOICES)
    file = models.FileField(upload_to='learning_materials/')
    url = models.URLField(blank=True, null=True)
    
    # Metadata
    is_published = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name = 'Learning Material'
        verbose_name_plural = 'Learning Materials'
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.title} ({self.material_type})"


class TutoringSession(models.Model):
    """Model for tutoring sessions."""
    
    SESSION_TYPE_CHOICES = (
        ('one_on_one', 'One-on-One'),
        ('group', 'Group'),
    )
    
    SESSION_STATUS_CHOICES = (
        ('scheduled', 'Scheduled'),
        ('ongoing', 'Ongoing'),
        ('completed', 'Completed'),
        ('cancelled', 'Cancelled'),
    )
    
    MODE_CHOICES = (
        ('video', 'Video'),
        ('audio', 'Audio'),
        ('text', 'Text'),
    )
    
    # Session basics
    tutor = models.ForeignKey(User, on_delete=models.CASCADE, related_name='tutoring_sessions')
    subject = models.ForeignKey(Subject, on_delete=models.CASCADE, related_name='tutoring_sessions')
    session_type = models.CharField(max_length=20, choices=SESSION_TYPE_CHOICES)
    
    # Schedule
    scheduled_start = models.DateTimeField()
    scheduled_end = models.DateTimeField()
    actual_start = models.DateTimeField(null=True, blank=True)
    actual_end = models.DateTimeField(null=True, blank=True)
    
    # Session details
    topic = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    session_mode = models.CharField(max_length=20, choices=MODE_CHOICES, default='video')
    meeting_link = models.URLField(blank=True, null=True)
    max_participants = models.IntegerField(default=1)
    
    # Status
    status = models.CharField(max_length=20, choices=SESSION_STATUS_CHOICES, default='scheduled')
    
    # Learning materials
    materials = models.ManyToManyField(LearningMaterial, blank=True, related_name='used_in_sessions')
    
    # Supervision
    supervised_by = models.ForeignKey(
        User, 
        on_delete=models.SET_NULL, 
        null=True, 
        blank=True, 
        related_name='supervised_sessions'
    )
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name = 'Tutoring Session'
        verbose_name_plural = 'Tutoring Sessions'
        ordering = ['-scheduled_start']
    
    def __str__(self):
        return f"{self.subject} - {self.topic} ({self.scheduled_start.strftime('%Y-%m-%d %H:%M')})"
    
    @property
    def is_upcoming(self):
        """Check if the session is upcoming."""
        return self.scheduled_start > timezone.now()
    
    @property
    def duration_minutes(self):
        """Get the scheduled duration in minutes."""
        delta = self.scheduled_end - self.scheduled_start
        return delta.total_seconds() / 60


class SessionParticipant(models.Model):
    """Model for tutoring session participants (tutees)."""
    
    ATTENDANCE_STATUS_CHOICES = (
        ('registered', 'Registered'),
        ('attended', 'Attended'),
        ('absent', 'Absent'),
    )
    
    session = models.ForeignKey(TutoringSession, on_delete=models.CASCADE, related_name='participants')
    student = models.ForeignKey(User, on_delete=models.CASCADE, related_name='attended_sessions')
    
    # Attendance
    attendance_status = models.CharField(max_length=20, choices=ATTENDANCE_STATUS_CHOICES, default='registered')
    join_time = models.DateTimeField(null=True, blank=True)
    leave_time = models.DateTimeField(null=True, blank=True)
    
    # Feedback
    feedback_given = models.BooleanField(default=False)
    
    class Meta:
        verbose_name = 'Session Participant'
        verbose_name_plural = 'Session Participants'
        unique_together = ['session', 'student']
    
    def __str__(self):
        return f"{self.student} - {self.session}"


class SessionFeedback(models.Model):
    """Model for feedback on tutoring sessions."""
    
    session = models.ForeignKey(TutoringSession, on_delete=models.CASCADE, related_name='feedback')
    participant = models.ForeignKey(User, on_delete=models.CASCADE, related_name='given_feedback')
    
    # Ratings (1-5 scale)
    tutor_rating = models.IntegerField()
    content_rating = models.IntegerField()
    overall_rating = models.IntegerField()
    
    # Comments
    comments = models.TextField(blank=True)
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        verbose_name = 'Session Feedback'
        verbose_name_plural = 'Session Feedback'
        unique_together = ['session', 'participant']
    
    def __str__(self):
        return f"{self.participant} - {self.session} - {self.overall_rating}/5"


class SessionReport(models.Model):
    """Model for tutoring session reports submitted by tutors."""
    
    session = models.OneToOneField(TutoringSession, on_delete=models.CASCADE, related_name='report')
    tutor = models.ForeignKey(User, on_delete=models.CASCADE, related_name='submitted_reports')
    
    # Report details
    topics_covered = models.TextField()
    challenges = models.TextField(blank=True)
    recommendations = models.TextField(blank=True)
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    # Instructor review
    reviewed_by = models.ForeignKey(
        User, 
        on_delete=models.SET_NULL, 
        null=True, 
        blank=True, 
        related_name='reviewed_reports'
    )
    instructor_comments = models.TextField(blank=True)
    
    class Meta:
        verbose_name = 'Session Report'
        verbose_name_plural = 'Session Reports'
    
    def __str__(self):
        return f"Report: {self.session}"
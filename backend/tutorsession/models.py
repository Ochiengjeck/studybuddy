from django.db import models
from users.models import CustomUser
import uuid
from django.utils import timezone

class Session(models.Model):
    class Status(models.TextChoices):
        UPCOMING = 'upcoming', 'Upcoming'
        COMPLETED = 'completed', 'Completed'
        PENDING = 'pending', 'Pending'
        DECLINED = 'declined', 'Declined'
        IN_PROGRESS = 'in_progress', 'In Progress'

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    title = models.CharField(max_length=100)
    tutor = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name='tutor_sessions')
    tutor_name = models.CharField(max_length=100)
    tutor_image = models.ImageField(upload_to='profile_pics/', blank=True, null=True)
    platform = models.CharField(max_length=50, default='Google Meet')
    start_time = models.DateTimeField()
    duration = models.DurationField()
    description = models.TextField(blank=True)
    status = models.CharField(max_length=20, choices=Status.choices, default=Status.PENDING)
    rating = models.FloatField(null=True, blank=True)
    participant_images = models.JSONField(default=list)
    is_current_user = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.title} - {self.tutor_name} ({self.status})"

from django.db import models
from users.models import CustomUser
import uuid

class Achievement(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name='achievements')
    title = models.CharField(max_length=100)
    description = models.TextField()
    icon = models.CharField(max_length=50, default='emoji_events')
    earned = models.BooleanField(default=False)
    progress = models.FloatField(default=0.0)
    earned_date = models.DateTimeField(null=True, blank=True)
    points = models.IntegerField(default=0)

    def __str__(self):
        return f"{self.title} for {self.user.email}"

class UserStats(models.Model):
    user = models.OneToOneField(CustomUser, on_delete=models.CASCADE, related_name='stats')
    sessions_completed = models.IntegerField(default=0)
    points_earned = models.IntegerField(default=0)
    badges_earned = models.IntegerField(default=0)
    average_rating = models.FloatField(default=0.0)
    upcoming_sessions = models.IntegerField(default=0)
    pending_sessions = models.IntegerField(default=0)

    def __str__(self):
        return f"Stats for {self.user.email}"
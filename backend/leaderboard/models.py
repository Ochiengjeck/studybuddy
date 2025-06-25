from django.db import models
from users.models import CustomUser
import uuid

class LeaderboardUser(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name='leaderboard_entries')
    name = models.CharField(max_length=100)
    subject = models.CharField(max_length=50, blank=True, null=True)
    points = models.IntegerField(default=0)
    position = models.IntegerField(default=0)
    profile_picture = models.ImageField(upload_to='profile_pics/', blank=True, null=True)
    is_current_user = models.BooleanField(default=False)

    def __str__(self):
        return f"{self.name} - {self.points} points"
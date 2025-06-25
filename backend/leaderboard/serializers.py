from rest_framework import serializers
from .models import LeaderboardUser

class LeaderboardUserSerializer(serializers.ModelSerializer):
    class Meta:
        model = LeaderboardUser
        fields = ('id', 'name', 'subject', 'points', 'position', 'profile_picture', 'is_current_user')
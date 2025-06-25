from rest_framework import serializers
from .models import Achievement, UserStats

class AchievementSerializer(serializers.ModelSerializer):
    class Meta:
        model = Achievement
        fields = ('id', 'title', 'description', 'icon', 'earned', 'progress', 'earned_date', 'points')

class UserStatsSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserStats
        fields = (
            'sessions_completed', 'points_earned', 'badges_earned',
            'average_rating', 'upcoming_sessions', 'pending_sessions'
        )
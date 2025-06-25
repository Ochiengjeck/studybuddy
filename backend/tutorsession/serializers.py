from rest_framework import serializers
from .models import Session

class SessionSerializer(serializers.ModelSerializer):
    participant_images = serializers.ListField(child=serializers.CharField(), default=[])
    duration_minutes = serializers.SerializerMethodField()

    class Meta:
        model = Session
        fields = (
            'id', 'title', 'tutor_name', 'tutor_image', 'platform', 'start_time',
            'duration_minutes', 'description', 'status', 'rating', 'participant_images',
            'is_current_user'
        )

    def get_duration_minutes(self, obj):
        return int(obj.duration.total_seconds() / 60)

class FeedbackSerializer(serializers.Serializer):
    rating = serializers.IntegerField(min_value=1, max_value=5)
    review = serializers.CharField(max_length=500)

class RescheduleSerializer(serializers.Serializer):
    new_time = serializers.DateTimeField()
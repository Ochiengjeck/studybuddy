# tutoring/serializers.py

from rest_framework import serializers
from .models import (
    Subject,
    TutorApplication,
    Tutor,
    LearningMaterial,
    TutoringSession,
    SessionParticipant,
    SessionFeedback,
    SessionReport
)
from users.serializers import UserSerializer

class SubjectSerializer(serializers.ModelSerializer):
    class Meta:
        model = Subject
        fields = '__all__'

class TutorApplicationSerializer(serializers.ModelSerializer):
    student = UserSerializer(read_only=True)
    subject = SubjectSerializer(read_only=True)
    instructor = UserSerializer(read_only=True)
    
    class Meta:
        model = TutorApplication
        fields = '__all__'
        read_only_fields = ('created_at', 'updated_at', 'status')

class TutorSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    subject = SubjectSerializer(read_only=True)
    approved_by = UserSerializer(read_only=True)
    
    class Meta:
        model = Tutor
        fields = '__all__'
        read_only_fields = ('created_at', 'updated_at', 'average_rating', 'rating_count')

class LearningMaterialSerializer(serializers.ModelSerializer):
    subject = SubjectSerializer(read_only=True)
    instructor = UserSerializer(read_only=True)
    file_url = serializers.SerializerMethodField()
    
    class Meta:
        model = LearningMaterial
        fields = '__all__'
        read_only_fields = ('created_at', 'updated_at')
    
    def get_file_url(self, obj):
        if obj.file:
            return self.context['request'].build_absolute_uri(obj.file.url)
        return None

class TutoringSessionSerializer(serializers.ModelSerializer):
    tutor = UserSerializer(read_only=True)
    subject = SubjectSerializer(read_only=True)
    supervised_by = UserSerializer(read_only=True)
    materials = LearningMaterialSerializer(many=True, read_only=True)
    participants = serializers.SerializerMethodField()
    meeting_link = serializers.SerializerMethodField()
    
    class Meta:
        model = TutoringSession
        fields = '__all__'
        read_only_fields = ('created_at', 'updated_at', 'actual_start', 'actual_end', 'status')
    
    def get_participants(self, obj):
        return obj.participants.count()
    
    def get_meeting_link(self, obj):
        # Generate meeting link logic here
        if obj.session_mode == 'video':
            return f"https://meet.example.com/{obj.id}"
        return None

class SessionParticipantSerializer(serializers.ModelSerializer):
    student = UserSerializer(read_only=True)
    session = TutoringSessionSerializer(read_only=True)
    
    class Meta:
        model = SessionParticipant
        fields = '__all__'
        read_only_fields = ('join_time', 'leave_time', 'feedback_given')

class SessionFeedbackSerializer(serializers.ModelSerializer):
    participant = UserSerializer(read_only=True)
    session = TutoringSessionSerializer(read_only=True)
    
    class Meta:
        model = SessionFeedback
        fields = '__all__'
        read_only_fields = ('created_at',)

class SessionReportSerializer(serializers.ModelSerializer):
    tutor = UserSerializer(read_only=True)
    session = TutoringSessionSerializer(read_only=True)
    reviewed_by = UserSerializer(read_only=True)
    
    class Meta:
        model = SessionReport
        fields = '__all__'
        read_only_fields = ('created_at', 'updated_at')
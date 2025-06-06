# analytics/serializers.py

from rest_framework import serializers
from .models import (
    InstitutionAnalytic,
    SubjectAnalytic,
    TutorPerformanceMetric,
    StudentProgressMetric,
    StudentRiskAssessment,
    RecommendedAction,
    PredictiveModel
)
from tutoring.serializers import SubjectSerializer
from users.serializers import UserSerializer

class InstitutionAnalyticSerializer(serializers.ModelSerializer):
    class Meta:
        model = InstitutionAnalytic
        fields = '__all__'

class SubjectAnalyticSerializer(serializers.ModelSerializer):
    subject = SubjectSerializer(read_only=True)
    
    class Meta:
        model = SubjectAnalytic
        fields = '__all__'

class TutorPerformanceMetricSerializer(serializers.ModelSerializer):
    tutor = UserSerializer(read_only=True)
    subject = SubjectSerializer(read_only=True)
    
    class Meta:
        model = TutorPerformanceMetric
        fields = '__all__'

class StudentProgressMetricSerializer(serializers.ModelSerializer):
    student = UserSerializer(read_only=True)
    subject = SubjectSerializer(read_only=True)
    
    class Meta:
        model = StudentProgressMetric
        fields = '__all__'

class StudentRiskAssessmentSerializer(serializers.ModelSerializer):
    student = UserSerializer(read_only=True)
    subject = SubjectSerializer(read_only=True)
    model = serializers.StringRelatedField()
    
    class Meta:
        model = StudentRiskAssessment
        fields = '__all__'

class RecommendedActionSerializer(serializers.ModelSerializer):
    student = UserSerializer(read_only=True)
    subject = SubjectSerializer(read_only=True)
    related_session = serializers.StringRelatedField()
    related_tutor = UserSerializer(read_only=True)
    related_material = serializers.StringRelatedField()
    based_on_risk_assessment = StudentRiskAssessmentSerializer(read_only=True)
    
    class Meta:
        model = RecommendedAction
        fields = '__all__'

class PredictiveModelSerializer(serializers.ModelSerializer):
    class Meta:
        model = PredictiveModel
        fields = '__all__'
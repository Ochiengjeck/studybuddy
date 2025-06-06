# analytics/admin.py

from django.contrib import admin
from .models import (
    InstitutionAnalytic,
    SubjectAnalytic,
    TutorPerformanceMetric,
    StudentProgressMetric,
    StudentRiskAssessment,
    RecommendedAction,
    PredictiveModel
)

@admin.register(InstitutionAnalytic)
class InstitutionAnalyticAdmin(admin.ModelAdmin):
    list_display = ('period_start', 'period_end', 'active_subjects', 'total_sessions', 'total_tutoring_hours')
    list_filter = ('period_start', 'period_end')
    search_fields = ('period_start', 'period_end')
    ordering = ('-period_end',)

@admin.register(SubjectAnalytic)
class SubjectAnalyticAdmin(admin.ModelAdmin):
    list_display = ('subject', 'period_start', 'period_end', 'total_sessions', 'average_session_rating')
    list_filter = ('subject', 'period_start', 'period_end')
    search_fields = ('subject__name',)
    ordering = ('-period_end', 'subject')

@admin.register(TutorPerformanceMetric)
class TutorPerformanceMetricAdmin(admin.ModelAdmin):
    list_display = ('tutor', 'subject', 'period_start', 'period_end', 'sessions_conducted', 'average_rating')
    list_filter = ('subject', 'period_start', 'period_end')
    search_fields = ('tutor__username', 'tutor__email', 'subject__name')
    ordering = ('-period_end', 'tutor')

@admin.register(StudentProgressMetric)
class StudentProgressMetricAdmin(admin.ModelAdmin):
    list_display = ('student', 'subject', 'period_start', 'period_end', 'sessions_attended', 'total_learning_hours')
    list_filter = ('subject', 'period_start', 'period_end')
    search_fields = ('student__username', 'student__email', 'subject__name')
    ordering = ('-period_end', 'student')

@admin.register(StudentRiskAssessment)
class StudentRiskAssessmentAdmin(admin.ModelAdmin):
    list_display = ('student', 'subject', 'risk_level', 'risk_score', 'assessed_at')
    list_filter = ('risk_level', 'subject', 'assessed_at')
    search_fields = ('student__username', 'student__email', 'subject__name')
    ordering = ('-assessed_at', 'student')

@admin.register(RecommendedAction)
class RecommendedActionAdmin(admin.ModelAdmin):
    list_display = ('student', 'subject', 'action_type', 'priority', 'is_completed', 'created_at')
    list_filter = ('action_type', 'priority', 'is_completed', 'subject')
    search_fields = ('student__username', 'student__email', 'subject__name')
    ordering = ('priority', '-created_at')

@admin.register(PredictiveModel)
class PredictiveModelAdmin(admin.ModelAdmin):
    list_display = ('name', 'model_type', 'accuracy', 'is_active', 'updated_at')
    list_filter = ('model_type', 'is_active')
    search_fields = ('name', 'description')
    ordering = ('-updated_at',)
# tutoring/admin.py

from django.contrib import admin
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

@admin.register(Subject)
class SubjectAdmin(admin.ModelAdmin):
    list_display = ('name', 'code')
    search_fields = ('name', 'code')

@admin.register(TutorApplication)
class TutorApplicationAdmin(admin.ModelAdmin):
    list_display = ('student', 'subject', 'status', 'created_at')
    list_filter = ('status', 'subject')
    search_fields = ('student__username', 'subject__name')

@admin.register(Tutor)
class TutorAdmin(admin.ModelAdmin):
    list_display = ('user', 'subject', 'is_active', 'average_rating')
    list_filter = ('subject', 'is_active')
    search_fields = ('user__username', 'subject__name')

@admin.register(LearningMaterial)
class LearningMaterialAdmin(admin.ModelAdmin):
    list_display = ('title', 'subject', 'material_type', 'is_published')
    list_filter = ('material_type', 'is_published', 'subject')
    search_fields = ('title', 'subject__name')

@admin.register(TutoringSession)
class TutoringSessionAdmin(admin.ModelAdmin):
    list_display = ('subject', 'tutor', 'scheduled_start', 'status')
    list_filter = ('status', 'subject', 'session_type')
    search_fields = ('tutor__username', 'subject__name', 'topic')

@admin.register(SessionParticipant)
class SessionParticipantAdmin(admin.ModelAdmin):
    list_display = ('student', 'session', 'attendance_status')
    list_filter = ('attendance_status',)
    search_fields = ('student__username', 'session__topic')

@admin.register(SessionFeedback)
class SessionFeedbackAdmin(admin.ModelAdmin):
    list_display = ('session', 'participant', 'overall_rating')
    list_filter = ('overall_rating',)
    search_fields = ('participant__username', 'session__topic')

@admin.register(SessionReport)
class SessionReportAdmin(admin.ModelAdmin):
    list_display = ('session', 'tutor', 'created_at')
    search_fields = ('tutor__username', 'session__topic')
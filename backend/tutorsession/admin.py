from django.contrib import admin
from .models import Session

@admin.register(Session)
class SessionAdmin(admin.ModelAdmin):
    list_display = ('title', 'tutor_name', 'start_time', 'status', 'rating')
    list_filter = ('status', 'platform')
    search_fields = ('title', 'tutor_name', 'description')
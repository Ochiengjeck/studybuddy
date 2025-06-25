from django.contrib import admin
from .models import Achievement, UserStats

@admin.register(Achievement)
class AchievementAdmin(admin.ModelAdmin):
    list_display = ('user', 'title', 'earned', 'progress', 'points', 'earned_date')
    list_filter = ('earned',)
    search_fields = ('title', 'description', 'user__email')

@admin.register(UserStats)
class UserStatsAdmin(admin.ModelAdmin):
    list_display = ('user', 'sessions_completed', 'points_earned', 'badges_earned', 'average_rating')
    search_fields = ('user__email',)
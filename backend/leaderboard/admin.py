from django.contrib import admin
from .models import LeaderboardUser

@admin.register(LeaderboardUser)
class LeaderboardUserAdmin(admin.ModelAdmin):
    list_display = ('user', 'name', 'subject', 'points', 'position', 'is_current_user')
    list_filter = ('subject', 'is_current_user')
    search_fields = ('name', 'user__email')
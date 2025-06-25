from django.contrib import admin
from .models import CustomUser, OtpToken

@admin.register(CustomUser)
class CustomUserAdmin(admin.ModelAdmin):
    list_display = ('email', 'first_name', 'last_name', 'is_active', 'is_verified', 'date_joined')
    list_filter = ('is_active', 'is_verified', 'user_type')
    search_fields = ('email', 'first_name', 'last_name')
    readonly_fields = ('date_joined', 'last_login')

@admin.register(OtpToken)
class OtpTokenAdmin(admin.ModelAdmin):
    list_display = ('user', 'otp', 'created_at', 'expires_at')
    search_fields = ('user__email', 'otp')
    readonly_fields = ('created_at', 'expires_at')
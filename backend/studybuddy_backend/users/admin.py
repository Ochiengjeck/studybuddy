# users/admin.py

from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from django.utils.translation import gettext_lazy as _
from .models import User, Student, Instructor


@admin.register(User)
class UserAdmin(BaseUserAdmin):
    """Custom admin view for User model"""
    
    list_display = ('email', 'name', 'firebase_uid', 'is_instructor', 
                    'is_tutor', 'points', 'is_staff', 'is_active')
    list_filter = ('is_instructor', 'is_tutor', 'is_staff', 'is_active')
    search_fields = ('email', 'name', 'firebase_uid')
    ordering = ('email',)
    
    fieldsets = (
        (None, {'fields': ('email', 'password')}),
        (_('Personal info'), {'fields': ('name', 'firebase_uid', 'profile_picture')}),
        (_('Roles'), {'fields': ('is_instructor', 'is_tutor')}),
        (_('Gamification'), {'fields': ('points',)}),
        (_('Permissions'), {'fields': ('is_active', 'is_staff', 'is_superuser',
                                       'groups', 'user_permissions')}),
        (_('Important dates'), {'fields': ('last_login', 'date_joined')}),
    )
    
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('email', 'password1', 'password2', 'name'),
        }),
    )


@admin.register(Student)
class StudentAdmin(admin.ModelAdmin):
    """Admin view for Student model"""
    
    list_display = ('get_name', 'student_id', 'institution', 'department', 'year_of_study')
    list_filter = ('institution', 'department', 'year_of_study')
    search_fields = ('user__email', 'user__name', 'student_id', 'institution')
    
    def get_name(self, obj):
        return obj.user.name or obj.user.email
    get_name.short_description = 'Name'
    get_name.admin_order_field = 'user__name'


@admin.register(Instructor)
class InstructorAdmin(admin.ModelAdmin):
    """Admin view for Instructor model"""
    
    list_display = ('get_name', 'employee_id', 'department', 'position')
    list_filter = ('department', 'position')
    search_fields = ('user__email', 'user__name', 'employee_id', 'department')
    filter_horizontal = ('subjects',)
    
    def get_name(self, obj):
        return obj.user.name or obj.user.email
    get_name.short_description = 'Name'
    get_name.admin_order_field = 'user__name'
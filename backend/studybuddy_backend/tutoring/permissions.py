# tutoring/permissions.py

from rest_framework import permissions

class IsTutor(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.role == 'tutor'

class IsStudent(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.role == 'student'

class IsInstructor(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.role == 'instructor'

class IsTutorOrInstructor(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.role in ['tutor', 'instructor']

class IsSessionTutor(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        return obj.tutor == request.user

class IsSessionParticipant(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        return obj.student == request.user
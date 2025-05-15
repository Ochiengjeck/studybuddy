# users/permissions.py

from rest_framework import permissions

class IsOwnerOrAdmin(permissions.BasePermission):
    """
    Custom permission to only allow owners of an object or admins to access it.
    """
    
    def has_object_permission(self, request, view, obj):
        # Admins have full access
        if request.user.is_staff or request.user.is_superuser:
            return True
            
        # Check if the object has a user attribute directly
        if hasattr(obj, 'user'):
            return obj.user == request.user
            
        # If the object is the user itself
        return obj == request.user


class IsInstructorOrReadOnly(permissions.BasePermission):
    """
    Custom permission to only allow instructors to edit but allow read access to everyone.
    """
    
    def has_permission(self, request, view):
        # Allow GET, HEAD, OPTIONS requests
        if request.method in permissions.SAFE_METHODS:
            return True
            
        # For write operations, check if user is instructor
        return request.user.is_authenticated and request.user.is_instructor


class IsTutorOrReadOnly(permissions.BasePermission):
    """
    Custom permission to only allow tutors to edit but allow read access to everyone.
    """
    
    def has_permission(self, request, view):
        # Allow GET, HEAD, OPTIONS requests
        if request.method in permissions.SAFE_METHODS:
            return True
            
        # For write operations, check if user is tutor
        return request.user.is_authenticated and request.user.is_tutor
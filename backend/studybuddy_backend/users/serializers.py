# users/serializers.py

from rest_framework import serializers
from django.contrib.auth import get_user_model
from .models import Student, Instructor

User = get_user_model()

class UserSerializer(serializers.ModelSerializer):
    """Serializer for the User model."""
    
    class Meta:
        model = User
        fields = [
            'id', 'email', 'name', 'profile_picture', 
            'is_instructor', 'is_tutor', 'points',
            'date_joined', 'last_login'
        ]
        read_only_fields = ['id', 'email', 'date_joined', 'last_login']


class UserDetailSerializer(serializers.ModelSerializer):
    """Detailed serializer for the User model."""
    
    class Meta:
        model = User
        fields = [
            'id', 'email', 'name', 'profile_picture', 
            'is_instructor', 'is_tutor', 'points',
            'date_joined', 'last_login'
        ]
        read_only_fields = ['id', 'email', 'date_joined', 'last_login']


class StudentSerializer(serializers.ModelSerializer):
    """Serializer for the Student model."""
    
    user = UserSerializer(read_only=True)
    
    class Meta:
        model = Student
        fields = ['id', 'user', 'student_id', 'institution', 'department', 'year_of_study']


class InstructorSerializer(serializers.ModelSerializer):
    """Serializer for the Instructor model."""
    
    user = UserSerializer(read_only=True)
    subjects = serializers.PrimaryKeyRelatedField(many=True, read_only=True)
    
    class Meta:
        model = Instructor
        fields = ['id', 'user', 'employee_id', 'department', 'position', 'subjects']


class CreateStudentProfileSerializer(serializers.ModelSerializer):
    """Serializer for creating a student profile."""
    
    class Meta:
        model = Student
        fields = ['student_id', 'institution', 'department', 'year_of_study']
    
    def create(self, validated_data):
        user = self.context['request'].user
        return Student.objects.create(user=user, **validated_data)


class CreateInstructorProfileSerializer(serializers.ModelSerializer):
    """Serializer for creating an instructor profile."""
    
    class Meta:
        model = Instructor
        fields = ['employee_id', 'department', 'position']
    
    def create(self, validated_data):
        user = self.context['request'].user
        user.is_instructor = True
        user.save()
        return Instructor.objects.create(user=user, **validated_data)


class UpdateUserProfileSerializer(serializers.ModelSerializer):
    """Serializer for updating user profile information."""
    
    class Meta:
        model = User
        fields = ['name', 'profile_picture']
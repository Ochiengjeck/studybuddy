# users/views.py

from rest_framework import viewsets, permissions, status, generics
from rest_framework.decorators import api_view, permission_classes, action
from rest_framework.response import Response
from rest_framework.views import APIView
from django.contrib.auth import get_user_model
from django.shortcuts import get_object_or_404

from .models import Student, Instructor
from .serializers import (
    UserSerializer, 
    UserDetailSerializer,
    StudentSerializer, 
    InstructorSerializer,
    CreateStudentProfileSerializer,
    CreateInstructorProfileSerializer,
    UpdateUserProfileSerializer
)

User = get_user_model()


class UserViewSet(viewsets.ModelViewSet):
    """
    API endpoint that allows users to be viewed or edited.
    """
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_serializer_class(self):
        if self.action == 'retrieve':
            return UserDetailSerializer
        return UserSerializer
    
    def get_queryset(self):
        # Regular users can only see their own profile
        # Staff/admin can see all users
        user = self.request.user
        if user.is_staff or user.is_superuser:
            return User.objects.all()
        return User.objects.filter(id=user.id)
    
    @action(detail=False, methods=['get'])
    def me(self, request):
        """Get the current user's profile"""
        serializer = UserDetailSerializer(request.user)
        return Response(serializer.data)
    
    @action(detail=False, methods=['patch', 'put'])
    def update_profile(self, request):
        """Update the current user's profile"""
        user = request.user
        serializer = UpdateUserProfileSerializer(user, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(UserDetailSerializer(user).data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class StudentViewSet(viewsets.ModelViewSet):
    """
    API endpoint that allows student profiles to be viewed or edited.
    """
    queryset = Student.objects.all()
    serializer_class = StudentSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        user = self.request.user
        if user.is_staff or user.is_superuser:
            return Student.objects.all()
        # Regular users can only see their own student profile if they have one
        return Student.objects.filter(user=user)


class InstructorViewSet(viewsets.ModelViewSet):
    """
    API endpoint that allows instructor profiles to be viewed or edited.
    """
    queryset = Instructor.objects.all()
    serializer_class = InstructorSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        user = self.request.user
        if user.is_staff or user.is_superuser:
            return Instructor.objects.all()
        # Regular users can only see their own instructor profile if they have one
        # or all instructors if they're students looking for instructors
        if hasattr(user, 'instructor_profile'):
            return Instructor.objects.filter(user=user)
        return Instructor.objects.all()


class CreateStudentProfileView(generics.CreateAPIView):
    """
    API endpoint for creating a student profile for the current user.
    """
    serializer_class = CreateStudentProfileSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def perform_create(self, serializer):
        # Check if user already has a student profile
        if hasattr(self.request.user, 'student_profile'):
            raise serializer.ValidationError("User already has a student profile")
        serializer.save()


class CreateInstructorProfileView(generics.CreateAPIView):
    """
    API endpoint for creating an instructor profile for the current user.
    """
    serializer_class = CreateInstructorProfileSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def perform_create(self, serializer):
        # Check if user already has an instructor profile
        if hasattr(self.request.user, 'instructor_profile'):
            raise serializer.ValidationError("User already has an instructor profile")
        serializer.save()


@api_view(['GET'])
@permission_classes([permissions.IsAuthenticated])
def check_profile_status(request):
    """
    Endpoint to check what type of profiles the user has.
    """
    user = request.user
    has_student_profile = hasattr(user, 'student_profile')
    has_instructor_profile = hasattr(user, 'instructor_profile')
    
    return Response({
        'has_student_profile': has_student_profile,
        'has_instructor_profile': has_instructor_profile,
        'is_tutor': user.is_tutor,
        'is_instructor': user.is_instructor,
    })


class BecomeATutorView(APIView):
    """
    API endpoint for becoming a tutor.
    """
    permission_classes = [permissions.IsAuthenticated]
    
    def post(self, request):
        user = request.user
        user.is_tutor = True
        user.save()
        return Response({"message": "You are now registered as a tutor."}, status=status.HTTP_200_OK)
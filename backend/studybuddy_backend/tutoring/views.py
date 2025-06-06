# tutoring/views.py

from rest_framework import viewsets, status, permissions
from rest_framework.response import Response
from rest_framework.decorators import action
from rest_framework.views import APIView
from django.utils import timezone
from django.shortcuts import get_object_or_404
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
from .serializers import (
    SubjectSerializer,
    TutorApplicationSerializer,
    TutorSerializer,
    LearningMaterialSerializer,
    TutoringSessionSerializer,
    SessionParticipantSerializer,
    SessionFeedbackSerializer,
    SessionReportSerializer
)
from users.models import User

class SubjectViewSet(viewsets.ModelViewSet):
    queryset = Subject.objects.all()
    serializer_class = SubjectSerializer
    permission_classes = [permissions.IsAuthenticated]

class TutorApplicationViewSet(viewsets.ModelViewSet):
    queryset = TutorApplication.objects.all()
    serializer_class = TutorApplicationSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.role == 'student':
            return self.queryset.filter(student=user)
        elif user.role == 'instructor':
            return self.queryset.filter(instructor=user)
        return self.queryset.none()

    def perform_create(self, serializer):
        serializer.save(student=self.request.user)

    @action(detail=True, methods=['post'])
    def approve(self, request, pk=None):
        application = self.get_object()
        if request.user != application.instructor:
            return Response(
                {'error': 'Only the assigned instructor can approve applications'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        application.status = 'approved'
        application.save()
        
        # Create tutor record
        Tutor.objects.create(
            user=application.student,
            subject=application.subject,
            approved_by=request.user,
            bio=application.motivation,
            expertise_level=application.grade
        )
        
        return Response({'status': 'application approved'})

    @action(detail=True, methods=['post'])
    def reject(self, request, pk=None):
        application = self.get_object()
        if request.user != application.instructor:
            return Response(
                {'error': 'Only the assigned instructor can reject applications'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        feedback = request.data.get('feedback', '')
        application.status = 'rejected'
        application.instructor_feedback = feedback
        application.save()
        
        return Response({'status': 'application rejected'})

class TutorViewSet(viewsets.ModelViewSet):
    queryset = Tutor.objects.filter(is_active=True)
    serializer_class = TutorSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        queryset = super().get_queryset()
        subject_id = self.request.query_params.get('subject')
        if subject_id:
            queryset = queryset.filter(subject_id=subject_id)
        return queryset

class LearningMaterialViewSet(viewsets.ModelViewSet):
    queryset = LearningMaterial.objects.filter(is_published=True)
    serializer_class = LearningMaterialSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        queryset = super().get_queryset()
        subject_id = self.request.query_params.get('subject')
        if subject_id:
            queryset = queryset.filter(subject_id=subject_id)
        return queryset

    def perform_create(self, serializer):
        serializer.save(instructor=self.request.user)

class TutoringSessionViewSet(viewsets.ModelViewSet):
    queryset = TutoringSession.objects.all()
    serializer_class = TutoringSessionSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        queryset = super().get_queryset()
        user = self.request.user
        
        # Filter by status if provided
        status = self.request.query_params.get('status')
        if status:
            queryset = queryset.filter(status=status)
        
        # Filter by subject if provided
        subject_id = self.request.query_params.get('subject')
        if subject_id:
            queryset = queryset.filter(subject_id=subject_id)
        
        # Filter upcoming sessions if requested
        upcoming = self.request.query_params.get('upcoming')
        if upcoming and upcoming.lower() == 'true':
            queryset = queryset.filter(scheduled_start__gt=timezone.now())
        
        # Students see sessions they're registered for
        if user.role == 'student':
            return queryset.filter(participants__student=user)
        # Tutors see their own sessions
        elif user.role == 'tutor':
            return queryset.filter(tutor=user)
        # Instructors see sessions for their subjects
        elif user.role == 'instructor':
            return queryset.filter(subject__in=user.instructor.subjects.all())
        
        return queryset

    def perform_create(self, serializer):
        serializer.save(tutor=self.request.user)

    @action(detail=True, methods=['post'])
    def add_material(self, request, pk=None):
        session = self.get_object()
        material_id = request.data.get('material_id')
        if not material_id:
            return Response(
                {'error': 'material_id is required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        material = get_object_or_404(LearningMaterial, pk=material_id)
        session.materials.add(material)
        return Response({'status': 'material added'})

class SessionParticipantViewSet(viewsets.ModelViewSet):
    queryset = SessionParticipant.objects.all()
    serializer_class = SessionParticipantSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.role == 'student':
            return self.queryset.filter(student=user)
        return self.queryset.filter(session__tutor=user)

class SessionFeedbackViewSet(viewsets.ModelViewSet):
    queryset = SessionFeedback.objects.all()
    serializer_class = SessionFeedbackSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.role == 'student':
            return self.queryset.filter(participant=user)
        return self.queryset.filter(session__tutor=user)

    def perform_create(self, serializer):
        participant = get_object_or_404(
            SessionParticipant,
            session_id=serializer.validated_data['session'].id,
            student=self.request.user
        )
        participant.feedback_given = True
        participant.save()
        serializer.save(participant=self.request.user)

class SessionReportViewSet(viewsets.ModelViewSet):
    queryset = SessionReport.objects.all()
    serializer_class = SessionReportSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.role == 'tutor':
            return self.queryset.filter(tutor=user)
        return self.queryset.filter(session__subject__in=user.instructor.subjects.all())

    def perform_create(self, serializer):
        serializer.save(tutor=self.request.user)

# Custom Views

class AvailableTutorsView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        subject_id = request.query_params.get('subject')
        if not subject_id:
            return Response(
                {'error': 'subject parameter is required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        tutors = Tutor.objects.filter(
            subject_id=subject_id,
            is_active=True
        ).select_related('user', 'subject')
        
        # Filter by availability (simplified)
        now = timezone.now()
        upcoming_sessions = TutoringSession.objects.filter(
            tutor__in=tutors,
            scheduled_start__gt=now,
            scheduled_end__lt=now + timezone.timedelta(hours=2)
        ).values_list('tutor_id', flat=True)
        
        available_tutors = tutors.exclude(id__in=upcoming_sessions)
        serializer = TutorSerializer(available_tutors, many=True)
        return Response(serializer.data)

class UpcomingSessionsView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        user = request.user
        now = timezone.now()
        
        if user.role == 'student':
            sessions = TutoringSession.objects.filter(
                participants__student=user,
                scheduled_start__gt=now
            ).order_by('scheduled_start')
        elif user.role == 'tutor':
            sessions = TutoringSession.objects.filter(
                tutor=user,
                scheduled_start__gt=now
            ).order_by('scheduled_start')
        else:
            sessions = TutoringSession.objects.filter(
                scheduled_start__gt=now
            ).order_by('scheduled_start')[:10]
        
        serializer = TutoringSessionSerializer(sessions, many=True)
        return Response(serializer.data)

class SessionJoinView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, pk):
        session = get_object_or_404(TutoringSession, pk=pk)
        
        if session.participants.count() >= session.max_participants:
            return Response(
                {'error': 'Session is full'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        participant, created = SessionParticipant.objects.get_or_create(
            session=session,
            student=request.user,
            defaults={'attendance_status': 'registered'}
        )
        
        if not created:
            return Response(
                {'error': 'Already registered for this session'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        return Response({'status': 'registered for session'})

class SessionStartView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, pk):
        session = get_object_or_404(TutoringSession, pk=pk)
        
        if session.tutor != request.user:
            return Response(
                {'error': 'Only the tutor can start the session'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        if session.status != 'scheduled':
            return Response(
                {'error': 'Session cannot be started in its current state'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        session.status = 'ongoing'
        session.actual_start = timezone.now()
        session.save()
        
        return Response({'status': 'session started'})

class SessionEndView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, pk):
        session = get_object_or_404(TutoringSession, pk=pk)
        
        if session.tutor != request.user:
            return Response(
                {'error': 'Only the tutor can end the session'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        if session.status != 'ongoing':
            return Response(
                {'error': 'Session is not ongoing'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        session.status = 'completed'
        session.actual_end = timezone.now()
        session.save()
        
        # Update participants' status
        SessionParticipant.objects.filter(session=session).update(
            attendance_status='attended',
            join_time=session.actual_start,
            leave_time=session.actual_end
        )
        
        return Response({'status': 'session ended'})
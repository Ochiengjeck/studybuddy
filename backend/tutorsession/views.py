from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from .models import Session
from .serializers import SessionSerializer, FeedbackSerializer, RescheduleSerializer
from django.utils import timezone
from django.core.exceptions import ObjectDoesNotExist

class ApiResponse:
    def __init__(self, success, message, data=None, status_code=None):
        self.success = success
        self.message = message
        self.data = data
        self.status_code = status_code

    def to_dict(self):
        return {
            'success': self.success,
            'message': self.message,
            'data': self.data,
            'status_code': self.status_code
        }

class UpcomingSessionsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        sessions = Session.objects.filter(
            tutor=request.user,
            start_time__gt=timezone.now(),
            status__in=['upcoming', 'in_progress']
        ).order_by('start_time')
        for session in sessions:
            session.is_current_user = (session.tutor == request.user)
        serializer = SessionSerializer(sessions, many=True)
        return Response(
            ApiResponse(True, 'Upcoming sessions retrieved successfully', serializer.data).to_dict(),
            status=status.HTTP_200_OK
        )

class PastSessionsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        sessions = Session.objects.filter(
            tutor=request.user,
            start_time__lt=timezone.now(),
            status='completed'
        ).order_by('-start_time')
        for session in sessions:
            session.is_current_user = (session.tutor == request.user)
        serializer = SessionSerializer(sessions, many=True)
        return Response(
            ApiResponse(True, 'Past sessions retrieved successfully', serializer.data).to_dict(),
            status=status.HTTP_200_OK
        )

class PendingSessionsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        sessions = Session.objects.filter(
            tutor=request.user,
            status='pending'
        ).order_by('start_time')
        for session in sessions:
            session.is_current_user = (session.tutor == request.user)
        serializer = SessionSerializer(sessions, many=True)
        return Response(
            ApiResponse(True, 'Pending sessions retrieved successfully', serializer.data).to_dict(),
            status=status.HTTP_200_OK
        )

class SessionDetailView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, session_id):
        try:
            session = Session.objects.get(id=session_id, tutor=request.user)
            session.is_current_user = (session.tutor == request.user)
            serializer = SessionSerializer(session)
            return Response(
                ApiResponse(True, 'Session details retrieved successfully', serializer.data).to_dict(),
                status=status.HTTP_200_OK
            )
        except ObjectDoesNotExist:
            return Response(
                ApiResponse(False, 'Session not found').to_dict(),
                status=status.HTTP_404_NOT_FOUND
            )

class CancelSessionView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, session_id):
        try:
            session = Session.objects.get(id=session_id, tutor=request.user)
            if session.status in ['completed', 'declined']:
                return Response(
                    ApiResponse(False, 'Cannot cancel a completed or declined session').to_dict(),
                    status=status.HTTP_400_BAD_REQUEST
                )
            session.status = 'declined'
            session.save()
            return Response(
                ApiResponse(True, 'Session canceled successfully').to_dict(),
                status=status.HTTP_200_OK
            )
        except ObjectDoesNotExist:
            return Response(
                ApiResponse(False, 'Session not found').to_dict(),
                status=status.HTTP_404_NOT_FOUND
            )

class RescheduleSessionView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, session_id):
        serializer = RescheduleSerializer(data=request.data)
        if serializer.is_valid():
            try:
                session = Session.objects.get(id=session_id, tutor=request.user)
                if session.status in ['completed', 'declined']:
                    return Response(
                        ApiResponse(False, 'Cannot reschedule a completed or declined session').to_dict(),
                        status=status.HTTP_400_BAD_REQUEST
                    )
                new_time = serializer.validated_data['new_time']
                if new_time < timezone.now():
                    return Response(
                        ApiResponse(False, 'New time cannot be in the past').to_dict(),
                        status=status.HTTP_400_BAD_REQUEST
                    )
                session.start_time = new_time
                session.status = 'pending'  # Reset to pending for approval
                session.save()
                return Response(
                    ApiResponse(True, 'Session rescheduled successfully').to_dict(),
                    status=status.HTTP_200_OK
                )
            except ObjectDoesNotExist:
                return Response(
                    ApiResponse(False, 'Session not found').to_dict(),
                    status=status.HTTP_404_NOT_FOUND
                )
        return Response(
            ApiResponse(False, 'Invalid input', serializer.errors).to_dict(),
            status=status.HTTP_400_BAD_REQUEST
        )

class SubmitFeedbackView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, session_id):
        serializer = FeedbackSerializer(data=request.data)
        if serializer.is_valid():
            try:
                session = Session.objects.get(id=session_id, tutor=request.user)
                if session.status != 'completed':
                    return Response(
                        ApiResponse(False, 'Feedback can only be submitted for completed sessions').to_dict(),
                        status=status.HTTP_400_BAD_REQUEST
                    )
                session.rating = serializer.validated_data['rating']
                session.save()
                return Response(
                    ApiResponse(True, 'Feedback submitted successfully').to_dict(),
                    status=status.HTTP_200_OK
                )
            except ObjectDoesNotExist:
                return Response(
                    ApiResponse(False, 'Session not found').to_dict(),
                    status=status.HTTP_404_NOT_FOUND
                )
        return Response(
            ApiResponse(False, 'Invalid input', serializer.errors).to_dict(),
            status=status.HTTP_400_BAD_REQUEST
        )

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from .models import Achievement, UserStats
from .serializers import AchievementSerializer, UserStatsSerializer

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

class AchievementsListView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        achievements = Achievement.objects.filter(user=request.user)
        serializer = AchievementSerializer(achievements, many=True)
        return Response(
            ApiResponse(True, 'Achievements retrieved successfully', serializer.data).to_dict(),
            status=status.HTTP_200_OK
        )

class UserStatsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        try:
            stats = UserStats.objects.get(user=request.user)
            serializer = UserStatsSerializer(stats)
            return Response(
                ApiResponse(True, 'User stats retrieved successfully', serializer.data).to_dict(),
                status=status.HTTP_200_OK
            )
        except UserStats.DoesNotExist:
            return Response(
                ApiResponse(False, 'User stats not found').to_dict(),
                status=status.HTTP_404_NOT_FOUND
            )
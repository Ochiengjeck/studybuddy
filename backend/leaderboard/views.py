from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from .models import LeaderboardUser
from .serializers import LeaderboardUserSerializer

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

class LeaderboardView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        filter_type = request.query_params.get('filter', 'overall')
        leaderboard = LeaderboardUser.objects.all()
        if filter_type != 'overall':
            leaderboard = leaderboard.filter(subject=filter_type)
        leaderboard = leaderboard.order_by('-points')
        for index, entry in enumerate(leaderboard, start=1):
            entry.position = index
            entry.is_current_user = (entry.user == request.user)
            entry.save()
        serializer = LeaderboardUserSerializer(leaderboard, many=True)
        return Response(
            ApiResponse(True, 'Leaderboard retrieved successfully', serializer.data).to_dict(),
            status=status.HTTP_200_OK
        )

class TopPerformersView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        leaderboard = LeaderboardUser.objects.order_by('-points')[:10]
        for index, entry in enumerate(leaderboard, start=1):
            entry.position = index
            entry.is_current_user = (entry.user == request.user)
            entry.save()
        serializer = LeaderboardUserSerializer(leaderboard, many=True)
        return Response(
            ApiResponse(True, 'Top performers retrieved successfully', serializer.data).to_dict(),
            status=status.HTTP_200_OK
        )
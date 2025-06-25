from django.urls import path
from .views import LeaderboardView, TopPerformersView

app_name = 'leaderboard'

urlpatterns = [
    path('leaderboard/', LeaderboardView.as_view(), name='leaderboard'),
    path('leaderboard/top/', TopPerformersView.as_view(), name='top_performers'),
]
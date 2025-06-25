from django.urls import path
from .views import AchievementsListView, UserStatsView

app_name = 'achievements'

urlpatterns = [
    path('achievements/', AchievementsListView.as_view(), name='achievements_list'),
    path('achievements/stats/', UserStatsView.as_view(), name='user_stats'),
]
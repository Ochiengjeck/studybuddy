
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),

    path('api/', include('users.urls')),
    path('api/', include('achievements.urls')),
    path('api/', include('leaderboard.urls')),
    path('api/', include('tutorsession.urls')),
]

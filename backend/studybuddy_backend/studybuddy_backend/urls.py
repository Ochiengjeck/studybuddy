# studybuddy_backend/urls.py

from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from rest_framework.documentation import include_docs_urls

urlpatterns = [
    # Admin site
    path('admin/', admin.site.urls),
    
    # API routes
    path('api/users/', include('users.urls')),
    path('api/tutoring/', include('tutoring.urls')),
    # path('api/gamification/', include('gamification.urls')),
    path('api/analytics/', include('analytics.urls')),
    
    # API documentation
    # path('api/docs/', include_docs_urls(title='StudyBuddy API')),
]

# Serve media files in development
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
# tutoring/urls.py

from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register(r'subjects', views.SubjectViewSet, basename='subject')
router.register(r'tutor-applications', views.TutorApplicationViewSet, basename='tutor-application')
router.register(r'tutors', views.TutorViewSet, basename='tutor')
router.register(r'learning-materials', views.LearningMaterialViewSet, basename='learning-material')
router.register(r'sessions', views.TutoringSessionViewSet, basename='session')
router.register(r'session-participants', views.SessionParticipantViewSet, basename='session-participant')
router.register(r'session-feedback', views.SessionFeedbackViewSet, basename='session-feedback')
router.register(r'session-reports', views.SessionReportViewSet, basename='session-report')

urlpatterns = [
    path('', include(router.urls)),
    path('available-tutors/', views.AvailableTutorsView.as_view(), name='available-tutors'),
    path('upcoming-sessions/', views.UpcomingSessionsView.as_view(), name='upcoming-sessions'),
    path('session-join/<int:pk>/', views.SessionJoinView.as_view(), name='session-join'),
    path('session-start/<int:pk>/', views.SessionStartView.as_view(), name='session-start'),
    path('session-end/<int:pk>/', views.SessionEndView.as_view(), name='session-end'),
]
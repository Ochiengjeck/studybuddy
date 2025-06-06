# analytics/urls.py

from django.urls import path
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register(r'institution-analytics', views.InstitutionAnalyticsViewSet, basename='institution-analytics')
router.register(r'subject-analytics', views.SubjectAnalyticsViewSet, basename='subject-analytics')
router.register(r'tutor-performance', views.TutorPerformanceViewSet, basename='tutor-performance')
router.register(r'student-progress', views.StudentProgressViewSet, basename='student-progress')
router.register(r'risk-assessments', views.RiskAssessmentViewSet, basename='risk-assessments')
router.register(r'recommended-actions', views.RecommendedActionViewSet, basename='recommended-actions')
router.register(r'predictive-models', views.PredictiveModelViewSet, basename='predictive-models')

urlpatterns = [
    path('dashboard/', views.AnalyticsDashboardView.as_view(), name='analytics-dashboard'),
    path('generate-reports/', views.GenerateReportsView.as_view(), name='generate-reports'),
] + router.urls
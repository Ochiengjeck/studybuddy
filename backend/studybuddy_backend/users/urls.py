# users/urls.py

from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register(r'users', views.UserViewSet)
router.register(r'students', views.StudentViewSet)
router.register(r'instructors', views.InstructorViewSet)

urlpatterns = [
    path('', include(router.urls)),
    path('me/', views.UserViewSet.as_view({'get': 'me'}), name='user-me'),
    path('update-profile/', views.UserViewSet.as_view({'put': 'update_profile', 'patch': 'update_profile'}), name='update-profile'),
    path('create-student-profile/', views.CreateStudentProfileView.as_view(), name='create-student-profile'),
    path('create-instructor-profile/', views.CreateInstructorProfileView.as_view(), name='create-instructor-profile'),
    path('profile-status/', views.check_profile_status, name='profile-status'),
    path('become-tutor/', views.BecomeATutorView.as_view(), name='become-tutor'),
]
from django.urls import path
from .views import (
    LoginView, RegisterView, PasswordResetRequestView,
    OtpVerificationView, PasswordResetConfirmView,
    UserProfileView, LogoutView
)

app_name = 'users'

urlpatterns = [
    path('auth/login/', LoginView.as_view(), name='login'),
    path('auth/register/', RegisterView.as_view(), name='register'),
    path('auth/password/reset/', PasswordResetRequestView.as_view(), name='password_reset'),
    path('auth/otp/verify/', OtpVerificationView.as_view(), name='otp_verify'),
    path('auth/password/reset/confirm/', PasswordResetConfirmView.as_view(), name='password_reset_confirm'),
    path('auth/user/', UserProfileView.as_view(), name='user_profile'),
    path('auth/logout/', LogoutView.as_view(), name='logout'),
]
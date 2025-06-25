from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth import authenticate
from django.core.exceptions import ObjectDoesNotExist
from .models import CustomUser, OtpToken
from .serializers import (
    LoginRequestSerializer, RegisterRequestSerializer, PasswordResetRequestSerializer,
    OtpVerificationSerializer, PasswordResetConfirmSerializer, UserSerializer
)
from .utils import create_otp
from datetime import datetime

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

class LoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = LoginRequestSerializer(data=request.data)
        if serializer.is_valid():
            email = serializer.validated_data['email']
            password = serializer.validated_data['password']
            user = authenticate(email=email, password=password)
            if user:
                if not user.is_active:
                    return Response(
                        ApiResponse(False, 'Account is deactivated').to_dict(),
                        status=status.HTTP_401_UNAUTHORIZED
                    )
                refresh = RefreshToken.for_user(user)
                user.last_login = datetime.now()
                user.save()
                data = UserSerializer(user).data
                data['refresh'] = str(refresh)
                return Response(
                    ApiResponse(True, 'Login successful', data).to_dict(),
                    status=status.HTTP_200_OK
                )
            return Response(
                ApiResponse(False, 'Invalid credentials').to_dict(),
                status=status.HTTP_401_UNAUTHORIZED
            )
        return Response(
            ApiResponse(False, 'Invalid input', serializer.errors).to_dict(),
            status=status.HTTP_400_BAD_REQUEST
        )

class RegisterView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = RegisterRequestSerializer(data=request.data)
        if serializer.is_valid():
            try:
                user = CustomUser.objects.create_user(
                    email=serializer.validated_data['email'],
                    password=serializer.validated_data['password'],
                    first_name=serializer.validated_data.get('first_name'),
                    last_name=serializer.validated_data.get('last_name'),
                    phone=serializer.validated_data.get('phone')
                )
                return Response(
                    ApiResponse(True, 'Registration successful', UserSerializer(user).data).to_dict(),
                    status=status.HTTP_201_CREATED
                )
            except ValueError as e:
                return Response(
                    ApiResponse(False, str(e)).to_dict(),
                    status=status.HTTP_400_BAD_REQUEST
                )
        return Response(
            ApiResponse(False, 'Invalid input', serializer.errors).to_dict(),
            status=status.HTTP_400_BAD_REQUEST
        )

class PasswordResetRequestView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = PasswordResetRequestSerializer(data=request.data)
        if serializer.is_valid():
            email = serializer.validated_data['email']
            try:
                user = CustomUser.objects.get(email=email)
                create_otp(user)
                return Response(
                    ApiResponse(True, 'OTP sent to your email').to_dict(),
                    status=status.HTTP_200_OK
                )
            except ObjectDoesNotExist:
                return Response(
                    ApiResponse(False, 'User with this email does not exist').to_dict(),
                    status=status.HTTP_404_NOT_FOUND
                )
        return Response(
            ApiResponse(False, 'Invalid input', serializer.errors).to_dict(),
            status=status.HTTP_400_BAD_REQUEST
        )

class OtpVerificationView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = OtpVerificationSerializer(data=request.data)
        if serializer.is_valid():
            email = serializer.validated_data['email']
            otp = serializer.validated_data['otp']
            try:
                user = CustomUser.objects.get(email=email)
                otp_token = OtpToken.objects.filter(user=user, otp=otp, expires_at__gt=NOW()).first()
                if otp_token:
                    otp_token.delete()
                    return Response(
                        ApiResponse(True, 'OTP verified successfully').to_dict(),
                        status=status.HTTP_200_OK
                    )
                return Response(
                    ApiResponse(False, 'Invalid or expired OTP').to_dict(),
                    status=status.HTTP_400_BAD_REQUEST
                )
            except ObjectDoesNotExist:
                return Response(
                    ApiResponse(False, 'User with this email does not exist').to_dict(),
                    status=status.HTTP_404_NOT_FOUND
                )
        return Response(
            ApiResponse(False, 'Invalid input', serializer.errors).to_dict(),
            status=status.HTTP_400_BAD_REQUEST
        )

class PasswordResetConfirmView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = PasswordResetConfirmSerializer(data=request.data)
        if serializer.is_valid():
            email = serializer.validated_data['email']
            otp = serializer.validated_data['otp']
            new_password = serializer.validated_data['new_password']
            try:
                user = CustomUser.objects.get(email=email)
                otp_token = OtpToken.objects.filter(user=user, otp=otp, expires_at__gt=NOW()).first()
                if otp_token:
                    user.set_password(new_password)
                    user.save()
                    otp_token.delete()
                    return Response(
                        ApiResponse(True, 'Password reset successful', UserSerializer(user).data).to_dict(),
                        status=status.HTTP_200_OK
                    )
                return Response(
                    ApiResponse(False, 'Invalid or expired OTP').to_dict(),
                    status=status.HTTP_400_BAD_REQUEST
                )
            except ObjectDoesNotExist:
                return Response(
                    ApiResponse(False, 'User with this email does not exist').to_dict(),
                    status=status.HTTP_404_NOT_FOUND
                )
        return Response(
            ApiResponse(False, 'Invalid input', serializer.errors).to_dict(),
            status=status.HTTP_400_BAD_REQUEST
        )

class UserProfileView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        return Response(
            ApiResponse(True, 'User details retrieved', UserSerializer(user).data).to_dict(),
            status=status.HTTP_200_OK
        )

class LogoutView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        try:
            refresh_token = request.data.get('refresh')
            if refresh_token:
                token = RefreshToken(refresh_token)
                token.blacklist()
            return Response(
                ApiResponse(True, 'Successfully logged out').to_dict(),
                status=status.HTTP_200_OK
            )
        except Exception:
            return Response(
                ApiResponse(True, 'Logged out').to_dict(),
                status=status.HTTP_200_OK
            )

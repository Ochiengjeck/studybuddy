from rest_framework import serializers
from .models import CustomUser, OtpToken
from django.core.mail import send_mail
from django.conf import settings
import random
import string
from datetime import datetime, timedelta

class LoginRequestSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField()
    remember_me = serializers.BooleanField(default=False)

class RegisterRequestSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(min_length=8)
    password2 = serializers.CharField(min_length=8, label='Confirm Password')
    first_name = serializers.CharField(max_length=50, required=False, allow_blank=True)
    last_name = serializers.CharField(max_length=50, required=False, allow_blank=True)
    phone = serializers.CharField(max_length=15, required=False, allow_blank=True)

    def validate(self, data):
        if data['password'] != data['password2']:
            raise serializers.ValidationError({"password2": "Passwords do not match"})
        return data

class PasswordResetRequestSerializer(serializers.Serializer):
    email = serializers.EmailField()

class OtpVerificationSerializer(serializers.Serializer):
    email = serializers.EmailField()
    otp = serializers.CharField(max_length=6)

class PasswordResetConfirmSerializer(serializers.Serializer):
    email = serializers.EmailField()
    otp = serializers.CharField(max_length=6)
    new_password = serializers.CharField(min_length=8)
    confirm_password = serializers.CharField(min_length=8)

    def validate(self, data):
        if data['new_password'] != data['confirm_password']:
            raise serializers.ValidationError({"confirm_password": "Passwords do not match"})
        return data

class UserSerializer(serializers.ModelSerializer):
    auth_token = serializers.SerializerMethodField()

    class Meta:
        model = CustomUser
        fields = (
            'id', 'email', 'first_name', 'last_name', 'phone', 'profile_picture',
            'is_active', 'is_verified', 'date_joined', 'last_login', 'user_type', 'auth_token'
        )
        read_only_fields = ('id', 'is_active', 'is_verified', 'date_joined', 'last_login')

    def get_auth_token(self, obj):
        from rest_framework_simplejwt.tokens import RefreshToken
        refresh = RefreshToken.for_user(obj)
        return str(refresh.access_token)
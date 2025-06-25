from django.core.mail import send_mail
from django.conf import settings
from .models import OtpToken
from datetime import datetime, timedelta
import random
import string

def generate_otp(length=6):
    return ''.join(random.choices(string.digits, k=length))

def send_otp_email(user, otp):
    subject = 'Password Reset OTP'
    message = f'Your OTP for password reset is {otp}. It is valid for 10 minutes.'
    from_email = settings.DEFAULT_FROM_EMAIL
    send_mail(subject, message, from_email, [user.email])

def create_otp(user):
    otp = generate_otp()
    expires_at = datetime.now() + timedelta(minutes=10)
    OtpToken.objects.create(user=user, otp=otp, expires_at=expires_at)
    send_otp_email(user, otp)
    return otp
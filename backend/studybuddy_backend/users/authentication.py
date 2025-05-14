# users/authentication.py

import firebase_admin
from firebase_admin import auth, credentials
from django.conf import settings
from django.contrib.auth import get_user_model
from rest_framework import authentication
from rest_framework import exceptions

# Initialize Firebase Admin once
try:
    firebase_admin.get_app()
except ValueError:
    # Use environment variable or file path for production
    cred = credentials.Certificate("/home/jeckonia/My Space/Projects/Senior Project/studybuddy/firebase-adminsdk.json")
    firebase_admin.initialize_app(cred)

User = get_user_model()

class FirebaseAuthentication(authentication.BaseAuthentication):
    """
    Custom authentication for Firebase token-based authentication.
    Clients should pass the token in the "Authorization" HTTP header,
    prefixed with "Firebase " (with a space after).
    """
    
    def authenticate(self, request):
        auth_header = request.META.get('HTTP_AUTHORIZATION')
        if not auth_header:
            return None
            
        # Extract the Firebase ID token from the Authorization header
        try:
            prefix, token = auth_header.split(' ')
            if prefix.lower() != 'firebase':
                return None
        except ValueError:
            raise exceptions.AuthenticationFailed('Invalid token header')
            
        if not token:
            raise exceptions.AuthenticationFailed('No token provided')
            
        # Verify the Firebase ID token
        try:
            decoded_token = auth.verify_id_token(token)
            firebase_uid = decoded_token['uid']
            email = decoded_token.get('email', '')
            display_name = decoded_token.get('name', '')
        except Exception as e:
            raise exceptions.AuthenticationFailed(f'Invalid token: {str(e)}')
            
        # Get or create user based on Firebase UID
        try:
            user, created = User.objects.get_or_create(
                firebase_uid=firebase_uid,
                defaults={
                    'email': email,
                    'username': email,
                    'name': display_name,
                    'is_active': True,
                }
            )
            
            # Update user info if it has changed
            if not created and (user.email != email or user.name != display_name):
                user.email = email
                user.name = display_name
                user.save()
                
            return (user, token)
            
        except Exception as e:
            raise exceptions.AuthenticationFailed(f'Failed to authenticate: {str(e)}')
    
    def authenticate_header(self, request):
        return 'Firebase'
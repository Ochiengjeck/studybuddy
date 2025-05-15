# users/signals.py

from django.db.models.signals import post_save
from django.dispatch import receiver
from django.contrib.auth import get_user_model
from .models import Student, Instructor

User = get_user_model()

@receiver(post_save, sender=User)
def create_user_profiles(sender, instance, created, **kwargs):
    """
    Signal to automatically set user fields when profiles are created
    """
    if not created:
        # Check if user has instructor profile and update is_instructor flag
        if hasattr(instance, 'instructor_profile') and not instance.is_instructor:
            instance.is_instructor = True
            instance.save(update_fields=['is_instructor'])
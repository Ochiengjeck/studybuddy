# tutoring/signals.py

from django.db.models.signals import post_save
from django.dispatch import receiver
from django.utils import timezone
from .models import TutoringSession, SessionParticipant

@receiver(post_save, sender=TutoringSession)
def send_session_notification(sender, instance, created, **kwargs):
    if created:
        # Send notifications to tutor
        pass

@receiver(post_save, sender=SessionParticipant)
def send_participant_notification(sender, instance, created, **kwargs):
    if created:
        # Send confirmation to student
        pass
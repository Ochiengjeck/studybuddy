# tutoring/apps.py

from django.apps import AppConfig

class TutoringConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'tutoring'
    
    def ready(self):
        import tutoring.signals
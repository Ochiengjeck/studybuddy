# users/models.py

from django.db import models
from django.contrib.auth.models import AbstractUser, BaseUserManager
from django.utils.translation import gettext_lazy as _

class UserManager(BaseUserManager):
    """Define a model manager for User model with no username field."""

    use_in_migrations = True

    def _create_user(self, email, password, **extra_fields):
        """Create and save a User with the given email and password."""
        if not email:
            raise ValueError('The given email must be set')
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_user(self, email, password=None, **extra_fields):
        """Create and save a regular User with the given email and password."""
        extra_fields.setdefault('is_staff', False)
        extra_fields.setdefault('is_superuser', False)
        return self._create_user(email, password, **extra_fields)

    def create_superuser(self, email, password, **extra_fields):
        """Create and save a SuperUser with the given email and password."""
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)

        if extra_fields.get('is_staff') is not True:
            raise ValueError('Superuser must have is_staff=True.')
        if extra_fields.get('is_superuser') is not True:
            raise ValueError('Superuser must have is_superuser=True.')

        return self._create_user(email, password, **extra_fields)


class User(AbstractUser):
    """Custom User model for StudyBuddy application."""
    
    username = models.CharField(max_length=150, unique=True, null=True, blank=True)
    email = models.EmailField(_('email address'), unique=True)
    name = models.CharField(max_length=255, blank=True)
    firebase_uid = models.CharField(max_length=128, unique=True, null=True, blank=True)
    profile_picture = models.ImageField(upload_to='profile_pictures/', null=True, blank=True)
    
    # Role fields
    is_instructor = models.BooleanField(default=False)
    is_tutor = models.BooleanField(default=False)
    
    # Fields for gamification
    points = models.IntegerField(default=0)
    
    # Metadata
    date_joined = models.DateTimeField(auto_now_add=True)
    last_login = models.DateTimeField(auto_now=True)
    
    # Set email as the unique identifier instead of username
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = []
    
    objects = UserManager()
    
    class Meta:
        verbose_name = 'User'
        verbose_name_plural = 'Users'
    
    def __str__(self):
        return self.email
    
    @property
    def full_name(self):
        return self.name or f"{self.first_name} {self.last_name}".strip() or self.email


class Student(models.Model):
    """Model for Student profile with additional student-specific information."""
    
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='student_profile')
    student_id = models.CharField(max_length=20, unique=True)
    institution = models.CharField(max_length=255)
    department = models.CharField(max_length=255)
    year_of_study = models.IntegerField()
    
    class Meta:
        verbose_name = 'Student'
        verbose_name_plural = 'Students'
    
    def __str__(self):
        return f"{self.user.full_name} ({self.student_id})"


class Instructor(models.Model):
    """Model for Instructor profile with additional instructor-specific information."""
    
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='instructor_profile')
    employee_id = models.CharField(max_length=20, unique=True)
    department = models.CharField(max_length=255)
    position = models.CharField(max_length=100)
    subjects = models.ManyToManyField('tutoring.Subject', related_name='instructors')
    
    class Meta:
        verbose_name = 'Instructor'
        verbose_name_plural = 'Instructors'
    
    def __str__(self):
        return f"{self.user.full_name} ({self.position})"
# users/tests.py

from django.test import TestCase
from django.urls import reverse
from rest_framework.test import APIClient
from rest_framework import status
from django.contrib.auth import get_user_model
from .models import Student, Instructor

User = get_user_model()


class UserAPITestCase(TestCase):
    """Test case for User API endpoints"""
    
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(
            email='testuser@example.com', 
            password='testpassword123',
            name='Test User'
        )
        # Mock Firebase authentication by directly authenticating the user
        self.client.force_authenticate(user=self.user)
        
    def test_me_endpoint(self):
        """Test retrieving current user's profile"""
        url = reverse('user-me')
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['email'], self.user.email)
        
    def test_update_profile(self):
        """Test updating user profile"""
        url = reverse('update-profile')
        data = {
            'name': 'Updated Test User'
        }
        response = self.client.patch(url, data)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['name'], 'Updated Test User')
        
        # Verify the change was saved to the database
        self.user.refresh_from_db()
        self.assertEqual(self.user.name, 'Updated Test User')
        
    def test_profile_status(self):
        """Test checking profile status"""
        url = reverse('profile-status')
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertFalse(response.data['has_student_profile'])
        self.assertFalse(response.data['has_instructor_profile'])
        self.assertFalse(response.data['is_tutor'])
        self.assertFalse(response.data['is_instructor'])


class StudentProfileTestCase(TestCase):
    """Test case for Student Profile API endpoints"""
    
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(
            email='student@example.com', 
            password='testpassword123',
            name='Student User'
        )
        self.client.force_authenticate(user=self.user)
        
    def test_create_student_profile(self):
        """Test creating a student profile"""
        url = reverse('create-student-profile')
        data = {
            'student_id': 'STU123456',
            'institution': 'Test University',
            'department': 'Computer Science',
            'year_of_study': 3
        }
        response = self.client.post(url, data)
        
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        
        # Verify profile was created
        student = Student.objects.get(user=self.user)
        self.assertEqual(student.student_id, 'STU123456')
        self.assertEqual(student.institution, 'Test University')
        
        # Check profile status
        url = reverse('profile-status')
        response = self.client.get(url)
        self.assertTrue(response.data['has_student_profile'])


class InstructorProfileTestCase(TestCase):
    """Test case for Instructor Profile API endpoints"""
    
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(
            email='instructor@example.com', 
            password='testpassword123',
            name='Instructor User'
        )
        self.client.force_authenticate(user=self.user)
        
    def test_create_instructor_profile(self):
        """Test creating an instructor profile"""
        url = reverse('create-instructor-profile')
        data = {
            'employee_id': 'EMP789012',
            'department': 'Computer Science',
            'position': 'Associate Professor'
        }
        response = self.client.post(url, data)
        
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        
        # Verify profile was created
        instructor = Instructor.objects.get(user=self.user)
        self.assertEqual(instructor.employee_id, 'EMP789012')
        self.assertEqual(instructor.position, 'Associate Professor')
        
        # Verify user is now marked as instructor
        self.user.refresh_from_db()
        self.assertTrue(self.user.is_instructor)
        
        # Check profile status
        url = reverse('profile-status')
        response = self.client.get(url)
        self.assertTrue(response.data['has_instructor_profile'])
        self.assertTrue(response.data['is_instructor'])


class TutorAPITestCase(TestCase):
    """Test case for Tutor API endpoints"""
    
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(
            email='tutor@example.com', 
            password='testpassword123',
            name='Tutor User'
        )
        self.client.force_authenticate(user=self.user)
        
    def test_become_tutor(self):
        """Test becoming a tutor"""
        url = reverse('become-tutor')
        response = self.client.post(url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        # Verify user is now marked as tutor
        self.user.refresh_from_db()
        self.assertTrue(self.user.is_tutor)
        
        # Check profile status
        url = reverse('profile-status')
        response = self.client.get(url)
        self.assertTrue(response.data['is_tutor'])
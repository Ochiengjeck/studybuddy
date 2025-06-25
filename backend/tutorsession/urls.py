from django.urls import path
from .views import (
    UpcomingSessionsView, PastSessionsView, PendingSessionsView,
    SessionDetailView, CancelSessionView, RescheduleSessionView,
    SubmitFeedbackView
)

app_name = 'tutorsession'

urlpatterns = [
    path('sessions/upcoming/', UpcomingSessionsView.as_view(), name='upcoming_sessions'),
    path('sessions/past/', PastSessionsView.as_view(), name='past_sessions'),
    path('sessions/pending/', PendingSessionsView.as_view(), name='pending_sessions'),
    path('sessions/<uuid:session_id>/', SessionDetailView.as_view(), name='session_detail'),
    path('sessions/<uuid:session_id>/cancel/', CancelSessionView.as_view(), name='cancel_session'),
    path('sessions/<uuid:session_id>/reschedule/', RescheduleSessionView.as_view(), name='reschedule_session'),
    path('sessions/<uuid:session_id>/feedback/', SubmitFeedbackView.as_view(), name='submit_feedback'),
]
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../modelsAndRepsositories/models_and_repositories.dart';

/// Extension to create a copy of Session with updated fields
extension SessionExtension on Session {
  Session copyWith({
    String? id,
    String? title,
    String? tutorName,
    String? tutorImage,
    String? platform,
    DateTime? startTime,
    Duration? duration,
    String? description,
    SessionStatus? status,
    SessionType? type,
    double? rating,
    String? review,
    List<String>? participantImages,
    List<String>? participants,
    bool? isCurrentUser,
    String? userId,
    String? organizerId,
    String? subject,
    String? level,
    String? notes,
    int? maxParticipants,
    int? currentParticipants,
    bool? isRecurring,
    String? recurringPattern,
    bool? isPaid,
    double? price,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Session(
      id: id ?? this.id,
      title: title ?? this.title,
      tutorName: tutorName ?? this.tutorName,
      tutorImage: tutorImage ?? this.tutorImage,
      platform: platform ?? this.platform,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      description: description ?? this.description,
      status: status ?? this.status,
      type: type ?? this.type,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      participantImages: participantImages ?? this.participantImages,
      participants: participants ?? this.participants,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
      userId: userId ?? this.userId,
      organizerId: organizerId ?? this.organizerId,
      subject: subject ?? this.subject,
      level: level ?? this.level,
      notes: notes ?? this.notes,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPattern: recurringPattern ?? this.recurringPattern,
      isPaid: isPaid ?? this.isPaid,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Base provider class with common functionality
abstract class BaseProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  DateTime? _lastFetched;

  bool get isLoading => _isLoading;
  String? get error => _error;

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  bool isCacheValid(Duration cacheDuration) =>
      _lastFetched != null &&
      DateTime.now().difference(_lastFetched!) < cacheDuration;
}

/// Main App Provider for managing global app state
class AppProvider extends BaseProvider {
  User? _currentUser;
  bool _isInitializing = false;

  User? get currentUser => _currentUser;
  bool get isInitializing => _isInitializing;

  Future<void> initializeApp() async {
    if (_isInitializing) return;
    _isInitializing = true;
    clearError();
    notifyListeners();

    try {
      final firebaseUser = auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        final response = await AuthRepository().getCurrentUser(
          firebaseUser.uid,
        );
        _currentUser = response.data;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  void setCurrentUser(User? user) {
    _currentUser = user;
    notifyListeners();
  }

  Future<void> updateUser(User updatedUser) async {
    _currentUser = updatedUser;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}

/// Extension to create a copy of User with updated fields
extension UserExtension on User {
  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? profilePicture,
    bool? isActive,
    bool? isVerified,
    DateTime? dateJoined,
    DateTime? lastLogin,
    String? userType,
    Map<String, dynamic>? notificationSettings,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      profilePicture: profilePicture ?? this.profilePicture,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      dateJoined: dateJoined ?? this.dateJoined,
      lastLogin: lastLogin ?? this.lastLogin,
      userType: userType ?? this.userType,
      notificationSettings: notificationSettings ?? this.notificationSettings,
    );
  }
}

/// Authentication Provider
class AuthProvider extends BaseProvider {
  final AuthRepository _authRepository;
  bool _isAuthenticated = false;

  AuthProvider(this._authRepository);

  bool get isAuthenticated => _isAuthenticated;

  Future<ApiResponse<User>> login(LoginRequest request) async {
    _isLoading = true;
    clearError();
    notifyListeners();

    try {
      final response = await _authRepository.login(request);
      _isAuthenticated = response.data != null;
      return response;
    } on ApiError catch (e) {
      _error = e.message;
      _isAuthenticated = false;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ApiResponse<User>> register(RegisterRequest request) async {
    _isLoading = true;
    clearError();
    notifyListeners();

    try {
      final response = await _authRepository.register(request);
      return response;
    } on ApiError catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ApiResponse<User>> getCurrentUser() async {
    _isLoading = true;
    clearError();
    notifyListeners();

    try {
      final response = await _authRepository.getCurrentUser('');
      _isAuthenticated = response.data != null;
      return response;
    } on ApiError catch (e) {
      _error = e.message;
      _isAuthenticated = false;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ApiResponse<void>> logout() async {
    _isLoading = true;
    clearError();
    notifyListeners();

    try {
      final response = await _authRepository.logout('');
      _isAuthenticated = false;
      return response;
    } on ApiError catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

/// Achievements Provider
class AchievementsProvider extends BaseProvider {
  final AchievementsRepository _repository;
  List<Achievement>? _achievements;
  UserStats? _userStats;

  AchievementsProvider(this._repository);

  List<Achievement>? get achievements => _achievements;
  UserStats? get userStats => _userStats;

  Future<void> loadAchievements(
    String userId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        _achievements != null &&
        isCacheValid(const Duration(minutes: 5))) {
      return;
    }

    _isLoading = true;
    clearError();
    notifyListeners();

    try {
      final response = await _repository.getAchievements(userId);
      _achievements = response.data;
      _lastFetched = DateTime.now();
    } on ApiError catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserStats(String userId, {bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _userStats != null &&
        isCacheValid(const Duration(minutes: 5)))
      return;

    _isLoading = true;
    clearError();
    notifyListeners();

    try {
      final response = await _repository.getUserStats(userId);
      _userStats = response.data;
      _lastFetched = DateTime.now();
    } on ApiError catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> initializeDefaultBadges(
    String userId,
    List<Map<String, dynamic>> defaultBadges,
  ) async {
    _isLoading = true;
    clearError();
    notifyListeners();

    try {
      await _repository.initializeDefaultBadges(userId, defaultBadges);
      await loadAchievements(userId, forceRefresh: true);
    } on ApiError catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

/// Leaderboard Provider
class LeaderboardProvider extends BaseProvider {
  final LeaderboardRepository _repository;
  List<LeaderboardUser>? _leaderboard;
  List<LeaderboardUser>? _topPerformers;
  String _currentFilter = 'overall';
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;

  LeaderboardProvider(this._repository);

  List<LeaderboardUser>? get leaderboard => _leaderboard;
  List<LeaderboardUser>? get topPerformers => _topPerformers;
  String get currentFilter => _currentFilter;
  bool get hasMore => _hasMore;

  Future<void> loadLeaderboard({
    String filter = 'overall',
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        _leaderboard != null &&
        _currentFilter == filter &&
        isCacheValid(const Duration(minutes: 5)) &&
        !_hasMore) {
      return;
    }

    _isLoading = true;
    clearError();
    if (forceRefresh || _currentFilter != filter) {
      _leaderboard = [];
      _lastDocument = null;
      _hasMore = true;
      _currentFilter = filter;
    }
    notifyListeners();

    try {
      final response = await _repository.getLeaderboard(
        filter: filter,
        startAfter: _lastDocument,
        limit: 10,
      );
      _leaderboard = (_leaderboard ?? []) + (response.data ?? []);
      _lastDocument = response.metadata?['lastDocument'];
      _hasMore = response.data?.length == 10;
      _lastFetched = DateTime.now();
    } on ApiError catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTopPerformers({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _topPerformers != null &&
        isCacheValid(const Duration(minutes: 5))) {
      return;
    }

    _isLoading = true;
    clearError();
    notifyListeners();

    try {
      final response = await _repository.getTopPerformers();
      _topPerformers = response.data;
      _lastFetched = DateTime.now();
    } on ApiError catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

/// Session Provider
class SessionProvider extends BaseProvider {
  final SessionRepository _repository;
  List<Session>? _upcomingSessions;
  List<Session>? _pastSessions;
  List<Session>? _pendingSessions;
  List<Session>? _availableSessions;
  Session? _selectedSession;

  SessionProvider(this._repository);

  List<Session>? get upcomingSessions => _upcomingSessions;
  List<Session>? get pastSessions => _pastSessions;
  List<Session>? get pendingSessions => _pendingSessions;
  List<Session>? get availableSessions => _availableSessions;
  Session? get selectedSession => _selectedSession;

  Future<void> loadUpcomingSessions(
    String userId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        _upcomingSessions != null &&
        isCacheValid(const Duration(minutes: 5))) {
      return;
    }

    _isLoading = true;
    clearError();

    // Don't call notifyListeners() immediately if called during build
    if (WidgetsBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } else {
      notifyListeners();
    }

    try {
      final response = await _repository.getUpcomingSessions(userId);
      _upcomingSessions = response.data;
      _lastFetched = DateTime.now();
      debugPrint('Upcoming sessions loaded: ${_upcomingSessions?.length ?? 0}');
    } on ApiError catch (e) {
      _error = e.message;
      debugPrint('Error loading upcoming sessions: ${e.message}');
      rethrow;
    } finally {
      _isLoading = false;

      // Safe notifyListeners call
      if (WidgetsBinding.instance.schedulerPhase ==
          SchedulerPhase.persistentCallbacks) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      } else {
        notifyListeners();
      }
    }
  }

  Future<void> loadPastSessions(
    String userId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        _pastSessions != null &&
        isCacheValid(const Duration(minutes: 5))) {
      return;
    }

    _isLoading = true;
    clearError();
    notifyListeners();

    try {
      final response = await _repository.getPastSessions(userId);
      _pastSessions = response.data;
      _lastFetched = DateTime.now();
      debugPrint('Past sessions loaded: ${_pastSessions?.length ?? 0}');
    } on ApiError catch (e) {
      _error = e.message;
      debugPrint('Error loading past sessions: ${e.message}');
      rethrow;
    } finally {
      debugPrint('Past sessions loaded: ${_pastSessions?.length ?? 0}');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPendingSessions(
    String userId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        _pendingSessions != null &&
        isCacheValid(const Duration(minutes: 5))) {
      return;
    }

    _isLoading = true;
    clearError();
    notifyListeners();

    try {
      final response = await _repository.getPendingSessions(userId);
      _pendingSessions = response.data;
      _lastFetched = DateTime.now();
      debugPrint('Pending sessions loaded: ${_pendingSessions?.length ?? 0}');
    } on ApiError catch (e) {
      _error = e.message;
      debugPrint('Error loading pending sessions: ${e.message}');
      rethrow;
    } finally {
      debugPrint('Pending sessions loaded: ${_pendingSessions?.length ?? 0}');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSessionDetails(String userId, String sessionId) async {
    _isLoading = true;
    clearError();
    notifyListeners();

    try {
      final response = await _repository.getSessionDetails(userId, sessionId);
      _selectedSession = response.data;
    } on ApiError catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelSession(String userId, String sessionId) async {
    _isLoading = true;
    clearError();
    notifyListeners();

    try {
      await _repository.cancelSession(userId, sessionId);
      _upcomingSessions?.removeWhere((session) => session.id == sessionId);
      _pendingSessions?.removeWhere((session) => session.id == sessionId);
      if (_selectedSession?.id == sessionId) {
        _selectedSession = null;
      }
    } on ApiError catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> rescheduleSession(
    String userId,
    String sessionId,
    DateTime startTime,
  ) async {
    _isLoading = true;
    clearError();
    notifyListeners();

    try {
      ValidationUtil.validateSessionTiming(startTime);
      await _repository.rescheduleSession(userId, sessionId, startTime);
      _updateSessionTime(sessionId, startTime);
    } on ApiError catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitFeedback(
    String userId,
    String sessionId,
    int rating,
    String review,
  ) async {
    _isLoading = true;
    clearError();
    notifyListeners();

    try {
      ValidationUtil.validateRating(rating);
      await _repository.submitFeedback(userId, sessionId, rating, review);
      _updateSessionAfterFeedback(sessionId, rating, review);
    } on ApiError catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Session> applyForSession({
    required String userId,
    required String title,
    required String subject,
    required String level,
    required String description,
    required DateTime startTime,
    required Duration duration,
    required String platform,
    String? notes,
  }) async {
    _isLoading = true;
    clearError();
    notifyListeners();

    try {
      ValidationUtil.validateSessionTiming(startTime);
      ValidationUtil.validateDuration(duration.inMinutes);
      final response = await _repository.applyForSession(
        userId: userId,
        title: title,
        subject: subject,
        level: level,
        description: description,
        startTime: startTime,
        duration: duration,
        platform: platform,
        notes: notes,
      );
      _pendingSessions = [...?_pendingSessions, response.data!];
      return response.data!;
    } on ApiError catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Session> organizeSession({
    required String userId,
    required String title,
    required String subject,
    required String level,
    required String description,
    required DateTime startTime,
    required Duration duration,
    required String platform,
    required int maxParticipants,
    bool isRecurring = false,
    String? recurringPattern,
    bool isPaid = false,
    double price = 0.0,
  }) async {
    _isLoading = true;
    clearError();
    notifyListeners();

    try {
      ValidationUtil.validateSessionTiming(startTime);
      ValidationUtil.validateDuration(duration.inMinutes);
      ValidationUtil.validateMaxParticipants(maxParticipants);
      ValidationUtil.validatePrice(isPaid, price);
      final response = await _repository.organizeSession(
        userId: userId,
        title: title,
        subject: subject,
        level: level,
        description: description,
        startTime: startTime,
        duration: duration,
        platform: platform,
        maxParticipants: maxParticipants,
        isRecurring: isRecurring,
        recurringPattern: recurringPattern,
        isPaid: isPaid,
        price: price,
      );
      _upcomingSessions = [...?_upcomingSessions, response.data!];
      return response.data!;
    } on ApiError catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAvailableSessions({
    String? subject,
    String? level,
    DateTime? startDate,
    DateTime? endDate,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        _availableSessions != null &&
        isCacheValid(const Duration(minutes: 5))) {
      return;
    }

    _isLoading = true;
    clearError();
    notifyListeners();

    try {
      final response = await _repository.getAvailableSessions(
        subject: subject,
        level: level,
        startDate: startDate,
        endDate: endDate,
      );
      _availableSessions = response.data;
      _lastFetched = DateTime.now();
    } on ApiError catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> joinSession(String userId, String sessionId) async {
    _isLoading = true;
    clearError();
    notifyListeners();

    try {
      await _repository.joinSession(userId, sessionId);
      final sessionResponse = await _repository.getSessionDetails(
        userId,
        sessionId,
      );
      final session = sessionResponse.data;
      if (session != null) {
        _upcomingSessions = [...?_upcomingSessions, session];
        _availableSessions =
            _availableSessions
                ?.map((s) => s.id == sessionId ? session : s)
                .toList();
      }
    } on ApiError catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> leaveSession(String userId, String sessionId) async {
    _isLoading = true;
    clearError();
    notifyListeners();

    try {
      await _repository.leaveSession(userId, sessionId);
      _upcomingSessions?.removeWhere((session) => session.id == sessionId);
      final sessionResponse = await _repository.getSessionDetails(
        userId,
        sessionId,
      );
      final session = sessionResponse.data;
      if (session != null) {
        _availableSessions =
            _availableSessions
                ?.map((s) => s.id == sessionId ? session : s)
                .toList();
      }
    } on ApiError catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSelectedSession() {
    _selectedSession = null;
    notifyListeners();
  }

  void clearAvailableSessions() {
    _availableSessions = null;
    notifyListeners();
  }

  void refreshAllSessions(String userId) {
    loadUpcomingSessions(userId, forceRefresh: true);
    loadPastSessions(userId, forceRefresh: true);
    loadPendingSessions(userId, forceRefresh: true);
    loadAvailableSessions(forceRefresh: true);
  }

  void _updateSessionTime(String sessionId, DateTime startTime) {
    _upcomingSessions =
        _upcomingSessions
            ?.map(
              (session) =>
                  session.id == sessionId
                      ? session.copyWith(
                        startTime: startTime,
                        updatedAt: DateTime.now(),
                      )
                      : session,
            )
            .toList();
    _pendingSessions =
        _pendingSessions
            ?.map(
              (session) =>
                  session.id == sessionId
                      ? session.copyWith(
                        startTime: startTime,
                        updatedAt: DateTime.now(),
                      )
                      : session,
            )
            .toList();
    if (_selectedSession?.id == sessionId) {
      _selectedSession = _selectedSession?.copyWith(
        startTime: startTime,
        updatedAt: DateTime.now(),
      );
    }
  }

  void _updateSessionAfterFeedback(
    String sessionId,
    int rating,
    String review,
  ) {
    _upcomingSessions =
        _upcomingSessions
            ?.map(
              (session) =>
                  session.id == sessionId
                      ? session.copyWith(
                        rating: rating.toDouble(),
                        review: review,
                        status: SessionStatus.completed,
                        updatedAt: DateTime.now(),
                      )
                      : session,
            )
            .toList();
    _pastSessions =
        _pastSessions
            ?.map(
              (session) =>
                  session.id == sessionId
                      ? session.copyWith(
                        rating: rating.toDouble(),
                        review: review,
                        status: SessionStatus.completed,
                        updatedAt: DateTime.now(),
                      )
                      : session,
            )
            .toList();
    if (_selectedSession?.id == sessionId) {
      _selectedSession = _selectedSession?.copyWith(
        rating: rating.toDouble(),
        review: review,
        status: SessionStatus.completed,
        updatedAt: DateTime.now(),
      );
    }
  }
}

/// Home Provider
class HomeProvider extends BaseProvider {
  final HomeRepository _repository;
  UserStats? _userStats;
  List<Activity>? _recentActivities;
  List<Session>? _upcomingSessionsPreview;

  HomeProvider(this._repository);

  UserStats? get userStats => _userStats;
  List<Activity>? get recentActivities => _recentActivities;
  List<Session>? get upcomingSessionsPreview => _upcomingSessionsPreview;

  Future<void> loadHomeData(String userId, {bool forceRefresh = false}) async {
    if (!forceRefresh && isCacheValid(const Duration(minutes: 5))) return;

    _isLoading = true;
    clearError();
    notifyListeners();

    try {
      final responses = await Future.wait([
        _repository.getUserStats(userId),
        _repository.getRecentActivities(userId: userId),
        _repository.getUpcomingSessionsPreview(userId),
      ]);

      _userStats = responses[0].data as UserStats?;
      _recentActivities = responses[1].data as List<Activity>?;
      _upcomingSessionsPreview = responses[2].data as List<Session>?;
      _lastFetched = DateTime.now();
    } on ApiError catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

/// Tutor Provider
class TutorProvider extends BaseProvider {
  final TutorRepository _repository;
  List<Tutor>? _tutors;
  Tutor? _selectedTutor;
  List<TutorApplication>? _tutorApplications;
  String? _currentSubjectFilter;
  String? _currentAvailabilityFilter;
  double? _currentMinRating;
  int _currentPage = 1;
  bool _hasMore = true;

  TutorProvider(this._repository);

  List<Tutor>? get tutors => _tutors;
  Tutor? get selectedTutor => _selectedTutor;
  List<TutorApplication>? get tutorApplications => _tutorApplications;
  String? get currentSubjectFilter => _currentSubjectFilter;
  String? get currentAvailabilityFilter => _currentAvailabilityFilter;
  double? get currentMinRating => _currentMinRating;
  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;

  Future<void> loadTutors({
    String? subject,
    String? availability,
    double? minRating,
    int page = 1,
    bool loadMore = false,
  }) async {
    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      _tutors = null;
    }

    _isLoading = true;
    clearError();
    _currentSubjectFilter = subject;
    _currentAvailabilityFilter = availability;
    _currentMinRating = minRating;
    notifyListeners();

    try {
      final response = await _repository.getTutors(
        subject: subject,
        availability: availability,
        minRating: minRating,
        limit: 10,
        offset: (page - 1) * 10,
      );

      _tutors =
          loadMore && _tutors != null
              ? [...?_tutors, ...?response.data]
              : response.data;
      _hasMore = response.data?.length == 10;
      _currentPage = page;
      _lastFetched = DateTime.now();
    } on ApiError catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreTutors() async {
    if (_hasMore && !_isLoading) {
      await loadTutors(
        subject: _currentSubjectFilter,
        availability: _currentAvailabilityFilter,
        minRating: _currentMinRating,
        page: _currentPage + 1,
        loadMore: true,
      );
    }
  }

  Future<void> loadTutorDetails(String tutorId) async {
    _isLoading = true;
    clearError();
    notifyListeners();

    try {
      final response = await _repository.getTutorDetails(tutorId);
      _selectedTutor = response.data;
    } on ApiError catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTutorApplications(String userId) async {
    _isLoading = true;
    clearError();
    notifyListeners();

    try {
      final response = await _repository.getTutorApplications(userId);
      _tutorApplications = response.data;
    } on ApiError catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> bookTutorSession({
    required BuildContext context,
    required String userId,
    required String tutorId,
    required String subject,
    required DateTime startTime,
    required int durationMinutes,
    required String platform,
    String? description,
  }) async {
    _isLoading = true;
    clearError();
    notifyListeners();

    try {
      ValidationUtil.validateSessionTiming(startTime);
      ValidationUtil.validateDuration(durationMinutes);
      final response = await _repository.bookSession(
        userId: userId,
        tutorId: tutorId,
        subject: subject,
        startTime: startTime,
        durationMinutes: durationMinutes,
        platform: platform,
        description: description,
      );
      // Fetch the new session and add to _pendingSessions
      final sessionResponse = await SessionRepository().getSessionDetails(
        userId,
        response.data!,
      );
      final sessionProvider = Provider.of<SessionProvider>(
        context,
        listen: false,
      );
      if (sessionResponse.data != null) {
        sessionProvider._pendingSessions = [
          ...?sessionProvider._pendingSessions,
          sessionResponse.data!,
        ];
      }
    } on ApiError catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitTutorApplication({
    required String userId,
    required Map<String, dynamic> personalInfo,
    required List<String> subjects,
    required Map<String, List<String>> availability,
    String? teachingMode,
    String? venue,
  }) async {
    _isLoading = true;
    clearError();
    notifyListeners();

    try {
      await _repository.submitTutorApplication(
        userId: userId,
        personalInfo: personalInfo,
        subjects: subjects,
        availability: availability,
        teachingMode: teachingMode,
        venue: venue,
      );
      await loadTutorApplications(userId); // Refresh applications
    } on ApiError catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> approveTutorApplication({
    required String applicationId,
    required String name,
    String? bio,
    String? education,
    String? experience,
    String? teachingStyle,
    String? profilePicture,
  }) async {
    _isLoading = true;
    clearError();
    notifyListeners();

    try {
      final response = await _repository.approveTutorApplication(
        applicationId: applicationId,
        name: name,
        bio: bio,
        education: education,
        experience: experience,
        teachingStyle: teachingStyle,
        profilePicture: profilePicture,
      );
      _tutors = [...?_tutors, response.data!];
      _tutorApplications =
          _tutorApplications?.where((app) => app.id != applicationId).toList();
    } on ApiError catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

/// Chat Provider
class ChatProvider extends BaseProvider {
  final ChatRepository _repository;
  final Map<String, List<Chat>> _chatCache = {};
  final Map<String, List<Message>> _messageCache = {};
  List<Chat> _chats = [];
  List<Message> _messages = [];

  ChatProvider(this._repository);

  List<Chat> get chats => _chats;
  List<Message> get messages => _messages;

  Future<void> loadChats(String userId, {bool forceRefresh = false}) async {
    if (!forceRefresh && _chatCache.containsKey(userId)) {
      _chats = _chatCache[userId]!;
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      clearError();
      notifyListeners();

      _chats = await _repository.getChats(userId);
      _chatCache[userId] = _chats;
      _lastFetched = DateTime.now();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMessages(String chatId, {bool forceRefresh = false}) async {
    if (!forceRefresh && _messageCache.containsKey(chatId)) {
      _messages = _messageCache[chatId]!;
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      clearError();
      notifyListeners();

      _messages = await _repository.getMessages(chatId);
      _messageCache[chatId] = _messages;
      _lastFetched = DateTime.now();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(Message message) async {
    try {
      _isLoading = true;
      clearError();
      notifyListeners();

      await _repository.sendMessage(message);
      _messageCache[message.chatId] = [
        message,
        ..._messageCache[message.chatId] ?? [],
      ];
      _messages = _messageCache[message.chatId]!;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> createChat(
    String currentUserId,
    String currentUserName,
    String otherUserId,
    String otherUserName,
  ) async {
    try {
      _isLoading = true;
      clearError();
      notifyListeners();

      final batch = FirebaseFirestore.instance.batch();
      final chatId = FirebaseFirestore.instance.collection('chats').doc().id;

      final users = await Future.wait([
        FirebaseFirestore.instance.collection('users').doc(currentUserId).get(),
        FirebaseFirestore.instance.collection('users').doc(otherUserId).get(),
      ]);

      final currentUserProfilePicture =
          users[0].data()?['profile_picture'] as String?;
      final otherUserProfilePicture =
          users[1].data()?['profile_picture'] as String?;

      final chatData = {
        'members': [currentUserId, otherUserId],
        'last_message': '',
        'last_message_time': FieldValue.serverTimestamp(),
        'created_at': FieldValue.serverTimestamp(),
      };

      final currentUserChat = Chat(
        id: chatId,
        name: otherUserName,
        imageUrl: otherUserProfilePicture,
        lastMessage: '',
        lastMessageTime: DateTime.now(),
        unreadCount: 0,
      );

      final otherUserChat = Chat(
        id: chatId,
        name: currentUserName,
        imageUrl: currentUserProfilePicture,
        lastMessage: '',
        lastMessageTime: DateTime.now(),
        unreadCount: 0,
      );

      batch.set(
        FirebaseFirestore.instance.collection('chats').doc(chatId),
        chatData,
      );
      batch.set(
        FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .collection('chats')
            .doc(chatId),
        currentUserChat.toJson(),
      );
      batch.set(
        FirebaseFirestore.instance
            .collection('users')
            .doc(otherUserId)
            .collection('chats')
            .doc(chatId),
        otherUserChat.toJson(),
      );

      await batch.commit();

      _chatCache[currentUserId] = [
        currentUserChat,
        ..._chatCache[currentUserId] ?? [],
      ];
      _chats = _chatCache[currentUserId]!;
      return chatId;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearCache() {
    _chatCache.clear();
    _messageCache.clear();
    _chats = [];
    _messages = [];
    notifyListeners();
  }

  @override
  void dispose() {
    clearCache();
    super.dispose();
  }
}

/// Analytics Provider
class AnalyticsProvider extends BaseProvider {
  final AnalyticsRepository _repository;
  List<WeeklyActivity>? _weeklyActivity;
  List<SubjectDistribution>? _subjectDistribution;
  List<TutorPerformance>? _tutorPerformance;
  DateTimeRange? _dateRange;

  AnalyticsProvider(this._repository);

  List<WeeklyActivity>? get weeklyActivity => _weeklyActivity;
  List<SubjectDistribution>? get subjectDistribution => _subjectDistribution;
  List<TutorPerformance>? get tutorPerformance => _tutorPerformance;
  DateTimeRange? get dateRange => _dateRange;

  void setDateRange(DateTimeRange range) {
    if (_dateRange != range) {
      _dateRange = range;
      notifyListeners();
    }
  }

  Future<void> loadAnalyticsData(
    String userId, {
    DateTimeRange? dateRange,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && isCacheValid(const Duration(minutes: 30))) return;

    _isLoading = true;
    clearError();
    _dateRange = dateRange ?? _dateRange;
    notifyListeners();

    try {
      final responses = await Future.wait([
        _repository.getWeeklyActivity(userId),
        _repository.getSubjectDistribution(userId),
        _repository.getTutorPerformance(),
      ]);

      _weeklyActivity = responses[0].data?.cast<WeeklyActivity>();
      _subjectDistribution = responses[1].data?.cast<SubjectDistribution>();
      _tutorPerformance = responses[2].data?.cast<TutorPerformance>();
      _lastFetched = DateTime.now();
    } on ApiError catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

/// Study Materials Provider
class StudyMaterialsProvider extends BaseProvider {
  final StudyMaterialsRepository _repository;
  List<StudyMaterial>? _studyMaterials;

  StudyMaterialsProvider(this._repository);

  List<StudyMaterial>? get studyMaterials => _studyMaterials;

  Future<void> loadStudyMaterials(
    String userId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        _studyMaterials != null &&
        isCacheValid(const Duration(minutes: 30)))
      return;

    _isLoading = true;
    clearError();
    notifyListeners();

    try {
      final response = await _repository.getStudyMaterials(userId);
      _studyMaterials = response.data;
      _lastFetched = DateTime.now();
    } on ApiError catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

/// Practice Tests Provider
class PracticeTestsProvider extends BaseProvider {
  final PracticeTestsRepository _repository;
  List<PracticeTest>? _practiceTests;
  List<TestQuestion>? _testQuestions;
  String? _selectedTestId;
  Map<String, dynamic>? _testResults;
  String? _currentSubjectFilter;
  String? _currentDifficultyFilter;
  String? _currentSortBy;

  PracticeTestsProvider(this._repository);

  List<PracticeTest>? get practiceTests => _practiceTests;
  List<TestQuestion>? get testQuestions => _testQuestions;
  String? get selectedTestId => _selectedTestId;
  Map<String, dynamic>? get testResults => _testResults;
  String? get currentSubjectFilter => _currentSubjectFilter;
  String? get currentDifficultyFilter => _currentDifficultyFilter;
  String? get currentSortBy => _currentSortBy;

  Future<void> loadPracticeTests({
    String? userId,
    String? subject,
    String? difficulty,
    String? sortBy,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        _practiceTests != null &&
        _currentSubjectFilter == subject &&
        _currentDifficultyFilter == difficulty &&
        _currentSortBy == sortBy &&
        isCacheValid(const Duration(minutes: 30))) {
      return;
    }

    _isLoading = true;
    clearError();
    _currentSubjectFilter = subject;
    _currentDifficultyFilter = difficulty;
    _currentSortBy = sortBy;
    notifyListeners();

    try {
      final response = await _repository.getPracticeTests(
        userId: userId,
        subject: subject,
        difficulty: difficulty,
        sortBy: sortBy,
      );
      _practiceTests = response.data;
      _lastFetched = DateTime.now();
    } on ApiError catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTestQuestions(String testId) async {
    _isLoading = true;
    clearError();
    _selectedTestId = testId;
    notifyListeners();

    try {
      final response = await _repository.getTestQuestions(testId);
      _testQuestions = response.data;
    } on ApiError catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitTestAnswers(
    String testId,
    Map<int, String> answers,
    String userId,
  ) async {
    _isLoading = true;
    clearError();
    notifyListeners();

    try {
      await _repository.submitTestAnswers(testId, answers, userId);
      _testResults = {'score': 85, 'correct': 17, 'total': 20};
    } on ApiError catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

/// Saved Items Provider
class SavedItemsProvider extends BaseProvider {
  final SavedItemsRepository _repository;
  List<SavedItem>? _savedSessions;
  List<SavedItem>? _savedMaterials;
  List<SavedItem>? _savedTests;

  SavedItemsProvider(this._repository);

  List<SavedItem>? get savedSessions => _savedSessions;
  List<SavedItem>? get savedMaterials => _savedMaterials;
  List<SavedItem>? get savedTests => _savedTests;

  Future<void> loadSavedItems(
    String userId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        _savedSessions != null &&
        _savedMaterials != null &&
        _savedTests != null &&
        isCacheValid(const Duration(minutes: 30))) {
      return;
    }

    _isLoading = true;
    clearError();
    notifyListeners();

    try {
      final responses = await Future.wait([
        _repository.getSavedItems(userId, 'Session'),
        _repository.getSavedItems(userId, 'Material'),
        _repository.getSavedItems(userId, 'Test'),
      ]);

      _savedSessions = responses[0].data?.cast<SavedItem>();
      _savedMaterials = responses[1].data?.cast<SavedItem>();
      _savedTests = responses[2].data?.cast<SavedItem>();
      _lastFetched = DateTime.now();
    } on ApiError catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeSavedItem(String userId, String itemId) async {
    _isLoading = true;
    clearError();
    notifyListeners();

    try {
      await _repository.removeSavedItem(userId, itemId);
      // Refresh the saved items after removal
      await loadSavedItems(userId, forceRefresh: true);
    } on ApiError catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

/// Lecturer Dashboard Provider
class LecturerDashboardProvider with ChangeNotifier {
  final TutorRepository _tutorRepository = TutorRepository();
  final StudyMaterialsRepository _studyMaterialsRepository =
      StudyMaterialsRepository();
  final AnalyticsRepository _analyticsRepository = AnalyticsRepository();
  final SessionRepository sessionRepository = SessionRepository();

  List<Tutor> _tutors = [];
  List<TutorApplication> _tutorApplications = [];
  List<StudyMaterial> _studyMaterials = [];
  List<WeeklyActivity> _weeklyActivities = [];
  List<SubjectDistribution> _subjectDistributions = [];
  List<Session> _sessions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Tutor> get tutors => _tutors;
  List<TutorApplication> get tutorApplications => _tutorApplications;
  List<StudyMaterial> get studyMaterials => _studyMaterials;
  List<WeeklyActivity> get weeklyActivities => _weeklyActivities;
  List<SubjectDistribution> get subjectDistributions => _subjectDistributions;
  List<Session> get sessions => _sessions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchTutors() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _tutorRepository.getTutors(limit: 50);
      _tutors = response.data ?? [];
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTutorApplications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _tutorRepository.getTutorApplications(
        FirebaseConfig.firebaseAuth.currentUser?.uid ?? '',
      );
      _tutorApplications = response.data ?? [];
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> approveTutorApplication(
    String applicationId,
    String name,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _tutorRepository.approveTutorApplication(
        applicationId: applicationId,
        name: name,
      );
      _tutorApplications.removeWhere((app) => app.id == applicationId);
      await fetchTutors();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchStudyMaterials(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _studyMaterialsRepository.getStudyMaterials(
        userId,
      );
      _studyMaterials = response.data ?? [];
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addStudyMaterial({
    required String userId,
    required String subject,
    required int resourceCount,
    required double progress,
    required Color color,
    required IconData icon,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final material = StudyMaterial(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        subject: subject,
        resourceCount: resourceCount,
        progress: progress,
        color: color,
        icon: icon,
      );
      await FirebaseConfig.firestore
          .collection('users')
          .doc(userId)
          .collection('study_materials')
          .doc(material.id)
          .set(material.toJson());
      await fetchStudyMaterials(userId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAnalytics(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final weeklyResponse = await _analyticsRepository.getWeeklyActivity(
        userId,
      );
      final subjectResponse = await _analyticsRepository.getSubjectDistribution(
        userId,
      );
      _weeklyActivities = weeklyResponse.data ?? [];
      _subjectDistributions = subjectResponse.data ?? [];
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSessions() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await sessionRepository.getAvailableSessions();
      _sessions = response.data ?? [];
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

/// MultiProvider Setup
List<SingleChildWidget> getProviders() {
  return [
    ChangeNotifierProvider(create: (_) => AppProvider()),
    Provider(create: (_) => AuthRepository()),
    ChangeNotifierProxyProvider<AppProvider, AuthProvider>(
      create: (_) => AuthProvider(AuthRepository()),
      update: (_, __, provider) => provider!,
    ),
    Provider(create: (_) => AchievementsRepository()),
    ChangeNotifierProxyProvider<AppProvider, AchievementsProvider>(
      create: (_) => AchievementsProvider(AchievementsRepository()),
      update: (_, __, provider) => provider!,
    ),
    Provider(create: (_) => LeaderboardRepository()),
    ChangeNotifierProxyProvider<AppProvider, LeaderboardProvider>(
      create: (_) => LeaderboardProvider(LeaderboardRepository()),
      update: (_, __, provider) => provider!,
    ),
    Provider(create: (_) => SessionRepository()),
    ChangeNotifierProxyProvider<AppProvider, SessionProvider>(
      create: (_) => SessionProvider(SessionRepository()),
      update: (_, __, provider) => provider!,
    ),
    Provider(create: (_) => HomeRepository()),
    ChangeNotifierProxyProvider<AppProvider, HomeProvider>(
      create: (_) => HomeProvider(HomeRepository()),
      update: (_, __, provider) => provider!,
    ),
    Provider(create: (_) => TutorRepository()),
    ChangeNotifierProxyProvider<AppProvider, TutorProvider>(
      create: (_) => TutorProvider(TutorRepository()),
      update: (_, __, provider) => provider!,
    ),
    Provider(create: (_) => ChatRepository()),
    ChangeNotifierProxyProvider<AppProvider, ChatProvider>(
      create: (_) => ChatProvider(ChatRepository()),
      update: (_, __, provider) => provider!,
    ),
    Provider(create: (_) => AnalyticsRepository()),
    ChangeNotifierProxyProvider<AppProvider, AnalyticsProvider>(
      create: (_) => AnalyticsProvider(AnalyticsRepository()),
      update: (_, __, provider) => provider!,
    ),
    Provider(create: (_) => StudyMaterialsRepository()),
    ChangeNotifierProxyProvider<AppProvider, StudyMaterialsProvider>(
      create: (_) => StudyMaterialsProvider(StudyMaterialsRepository()),
      update: (_, __, provider) => provider!,
    ),
    Provider(create: (_) => SavedItemsRepository()),
    ChangeNotifierProxyProvider<AppProvider, SavedItemsProvider>(
      create: (_) => SavedItemsProvider(SavedItemsRepository()),
      update: (_, __, provider) => provider!,
    ),
    Provider(create: (_) => PracticeTestsRepository()),
    ChangeNotifierProxyProvider<AppProvider, PracticeTestsProvider>(
      create: (_) => PracticeTestsProvider(PracticeTestsRepository()),
      update: (_, __, provider) => provider!,
    ),
  ];
}

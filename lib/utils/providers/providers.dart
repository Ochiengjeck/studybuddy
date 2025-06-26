import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../modelsAndRepsositories/models_and_repositories.dart';

// 1. Main App Provider
class AppProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isInitializing = false;
  String? _initializationError;

  User? get currentUser => _currentUser;
  bool get isInitializing => _isInitializing;
  String? get initializationError => _initializationError;

  Future<void> initializeApp() async {
    if (_isInitializing) return;
    _isInitializing = true;
    _initializationError = null;
    notifyListeners();

    try {
      final firebaseUser = auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        final response = await AuthRepository().getCurrentUser('');
        _currentUser = response.data;
      }
    } catch (e) {
      _initializationError = e.toString();
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  void setCurrentUser(User? user) {
    _currentUser = user;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}

// 2. Auth Provider
class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthProvider(this._authRepository);

  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  Future<ApiResponse<User>> login(LoginRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authRepository.login(request);
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return response;
    } on ApiError catch (e) {
      _isLoading = false;
      _error = e.message;
      _isAuthenticated = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<ApiResponse<User>> register(RegisterRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authRepository.register(request);
      _isLoading = false;
      notifyListeners();
      return response;
    } on ApiError catch (e) {
      _isLoading = false;
      _error = e.message;
      notifyListeners();
      rethrow;
    }
  }

  Future<ApiResponse<User>> getCurrentUser() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authRepository.getCurrentUser('');
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return response;
    } on ApiError catch (e) {
      _isLoading = false;
      _error = e.message;
      _isAuthenticated = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<ApiResponse<void>> logout() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authRepository.logout('');
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
      return response;
    } on ApiError catch (e) {
      _isLoading = false;
      _error = e.message;
      notifyListeners();
      rethrow;
    }
  }
}

// 3. Achievements Provider
class AchievementsProvider extends ChangeNotifier {
  final AchievementsRepository _repository;

  AchievementsProvider(this._repository);

  bool _isLoading = false;
  String? _error;
  List<Achievement>? _achievements;
  UserStats? _userStats;
  DateTime? _lastFetched;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Achievement>? get achievements => _achievements;
  UserStats? get userStats => _userStats;

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  Future<void> loadAchievements(
    String userId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _achievements != null && _isCacheValid) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.getAchievements(userId);
      _achievements = response.data;
      _lastFetched = DateTime.now();
      _isLoading = false;
      notifyListeners();
    } on ApiError catch (e) {
      _isLoading = false;
      _error = e.message;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadUserStats(String userId, {bool forceRefresh = false}) async {
    if (!forceRefresh && _userStats != null && _isCacheValid) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.getUserStats(userId);
      _userStats = response.data;
      _lastFetched = DateTime.now();
      _isLoading = false;
      notifyListeners();
    } on ApiError catch (e) {
      _isLoading = false;
      _error = e.message;
      notifyListeners();
      rethrow;
    }
  }

  bool get _isCacheValid =>
      _lastFetched != null &&
      DateTime.now().difference(_lastFetched!) < const Duration(minutes: 5);
}

// 4. Leaderboard Provider
class LeaderboardProvider extends ChangeNotifier {
  final LeaderboardRepository _repository;

  LeaderboardProvider(this._repository);

  bool _isLoading = false;
  String? _error;
  List<LeaderboardUser>? _leaderboard;
  List<LeaderboardUser>? _topPerformers;
  String _currentFilter = 'overall';
  DateTime? _lastFetched;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<LeaderboardUser>? get leaderboard => _leaderboard;
  List<LeaderboardUser>? get topPerformers => _topPerformers;
  String get currentFilter => _currentFilter;

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  Future<void> loadLeaderboard({
    String filter = 'overall',
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        _leaderboard != null &&
        _currentFilter == filter &&
        _isCacheValid)
      return;

    _isLoading = true;
    _error = null;
    _currentFilter = filter;
    notifyListeners();

    try {
      final response = await _repository.getLeaderboard(filter: filter);
      _leaderboard = response.data;
      _lastFetched = DateTime.now();
      _isLoading = false;
      notifyListeners();
    } on ApiError catch (e) {
      _isLoading = false;
      _error = e.message;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadTopPerformers({bool forceRefresh = false}) async {
    if (!forceRefresh && _topPerformers != null && _isCacheValid) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.getTopPerformers();
      _topPerformers = response.data;
      _lastFetched = DateTime.now();
      _isLoading = false;
      notifyListeners();
    } on ApiError catch (e) {
      _isLoading = false;
      _error = e.message;
      notifyListeners();
      rethrow;
    }
  }

  bool get _isCacheValid =>
      _lastFetched != null &&
      DateTime.now().difference(_lastFetched!) < const Duration(minutes: 5);
}

// 5. Session Provider
// Enhanced Session Provider
class SessionProvider extends ChangeNotifier {
  final SessionRepository _repository;

  SessionProvider(this._repository);

  bool _isLoading = false;
  String? _error;
  List<Session>? _upcomingSessions;
  List<Session>? _pastSessions;
  List<Session>? _pendingSessions;
  List<Session>? _availableSessions;
  Session? _selectedSession;
  DateTime? _lastFetched;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Session>? get upcomingSessions => _upcomingSessions;
  List<Session>? get pastSessions => _pastSessions;
  List<Session>? get pendingSessions => _pendingSessions;
  List<Session>? get availableSessions => _availableSessions;
  Session? get selectedSession => _selectedSession;

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  // Existing methods
  Future<void> loadUpcomingSessions(
    String userId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _upcomingSessions != null && _isCacheValid) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.getUpcomingSessions(userId);
      _upcomingSessions = response.data;
      _lastFetched = DateTime.now();
      _isLoading = false;
      notifyListeners();
    } on ApiError catch (e) {
      _isLoading = false;
      _error = e.message;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadPastSessions(
    String userId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _pastSessions != null && _isCacheValid) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.getPastSessions(userId);
      _pastSessions = response.data;
      _lastFetched = DateTime.now();
      _isLoading = false;
      notifyListeners();
    } on ApiError catch (e) {
      _isLoading = false;
      _error = e.message;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadPendingSessions(
    String userId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _pendingSessions != null && _isCacheValid) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.getPendingSessions(userId);
      _pendingSessions = response.data;
      _lastFetched = DateTime.now();
      _isLoading = false;
      notifyListeners();
    } on ApiError catch (e) {
      _isLoading = false;
      _error = e.message;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadSessionDetails(String userId, String sessionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.getSessionDetails(userId, sessionId);
      _selectedSession = response.data;
      _isLoading = false;
      notifyListeners();
    } on ApiError catch (e) {
      _isLoading = false;
      _error = e.message;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> cancelSession(String userId, String sessionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.cancelSession(userId, sessionId);
      _upcomingSessions?.removeWhere((session) => session.id == sessionId);
      _isLoading = false;
      notifyListeners();
    } on ApiError catch (e) {
      _isLoading = false;
      _error = e.message;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> rescheduleSession(
    String userId,
    String sessionId,
    DateTime newStartTime,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.rescheduleSession(userId, sessionId, newStartTime);

      if (_upcomingSessions != null) {
        _upcomingSessions =
            _upcomingSessions?.map((session) {
              if (session.id == sessionId) {
                return session.copyWith(startTime: newStartTime);
              }
              return session;
            }).toList();
      }

      if (_pendingSessions != null) {
        _pendingSessions =
            _pendingSessions?.map((session) {
              if (session.id == sessionId) {
                return session.copyWith(startTime: newStartTime);
              }
              return session;
            }).toList();
      }

      if (_selectedSession?.id == sessionId) {
        _selectedSession = _selectedSession?.copyWith(startTime: newStartTime);
      }

      _isLoading = false;
      notifyListeners();
    } on ApiError catch (e) {
      _isLoading = false;
      _error = e.message;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> submitFeedback(
    String userId,
    String sessionId,
    int rating,
    String review,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.submitFeedback(userId, sessionId, rating, review);

      // Move session from upcoming to past sessions
      if (_upcomingSessions != null) {
        final sessionIndex = _upcomingSessions!.indexWhere(
          (s) => s.id == sessionId,
        );
        if (sessionIndex != -1) {
          final session = _upcomingSessions![sessionIndex];
          _upcomingSessions!.removeAt(sessionIndex);

          // Add to past sessions if loaded
          // if (_pastSessions != null) {
          //   _pastSessions!.add(
          //     session.copyWith(
          //       rating: rating,
          //       review: review,
          //       status: 'completed',
          //     ),
          //   );
          // }
        }
      }

      _isLoading = false;
      notifyListeners();
    } on ApiError catch (e) {
      _isLoading = false;
      _error = e.message;
      notifyListeners();
      rethrow;
    }
  }

  // NEW METHODS

  Future<Session> applyForSession({
    required String userId,
    required String title,
    required String subject,
    required String level,
    required String description,
    required DateTime preferredDateTime,
    required Duration duration,
    required String platform,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.applyForSession(
        userId: userId,
        title: title,
        subject: subject,
        level: level,
        description: description,
        preferredDateTime: preferredDateTime,
        duration: duration,
        platform: platform,
        notes: notes,
      );

      // Add to pending sessions if loaded
      if (_pendingSessions != null) {
        _pendingSessions!.add(response.data!);
      }

      _isLoading = false;
      notifyListeners();

      return response.data!;
    } on ApiError catch (e) {
      _isLoading = false;
      _error = e.message;
      notifyListeners();
      rethrow;
    }
  }

  Future<Session> organizeSession({
    required String userId,
    required String title,
    required String subject,
    required String level,
    required String description,
    required DateTime scheduledDateTime,
    required Duration duration,
    required String platform,
    required int maxParticipants,
    bool isRecurring = false,
    String? recurringPattern,
    bool isPaid = false,
    double price = 0.0,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.organizeSession(
        userId: userId,
        title: title,
        subject: subject,
        level: level,
        description: description,
        scheduledDateTime: scheduledDateTime,
        duration: duration,
        platform: platform,
        maxParticipants: maxParticipants,
        isRecurring: isRecurring,
        recurringPattern: recurringPattern,
        isPaid: isPaid,
        price: price,
      );

      // Add to upcoming sessions if loaded
      if (_upcomingSessions != null) {
        _upcomingSessions!.add(response.data!);
      }

      _isLoading = false;
      notifyListeners();

      return response.data!;
    } on ApiError catch (e) {
      _isLoading = false;
      _error = e.message;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadAvailableSessions({
    String? subject,
    String? level,
    DateTime? startDate,
    DateTime? endDate,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _availableSessions != null && _isCacheValid) return;

    _isLoading = true;
    _error = null;
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
      _isLoading = false;
      notifyListeners();
    } on ApiError catch (e) {
      _isLoading = false;
      _error = e.message;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> joinSession(String userId, String sessionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.joinSession(userId, sessionId);

      // Update available sessions to reflect the change
      // if (_availableSessions != null) {
      //   final sessionIndex = _availableSessions!.indexWhere(
      //     (s) => s.id == sessionId,
      //   );
      //   if (sessionIndex != -1) {
      //     final session = _availableSessions![sessionIndex];
      //     _availableSessions![sessionIndex] = session.copyWith(
      //       currentParticipants: (session.currentParticipants ?? 0) + 1,
      //     );
      //   }
      // }

      // Add to upcoming sessions if loaded
      if (_upcomingSessions != null && _availableSessions != null) {
        final session = _availableSessions!.firstWhere(
          (s) => s.id == sessionId,
        );
        _upcomingSessions!.add(session);
      }

      _isLoading = false;
      notifyListeners();
    } on ApiError catch (e) {
      _isLoading = false;
      _error = e.message;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> leaveSession(String userId, String sessionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.leaveSession(userId, sessionId);

      // Update available sessions to reflect the change
      if (_availableSessions != null) {
        final sessionIndex = _availableSessions!.indexWhere(
          (s) => s.id == sessionId,
        );
        // if (sessionIndex != -1) {
        //   final session = _availableSessions![sessionIndex];
        //   _availableSessions![sessionIndex] = session.copyWith(
        //     currentParticipants: (session.currentParticipants ?? 1) - 1,
        //   );
        // }
      }

      // Remove from upcoming sessions if loaded
      if (_upcomingSessions != null) {
        _upcomingSessions!.removeWhere((session) => session.id == sessionId);
      }

      _isLoading = false;
      notifyListeners();
    } on ApiError catch (e) {
      _isLoading = false;
      _error = e.message;
      notifyListeners();
      rethrow;
    }
  }

  // Utility methods
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
  }

  bool get _isCacheValid =>
      _lastFetched != null &&
      DateTime.now().difference(_lastFetched!) < const Duration(minutes: 5);
}

// 6. Home Provider
class HomeProvider extends ChangeNotifier {
  final HomeRepository _repository;

  HomeProvider(this._repository);

  bool _isLoading = false;
  String? _error;
  UserStats? _userStats;
  List<Activity>? _recentActivities;
  List<Session>? _upcomingSessionsPreview;
  DateTime? _lastFetched;

  bool get isLoading => _isLoading;
  String? get error => _error;
  UserStats? get userStats => _userStats;
  List<Activity>? get recentActivities => _recentActivities;
  List<Session>? get upcomingSessionsPreview => _upcomingSessionsPreview;

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  Future<void> loadHomeData(String userId, {bool forceRefresh = false}) async {
    if (!forceRefresh && _isCacheValid) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final statsResponse = await _repository.getUserStats(userId);
      final activitiesResponse = await _repository.getRecentActivities(
        userId: userId,
      );
      final sessionsResponse = await _repository.getUpcomingSessionsPreview(
        userId,
      );

      _userStats = statsResponse.data;
      _recentActivities = activitiesResponse.data;
      _upcomingSessionsPreview = sessionsResponse.data;
      _lastFetched = DateTime.now();
      _isLoading = false;
    } on ApiError catch (e) {
      _error = e.message;
      debugPrint('Error loading home data: ${e.message}');
    } finally {
      notifyListeners();
    }
  }

  bool get _isCacheValid =>
      _lastFetched != null &&
      DateTime.now().difference(_lastFetched!) < const Duration(minutes: 5);
}

// 7. Tutor Provider
class TutorProvider extends ChangeNotifier {
  final TutorRepository _repository;

  TutorProvider(this._repository);

  bool _isLoading = false;
  String? _error;
  List<Tutor>? _tutors;
  Tutor? _selectedTutor;
  List<TutorApplication>? _tutorApplications;
  String? _currentSubjectFilter;
  String? _currentAvailabilityFilter;
  double? _currentMinRating;
  int _currentPage = 1;
  bool _hasMore = true;
  DateTime? _lastFetched;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Tutor>? get tutors => _tutors;
  Tutor? get selectedTutor => _selectedTutor;
  List<TutorApplication>? get tutorApplications => _tutorApplications;
  String? get currentSubjectFilter => _currentSubjectFilter;
  String? get currentAvailabilityFilter => _currentAvailabilityFilter;
  double? get currentMinRating => _currentMinRating;
  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

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
    _error = null;
    _currentSubjectFilter = subject;
    _currentAvailabilityFilter = availability;
    _currentMinRating = minRating;
    notifyListeners();

    try {
      final response = await _repository.getTutors(
        subject: subject,
        availability: availability,
        minRating: minRating,
        offset: (page - 1) * 10,
      );

      if (loadMore && _tutors != null && response.data != null) {
        _tutors!.addAll(response.data!);
      } else {
        _tutors = response.data;
      }

      _hasMore = response.data != null && response.data!.length >= 10;
      _currentPage = page;
      _lastFetched = DateTime.now();
      _isLoading = false;
      notifyListeners();
    } on ApiError catch (e) {
      _isLoading = false;
      _error = e.message;
      notifyListeners();
      rethrow;
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
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.getTutorDetails(tutorId);
      _selectedTutor = response.data;
      _isLoading = false;
      notifyListeners();
    } on ApiError catch (e) {
      _isLoading = false;
      _error = e.message;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadTutorApplications(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.getTutorApplications(userId);
      _tutorApplications = response.data;
      _isLoading = false;
      notifyListeners();
    } on ApiError catch (e) {
      _isLoading = false;
      _error = e.message;
      notifyListeners();
      rethrow;
    }
  }
}

// 8. Chat Provider
class ChatProvider extends ChangeNotifier {
  final ChatRepository _repository;

  ChatProvider(this._repository);

  bool _isLoading = false;
  String? _error;
  List<Chat>? _chats;
  List<Message>? _messages;
  String? _selectedChatId;
  DateTime? _lastFetched;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Chat>? get chats => _chats;
  List<Message>? get messages => _messages;
  String? get selectedChatId => _selectedChatId;

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  Future<void> loadChats(String userId, {bool forceRefresh = false}) async {
    if (!forceRefresh && _chats != null && _isCacheValid) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.getChats(userId);
      _chats = response.data;
      _lastFetched = DateTime.now();
      _isLoading = false;
      notifyListeners();
    } on ApiError catch (e) {
      _isLoading = false;
      _error = e.message;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadMessages(String chatId) async {
    _isLoading = true;
    _error = null;
    _selectedChatId = chatId;
    notifyListeners();

    try {
      final response = await _repository.getMessages(chatId);
      _messages = response.data;
      _isLoading = false;
      notifyListeners();
    } on ApiError catch (e) {
      _isLoading = false;
      _error = e.message;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> sendMessage(Message message) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.sendMessage(message);
      if (response.data != null) {
        _messages ??= [];
        _messages!.add(response.data!);
      }
      _isLoading = false;
      notifyListeners();
    } on ApiError catch (e) {
      _isLoading = false;
      _error = e.message;
      notifyListeners();
      rethrow;
    }
  }

  bool get _isCacheValid =>
      _lastFetched != null &&
      DateTime.now().difference(_lastFetched!) < const Duration(minutes: 1);
}

// 9. Analytics Provider
class AnalyticsProvider extends ChangeNotifier {
  final AnalyticsRepository _repository;

  AnalyticsProvider(this._repository);

  bool _isLoading = false;
  String? _error;
  List<WeeklyActivity>? _weeklyActivity;
  List<SubjectDistribution>? _subjectDistribution;
  List<TutorPerformance>? _tutorPerformance;
  DateTimeRange? _dateRange;
  DateTime? _lastFetched;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<WeeklyActivity>? get weeklyActivity => _weeklyActivity;
  List<SubjectDistribution>? get subjectDistribution => _subjectDistribution;
  List<TutorPerformance>? get tutorPerformance => _tutorPerformance;
  DateTimeRange? get dateRange => _dateRange;

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

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
    if (!forceRefresh && _isCacheValid) return;

    _isLoading = true;
    _error = null;
    _dateRange = dateRange ?? _dateRange;
    notifyListeners();

    try {
      final weeklyResponse = await _repository.getWeeklyActivity(userId);
      final subjectResponse = await _repository.getSubjectDistribution(userId);
      final tutorResponse = await _repository.getTutorPerformance();

      _weeklyActivity = weeklyResponse.data;
      _subjectDistribution = subjectResponse.data;
      _tutorPerformance = tutorResponse.data;
      _lastFetched = DateTime.now();
      _isLoading = false;
      notifyListeners();
    } on ApiError catch (e) {
      _isLoading = false;
      _error = e.message;
      notifyListeners();
      rethrow;
    }
  }

  bool get _isCacheValid =>
      _lastFetched != null &&
      DateTime.now().difference(_lastFetched!) < const Duration(minutes: 30);
}

// 10. Study Materials Provider
class StudyMaterialsProvider extends ChangeNotifier {
  final StudyMaterialsRepository _repository;

  StudyMaterialsProvider(this._repository);

  bool _isLoading = false;
  String? _error;
  List<StudyMaterial>? _studyMaterials;
  DateTime? _lastFetched;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<StudyMaterial>? get studyMaterials => _studyMaterials;

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  Future<void> loadStudyMaterials(
    String userId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _studyMaterials != null && _isCacheValid) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.getStudyMaterials(userId);
      _studyMaterials = response.data;
      _lastFetched = DateTime.now();
      _isLoading = false;
      notifyListeners();
    } on ApiError catch (e) {
      _isLoading = false;
      _error = e.message;
      notifyListeners();
      rethrow;
    }
  }

  bool get _isCacheValid =>
      _lastFetched != null &&
      DateTime.now().difference(_lastFetched!) < const Duration(minutes: 30);
}

// 11. Practice Tests Provider
class PracticeTestsProvider extends ChangeNotifier {
  final PracticeTestsRepository _repository;

  PracticeTestsProvider(this._repository);

  bool _isLoading = false;
  String? _error;
  List<PracticeTest>? _practiceTests;
  List<TestQuestion>? _testQuestions;
  String? _selectedTestId;
  Map<String, dynamic>? _testResults;
  String? _currentSubjectFilter;
  String? _currentDifficultyFilter;
  String? _currentSortBy;
  DateTime? _lastFetched;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<PracticeTest>? get practiceTests => _practiceTests;
  List<TestQuestion>? get testQuestions => _testQuestions;
  String? get selectedTestId => _selectedTestId;
  Map<String, dynamic>? get testResults => _testResults;
  String? get currentSubjectFilter => _currentSubjectFilter;
  String? get currentDifficultyFilter => _currentDifficultyFilter;
  String? get currentSortBy => _currentSortBy;

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

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
        _isCacheValid)
      return;

    _isLoading = true;
    _error = null;
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
      _isLoading = false;
      notifyListeners();
    } on ApiError catch (e) {
      _isLoading = false;
      _error = e.message;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadTestQuestions(String testId) async {
    _isLoading = true;
    _error = null;
    _selectedTestId = testId;
    notifyListeners();

    try {
      final response = await _repository.getTestQuestions(testId);
      _testQuestions = response.data;
      _isLoading = false;
      notifyListeners();
    } on ApiError catch (e) {
      _isLoading = false;
      _error = e.message;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> submitTestAnswers(
    String testId,
    Map<int, String> answers,
    String userId,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.submitTestAnswers(testId, answers, userId);
      _testResults = {'score': 85, 'correct': 17, 'total': 20};
      _isLoading = false;
      notifyListeners();
    } on ApiError catch (e) {
      _isLoading = false;
      _error = e.message;
      notifyListeners();
      rethrow;
    }
  }

  bool get _isCacheValid =>
      _lastFetched != null &&
      DateTime.now().difference(_lastFetched!) < const Duration(minutes: 30);
}

// 12. MultiProvider Setup
List<SingleChildWidget> getProviders() {
  return [
    ChangeNotifierProvider<AppProvider>(create: (_) => AppProvider()),
    Provider<AuthRepository>(create: (_) => AuthRepository()),
    ChangeNotifierProxyProvider<AppProvider, AuthProvider>(
      create: (_) => AuthProvider(AuthRepository()),
      update: (_, appProvider, authProvider) => authProvider!,
    ),
    Provider<AchievementsRepository>(create: (_) => AchievementsRepository()),
    ChangeNotifierProxyProvider<AppProvider, AchievementsProvider>(
      create: (_) => AchievementsProvider(AchievementsRepository()),
      update: (_, appProvider, provider) => provider!,
    ),
    Provider<LeaderboardRepository>(create: (_) => LeaderboardRepository()),
    ChangeNotifierProxyProvider<AppProvider, LeaderboardProvider>(
      create: (_) => LeaderboardProvider(LeaderboardRepository()),
      update: (_, appProvider, provider) => provider!,
    ),
    Provider<SessionRepository>(create: (_) => SessionRepository()),
    ChangeNotifierProxyProvider<AppProvider, SessionProvider>(
      create: (_) => SessionProvider(SessionRepository()),
      update: (_, appProvider, provider) => provider!,
    ),
    Provider<HomeRepository>(create: (_) => HomeRepository()),
    ChangeNotifierProxyProvider<AppProvider, HomeProvider>(
      create: (_) => HomeProvider(HomeRepository()),
      update: (_, appProvider, provider) => provider!,
    ),
    Provider<TutorRepository>(create: (_) => TutorRepository()),
    ChangeNotifierProxyProvider<AppProvider, TutorProvider>(
      create: (_) => TutorProvider(TutorRepository()),
      update: (_, appProvider, provider) => provider!,
    ),
    Provider<ChatRepository>(create: (_) => ChatRepository()),
    ChangeNotifierProxyProvider<AppProvider, ChatProvider>(
      create: (_) => ChatProvider(ChatRepository()),
      update: (_, appProvider, provider) => provider!,
    ),
    Provider<AnalyticsRepository>(create: (_) => AnalyticsRepository()),
    ChangeNotifierProxyProvider<AppProvider, AnalyticsProvider>(
      create: (_) => AnalyticsProvider(AnalyticsRepository()),
      update: (_, appProvider, provider) => provider!,
    ),
    Provider<StudyMaterialsRepository>(
      create: (_) => StudyMaterialsRepository(),
    ),
    ChangeNotifierProxyProvider<AppProvider, StudyMaterialsProvider>(
      create: (_) => StudyMaterialsProvider(StudyMaterialsRepository()),
      update: (_, appProvider, provider) => provider!,
    ),
    Provider<PracticeTestsRepository>(create: (_) => PracticeTestsRepository()),
    ChangeNotifierProxyProvider<AppProvider, PracticeTestsProvider>(
      create: (_) => PracticeTestsProvider(PracticeTestsRepository()),
      update: (_, appProvider, provider) => provider!,
    ),
  ];
}

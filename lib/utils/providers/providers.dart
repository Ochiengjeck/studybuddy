// providers.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/single_child_widget.dart';

import '../modelsAndRepsositories/models_and_repositories.dart';

// 1. Main App Provider
class AppProvider extends ChangeNotifier {
  String? _authToken;
  User? _currentUser;
  bool _isInitializing = false;
  String? _initializationError;

  String? get authToken => _authToken;
  User? get currentUser => _currentUser;
  bool get isInitializing => _isInitializing;
  String? get initializationError => _initializationError;

  Future<void> initializeApp() async {
    _isInitializing = true;
    notifyListeners();

    try {
      // Add app initialization logic here:
      // 1. Load cached token/user
      // 2. Validate token
      // 3. Fetch fresh user data if token exists
      // 4. Set initial state

      _isInitializing = false;
      notifyListeners();
    } catch (e) {
      _initializationError = e.toString();
      _isInitializing = false;
      notifyListeners();
    }
  }

  void setAuthToken(String token) {
    _authToken = token;
    notifyListeners();
  }

  void setCurrentUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  void logout() {
    _authToken = null;
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
    _error = null;
    notifyListeners();
  }

  Future<ApiResponse<User>> login(LoginRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authRepository.login(request);
      _isLoading = false;
      _isAuthenticated = true;
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

  Future<ApiResponse<User>> getCurrentUser(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authRepository.getCurrentUser(token);
      _isLoading = false;
      _isAuthenticated = true;
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

  Future<ApiResponse<void>> logout(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authRepository.logout(token);
      _isLoading = false;
      _isAuthenticated = false;
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

  String? _authToken;
  set authToken(String? token) => _authToken = token;
  String? get authToken => _authToken;

  bool _isLoading = false;
  String? _error;
  List<Achievement>? _achievements;
  UserStats? _userStats;
  DateTime? _lastFetched;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Achievement>? get achievements => _achievements;
  UserStats? get userStats => _userStats;
  DateTime? get lastFetched => _lastFetched;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> loadAchievements(
    String token, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        _achievements != null &&
        _lastFetched != null &&
        DateTime.now().difference(_lastFetched!) < const Duration(minutes: 5)) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.getAchievements(token);
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

  Future<void> loadUserStats(String token, {bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _userStats != null &&
        _lastFetched != null &&
        DateTime.now().difference(_lastFetched!) < const Duration(minutes: 5)) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.getUserStats(token);
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
}

// 4. Leaderboard Provider
class LeaderboardProvider extends ChangeNotifier {
  final LeaderboardRepository _repository;

  LeaderboardProvider(this._repository);

  String? _authToken;
  set authToken(String? token) => _authToken = token;
  String? get authToken => _authToken;

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
  DateTime? get lastFetched => _lastFetched;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> loadLeaderboard(
    String token, {
    String filter = 'overall',
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        _leaderboard != null &&
        _currentFilter == filter &&
        _lastFetched != null &&
        DateTime.now().difference(_lastFetched!) < const Duration(minutes: 5)) {
      return;
    }

    _isLoading = true;
    _error = null;
    _currentFilter = filter;
    notifyListeners();

    try {
      final response = await _repository.getLeaderboard(token, filter: filter);
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

  Future<void> loadTopPerformers(
    String token, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        _topPerformers != null &&
        _lastFetched != null &&
        DateTime.now().difference(_lastFetched!) < const Duration(minutes: 5)) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.getTopPerformers(token);
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
}

// 5. Session Provider
class SessionProvider extends ChangeNotifier {
  final SessionRepository _repository;

  SessionProvider(this._repository);

  String? _authToken;
  set authToken(String? token) => _authToken = token;
  String? get authToken => _authToken;

  bool _isLoading = false;
  String? _error;
  List<Session>? _upcomingSessions;
  List<Session>? _pastSessions;
  List<Session>? _pendingSessions;
  Session? _selectedSession;
  DateTime? _lastFetched;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Session>? get upcomingSessions => _upcomingSessions;
  List<Session>? get pastSessions => _pastSessions;
  List<Session>? get pendingSessions => _pendingSessions;
  Session? get selectedSession => _selectedSession;
  DateTime? get lastFetched => _lastFetched;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> loadUpcomingSessions(
    String token, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        _upcomingSessions != null &&
        _lastFetched != null &&
        DateTime.now().difference(_lastFetched!) < const Duration(minutes: 5)) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.getUpcomingSessions(token);
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
    String token, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        _pastSessions != null &&
        _lastFetched != null &&
        DateTime.now().difference(_lastFetched!) < const Duration(minutes: 5)) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.getPastSessions(token);
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
    String token, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        _pendingSessions != null &&
        _lastFetched != null &&
        DateTime.now().difference(_lastFetched!) < const Duration(minutes: 5)) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.getPendingSessions(token);
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

  Future<void> loadSessionDetails(String token, String sessionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.getSessionDetails(token, sessionId);
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

  Future<void> cancelSession(String token, String sessionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.cancelSession(token, sessionId);
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
}

// 6. Home Provider
class HomeProvider extends ChangeNotifier {
  final HomeRepository _repository;

  HomeProvider(this._repository);

  String? _authToken;
  set authToken(String? token) => _authToken = token;
  String? get authToken => _authToken;

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
  DateTime? get lastFetched => _lastFetched;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> loadHomeData(String token, {bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _lastFetched != null &&
        DateTime.now().difference(_lastFetched!) < const Duration(minutes: 5)) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final statsResponse = await _repository.getUserStats(token);
      final activitiesResponse = await _repository.getRecentActivities(token);
      final sessionsResponse = await _repository.getUpcomingSessionsPreview(
        token,
      );

      _userStats = statsResponse.data;
      _recentActivities = activitiesResponse.data;
      _upcomingSessionsPreview = sessionsResponse.data;
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
}

// 7. Tutor Provider
class TutorProvider extends ChangeNotifier {
  final TutorRepository _repository;

  TutorProvider(this._repository);

  String? _authToken;
  set authToken(String? token) => _authToken = token;
  String? get authToken => _authToken;

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
  DateTime? get lastFetched => _lastFetched;

  void clearError() {
    _error = null;
    notifyListeners();
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

  Future<void> loadTutorApplications(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.getTutorApplications(token);
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

  String? _authToken;
  set authToken(String? token) => _authToken = token;
  String? get authToken => _authToken;

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
  DateTime? get lastFetched => _lastFetched;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> loadChats({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _chats != null &&
        _lastFetched != null &&
        DateTime.now().difference(_lastFetched!) < const Duration(minutes: 1)) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.getChats();
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
}

// 9. Analytics Provider
class AnalyticsProvider extends ChangeNotifier {
  final AnalyticsRepository _repository;

  AnalyticsProvider(this._repository);

  String? _authToken;
  set authToken(String? token) => _authToken = token;
  String? get authToken => _authToken;

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
  DateTime? get lastFetched => _lastFetched;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void setDateRange(DateTimeRange range) {
    _dateRange = range;
    notifyListeners();
  }

  Future<void> loadAnalyticsData({
    DateTimeRange? dateRange,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        _lastFetched != null &&
        DateTime.now().difference(_lastFetched!) <
            const Duration(minutes: 30)) {
      return;
    }

    _isLoading = true;
    _error = null;
    _dateRange = dateRange ?? _dateRange;
    notifyListeners();

    try {
      final weeklyResponse = await _repository.getWeeklyActivity();
      final subjectResponse = await _repository.getSubjectDistribution();
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
}

// 10. Study Materials Provider
class StudyMaterialsProvider extends ChangeNotifier {
  final StudyMaterialsRepository _repository;

  StudyMaterialsProvider(this._repository);

  String? _authToken;
  set authToken(String? token) => _authToken = token;
  String? get authToken => _authToken;

  bool _isLoading = false;
  String? _error;
  List<StudyMaterial>? _studyMaterials;
  DateTime? _lastFetched;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<StudyMaterial>? get studyMaterials => _studyMaterials;
  DateTime? get lastFetched => _lastFetched;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> loadStudyMaterials({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _studyMaterials != null &&
        _lastFetched != null &&
        DateTime.now().difference(_lastFetched!) <
            const Duration(minutes: 30)) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.getStudyMaterials();
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
}

// 11. Practice Tests Provider
class PracticeTestsProvider extends ChangeNotifier {
  final PracticeTestsRepository _repository;

  PracticeTestsProvider(this._repository);

  String? _authToken;
  set authToken(String? token) => _authToken = token;
  String? get authToken => _authToken;

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
  DateTime? get lastFetched => _lastFetched;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> loadPracticeTests({
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
        _lastFetched != null &&
        DateTime.now().difference(_lastFetched!) <
            const Duration(minutes: 30)) {
      return;
    }

    _isLoading = true;
    _error = null;
    _currentSubjectFilter = subject;
    _currentDifficultyFilter = difficulty;
    _currentSortBy = sortBy;
    notifyListeners();

    try {
      final response = await _repository.getPracticeTests(
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
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.submitTestAnswers(testId, answers);
      // In a real app, you'd parse the results from the response
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
}

// 12. MultiProvider Setup
List<SingleChildWidget> getProviders(String authToken) {
  final httpClient = http.Client();

  return [
    ChangeNotifierProvider<AppProvider>(create: (_) => AppProvider()),
    Provider<AuthRepository>(create: (_) => AuthRepository(httpClient)),
    ChangeNotifierProxyProvider<AppProvider, AuthProvider>(
      create: (_) => AuthProvider(AuthRepository(httpClient)),
      update: (_, appProvider, authProvider) => authProvider!,
    ),
    Provider<AchievementsRepository>(
      create: (_) => AchievementsRepository(httpClient),
    ),
    ChangeNotifierProxyProvider<AppProvider, AchievementsProvider>(
      create: (_) => AchievementsProvider(AchievementsRepository(httpClient)),
      update:
          (_, appProvider, provider) =>
              provider!..authToken = appProvider.authToken,
    ),
    Provider<LeaderboardRepository>(
      create: (_) => LeaderboardRepository(httpClient),
    ),
    ChangeNotifierProxyProvider<AppProvider, LeaderboardProvider>(
      create: (_) => LeaderboardProvider(LeaderboardRepository(httpClient)),
      update:
          (_, appProvider, provider) =>
              provider!..authToken = appProvider.authToken,
    ),
    Provider<SessionRepository>(create: (_) => SessionRepository(httpClient)),
    ChangeNotifierProxyProvider<AppProvider, SessionProvider>(
      create: (_) => SessionProvider(SessionRepository(httpClient)),
      update:
          (_, appProvider, provider) =>
              provider!..authToken = appProvider.authToken,
    ),
    Provider<HomeRepository>(create: (_) => HomeRepository(httpClient)),
    ChangeNotifierProxyProvider<AppProvider, HomeProvider>(
      create: (_) => HomeProvider(HomeRepository(httpClient)),
      update:
          (_, appProvider, provider) =>
              provider!..authToken = appProvider.authToken,
    ),
    Provider<TutorRepository>(create: (_) => TutorRepository(httpClient)),
    ChangeNotifierProxyProvider<AppProvider, TutorProvider>(
      create: (_) => TutorProvider(TutorRepository(httpClient)),
      update:
          (_, appProvider, provider) =>
              provider!..authToken = appProvider.authToken,
    ),
    Provider<ChatRepository>(
      create: (_) => ChatRepository(httpClient, authToken),
    ),
    ChangeNotifierProxyProvider<AppProvider, ChatProvider>(
      create: (_) => ChatProvider(ChatRepository(httpClient, authToken)),
      update:
          (_, appProvider, provider) =>
              provider!..authToken = appProvider.authToken,
    ),
    Provider<AnalyticsRepository>(
      create: (_) => AnalyticsRepository(httpClient, authToken),
    ),
    ChangeNotifierProxyProvider<AppProvider, AnalyticsProvider>(
      create:
          (_) => AnalyticsProvider(AnalyticsRepository(httpClient, authToken)),
      update:
          (_, appProvider, provider) =>
              provider!..authToken = appProvider.authToken,
    ),
    Provider<StudyMaterialsRepository>(
      create: (_) => StudyMaterialsRepository(httpClient, authToken),
    ),
    ChangeNotifierProxyProvider<AppProvider, StudyMaterialsProvider>(
      create:
          (_) => StudyMaterialsProvider(
            StudyMaterialsRepository(httpClient, authToken),
          ),
      update:
          (_, appProvider, provider) =>
              provider!..authToken = appProvider.authToken,
    ),
    Provider<PracticeTestsRepository>(
      create: (_) => PracticeTestsRepository(httpClient, authToken),
    ),
    ChangeNotifierProxyProvider<AppProvider, PracticeTestsProvider>(
      create:
          (_) => PracticeTestsProvider(
            PracticeTestsRepository(httpClient, authToken),
          ),
      update:
          (_, appProvider, provider) =>
              provider!..authToken = appProvider.authToken,
    ),
  ];
}

// 1. Import Statements
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';

// =============================================
// 2. Configurations
// =============================================

class FirebaseConfig {
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  static auth.FirebaseAuth get firebaseAuth => auth.FirebaseAuth.instance;
}

// =============================================
// 3. Core Models
// =============================================

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? metadata;
  final String? errorCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errorCode,
    this.metadata,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      errorCode: json['error_code'],
    );
  }
}

class ApiError {
  final String message;
  final String? code;
  final dynamic errors;

  ApiError({required this.message, this.code, this.errors});

  factory ApiError.fromFirebaseException(dynamic e) {
    return ApiError(
      message: e.message ?? 'An error occurred',
      code: e.code,
      errors: null,
    );
  }
}

class User {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? profilePicture;
  final bool isActive;
  final bool isVerified;
  final DateTime? dateJoined;
  final DateTime? lastLogin;
  final String? userType;
  final Map<String, dynamic>? notificationSettings; // Added field

  User({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.profilePicture,
    required this.isActive,
    required this.isVerified,
    this.dateJoined,
    this.lastLogin,
    this.userType,
    this.notificationSettings, // Added to constructor
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id']?.toString() ?? '',
    email: json['email'] ?? '',
    firstName: json['first_name'],
    lastName: json['last_name'],
    phone: json['phone'],
    profilePicture: json['profile_picture'],
    isActive: json['is_active'] ?? false,
    isVerified: json['is_verified'] ?? false,
    dateJoined:
        json['date_joined'] != null
            ? (json['date_joined'] is Timestamp
                ? json['date_joined'].toDate()
                : DateTime.parse(json['date_joined']))
            : null,
    lastLogin:
        json['last_login'] != null
            ? (json['last_login'] is Timestamp
                ? json['last_login'].toDate()
                : DateTime.parse(json['last_login']))
            : null,
    userType: json['user_type'],
    notificationSettings:
        json['notification_settings'] as Map<String, dynamic>?, // Added
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'phone': phone,
    'profile_picture': profilePicture,
    'is_active': isActive,
    'is_verified': isVerified,
    'date_joined': dateJoined?.toIso8601String(),
    'last_login': lastLogin?.toIso8601String(),
    'user_type': userType,
    'notification_settings': notificationSettings,
  };

  String get fullName {
    if (firstName != null && lastName != null) return '$firstName $lastName';
    if (firstName != null) return firstName!;
    if (lastName != null) return lastName!;
    return email.split('@').first;
  }
}

// =============================================
// 4. Auth Models
// =============================================

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class RegisterRequest {
  final String email;
  final String password;
  final String? firstName;
  final String? lastName;
  final String? phone;

  RegisterRequest({
    required this.email,
    required this.password,
    this.firstName,
    this.lastName,
    this.phone,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'first_name': firstName,
    'last_name': lastName,
    'phone': phone,
  };
}

class PasswordResetRequest {
  final String email;

  PasswordResetRequest({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}

class OtpVerification {
  final String email;
  final String otp;

  OtpVerification({required this.email, required this.otp});

  Map<String, dynamic> toJson() => {'email': email, 'otp': otp};
}

// =============================================
// 5. Achievement Models
// =============================================

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool earned;
  final double progress;
  final DateTime? earnedDate;
  final int points;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.earned,
    required this.progress,
    this.earnedDate,
    required this.points,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
    id: json['id']?.toString() ?? '',
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    icon: json['icon'] ?? 'emoji_events',
    earned: json['earned'] ?? false,
    progress: (json['progress'] ?? 0.0).toDouble(),
    earnedDate:
        json['earned_date'] != null
            ? (json['earned_date'] is Timestamp
                ? json['earned_date'].toDate()
                : DateTime.parse(json['earned_date']))
            : null,
    points: json['points'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'icon': icon,
    'earned': earned,
    'progress': progress,
    'earned_date': earnedDate,
    'points': points,
  };
}

class LeaderboardUser {
  final String id;
  final String name;
  final String? subject;
  final int points;
  final int position;
  final String? profilePicture;
  final bool isCurrentUser;

  LeaderboardUser({
    required this.id,
    required this.name,
    this.subject,
    required this.points,
    required this.position,
    this.profilePicture,
    this.isCurrentUser = false,
  });

  factory LeaderboardUser.fromJson(Map<String, dynamic> json) =>
      LeaderboardUser(
        id: json['id']?.toString() ?? '',
        name: json['name'] ?? '',
        subject: json['subject'],
        points: json['points'] ?? 0,
        position: json['position'] ?? 0,
        profilePicture: json['profile_picture'],
        isCurrentUser: json['is_current_user'] ?? false,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'subject': subject,
    'points': points,
    'position': position,
    'profile_picture': profilePicture,
    'is_current_user': isCurrentUser,
  };
}

class UserStats {
  final int sessionsCompleted;
  final int pointsEarned;
  final int badgesEarned;
  final double averageRating;
  final int upcomingSessions;
  final int pendingSessions;

  UserStats({
    required this.sessionsCompleted,
    required this.pointsEarned,
    required this.badgesEarned,
    required this.averageRating,
    required this.upcomingSessions,
    required this.pendingSessions,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) => UserStats(
    sessionsCompleted: json['sessions_completed'] ?? 0,
    pointsEarned: json['points_earned'] ?? 0,
    badgesEarned: json['badges_earned'] ?? 0,
    averageRating: json['average_rating']?.toDouble() ?? 0.0,
    upcomingSessions: json['upcoming_sessions'] ?? 0,
    pendingSessions: json['pending_sessions'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'sessions_completed': sessionsCompleted,
    'points_earned': pointsEarned,
    'badges_earned': badgesEarned,
    'average_rating': averageRating,
    'upcoming_sessions': upcomingSessions,
    'pending_sessions': pendingSessions,
  };
}

// =============================================
// 6. Session Models
// =============================================
enum SessionStatus { upcoming, completed, pending, declined, inProgress }

enum SessionType { application, organized }

class Session {
  final String id;
  final String title;
  final String tutorName;
  final String tutorImage;
  final String platform;
  final DateTime startTime;
  final Duration duration;
  final String description;
  final SessionStatus status;
  final SessionType type;
  final double? rating;
  final String? review;
  final List<String> participantImages;
  final List<String> participants;
  final bool isCurrentUser;
  final String userId;
  final String? organizerId;
  final String subject;
  final String level;
  final String? notes;
  final int? maxParticipants;
  final int? currentParticipants;
  final bool isRecurring;
  final String? recurringPattern;
  final bool isPaid;
  final double price;
  final DateTime createdAt;
  final DateTime updatedAt;

  Session({
    required this.id,
    required this.title,
    required this.tutorName,
    required this.tutorImage,
    required this.platform,
    required this.startTime,
    required this.duration,
    required this.description,
    required this.status,
    required this.type,
    required this.userId,
    required this.subject,
    required this.level,
    required this.createdAt,
    required this.updatedAt,
    this.rating,
    this.review,
    this.participantImages = const [],
    this.participants = const [],
    this.isCurrentUser = false,
    this.organizerId,
    this.notes,
    this.maxParticipants,
    this.currentParticipants,
    this.isRecurring = false,
    this.recurringPattern,
    this.isPaid = false,
    this.price = 0.0,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      tutorName: json['tutor_name']?.toString() ?? '',
      tutorImage: json['tutor_image']?.toString() ?? '',
      platform: json['platform']?.toString() ?? 'Google Meet',
      startTime: _parseDateTime(json['start_time']),
      duration: Duration(
        minutes: _parseInt(json['duration_minutes'], 60) ?? 60,
      ),
      description: json['description']?.toString() ?? '',
      status: _parseSessionStatus(json['status']),
      type: _parseSessionType(json['type']),
      rating: _parseDouble(json['rating']),
      review: json['review']?.toString(),
      participantImages: _parseStringList(json['participant_images']),
      participants: _parseStringList(json['participants']),
      isCurrentUser: json['is_current_user'] == true,
      userId: json['userId']?.toString() ?? '',
      organizerId: json['organizer_id']?.toString(),
      subject: json['subject']?.toString() ?? '',
      level: json['level']?.toString() ?? '',
      notes: json['notes']?.toString(),
      maxParticipants: _parseInt(json['max_participants']),
      currentParticipants: _parseInt(json['current_participants']),
      isRecurring: json['is_recurring'] == true,
      recurringPattern: json['recurring_pattern']?.toString(),
      isPaid: json['is_paid'] == true,
      price: _parseDouble(json['price']) ?? 0.0,
      createdAt: _parseDateTime(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['updated_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'tutor_name': tutorName,
    'tutor_image': tutorImage,
    'platform': platform,
    'start_time': Timestamp.fromDate(startTime),
    'duration_minutes': duration.inMinutes,
    'description': description,
    'status': status.name,
    'type': type.name,
    'rating': rating,
    'review': review,
    'participant_images': participantImages,
    'participants': participants,
    'is_current_user': isCurrentUser,
    'userId': userId,
    'organizer_id': organizerId,
    'subject': subject,
    'level': level,
    'notes': notes,
    'max_participants': maxParticipants,
    'current_participants': currentParticipants,
    'is_recurring': isRecurring,
    'recurring_pattern': recurringPattern,
    'is_paid': isPaid,
    'price': price,
    'created_at': Timestamp.fromDate(createdAt),
    'updated_at': Timestamp.fromDate(updatedAt),
  };

  // Computed properties
  String get formattedDateTime {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDay = DateTime(startTime.year, startTime.month, startTime.day);

    if (sessionDay == today) {
      return 'Today, ${_formatTime(startTime)}';
    } else if (sessionDay == today.add(const Duration(days: 1))) {
      return 'Tomorrow, ${_formatTime(startTime)}';
    } else {
      return '${_formatDate(startTime)}, ${_formatTime(startTime)}';
    }
  }

  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return minutes > 0
          ? '$hours ${hours == 1 ? 'hour' : 'hours'} $minutes min'
          : '$hours ${hours == 1 ? 'hour' : 'hours'}';
    } else {
      return '$minutes minutes';
    }
  }

  String get statusText {
    switch (status) {
      case SessionStatus.upcoming:
        return 'Upcoming';
      case SessionStatus.completed:
        return 'Completed';
      case SessionStatus.pending:
        return 'Pending';
      case SessionStatus.declined:
        return 'Declined';
      case SessionStatus.inProgress:
        return 'In Progress';
    }
  }

  Color get statusColor {
    switch (status) {
      case SessionStatus.upcoming:
        return Colors.orange;
      case SessionStatus.completed:
        return Colors.green;
      case SessionStatus.pending:
        return Colors.blue;
      case SessionStatus.declined:
        return Colors.red;
      case SessionStatus.inProgress:
        return Colors.purple;
    }
  }

  String get typeText {
    switch (type) {
      case SessionType.application:
        return 'Application';
      case SessionType.organized:
        return 'Organized';
    }
  }

  bool get hasAvailableSpots {
    if (maxParticipants == null || currentParticipants == null) return true;
    return currentParticipants! < maxParticipants!;
  }

  String get participantInfo {
    if (maxParticipants == null || currentParticipants == null) return '';
    return '$currentParticipants/$maxParticipants participants';
  }

  bool get canJoin {
    return status == SessionStatus.upcoming &&
        hasAvailableSpots &&
        startTime.isAfter(DateTime.now()) &&
        !participants.contains(userId) &&
        organizerId != userId;
  }

  bool get canCancel {
    return (status == SessionStatus.upcoming ||
            status == SessionStatus.pending) &&
        startTime.isAfter(DateTime.now()) &&
        (userId == organizerId || isCurrentUser);
  }

  bool get canReschedule {
    return status == SessionStatus.upcoming &&
        startTime.isAfter(DateTime.now()) &&
        (userId == organizerId || isCurrentUser);
  }

  bool get canRate {
    return status == SessionStatus.completed &&
        rating == null &&
        (participants.contains(userId) || isCurrentUser);
  }

  bool get canLeave {
    return status == SessionStatus.upcoming &&
        startTime.isAfter(DateTime.now()) &&
        participants.contains(userId) &&
        organizerId != userId;
  }

  bool get isOrganizer {
    return organizerId == userId;
  }

  bool get isParticipant {
    return participants.contains(userId);
  }

  bool get isUpcoming {
    return status == SessionStatus.upcoming &&
        startTime.isAfter(DateTime.now());
  }

  bool get isPast {
    return startTime.isBefore(DateTime.now()) ||
        status == SessionStatus.completed;
  }

  String get priceText {
    if (!isPaid || price == 0) return 'Free';
    return 'KSh ${price.toStringAsFixed(0)}';
  }

  String get endTimeFormatted {
    final endTime = startTime.add(duration);
    return _formatTime(endTime);
  }

  String get fullTimeRange {
    return '${_formatTime(startTime)} - $endTimeFormatted';
  }

  // Helper methods
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  static int? _parseInt(dynamic value, [int? defaultValue]) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        return defaultValue;
      }
    }
    return defaultValue;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }

  static SessionStatus _parseSessionStatus(dynamic status) {
    if (status == null) return SessionStatus.upcoming;
    final statusStr = status.toString().toLowerCase();
    switch (statusStr) {
      case 'upcoming':
        return SessionStatus.upcoming;
      case 'completed':
        return SessionStatus.completed;
      case 'pending':
        return SessionStatus.pending;
      case 'declined':
        return SessionStatus.declined;
      case 'in_progress':
      case 'inprogress':
        return SessionStatus.inProgress;
      default:
        return SessionStatus.upcoming;
    }
  }

  static SessionType _parseSessionType(dynamic type) {
    if (type == null) return SessionType.application;
    final typeStr = type.toString().toLowerCase();
    switch (typeStr) {
      case 'application':
        return SessionType.application;
      case 'organized':
        return SessionType.organized;
      default:
        return SessionType.application;
    }
  }

  static String _formatTime(DateTime time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  static String _formatDate(DateTime date) =>
      '${_monthNames[date.month - 1]} ${date.day}, ${date.year}';

  static const List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  Duration get timeUntilStart => startTime.difference(DateTime.now());

  bool get isStartingSoon =>
      timeUntilStart.inMinutes <= 15 && timeUntilStart.inMinutes > 0;

  bool get hasStarted => DateTime.now().isAfter(startTime);

  bool get hasEnded => DateTime.now().isAfter(startTime.add(duration));

  String get timeStatus {
    if (hasEnded) return 'Ended';
    if (hasStarted) return 'In Progress';
    if (isStartingSoon) return 'Starting Soon';
    return 'Upcoming';
  }

  bool get isValid {
    return id.isNotEmpty &&
        title.isNotEmpty &&
        subject.isNotEmpty &&
        level.isNotEmpty &&
        userId.isNotEmpty &&
        duration.inMinutes > 0;
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (id.isEmpty) errors.add('Session ID is required');
    if (title.isEmpty) errors.add('Title is required');
    if (subject.isEmpty) errors.add('Subject is required');
    if (level.isEmpty) errors.add('Level is required');
    if (userId.isEmpty) errors.add('User ID is required');
    if (duration.inMinutes <= 0) errors.add('Duration must be greater than 0');
    if (startTime.isBefore(DateTime.now()) &&
        status == SessionStatus.upcoming) {
      errors.add('Start time cannot be in the past for upcoming sessions');
    }
    if (maxParticipants != null && maxParticipants! <= 0) {
      errors.add('Max participants must be greater than 0');
    }
    if (currentParticipants != null &&
        maxParticipants != null &&
        currentParticipants! > maxParticipants!) {
      errors.add('Current participants cannot exceed max participants');
    }
    return errors;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Session && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Session{id: $id, title: $title, status: $status, startTime: $startTime}';
}

// =============================================
// 7. Activity Models
// =============================================

enum ActivityType {
  badgeEarned,
  pointsEarned,
  sessionCompleted,
  sessionBooked,
  sessionRated,
  messageReceived,
}

class Activity {
  final String id;
  final ActivityType type;
  final String title;
  final String description;
  final DateTime time;
  final String? relatedSessionId;
  final String? relatedTutorName;
  final String? relatedTutorImage;

  Activity({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.time,
    this.relatedSessionId,
    this.relatedTutorName,
    this.relatedTutorImage,
  });

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
    id: json['id']?.toString() ?? '',
    type: _parseActivityType(json['type']),
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    time:
        json['time'] is Timestamp
            ? json['time'].toDate()
            : DateTime.parse(json['time']),
    relatedSessionId: json['related_session_id'],
    relatedTutorName: json['related_tutor_name'],
    relatedTutorImage: json['related_tutor_image'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toString().split('.').last,
    'title': title,
    'description': description,
    'time': time,
    'related_session_id': relatedSessionId,
    'related_tutor_name': relatedTutorName,
    'related_tutor_image': relatedTutorImage,
  };

  String get formattedTime {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final activityDay = DateTime(time.year, time.month, time.day);

    if (activityDay == today) {
      final hoursDiff = now.difference(time).inHours;
      if (hoursDiff < 1) {
        final minutesDiff = now.difference(time).inMinutes;
        return '$minutesDiff ${minutesDiff == 1 ? 'minute' : 'minutes'} ago';
      } else if (hoursDiff < 24) {
        return '$hoursDiff ${hoursDiff == 1 ? 'hour' : 'hours'} ago';
      }
    } else if (activityDay == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      final daysDiff = now.difference(time).inDays;
      return daysDiff < 7
          ? '$daysDiff ${daysDiff == 1 ? 'day' : 'days'} ago'
          : '${Session._monthNames[time.month - 1]} ${time.day}';
    }
    return ' TODAY';
  }

  IconData get icon {
    switch (type) {
      case ActivityType.badgeEarned:
        return Icons.emoji_events;
      case ActivityType.pointsEarned:
        return Icons.star;
      case ActivityType.sessionCompleted:
        return Icons.calendar_today;
      case ActivityType.sessionBooked:
        return Icons.event_available;
      case ActivityType.sessionRated:
        return Icons.star_rate;
      case ActivityType.messageReceived:
        return Icons.message;
    }
  }

  Color get iconColor {
    switch (type) {
      case ActivityType.badgeEarned:
        return Colors.amber;
      case ActivityType.pointsEarned:
        return Colors.green;
      case ActivityType.sessionCompleted:
        return Colors.blue;
      case ActivityType.sessionBooked:
        return Colors.purple;
      case ActivityType.sessionRated:
        return Colors.orange;
      case ActivityType.messageReceived:
        return Colors.teal;
    }
  }

  static ActivityType _parseActivityType(String type) {
    switch (type.toLowerCase()) {
      case 'badge_earned':
        return ActivityType.badgeEarned;
      case 'points_earned':
        return ActivityType.pointsEarned;
      case 'session_completed':
        return ActivityType.sessionCompleted;
      case 'session_booked':
        return ActivityType.sessionBooked;
      case 'session_rated':
        return ActivityType.sessionRated;
      case 'message_received':
        return ActivityType.messageReceived;
      default:
        return ActivityType.sessionCompleted;
    }
  }
}

// =============================================
// 8. Tutor Models (Unchanged)
// =============================================

class Tutor {
  final String id;
  final String userId;
  final String name;
  final String type; // Added to distinguish as 'tutor'
  final String? bio;
  final String? education;
  final String? experience;
  final String? teachingStyle;
  final double rating;
  final int sessionsCompleted;
  final int points;
  final int badges;
  final bool isAvailable;
  final String? profilePicture;
  final List<String> subjects;
  final Map<String, List<String>> availability;
  final String? preferredTeachingMode;
  final String? preferredVenue;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Tutor({
    required this.id,
    required this.userId,
    required this.name,
    this.type = 'tutor', // Default to 'tutor'
    this.bio,
    this.education,
    this.experience,
    this.teachingStyle,
    required this.rating,
    required this.sessionsCompleted,
    required this.points,
    required this.badges,
    required this.isAvailable,
    this.profilePicture,
    required this.subjects,
    required this.availability,
    this.preferredTeachingMode,
    this.preferredVenue,
    this.createdAt,
    this.updatedAt,
  });

  factory Tutor.fromJson(Map<String, dynamic> json) => Tutor(
    id: json['id']?.toString() ?? '',
    userId: json['userId']?.toString() ?? '',
    name: json['personal_info']['fullName']?.toString() ?? 'Unknown Tutor',
    type: json['type']?.toString() ?? 'tutor',
    bio: json['personal_info']['experience']?.toString(),
    education: json['personal_info']['fieldOfStudy']?.toString(),
    experience: json['personal_info']['experience']?.toString(),
    teachingStyle: json['teaching_style']?.toString() ?? "To be discussed",
    rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    sessionsCompleted: json['sessions_completed'] ?? 0,
    points: json['points'] ?? 0,
    badges: json['badges'] ?? 0,
    isAvailable: json['is_available'] ?? false,
    profilePicture: json['profile_picture']?.toString(),
    subjects: List<String>.from(json['subjects'] ?? []),
    availability: _parseAvailability(json['availability']),
    preferredTeachingMode: json['teaching_mode']?.toString(),
    preferredVenue: json['preferred_venue']?.toString(),
    createdAt:
        json['created_at'] != null
            ? (json['created_at'] is Timestamp
                ? json['created_at'].toDate()
                : DateTime.parse(json['created_at']))
            : null,
    updatedAt:
        json['updated_at'] != null
            ? (json['updated_at'] is Timestamp
                ? json['updated_at'].toDate()
                : DateTime.parse(json['updated_at']))
            : null,
  );

  static Map<String, List<String>> _parseAvailability(dynamic availability) {
    if (availability == null) return {};
    try {
      final availabilityMap = Map<String, dynamic>.from(availability);
      return availabilityMap.map(
        (key, value) => MapEntry(key, List<String>.from(value ?? [])),
      );
    } catch (e) {
      return {};
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'name': name,
    'type': type,
    'bio': bio,
    'education': education,
    'experience': experience,
    'teaching_style': teachingStyle,
    'rating': rating,
    'sessions_completed': sessionsCompleted,
    'points': points,
    'badges': badges,
    'is_available': isAvailable,
    'profile_picture': profilePicture,
    'subjects': subjects,
    'availability': availability,
    'preferred_teaching_mode': preferredTeachingMode,
    'preferred_venue': preferredVenue,
    'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    'updated_at': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
  };
}

class TutorApplication {
  final String id;
  final String userId;
  final String type; // Added to distinguish as 'application'
  final String status;
  final Map<String, dynamic> personalInfo;
  final List<String> subjects;
  final Map<String, List<String>> availability;
  final String? teachingMode;
  final String? venue;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final String? reviewNotes;

  TutorApplication({
    required this.id,
    required this.userId,
    this.type = 'application', // Default to 'application'
    required this.status,
    required this.personalInfo,
    required this.subjects,
    required this.availability,
    this.teachingMode,
    this.venue,
    this.submittedAt,
    this.reviewedAt,
    this.reviewNotes,
  });

  factory TutorApplication.fromJson(Map<String, dynamic> json) =>
      TutorApplication(
        id: json['id']?.toString() ?? '',
        userId: json['userId']?.toString() ?? '',
        type: json['type']?.toString() ?? 'application',
        status: json['status']?.toString() ?? 'pending',
        personalInfo: Map<String, dynamic>.from(json['personal_info'] ?? {}),
        subjects: List<String>.from(json['subjects'] ?? []),
        availability: _parseAvailability(json['availability']),
        teachingMode: json['teaching_mode']?.toString(),
        venue: json['venue']?.toString(),
        submittedAt:
            json['submitted_at'] != null
                ? (json['submitted_at'] is Timestamp
                    ? json['submitted_at'].toDate()
                    : DateTime.parse(json['submitted_at']))
                : null,
        reviewedAt:
            json['reviewed_at'] != null
                ? (json['reviewed_at'] is Timestamp
                    ? json['reviewed_at'].toDate()
                    : DateTime.parse(json['reviewed_at']))
                : null,
        reviewNotes: json['review_notes']?.toString(),
      );

  static Map<String, List<String>> _parseAvailability(dynamic availability) {
    if (availability == null) return {};
    try {
      final availabilityMap = Map<String, dynamic>.from(availability);
      return availabilityMap.map(
        (key, value) => MapEntry(key, List<String>.from(value ?? [])),
      );
    } catch (e) {
      return {};
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'type': type,
    'status': status,
    'personal_info': personalInfo,
    'subjects': subjects,
    'availability': availability,
    'teaching_mode': teachingMode,
    'venue': venue,
    'submitted_at':
        submittedAt != null ? Timestamp.fromDate(submittedAt!) : null,
    'reviewed_at': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
    'review_notes': reviewNotes,
  };
}

// =============================================
// 9. Chat Models
// =============================================

enum MessageStatus { sent, delivered, read }

class Chat {
  final String id;
  final String name;
  final String? imageUrl;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  Chat({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
  });

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
    id: json['id'] as String,
    name: json['name'] as String,
    imageUrl: json['image_url'] as String?,
    lastMessage: json['last_message'] as String? ?? '',
    lastMessageTime:
        (json['last_message_time'] as Timestamp?)?.toDate() ?? DateTime.now(),
    unreadCount: json['unread_count'] as int? ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'image_url': imageUrl,
    'last_message': lastMessage,
    'last_message_time': Timestamp.fromDate(lastMessageTime),
    'unread_count': unreadCount,
  };

  Chat copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
  }) {
    return Chat(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class Message {
  final String id;
  final String chatId;
  final String text;
  final String senderId;
  final bool isMe;
  final DateTime time;
  final MessageStatus status;

  Message({
    required this.id,
    required this.chatId,
    required this.text,
    required this.senderId,
    required this.isMe,
    required this.time,
    required this.status,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json['id'] as String? ?? '',
    chatId: json['chatId'] as String? ?? '',
    text: json['text'] as String? ?? '',
    senderId: json['senderId'] as String? ?? '',
    isMe: json['isMe'] as bool? ?? false,
    time: (json['time'] as Timestamp?)?.toDate() ?? DateTime.now(),
    status: MessageStatus.values.firstWhere(
      (e) => e.toString() == 'MessageStatus.${json['status']}',
      orElse: () => MessageStatus.sent,
    ),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'chatId': chatId,
    'text': text,
    'senderId': senderId,
    'isMe': isMe,
    'time': Timestamp.fromDate(time),
    'status': status.toString().split('.').last,
  };

  Message copyWith({
    String? id,
    String? chatId,
    String? text,
    String? senderId,
    bool? isMe,
    DateTime? time,
    MessageStatus? status,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      text: text ?? this.text,
      senderId: senderId ?? this.senderId,
      isMe: isMe ?? this.isMe,
      time: time ?? this.time,
      status: status ?? this.status,
    );
  }
}

// =============================================
// 10. Analytics Models
// =============================================

class WeeklyActivity {
  final String day;
  final int sessions;
  final int duration; // in minutes

  WeeklyActivity({
    required this.day,
    required this.sessions,
    required this.duration,
  });

  factory WeeklyActivity.fromJson(Map<String, dynamic> json) => WeeklyActivity(
    day: json['day'] ?? '',
    sessions: json['sessions'] ?? 0,
    duration: json['duration'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'day': day,
    'sessions': sessions,
    'duration': duration,
  };
}

class SubjectDistribution {
  final String subject;
  final int count;
  final Color color;

  SubjectDistribution({
    required this.subject,
    required this.count,
    required this.color,
  });

  factory SubjectDistribution.fromJson(Map<String, dynamic> json) =>
      SubjectDistribution(
        subject: json['subject'] ?? '',
        count: json['count'] ?? 0,
        color: Color(json['color'] ?? 0xFF000000),
      );

  Map<String, dynamic> toJson() => {
    'subject': subject,
    'count': count,
    'color': color.value,
  };
}

class TutorPerformance {
  final String tutorId;
  final String name;
  final int sessions;
  final double rating;
  final int points;

  TutorPerformance({
    required this.tutorId,
    required this.name,
    required this.sessions,
    required this.rating,
    required this.points,
  });

  factory TutorPerformance.fromJson(Map<String, dynamic> json) =>
      TutorPerformance(
        tutorId: json['tutor_id']?.toString() ?? '',
        name: json['name'] ?? '',
        sessions: json['sessions'] ?? 0,
        rating: json['rating']?.toDouble() ?? 0.0,
        points: json['points'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
    'tutor_id': tutorId,
    'name': name,
    'sessions': sessions,
    'rating': rating,
    'points': points,
  };
}

// =============================================
// 11. Study Models
// =============================================

class SavedItem {
  final String id;
  final String title;
  final String subtitle;
  final String type;
  final DateTime savedDate;
  final IconData icon;

  SavedItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.savedDate,
    required this.icon,
  });

  factory SavedItem.fromJson(Map<String, dynamic> json) => SavedItem(
    id: json['id']?.toString() ?? '',
    title: json['title'] ?? '',
    subtitle: json['subtitle'] ?? '',
    type: json['type'] ?? '',
    savedDate:
        json['saved_date'] is Timestamp
            ? json['saved_date'].toDate()
            : DateTime.parse(json['saved_date']),
    icon: _getIconFromString(json['icon']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'type': type,
    'saved_date': savedDate,
    'icon': _getIconString(icon),
  };

  static IconData _getIconFromString(String? iconName) {
    switch (iconName) {
      case 'video_library':
        return Icons.video_library;
      case 'article':
        return Icons.article;
      case 'quiz':
        return Icons.quiz;
      default:
        return Icons.bookmark;
    }
  }

  static String _getIconString(IconData icon) {
    if (icon == Icons.video_library) return 'video_library';
    if (icon == Icons.article) return 'article';
    if (icon == Icons.quiz) return 'quiz';
    return 'bookmark';
  }
}

class StudyMaterial {
  final String id;
  final String subject;
  final int resourceCount;
  final double progress;
  final Color color;
  final IconData icon;

  StudyMaterial({
    required this.id,
    required this.subject,
    required this.resourceCount,
    required this.progress,
    required this.color,
    required this.icon,
  });

  factory StudyMaterial.fromJson(Map<String, dynamic> json) => StudyMaterial(
    id: json['id']?.toString() ?? '',
    subject: json['subject'] ?? '',
    resourceCount: json['resource_count'] ?? 0,
    progress: json['progress']?.toDouble() ?? 0.0,
    color: Color(json['color'] ?? 0xFF000000),
    icon: _getIconFromString(json['icon']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'subject': subject,
    'resource_count': resourceCount,
    'progress': progress,
    'color': color.value,
    'icon': _getIconString(icon),
  };

  static IconData _getIconFromString(String? iconName) {
    switch (iconName) {
      case 'calculate':
        return Icons.calculate;
      case 'science':
        return Icons.science;
      case 'eco':
        return Icons.eco;
      case 'biotech':
        return Icons.biotech;
      case 'code':
        return Icons.code;
      case 'menu_book':
        return Icons.menu_book;
      default:
        return Icons.book;
    }
  }

  static String _getIconString(IconData icon) {
    if (icon == Icons.calculate) return 'calculate';
    if (icon == Icons.science) return 'science';
    if (icon == Icons.eco) return 'eco';
    if (icon == Icons.biotech) return 'biotech';
    if (icon == Icons.code) return 'code';
    if (icon == Icons.menu_book) return 'menu_book';
    return 'book';
  }
}

class PracticeTest {
  final String id;
  final String title;
  final String subject;
  final int questions;
  final String duration;
  final String difficulty;
  final double completion;
  final int totalMarks;
  final String description;

  PracticeTest({
    required this.id,
    required this.title,
    required this.subject,
    required this.questions,
    required this.duration,
    required this.difficulty,
    required this.completion,
    required this.totalMarks,
    required this.description,
  });

  factory PracticeTest.fromJson(Map<String, dynamic> json) => PracticeTest(
    id: json['id']?.toString() ?? '',
    title: json['title'] ?? '',
    subject: json['subject'] ?? '',
    questions: json['questions'] ?? 0,
    duration: json['duration'] ?? '',
    difficulty: json['difficulty'] ?? '',
    completion: json['completion']?.toDouble() ?? 0.0,
    totalMarks: json['total_marks'] ?? 0,
    description: json['description'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subject': subject,
    'questions': questions,
    'duration': duration,
    'difficulty': difficulty,
    'completion': completion,
    'total_marks': totalMarks,
    'description': description,
  };
}

class TestQuestion {
  final String id;
  final String testId;
  final String question;
  final List<String> options;
  final String correctAnswer;

  TestQuestion({
    required this.id,
    required this.testId,
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  factory TestQuestion.fromJson(Map<String, dynamic> json) => TestQuestion(
    id: json['id']?.toString() ?? '',
    testId: json['test_id']?.toString() ?? '',
    question: json['question'] ?? '',
    options: List<String>.from(json['options'] ?? []),
    correctAnswer: json['correct_answer'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'test_id': testId,
    'question': question,
    'options': options,
    'correct_answer': correctAnswer,
  };
}

// =============================================
// Validation Utility for validation and error handling
// =============================================

class ValidationUtil {
  static void validateSessionTiming(DateTime startTime) {
    if (startTime.isBefore(DateTime.now())) {
      throw ApiError(
        message: 'Cannot schedule session in the past',
        code: 'INVALID_TIME',
      );
    }
  }

  static void validateDuration(int durationMinutes) {
    if (durationMinutes < 15) {
      throw ApiError(
        message: 'Session duration must be at least 15 minutes',
        code: 'INVALID_DURATION',
      );
    }
  }

  static void validateParticipants(int? current, int? max) {
    if (current != null && max != null && current > max) {
      throw ApiError(
        message: 'Current participants cannot exceed max participants',
        code: 'PARTICIPANT_LIMIT_EXCEEDED',
      );
    }
  }

  static void validateRating(int rating) {
    if (rating < 1 || rating > 5) {
      throw ApiError(
        message: 'Rating must be between 1 and 5',
        code: 'INVALID_RATING',
      );
    }
  }

  static void validateMaxParticipants(int maxParticipants) {
    if (maxParticipants < 1) {
      throw ApiError(
        message: 'Must allow at least 1 participant',
        code: 'INVALID_PARTICIPANT_COUNT',
      );
    }
  }

  static void validatePrice(bool isPaid, double price) {
    if (isPaid && price <= 0) {
      throw ApiError(
        message: 'Paid sessions must have a price greater than 0',
        code: 'INVALID_PRICE',
      );
    }
  }
}

// =============================================
// 12. Repositories
// =============================================

class UserRepository {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final CollectionReference _usersCollection = FirebaseConfig.firestore
      .collection('users');

  Future<ApiResponse<User>> getUser(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (!doc.exists) {
        throw ApiError(message: 'User not found');
      }
      final user = User.fromJson({
        ...doc.data() as Map<String, dynamic>,
        'id': doc.id,
      });
      debugPrint('User fetched: ${user.fullName}, id: ${user.id}');
      return ApiResponse(success: true, message: 'User retrieved', data: user);
    } catch (e) {
      debugPrint('Error fetching user: $e');
      throw ApiError.fromFirebaseException(e);
    }
  }

  Future<ApiResponse<void>> updateUser(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _usersCollection.doc(userId).update(updates);
      debugPrint('User updated: $userId, updates: $updates');
      return ApiResponse(
        success: true,
        message: 'User updated successfully',
        data: null,
      );
    } catch (e) {
      debugPrint('Error updating user: $e');
      throw ApiError.fromFirebaseException(e);
    }
  }

  Future<ApiResponse<void>> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw ApiError(message: 'No user is signed in');
      }
      final credential = auth.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      debugPrint('Password updated for user: ${user.uid}');
      return ApiResponse(
        success: true,
        message: 'Password updated successfully',
        data: null,
      );
    } catch (e) {
      debugPrint('Error updating password: $e');
      throw ApiError.fromFirebaseException(e);
    }
  }

  Future<ApiResponse<void>> requestDataExport(String userId) async {
    try {
      // Placeholder: Implement backend function or Firestore trigger
      debugPrint('Data export requested for user: $userId');
      return ApiResponse(
        success: true,
        message: 'Data export requested',
        data: null,
      );
    } catch (e) {
      debugPrint('Error requesting data export: $e');
      throw ApiError.fromFirebaseException(e);
    }
  }

  Future<ApiResponse<void>> pauseNotifications(
    String userId,
    Duration duration,
  ) async {
    try {
      final pauseUntil = DateTime.now().add(duration);
      await _usersCollection.doc(userId).update({
        'notifications_paused_until': Timestamp.fromDate(pauseUntil),
      });
      debugPrint('Notifications paused for user: $userId until $pauseUntil');
      return ApiResponse(
        success: true,
        message: 'Notifications paused',
        data: null,
      );
    } catch (e) {
      debugPrint('Error pausing notifications: $e');
      throw ApiError.fromFirebaseException(e);
    }
  }

  Future<ApiResponse<void>> deactivateAccount(String userId) async {
    try {
      await _usersCollection.doc(userId).update({
        'is_active': false,
        'deactivated': true,
        'deactivated_at': Timestamp.now(),
      });
      debugPrint('Account deactivated: $userId');
      return ApiResponse(
        success: true,
        message: 'Account deactivated',
        data: null,
      );
    } catch (e) {
      debugPrint('Error deactivating account: $e');
      throw ApiError.fromFirebaseException(e);
    }
  }
}

class AuthRepository {
  Future<ApiResponse<User>> login(LoginRequest request) async {
    try {
      final credential = await FirebaseConfig.firebaseAuth
          .signInWithEmailAndPassword(
            email: request.email,
            password: request.password,
          );
      final userDoc =
          await FirebaseConfig.firestore
              .collection('users')
              .doc(credential.user!.uid)
              .get();

      return ApiResponse<User>(
        success: true,
        message: 'Login successful',
        data: User.fromJson({
          ...userDoc.data()!,
          'id': credential.user!.uid,
          'email': credential.user!.email,
          'is_verified': credential.user!.emailVerified,
        }),
      );
    } catch (e) {
      throw ApiError.fromFirebaseException(e);
    }
  }

  Future<ApiResponse<User>> register(RegisterRequest request) async {
    try {
      final credential = await FirebaseConfig.firebaseAuth
          .createUserWithEmailAndPassword(
            email: request.email,
            password: request.password,
          );

      final userData = {
        'email': request.email,
        'first_name': request.firstName,
        'last_name': request.lastName,
        'phone': request.phone,
        'is_active': true,
        'is_verified': false,
        'date_joined': Timestamp.now(),
        'user_type': 'student',
      };

      await FirebaseConfig.firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(userData);

      return ApiResponse<User>(
        success: true,
        message: 'Registration successful',
        data: User.fromJson({...userData, 'id': credential.user!.uid}),
      );
    } catch (e) {
      throw ApiError.fromFirebaseException(e);
    }
  }

  Future<ApiResponse<void>> sendPasswordResetOtp(String email) async {
    try {
      await FirebaseConfig.firebaseAuth.sendPasswordResetEmail(email: email);
      return ApiResponse<void>(
        success: true,
        message: 'Password reset email sent',
      );
    } catch (e) {
      throw ApiError.fromFirebaseException(e);
    }
  }

  Future<ApiResponse<void>> verifyOtp(OtpVerification verification) async {
    // Note: Firebase doesn't use OTP for password reset by default
    // This could be implemented with custom authentication or a third-party service
    throw ApiError(message: 'OTP verification not implemented with Firebase');
  }

  Future<ApiResponse<User>> resetPassword(PasswordResetRequest request) async {
    // Firebase handles password reset via email link, so this would need custom implementation
    throw ApiError(
      message: 'Direct password reset not supported with Firebase',
    );
  }

  Future<ApiResponse<User>> getCurrentUser(String token) async {
    try {
      final user = FirebaseConfig.firebaseAuth.currentUser;
      if (user == null) {
        throw ApiError(message: 'No user logged in');
      }
      final userDoc =
          await FirebaseConfig.firestore
              .collection('users')
              .doc(user.uid)
              .get();

      return ApiResponse<User>(
        success: true,
        message: 'User data retrieved',
        data: User.fromJson({
          ...userDoc.data()!,
          'id': user.uid,
          'email': user.email,
          'is_verified': user.emailVerified,
        }),
      );
    } catch (e) {
      throw ApiError.fromFirebaseException(e);
    }
  }

  Future<ApiResponse<void>> logout(String token) async {
    try {
      await FirebaseConfig.firebaseAuth.signOut();
      return ApiResponse<void>(success: true, message: 'Logout successful');
    } catch (e) {
      throw ApiError.fromFirebaseException(e);
    }
  }
}

class AchievementsRepository {
  Future<ApiResponse<List<Achievement>>> getAchievements(String userId) async {
    try {
      final snapshot =
          await FirebaseConfig.firestore
              .collection('users')
              .doc(userId)
              .collection('achievements')
              .get();

      final achievements =
          snapshot.docs
              .map((doc) => Achievement.fromJson({...doc.data(), 'id': doc.id}))
              .toList();
      debugPrint('Useer achievements: $achievements');

      return ApiResponse<List<Achievement>>(
        success: true,
        message: 'Achievements retrieved',
        data: achievements,
      );
    } catch (e) {
      throw ApiError.fromFirebaseException(e);
    }
  }

  Future<ApiResponse<UserStats>> getUserStats(String userId) async {
    try {
      final doc =
          await FirebaseConfig.firestore
              .collection('users')
              .doc(userId)
              .collection('stats')
              .doc('current')
              .get();

      if (!doc.exists || doc.data() == null) {
        // Return default stats if no data exists
        return ApiResponse<UserStats>(
          success: true,
          message: 'Using default stats',
          data: UserStats(
            sessionsCompleted: 0,
            pointsEarned: 0,
            badgesEarned: 0,
            averageRating: 0.0,
            upcomingSessions: 0,
            pendingSessions: 0,
          ),
        );
      }

      return ApiResponse<UserStats>(
        success: true,
        message: 'User stats retrieved',
        data: UserStats.fromJson(doc.data()!),
      );
    } catch (e) {
      debugPrint('Error fetching user stats: $e');
      throw ApiError.fromFirebaseException(e);
    }
  }

  Future<void> initializeDefaultBadges(
    String userId,
    List<Map<String, dynamic>> defaultBadges,
  ) async {
    try {
      final batch = FirebaseConfig.firestore.batch();
      final achievementsRef = FirebaseConfig.firestore
          .collection('users')
          .doc(userId)
          .collection('achievements');

      for (var badge in defaultBadges) {
        final achievement = Achievement(
          id: badge['id'],
          title: badge['title'],
          description: badge['description'],
          icon: badge['icon'],
          earned: false,
          progress: 0.0,
          points: badge['points'],
        );
        batch.set(achievementsRef.doc(badge['id']), achievement.toJson());
      }

      await batch.commit();
    } catch (e) {
      throw ApiError.fromFirebaseException(e);
    }
  }
}

class LeaderboardRepository {
  Future<ApiResponse<List<LeaderboardUser>>> getLeaderboard({
    String filter = 'overall',
    DocumentSnapshot? startAfter,
    int limit = 10,
  }) async {
    try {
      Query query = FirebaseConfig.firestore
          .collection('leaderboard')
          .orderBy('points', descending: true)
          .limit(limit);

      // Apply filter logic
      if (filter == 'this month') {
        final startOfMonth = DateTime(
          DateTime.now().year,
          DateTime.now().month,
        );
        query = query.where(
          'lastActive',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
        );
      } else if (filter == 'by subject') {
        // Example: Filter by a specific subject; adjust as needed
        query = query.where('subject', isEqualTo: 'Mathematics');
      }

      // Apply pagination
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      final users =
          snapshot.docs
              .map(
                (doc) => LeaderboardUser.fromJson({
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                }),
              )
              .toList();

      debugPrint('Leaderboard fetched: ${users.length} users, filter=$filter');
      return ApiResponse<List<LeaderboardUser>>(
        success: true,
        message: 'Leaderboard retrieved',
        data: users,
        metadata: {
          'lastDocument': snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
        },
      );
    } catch (e) {
      debugPrint('Error fetching leaderboard: $e');
      throw ApiError.fromFirebaseException(e);
    }
  }

  Future<ApiResponse<List<LeaderboardUser>>> getTopPerformers() async {
    try {
      final snapshot =
          await FirebaseConfig.firestore
              .collection('leaderboard')
              .orderBy('points', descending: true)
              .limit(10)
              .get();

      final currentUserId = FirebaseConfig.firebaseAuth.currentUser?.uid;

      final topPerformers =
          snapshot.docs.asMap().entries.map((entry) {
            final index = entry.key;
            final doc = entry.value;
            return LeaderboardUser.fromJson({
              ...doc.data(),
              'id': doc.id,
              'position': index + 1,
              'is_current_user': doc.id == currentUserId,
            });
          }).toList();

      return ApiResponse<List<LeaderboardUser>>(
        success: true,
        message: 'Top performers retrieved',
        data: topPerformers,
      );
    } catch (e) {
      throw ApiError.fromFirebaseException(e);
    }
  }
}

class SessionRepository {
  // Note: Ensure Firestore composite indexes are created for:
  // - sessions: userId, status, start_time
  // - sessions: subject, level, start_time
  // - sessions: status, type, start_time

  Future<List<Session>> _fetchSessions({
    required String userId,
    String? status,
    String? orderByField = 'start_time',
    bool descending = false,
  }) async {
    Query<Map<String, dynamic>> query = FirebaseConfig.firestore
        .collection('sessions')
        .where('userId', isEqualTo: userId);

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    if (orderByField != null) {
      query = query.orderBy(orderByField, descending: descending);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => Session.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  Future<ApiResponse<List<Session>>> getUpcomingSessions(String userId) async {
    try {
      final sessions = await _fetchSessions(
        userId: userId,
        status: 'upcoming',
        orderByField: 'start_time',
        descending: false,
      );
      return ApiResponse<List<Session>>(
        success: true,
        message: 'Upcoming sessions retrieved',
        data: sessions,
      );
    } catch (e) {
      throw ApiError.fromFirebaseException(e);
    }
  }

  Future<ApiResponse<List<Session>>> getPastSessions(String userId) async {
    try {
      final sessions = await _fetchSessions(
        userId: userId,
        status: 'completed',
        orderByField: 'start_time',
        descending: true,
      );
      return ApiResponse<List<Session>>(
        success: true,
        message: 'Past sessions retrieved',
        data: sessions,
      );
    } catch (e) {
      throw ApiError.fromFirebaseException(e);
    }
  }

  Future<ApiResponse<List<Session>>> getPendingSessions(String userId) async {
    try {
      final sessions = await _fetchSessions(userId: userId, status: 'pending');
      debugPrint(
        sessions.isEmpty
            ? 'No sessions found for user $userId with status pending'
            : 'Found ${sessions.length} pending sessions for user $userId',
      );
      return ApiResponse<List<Session>>(
        success: true,
        message: 'Pending sessions retrieved',
        data: sessions,
      );
    } catch (e) {
      debugPrint('Error incurred: ${e.toString()}');
      throw ApiError.fromFirebaseException(e);
    }
  }

  Future<ApiResponse<Session>> getSessionDetails(
    String userId,
    String sessionId,
  ) async {
    try {
      final doc =
          await FirebaseConfig.firestore
              .collection('sessions')
              .doc(sessionId)
              .get();

      if (!doc.exists) {
        throw ApiError(message: 'Session not found', code: 'SESSION_NOT_FOUND');
      }

      final sessionData = doc.data()!;

      if (sessionData['userId'] != userId &&
          !(sessionData['participants'] as List?)!.contains(userId)) {
        throw ApiError(
          message: 'Access denied to this session',
          code: 'ACCESS_DENIED',
        );
      }

      return ApiResponse<Session>(
        success: true,
        message: 'Session details retrieved',
        data: Session.fromJson({...sessionData, 'id': doc.id}),
      );
    } catch (e) {
      throw ApiError.fromFirebaseException(e);
    }
  }

  Future<ApiResponse<void>> cancelSession(
    String userId,
    String sessionId,
  ) async {
    try {
      final sessionRef = FirebaseConfig.firestore
          .collection('sessions')
          .doc(sessionId);

      await FirebaseConfig.firestore.runTransaction((transaction) async {
        final sessionDoc = await transaction.get(sessionRef);

        if (!sessionDoc.exists) {
          throw ApiError(
            message: 'Session not found',
            code: 'SESSION_NOT_FOUND',
          );
        }

        final sessionData = sessionDoc.data()!;

        if (sessionData['userId'] != userId &&
            sessionData['organizer_id'] != userId) {
          throw ApiError(
            message: 'You can only cancel your own sessions',
            code: 'ACCESS_DENIED',
          );
        }

        final status = sessionData['status'];
        if (status == 'completed' || status == 'declined') {
          throw ApiError(
            message: 'Cannot cancel a $status session',
            code: 'INVALID_STATUS',
          );
        }

        transaction.update(sessionRef, {
          'status': 'declined',
          'updated_at': Timestamp.now(),
        });
      });

      return ApiResponse<void>(
        success: true,
        message: 'Session cancelled successfully',
      );
    } catch (e) {
      throw ApiError.fromFirebaseException(e);
    }
  }

  Future<ApiResponse<void>> rescheduleSession(
    String userId,
    String sessionId,
    DateTime newTime,
  ) async {
    try {
      ValidationUtil.validateSessionTiming(newTime);

      final sessionRef = FirebaseConfig.firestore
          .collection('sessions')
          .doc(sessionId);

      await FirebaseConfig.firestore.runTransaction((transaction) async {
        final sessionDoc = await transaction.get(sessionRef);

        if (!sessionDoc.exists) {
          throw ApiError(
            message: 'Session not found',
            code: 'SESSION_NOT_FOUND',
          );
        }

        final sessionData = sessionDoc.data()!;

        if (sessionData['userId'] != userId &&
            sessionData['organizer_id'] != userId) {
          throw ApiError(
            message: 'You can only reschedule your own sessions',
            code: 'ACCESS_DENIED',
          );
        }

        transaction.update(sessionRef, {
          'start_time': Timestamp.fromDate(newTime),
          'updated_at': Timestamp.now(),
        });
      });

      return ApiResponse<void>(
        success: true,
        message: 'Session rescheduled successfully',
      );
    } catch (e) {
      throw ApiError.fromFirebaseException(e);
    }
  }

  Future<ApiResponse<void>> submitFeedback(
    String userId,
    String sessionId,
    int rating,
    String review,
  ) async {
    try {
      ValidationUtil.validateRating(rating);

      final sessionRef = FirebaseConfig.firestore
          .collection('sessions')
          .doc(sessionId);

      await FirebaseConfig.firestore.runTransaction((transaction) async {
        final sessionDoc = await transaction.get(sessionRef);

        if (!sessionDoc.exists) {
          throw ApiError(
            message: 'Session not found',
            code: 'SESSION_NOT_FOUND',
          );
        }

        final sessionData = sessionDoc.data()!;

        if (sessionData['userId'] != userId &&
            !(sessionData['participants'] as List?)!.contains(userId)) {
          throw ApiError(
            message: 'You can only rate sessions you participated in',
            code: 'ACCESS_DENIED',
          );
        }

        if (sessionData['status'] != 'completed') {
          throw ApiError(
            message: 'You can only rate completed sessions',
            code: 'INVALID_STATUS',
          );
        }

        transaction.update(sessionRef, {
          'rating': rating,
          'review': review,
          'updated_at': Timestamp.now(),
        });
      });

      return ApiResponse<void>(
        success: true,
        message: 'Feedback submitted successfully',
      );
    } catch (e) {
      throw ApiError.fromFirebaseException(e);
    }
  }

  Future<ApiResponse<Session>> applyForSession({
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
    try {
      ValidationUtil.validateSessionTiming(startTime);
      ValidationUtil.validateDuration(duration.inMinutes);

      final applicationData = {
        'userId': userId,
        'title': title.trim(),
        'subject': subject,
        'level': level,
        'description': description.trim(),
        'start_time': Timestamp.fromDate(startTime),
        'duration_minutes': duration.inMinutes,
        'platform': platform,
        'status': 'pending',
        'type': 'application',
        'notes': notes?.trim() ?? '',
        'tutor_name': 'To be assigned',
        'tutor_image': '',
        'participant_images': <String>[],
        'participants': <String>[],
        'is_current_user': true,
        'created_at': Timestamp.now(),
        'updated_at': Timestamp.now(),
      };

      final docRef = await FirebaseConfig.firestore
          .collection('sessions')
          .add(applicationData);

      final session = Session.fromJson({...applicationData, 'id': docRef.id});

      return ApiResponse<Session>(
        success: true,
        message: 'Session application submitted successfully',
        data: session,
      );
    } catch (e) {
      throw ApiError.fromFirebaseException(e);
    }
  }

  Future<ApiResponse<Session>> organizeSession({
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
    try {
      ValidationUtil.validateSessionTiming(startTime);
      ValidationUtil.validateDuration(duration.inMinutes);
      ValidationUtil.validateMaxParticipants(maxParticipants);
      ValidationUtil.validatePrice(isPaid, price);

      final sessionData = {
        'userId': userId,
        'organizer_id': userId,
        'title': title.trim(),
        'subject': subject,
        'level': level,
        'description': description.trim(),
        'start_time': Timestamp.fromDate(startTime),
        'duration_minutes': duration.inMinutes,
        'platform': platform,
        'status': 'upcoming',
        'type': 'organized',
        'max_participants': maxParticipants,
        'current_participants': 1,
        'is_recurring': isRecurring,
        'recurring_pattern': recurringPattern,
        'is_paid': isPaid,
        'price': price,
        'tutor_name': 'You',
        'tutor_image': '',
        'participant_images': <String>[],
        'participants': [userId],
        'is_current_user': true,
        'created_at': Timestamp.now(),
        'updated_at': Timestamp.now(),
      };

      final docRef = await FirebaseConfig.firestore
          .collection('sessions')
          .add(sessionData);

      final session = Session.fromJson({...sessionData, 'id': docRef.id});

      return ApiResponse<Session>(
        success: true,
        message: 'Session organized successfully',
        data: session,
      );
    } catch (e) {
      throw ApiError.fromFirebaseException(e);
    }
  }

  Future<ApiResponse<List<Session>>> getAvailableSessions({
    String? subject,
    String? level,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query<Map<String, dynamic>> query = FirebaseConfig.firestore
          .collection('sessions')
          .where('status', isEqualTo: 'upcoming')
          .where('type', isEqualTo: 'organized');

      if (subject != null && subject.isNotEmpty) {
        query = query.where('subject', isEqualTo: subject);
      }
      if (level != null && level.isNotEmpty) {
        query = query.where('level', isEqualTo: level);
      }
      if (startDate != null) {
        query = query.where(
          'start_time',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }
      if (endDate != null) {
        query = query.where(
          'start_time',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      final snapshot =
          await query.orderBy('start_time', descending: false).get();

      final sessions =
          snapshot.docs
              .map((doc) => Session.fromJson({...doc.data(), 'id': doc.id}))
              .where((session) {
                final currentParticipants = session.currentParticipants ?? 0;
                final maxParticipants = session.maxParticipants ?? 0;
                return currentParticipants < maxParticipants;
              })
              .toList();

      return ApiResponse<List<Session>>(
        success: true,
        message: 'Available sessions retrieved',
        data: sessions,
      );
    } catch (e) {
      throw ApiError.fromFirebaseException(e);
    }
  }

  Future<ApiResponse<void>> joinSession(String userId, String sessionId) async {
    try {
      final sessionRef = FirebaseConfig.firestore
          .collection('sessions')
          .doc(sessionId);

      await FirebaseConfig.firestore.runTransaction((transaction) async {
        final sessionDoc = await transaction.get(sessionRef);

        if (!sessionDoc.exists) {
          throw ApiError(
            message: 'Session not found',
            code: 'SESSION_NOT_FOUND',
          );
        }

        final sessionData = sessionDoc.data()!;

        if (sessionData['status'] != 'upcoming') {
          throw ApiError(
            message: 'Cannot join this session',
            code: 'INVALID_STATUS',
          );
        }

        final startTime = (sessionData['start_time'] as Timestamp).toDate();
        if (startTime.isBefore(DateTime.now())) {
          throw ApiError(
            message: 'Cannot join a past session',
            code: 'PAST_SESSION',
          );
        }

        final currentParticipants = sessionData['current_participants'] ?? 0;
        final maxParticipants = sessionData['max_participants'] ?? 0;
        final participants = List<String>.from(
          sessionData['participants'] ?? [],
        );

        if (currentParticipants >= maxParticipants) {
          throw ApiError(message: 'Session is full', code: 'SESSION_FULL');
        }

        if (participants.contains(userId)) {
          throw ApiError(
            message: 'Already joined this session',
            code: 'ALREADY_JOINED',
          );
        }

        participants.add(userId);

        transaction.update(sessionRef, {
          'participants': participants,
          'current_participants': participants.length,
          'updated_at': Timestamp.now(),
        });
      });

      return ApiResponse<void>(
        success: true,
        message: 'Successfully joined the session',
      );
    } catch (e) {
      throw ApiError.fromFirebaseException(e);
    }
  }

  Future<ApiResponse<void>> leaveSession(
    String userId,
    String sessionId,
  ) async {
    try {
      final sessionRef = FirebaseConfig.firestore
          .collection('sessions')
          .doc(sessionId);

      await FirebaseConfig.firestore.runTransaction((transaction) async {
        final sessionDoc = await transaction.get(sessionRef);

        if (!sessionDoc.exists) {
          throw ApiError(
            message: 'Session not found',
            code: 'SESSION_NOT_FOUND',
          );
        }

        final sessionData = sessionDoc.data()!;
        final participants = List<String>.from(
          sessionData['participants'] ?? [],
        );

        if (!participants.contains(userId)) {
          throw ApiError(
            message: 'Not a participant of this session',
            code: 'NOT_PARTICIPANT',
          );
        }

        if (sessionData['organizer_id'] == userId) {
          throw ApiError(
            message:
                'Organizers cannot leave their own sessions. Cancel the session instead.',
            code: 'ORGANIZER_CANNOT_LEAVE',
          );
        }

        if (sessionData['status'] != 'upcoming') {
          throw ApiError(
            message: 'Cannot leave a session that is not upcoming',
            code: 'INVALID_STATUS',
          );
        }

        participants.remove(userId);

        transaction.update(sessionRef, {
          'participants': participants,
          'current_participants': participants.length,
          'updated_at': Timestamp.now(),
        });
      });

      return ApiResponse<void>(
        success: true,
        message: 'Successfully left the session',
      );
    } catch (e) {
      throw ApiError.fromFirebaseException(e);
    }
  }
}

class HomeRepository {
  Future<ApiResponse<UserStats>> getUserStats(String userId) async {
    debugPrint('Getting user stats...');
    try {
      final doc =
          await FirebaseConfig.firestore
              .collection('users')
              .doc(userId)
              .collection('stats')
              .doc('current')
              .get();

      debugPrint('User stats data: ${doc.data()}');

      if (!doc.exists || doc.data() == null) {
        // Return default stats if no data exists
        return ApiResponse<UserStats>(
          success: true,
          message: 'Using default stats',
          data: UserStats(
            sessionsCompleted: 0,
            pointsEarned: 0,
            badgesEarned: 0,
            averageRating: 0.0,
            upcomingSessions: 0,
            pendingSessions: 0,
          ),
        );
      }

      return ApiResponse<UserStats>(
        success: true,
        message: 'User stats retrieved',
        data: UserStats.fromJson(doc.data()!),
      );
    } catch (e) {
      debugPrint('Error fetching user stats: $e');
      throw ApiError.fromFirebaseException(e);
    }
  }

  Future<ApiResponse<List<Activity>>> getRecentActivities({
    String? userId,
    int limit = 5,
  }) async {
    try {
      final snapshot =
          await FirebaseConfig.firestore
              .collection('users')
              .doc(userId)
              .collection('activities')
              .orderBy('time', descending: true)
              .limit(limit)
              .get();

      final activities =
          snapshot.docs
              .map((doc) => Activity.fromJson({...doc.data(), 'id': doc.id}))
              .toList();

      return ApiResponse<List<Activity>>(
        success: true,
        message: 'Recent activities retrieved',
        data: activities,
      );
    } catch (e) {
      throw ApiError.fromFirebaseException(e);
    }
  }

  Future<ApiResponse<List<Session>>> getUpcomingSessionsPreview(
    String userId,
  ) async {
    try {
      final snapshot =
          await FirebaseConfig.firestore
              .collection('sessions')
              .where('userId', isEqualTo: userId)
              .where('status', isEqualTo: 'upcoming')
              .limit(5)
              .get();

      final sessions =
          snapshot.docs
              .map((doc) => Session.fromJson({...doc.data(), 'id': doc.id}))
              .toList();

      return ApiResponse<List<Session>>(
        success: true,
        message: 'Upcoming sessions preview retrieved',
        data: sessions,
      );
    } catch (e) {
      throw ApiError.fromFirebaseException(e);
    }
  }
}

class TutorRepository {
  // Note: Ensure Firestore composite indexes are created for:
  // - tutors: type, subjects, rating
  // - tutors: type, userId

  Future<ApiResponse<List<Tutor>>> getTutors({
    String? subject,
    String? availability,
    double? minRating,
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      Query<Map<String, dynamic>> query = FirebaseConfig.firestore
          .collection('tutors')
          .where('type', isEqualTo: 'tutor')
          .limit(limit);

      if (subject != null && subject.isNotEmpty) {
        query = query.where('subjects', arrayContains: subject);
      }
      if (minRating != null) {
        query = query.where('rating', isGreaterThanOrEqualTo: minRating);
      }
      if (offset > 0) {
        // For pagination, assume we have a last document or offset logic
        // This is simplified; in practice, use startAfterDocument
        query = query.startAfter([offset]);
      }

      final snapshot = await query.get();

      final tutors =
          snapshot.docs
              .map((doc) => Tutor.fromJson({...doc.data(), 'id': doc.id}))
              .toList();

      return ApiResponse<List<Tutor>>(
        success: true,
        message: 'Tutors retrieved',
        data: tutors,
      );
    } catch (e) {
      throw ApiError.fromFirebaseException(e);
    }
  }

  Future<ApiResponse<Tutor>> getTutorDetails(String tutorId) async {
    try {
      final doc =
          await FirebaseConfig.firestore
              .collection('tutors')
              .doc(tutorId)
              .get();

      if (!doc.exists) {
        throw ApiError(message: 'Tutor not found', code: 'TUTOR_NOT_FOUND');
      }

      final data = doc.data()!;
      if (data['type'] != 'tutor') {
        throw ApiError(
          message: 'Document is not a tutor',
          code: 'INVALID_TYPE',
        );
      }

      return ApiResponse<Tutor>(
        success: true,
        message: 'Tutor details retrieved',
        data: Tutor.fromJson({...data, 'id': doc.id}),
      );
    } catch (e) {
      throw ApiError.fromFirebaseException(e);
    }
  }

  Future<ApiResponse<TutorApplication>> submitTutorApplication({
    required String userId,
    required Map<String, dynamic> personalInfo,
    required List<String> subjects,
    required Map<String, List<String>> availability,
    String? teachingMode,
    String? venue,
  }) async {
    try {
      final applicationData = {
        'userId': userId,
        'type': 'application',
        'status': 'pending',
        'personal_info': personalInfo,
        'subjects': subjects,
        'availability': availability,
        'teaching_mode': teachingMode,
        'venue': venue,
        'submitted_at': Timestamp.now(),
      };

      final ref = await FirebaseConfig.firestore
          .collection('tutors')
          .add(applicationData);

      return ApiResponse<TutorApplication>(
        success: true,
        message: 'Application submitted successfully',
        data: TutorApplication.fromJson({...applicationData, 'id': ref.id}),
      );
    } catch (e) {
      throw ApiError.fromFirebaseException(e);
    }
  }

  Future<ApiResponse<List<TutorApplication>>> getTutorApplications(
    String userId,
  ) async {
    try {
      final snapshot =
          await FirebaseConfig.firestore
              .collection('tutors')
              .where('type', isEqualTo: 'application')
              .get();

      final applications =
          snapshot.docs
              .map(
                (doc) =>
                    TutorApplication.fromJson({...doc.data(), 'id': doc.id}),
              )
              .toList();

      return ApiResponse<List<TutorApplication>>(
        success: true,
        message: 'Tutor applications retrieved',
        data: applications,
      );
    } catch (e) {
      throw ApiError.fromFirebaseException(e);
    }
  }

  Future<ApiResponse<Tutor>> approveTutorApplication({
    required String applicationId,
    required String name,
    String? bio,
    String? education,
    String? experience,
    String? teachingStyle,
    String? profilePicture,
  }) async {
    try {
      final applicationRef = FirebaseConfig.firestore
          .collection('tutors')
          .doc(applicationId);

      final applicationDoc = await applicationRef.get();
      if (!applicationDoc.exists) {
        throw ApiError(
          message: 'Tutor application not found',
          code: 'APPLICATION_NOT_FOUND',
        );
      }

      final applicationData = applicationDoc.data()!;
      if (applicationData['type'] != 'application') {
        throw ApiError(
          message: 'Document is not a tutor application',
          code: 'INVALID_TYPE',
        );
      }

      final tutorData = {
        'type': 'tutor',
        'userId': applicationData['userId'],
        'name': name,
        'bio': bio,
        'education': education,
        'experience': experience,
        'teaching_style': teachingStyle,
        'rating': 0.0,
        'sessions_completed': 0,
        'points': 0,
        'badges': 0,
        'is_available': true,
        'profile_picture':
            profilePicture ??
            applicationData['personal_info']['profile_picture'],
        'subjects': List<String>.from(applicationData['subjects'] ?? []),
        'availability': Map<String, List<String>>.from(
          applicationData['availability'] ?? {},
        ),
        'preferred_teaching_mode': applicationData['teaching_mode'],
        'preferred_venue': applicationData['venue'],
        'created_at': Timestamp.now(),
        'updated_at': Timestamp.now(),
      };

      await applicationRef.update(tutorData);

      return ApiResponse<Tutor>(
        success: true,
        message: 'Tutor application approved and converted to tutor',
        data: Tutor.fromJson({...tutorData, 'id': applicationId}),
      );
    } catch (e) {
      throw ApiError.fromFirebaseException(e);
    }
  }

  Future<ApiResponse<String>> bookSession({
    required String userId,
    required String tutorId,
    required String subject,
    required DateTime startTime,
    required int durationMinutes,
    required String platform,
    String? description,
  }) async {
    try {
      ValidationUtil.validateSessionTiming(startTime);
      ValidationUtil.validateDuration(durationMinutes);

      final tutorDoc =
          await FirebaseConfig.firestore
              .collection('tutors')
              .doc(tutorId)
              .get();

      if (!tutorDoc.exists) {
        throw ApiError(message: 'Tutor not found', code: 'TUTOR_NOT_FOUND');
      }

      final tutorData = tutorDoc.data()!;
      if (tutorData['type'] != 'tutor') {
        throw ApiError(
          message: 'Document is not a tutor',
          code: 'INVALID_TYPE',
        );
      }
      debugPrint('Tutor data: $tutorData');

      final tutorName =
          tutorData['personal_info']['fullName']?.toString() ?? 'Unknown Tutor';
      final tutorImage = tutorData['profile_picture']?.toString() ?? '';
      final subjects = List<String>.from(tutorData['subjects'] ?? []);

      if (!subjects.contains(subject)) {
        throw ApiError(
          message: 'Tutor does not teach this subject',
          code: 'INVALID_SUBJECT',
        );
      }

      final sessionData = {
        'userId': userId,
        'tutor_id': tutorId,
        'title': subject,
        'start_time': Timestamp.fromDate(startTime),
        'duration_minutes': durationMinutes,
        'platform': platform,
        'description': description?.trim() ?? '',
        'status': 'pending',
        'type': 'application',
        'tutor_name': tutorName,
        'tutor_image': tutorImage,
        'participant_images': <String>[],
        'participants': [userId],
        'is_current_user': true,
        'created_at': Timestamp.now(),
        'updated_at': Timestamp.now(),
      };

      final docRef = await FirebaseConfig.firestore
          .collection('sessions')
          .add(sessionData);

      return ApiResponse<String>(
        success: true,
        message: 'Session booked successfully',
        data: docRef.id,
      );
    } catch (e) {
      throw ApiError.fromFirebaseException(e);
    }
  }
}

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseConfig.firestore;
  static const int _messagePageSize = 20;

  Future<List<Chat>> getChats(String userId, {String? lastDocId}) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('users')
          .doc(userId)
          .collection('chats')
          .orderBy('last_message_time', descending: true)
          .limit(_messagePageSize);

      if (lastDocId != null) {
        final lastDoc =
            await _firestore
                .collection('users')
                .doc(userId)
                .collection('chats')
                .doc(lastDocId)
                .get();
        query = query.startAfterDocument(lastDoc);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => Chat.fromJson(doc.data())).toList();
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  Future<List<Message>> getMessages(String chatId, {String? lastDocId}) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('time', descending: true)
          .limit(_messagePageSize);

      if (lastDocId != null) {
        final lastDoc =
            await _firestore
                .collection('chats')
                .doc(chatId)
                .collection('messages')
                .doc(lastDocId)
                .get();
        query = query.startAfterDocument(lastDoc);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => Message.fromJson(doc.data())).toList();
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  Future<void> sendMessage(Message message) async {
    try {
      final batch = _firestore.batch();
      final messageRef =
          _firestore
              .collection('chats')
              .doc(message.chatId)
              .collection('messages')
              .doc();

      final messageData = {
        ...message.toJson(),
        'id': messageRef.id,
        'time': FieldValue.serverTimestamp(),
      };

      // Set message
      batch.set(messageRef, messageData);

      // Update chat metadata
      final chatData = {
        'last_message': message.text,
        'last_message_time': FieldValue.serverTimestamp(),
      };

      // Update main chat document
      final chatRef = _firestore.collection('chats').doc(message.chatId);
      batch.update(chatRef, chatData);

      // Get chat members
      final chatDoc = await chatRef.get();
      final members = List<String>.from(chatDoc.data()?['members'] ?? []);

      // Update user chat references
      for (final userId in members) {
        final userChatRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('chats')
            .doc(message.chatId);

        batch.update(userChatRef, {
          'last_message': message.text,
          'last_message_time': FieldValue.serverTimestamp(),
          if (userId != message.senderId)
            'unread_count': FieldValue.increment(1),
        });
      }

      await batch.commit();
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  Exception _handleFirestoreError(dynamic e) {
    // Add specific Firestore error handling
    if (e is FirebaseException) {
      switch (e.code) {
        case 'permission-denied':
          return Exception('Permission denied accessing Firestore');
        case 'not-found':
          return Exception('Requested document not found');
        default:
          return Exception('Firestore error: ${e.message}');
      }
    }
    return Exception('Unexpected error: $e');
  }
}

class AnalyticsRepository {
  Future<ApiResponse<List<WeeklyActivity>>> getWeeklyActivity(
    String userId,
  ) async {
    try {
      final snapshot =
          await FirebaseConfig.firestore
              .collection('users')
              .doc(userId)
              .collection('analytics')
              .doc('weekly_activity')
              .collection('days')
              .get();

      final activities =
          snapshot.docs
              .map((doc) => WeeklyActivity.fromJson(doc.data()))
              .toList();

      return ApiResponse<List<WeeklyActivity>>(
        success: true,
        message: 'Weekly activity retrieved',
        data: activities,
      );
    } catch (e) {
      throw ApiError.fromFirebaseException(e);
    }
  }

  Future<ApiResponse<List<SubjectDistribution>>> getSubjectDistribution(
    String userId,
  ) async {
    try {
      final snapshot =
          await FirebaseConfig.firestore
              .collection('users')
              .doc(userId)
              .collection('analytics')
              .doc('subject_distribution')
              .collection('subjects')
              .get();

      final distributions =
          snapshot.docs
              .map((doc) => SubjectDistribution.fromJson(doc.data()))
              .toList();

      return ApiResponse<List<SubjectDistribution>>(
        success: true,
        message: 'Subject distribution retrieved',
        data: distributions,
      );
    } catch (e) {
      throw ApiError.fromFirebaseException(e);
    }
  }

  Future<ApiResponse<List<TutorPerformance>>> getTutorPerformance() async {
    try {
      final snapshot =
          await FirebaseConfig.firestore
              .collection('analytics')
              .doc('tutor_performance')
              .collection('tutors')
              .get();

      final performances =
          snapshot.docs
              .map(
                (doc) => TutorPerformance.fromJson({
                  ...doc.data(),
                  'tutor_id': doc.id,
                }),
              )
              .toList();

      return ApiResponse<List<TutorPerformance>>(
        success: true,
        message: 'Tutor performance retrieved',
        data: performances,
      );
    } catch (e) {
      throw ApiError.fromFirebaseException(e);
    }
  }
}

class SavedItemsRepository {
  Future<ApiResponse<List<SavedItem>>> getSavedItems(
    String userId,
    String type,
  ) async {
    try {
      Query<Map<String, dynamic>> query = FirebaseConfig.firestore
          .collection('users')
          .doc(userId)
          .collection('saved_items');

      if (type.isNotEmpty) {
        query = query.where('type', isEqualTo: type);
      }

      final snapshot = await query.get();

      final items =
          snapshot.docs
              .map((doc) => SavedItem.fromJson({...doc.data(), 'id': doc.id}))
              .toList();

      return ApiResponse<List<SavedItem>>(
        success: true,
        message: 'Saved items retrieved',
        data: items,
      );
    } catch (e) {
      throw ApiError.fromFirebaseException(e);
    }
  }

  Future<ApiResponse<void>> removeSavedItem(
    String userId,
    String itemId,
  ) async {
    try {
      await FirebaseConfig.firestore
          .collection('users')
          .doc(userId)
          .collection('saved_items')
          .doc(itemId)
          .delete();

      return ApiResponse<void>(
        success: true,
        message: 'Item removed successfully',
      );
    } catch (e) {
      throw ApiError.fromFirebaseException(e);
    }
  }
}

class StudyMaterialsRepository {
  Future<ApiResponse<List<StudyMaterial>>> getStudyMaterials(
    String userId,
  ) async {
    try {
      final snapshot =
          await FirebaseConfig.firestore
              .collection('users')
              .doc(userId)
              .collection('study_materials')
              .get();

      final materials =
          snapshot.docs
              .map(
                (doc) => StudyMaterial.fromJson({...doc.data(), 'id': doc.id}),
              )
              .toList();

      return ApiResponse<List<StudyMaterial>>(
        success: true,
        message: 'Study materials retrieved',
        data: materials,
      );
    } catch (e) {
      throw ApiError.fromFirebaseException(e);
    }
  }
}

class PracticeTestsRepository {
  Future<ApiResponse<List<PracticeTest>>> getPracticeTests({
    String? userId,
    String? subject,
    String? difficulty,
    String? sortBy,
  }) async {
    try {
      Query<Map<String, dynamic>> query = FirebaseConfig.firestore.collection(
        'practice_tests',
      );

      if (subject != null && subject != 'All') {
        query = query.where('subject', isEqualTo: subject);
      }
      if (difficulty != null && difficulty != 'All') {
        query = query.where('difficulty', isEqualTo: difficulty);
      }
      if (sortBy != null) {
        query = query.orderBy(sortBy);
      }

      final snapshot = await query.get();

      final tests =
          snapshot.docs
              .map(
                (doc) => PracticeTest.fromJson({...doc.data(), 'id': doc.id}),
              )
              .toList();

      return ApiResponse<List<PracticeTest>>(
        success: true,
        message: 'Practice tests retrieved',
        data: tests,
      );
    } catch (e) {
      throw ApiError.fromFirebaseException(e);
    }
  }

  Future<ApiResponse<List<TestQuestion>>> getTestQuestions(
    String testId,
  ) async {
    try {
      final snapshot =
          await FirebaseConfig.firestore
              .collection('practice_tests')
              .doc(testId)
              .collection('questions')
              .get();

      final questions =
          snapshot.docs
              .map(
                (doc) => TestQuestion.fromJson({...doc.data(), 'id': doc.id}),
              )
              .toList();

      return ApiResponse<List<TestQuestion>>(
        success: true,
        message: 'Test questions retrieved',
        data: questions,
      );
    } catch (e) {
      throw ApiError.fromFirebaseException(e);
    }
  }

  Future<ApiResponse<void>> submitTestAnswers(
    String testId,
    Map<int, String> answers,
    String userId,
  ) async {
    try {
      await FirebaseConfig.firestore
          .collection('users')
          .doc(userId)
          .collection('test_submissions')
          .add({
            'test_id': testId,
            'answers': answers.map(
              (key, value) => MapEntry(key.toString(), value),
            ),
            'submitted_at': Timestamp.now(),
          });

      return ApiResponse<void>(
        success: true,
        message: 'Test submitted successfully',
      );
    } catch (e) {
      throw ApiError.fromFirebaseException(e);
    }
  }
}

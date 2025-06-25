// models_and_repositories.dart

// 1. Import Statements
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// =============================================
// 2. Configurations
// =============================================

class ApiConfig {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> authHeaders(String token) {
    return {...headers, 'Authorization': 'Bearer $token'};
  }
}

// =============================================
// 3. Core Models
// =============================================

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int? statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      statusCode: json['status_code'],
    );
  }
}

class ApiError {
  final String message;
  final int? statusCode;
  final dynamic errors;

  ApiError({required this.message, this.statusCode, this.errors});

  factory ApiError.fromResponse(http.Response response) {
    try {
      final json = jsonDecode(response.body);
      return ApiError(
        message: json['message'] ?? 'An error occurred',
        statusCode: response.statusCode,
        errors: json['errors'],
      );
    } catch (e) {
      return ApiError(
        message: 'Failed to parse error response: ${e.toString()}',
        statusCode: response.statusCode,
      );
    }
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
  final String? authToken;

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
    this.authToken,
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
            ? DateTime.parse(json['date_joined'])
            : null,
    lastLogin:
        json['last_login'] != null ? DateTime.parse(json['last_login']) : null,
    userType: json['user_type'],
    authToken: json['auth_token'],
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
  final bool rememberMe;

  LoginRequest({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'remember_me': rememberMe,
  };
}

class RegisterRequest {
  final String email;
  final String password;
  final String confirmPassword;
  final String? firstName;
  final String? lastName;
  final String? phone;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.confirmPassword,
    this.firstName,
    this.lastName,
    this.phone,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'password2': confirmPassword,
    'first_name': firstName,
    'last_name': lastName,
    'phone': phone,
  };
}

class PasswordResetRequest {
  final String email;
  final String? otp;
  final String? newPassword;
  final String? confirmPassword;

  PasswordResetRequest({
    required this.email,
    this.otp,
    this.newPassword,
    this.confirmPassword,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    if (otp != null) 'otp': otp,
    if (newPassword != null) 'new_password': newPassword,
    if (confirmPassword != null) 'confirm_password': confirmPassword,
  };
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
            ? DateTime.parse(json['earned_date'])
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
    'earned_date': earnedDate?.toIso8601String(),
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
  final double? rating;
  final List<String> participantImages;
  final bool isCurrentUser;

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
    this.rating,
    this.participantImages = const [],
    this.isCurrentUser = false,
  });

  factory Session.fromJson(Map<String, dynamic> json) => Session(
    id: json['id']?.toString() ?? '',
    title: json['title'] ?? '',
    tutorName: json['tutor_name'] ?? '',
    tutorImage: json['tutor_image'] ?? '',
    platform: json['platform'] ?? 'Google Meet',
    startTime: DateTime.parse(json['start_time']),
    duration: Duration(minutes: json['duration_minutes'] ?? 60),
    description: json['description'] ?? '',
    status: _parseSessionStatus(json['status']),
    rating: json['rating']?.toDouble(),
    participantImages: List<String>.from(json['participant_images'] ?? []),
    isCurrentUser: json['is_current_user'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'tutor_name': tutorName,
    'tutor_image': tutorImage,
    'platform': platform,
    'start_time': startTime.toIso8601String(),
    'duration_minutes': duration.inMinutes,
    'description': description,
    'status': status.toString().split('.').last,
    'rating': rating,
    'participant_images': participantImages,
    'is_current_user': isCurrentUser,
  };

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
    return hours > 0
        ? '$hours ${hours == 1 ? 'hour' : 'hours'} ${minutes > 0 ? '$minutes min' : ''}'
        : '$minutes minutes';
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

  static SessionStatus _parseSessionStatus(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return SessionStatus.upcoming;
      case 'completed':
        return SessionStatus.completed;
      case 'pending':
        return SessionStatus.pending;
      case 'declined':
        return SessionStatus.declined;
      case 'in_progress':
        return SessionStatus.inProgress;
      default:
        return SessionStatus.upcoming;
    }
  }

  static String _formatTime(DateTime time) =>
      '${time.hour}:${time.minute.toString().padLeft(2, '0')}';

  static String _formatDate(DateTime date) =>
      '${_monthNames[date.month - 1]} ${date.day}, ${date.year}';

  static const List<String> _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
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
    time: DateTime.parse(json['time']),
    relatedSessionId: json['related_session_id'],
    relatedTutorName: json['related_tutor_name'],
    relatedTutorImage: json['related_tutor_image'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toString().split('.').last,
    'title': title,
    'description': description,
    'time': time.toIso8601String(),
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
    return 'Today';
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
// 8. Tutor Models
// =============================================

class Tutor {
  final String id;
  final String userId;
  final String name;
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
    userId: json['user_id']?.toString() ?? '',
    name: json['name'] ?? '',
    bio: json['bio'],
    education: json['education'],
    experience: json['experience'],
    teachingStyle: json['teaching_style'],
    rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    sessionsCompleted: json['sessions_completed'] ?? 0,
    points: json['points'] ?? 0,
    badges: json['badges'] ?? 0,
    isAvailable: json['is_available'] ?? false,
    profilePicture: json['profile_picture'],
    subjects: List<String>.from(json['subjects'] ?? []),
    availability: _parseAvailability(json['availability']),
    preferredTeachingMode: json['preferred_teaching_mode'],
    preferredVenue: json['preferred_venue'],
    createdAt:
        json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    updatedAt:
        json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
  );

  static Map<String, List<String>> _parseAvailability(dynamic availability) {
    if (availability == null) return {};
    try {
      final availabilityMap =
          availability is String
              ? jsonDecode(availability)
              : Map<String, dynamic>.from(availability);
      return availabilityMap.map(
        (key, value) => MapEntry(key, List<String>.from(value ?? [])),
      );
    } catch (e) {
      return {};
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'name': name,
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
    'availability': jsonEncode(availability),
    'preferred_teaching_mode': preferredTeachingMode,
    'preferred_venue': preferredVenue,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}

class TutorApplication {
  final String id;
  final String userId;
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
        userId: json['user_id']?.toString() ?? '',
        status: json['status'] ?? 'pending',
        personalInfo: Map<String, dynamic>.from(json['personal_info'] ?? {}),
        subjects: List<String>.from(json['subjects'] ?? []),
        availability: _parseAvailability(json['availability']),
        teachingMode: json['teaching_mode'],
        venue: json['venue'],
        submittedAt:
            json['submitted_at'] != null
                ? DateTime.parse(json['submitted_at'])
                : null,
        reviewedAt:
            json['reviewed_at'] != null
                ? DateTime.parse(json['reviewed_at'])
                : null,
        reviewNotes: json['review_notes'],
      );

  static Map<String, List<String>> _parseAvailability(dynamic availability) {
    if (availability == null) return {};
    try {
      final availabilityMap =
          availability is String
              ? jsonDecode(availability)
              : Map<String, dynamic>.from(availability);
      return availabilityMap.map(
        (key, value) => MapEntry(key, List<String>.from(value ?? [])),
      );
    } catch (e) {
      return {};
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'status': status,
    'personal_info': personalInfo,
    'subjects': subjects,
    'availability': jsonEncode(availability),
    'teaching_mode': teachingMode,
    'venue': venue,
    'submitted_at': submittedAt?.toIso8601String(),
    'reviewed_at': reviewedAt?.toIso8601String(),
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
    id: json['id'],
    name: json['name'],
    imageUrl: json['image_url'],
    lastMessage: json['last_message'],
    lastMessageTime: DateTime.parse(json['last_message_time']),
    unreadCount: json['unread_count'],
  );
}

class Message {
  final String id;
  final String chatId;
  final String text;
  final bool isMe;
  final DateTime time;
  final MessageStatus status;

  Message({
    required this.id,
    required this.chatId,
    required this.text,
    required this.isMe,
    required this.time,
    this.status = MessageStatus.sent,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json['id'],
    chatId: json['chat_id'],
    text: json['text'],
    isMe: json['is_me'],
    time: DateTime.parse(json['time']),
    status: MessageStatus.values.firstWhere(
      (e) => e.toString() == 'MessageStatus.${json['status']}',
      orElse: () => MessageStatus.sent,
    ),
  );

  Map<String, dynamic> toJson() => {
    'chat_id': chatId,
    'text': text,
    'is_me': isMe,
    'status': status.toString().split('.').last,
  };
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
    day: json['day'],
    sessions: json['sessions'],
    duration: json['duration'],
  );
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
        subject: json['subject'],
        count: json['count'],
        color: Color(json['color']),
      );
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
        tutorId: json['tutor_id'],
        name: json['name'],
        sessions: json['sessions'],
        rating: json['rating'].toDouble(),
        points: json['points'],
      );
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
    id: json['id'],
    title: json['title'],
    subtitle: json['subtitle'],
    type: json['type'],
    savedDate: DateTime.parse(json['saved_date']),
    icon: _getIconFromString(json['icon']),
  );

  static IconData _getIconFromString(String iconName) {
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
    id: json['id'],
    subject: json['subject'],
    resourceCount: json['resource_count'],
    progress: json['progress'].toDouble(),
    color: Color(json['color']),
    icon: _getIconFromString(json['icon']),
  );

  static IconData _getIconFromString(String iconName) {
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
    id: json['id'],
    title: json['title'],
    subject: json['subject'],
    questions: json['questions'],
    duration: json['duration'],
    difficulty: json['difficulty'],
    completion: json['completion'].toDouble(),
    totalMarks: json['total_marks'],
    description: json['description'],
  );
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
    id: json['id'],
    testId: json['test_id'],
    question: json['question'],
    options: List<String>.from(json['options']),
    correctAnswer: json['correct_answer'],
  );
}

// =============================================
// 12. Repositories
// =============================================

class AuthRepository {
  final http.Client client;

  AuthRepository(this.client);

  Future<ApiResponse<User>> login(LoginRequest request) async {
    try {
      final response = await client.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/login/'),
        headers: ApiConfig.headers,
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ApiResponse<User>.fromJson(json, (data) => User.fromJson(data));
      } else {
        throw ApiError.fromResponse(response);
      }
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }

  Future<ApiResponse<User>> register(RegisterRequest request) async {
    try {
      final response = await client.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/register/'),
        headers: ApiConfig.headers,
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 201) {
        final json = jsonDecode(response.body);
        return ApiResponse<User>.fromJson(json, (data) => User.fromJson(data));
      } else {
        throw ApiError.fromResponse(response);
      }
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }

  Future<ApiResponse<void>> sendPasswordResetOtp(String email) async {
    try {
      final response = await client.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/password/reset/'),
        headers: ApiConfig.headers,
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ApiResponse<void>.fromJson(json, (data) => null);
      } else {
        throw ApiError.fromResponse(response);
      }
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }

  Future<ApiResponse<void>> verifyOtp(OtpVerification verification) async {
    try {
      final response = await client.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/otp/verify/'),
        headers: ApiConfig.headers,
        body: jsonEncode(verification.toJson()),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ApiResponse<void>.fromJson(json, (data) => null);
      } else {
        throw ApiError.fromResponse(response);
      }
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }

  Future<ApiResponse<User>> resetPassword(PasswordResetRequest request) async {
    try {
      final response = await client.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/password/reset/confirm/'),
        headers: ApiConfig.headers,
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ApiResponse<User>.fromJson(json, (data) => User.fromJson(data));
      } else {
        throw ApiError.fromResponse(response);
      }
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }

  Future<ApiResponse<User>> getCurrentUser(String token) async {
    try {
      final response = await client.get(
        Uri.parse('${ApiConfig.baseUrl}/auth/user/'),
        headers: ApiConfig.authHeaders(token),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ApiResponse<User>.fromJson(json, (data) => User.fromJson(data));
      } else {
        throw ApiError.fromResponse(response);
      }
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }

  Future<ApiResponse<void>> logout(String token) async {
    try {
      final response = await client.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/logout/'),
        headers: ApiConfig.authHeaders(token),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ApiResponse<void>.fromJson(json, (data) => null);
      } else {
        throw ApiError.fromResponse(response);
      }
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }
}

class AchievementsRepository {
  final http.Client client;

  AchievementsRepository(this.client);

  Future<ApiResponse<List<Achievement>>> getAchievements(String token) async {
    try {
      final response = await client.get(
        Uri.parse('${ApiConfig.baseUrl}/achievements/'),
        headers: ApiConfig.authHeaders(token),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ApiResponse<List<Achievement>>.fromJson(
          json,
          (data) => (data as List).map((e) => Achievement.fromJson(e)).toList(),
        );
      } else {
        throw ApiError.fromResponse(response);
      }
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }

  Future<ApiResponse<UserStats>> getUserStats(String token) async {
    try {
      final response = await client.get(
        Uri.parse('${ApiConfig.baseUrl}/achievements/stats/'),
        headers: ApiConfig.authHeaders(token),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ApiResponse<UserStats>.fromJson(
          json,
          (data) => UserStats.fromJson(data),
        );
      } else {
        throw ApiError.fromResponse(response);
      }
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }
}

class LeaderboardRepository {
  final http.Client client;

  LeaderboardRepository(this.client);

  Future<ApiResponse<List<LeaderboardUser>>> getLeaderboard(
    String token, {
    String filter = 'overall',
  }) async {
    try {
      final response = await client.get(
        Uri.parse('${ApiConfig.baseUrl}/leaderboard/?filter=$filter'),
        headers: ApiConfig.authHeaders(token),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ApiResponse<List<LeaderboardUser>>.fromJson(
          json,
          (data) =>
              (data as List).map((e) => LeaderboardUser.fromJson(e)).toList(),
        );
      } else {
        throw ApiError.fromResponse(response);
      }
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }

  Future<ApiResponse<List<LeaderboardUser>>> getTopPerformers(
    String token,
  ) async {
    try {
      final response = await client.get(
        Uri.parse('${ApiConfig.baseUrl}/leaderboard/top/'),
        headers: ApiConfig.authHeaders(token),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ApiResponse<List<LeaderboardUser>>.fromJson(
          json,
          (data) =>
              (data as List).map((e) => LeaderboardUser.fromJson(e)).toList(),
        );
      } else {
        throw ApiError.fromResponse(response);
      }
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }
}

class SessionRepository {
  final http.Client client;

  SessionRepository(this.client);

  Future<ApiResponse<List<Session>>> getUpcomingSessions(String token) async {
    try {
      final response = await client.get(
        Uri.parse('${ApiConfig.baseUrl}/sessions/upcoming/'),
        headers: ApiConfig.authHeaders(token),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ApiResponse<List<Session>>.fromJson(
          json,
          (data) => (data as List).map((e) => Session.fromJson(e)).toList(),
        );
      } else {
        throw ApiError.fromResponse(response);
      }
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }

  Future<ApiResponse<List<Session>>> getPastSessions(String token) async {
    try {
      final response = await client.get(
        Uri.parse('${ApiConfig.baseUrl}/sessions/past/'),
        headers: ApiConfig.authHeaders(token),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ApiResponse<List<Session>>.fromJson(
          json,
          (data) => (data as List).map((e) => Session.fromJson(e)).toList(),
        );
      } else {
        throw ApiError.fromResponse(response);
      }
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }

  Future<ApiResponse<List<Session>>> getPendingSessions(String token) async {
    try {
      final response = await client.get(
        Uri.parse('${ApiConfig.baseUrl}/sessions/pending/'),
        headers: ApiConfig.authHeaders(token),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ApiResponse<List<Session>>.fromJson(
          json,
          (data) => (data as List).map((e) => Session.fromJson(e)).toList(),
        );
      } else {
        throw ApiError.fromResponse(response);
      }
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }

  Future<ApiResponse<Session>> getSessionDetails(
    String token,
    String sessionId,
  ) async {
    try {
      final response = await client.get(
        Uri.parse('${ApiConfig.baseUrl}/sessions/$sessionId/'),
        headers: ApiConfig.authHeaders(token),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ApiResponse<Session>.fromJson(
          json,
          (data) => Session.fromJson(data),
        );
      } else {
        throw ApiError.fromResponse(response);
      }
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }

  Future<ApiResponse<void>> cancelSession(
    String token,
    String sessionId,
  ) async {
    try {
      final response = await client.post(
        Uri.parse('${ApiConfig.baseUrl}/sessions/$sessionId/cancel/'),
        headers: ApiConfig.authHeaders(token),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ApiResponse<void>.fromJson(json, (data) => null);
      } else {
        throw ApiError.fromResponse(response);
      }
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }

  Future<ApiResponse<void>> rescheduleSession(
    String token,
    String sessionId,
    DateTime newTime,
  ) async {
    try {
      final response = await client.post(
        Uri.parse('${ApiConfig.baseUrl}/sessions/$sessionId/reschedule/'),
        headers: ApiConfig.authHeaders(token),
        body: jsonEncode({'new_time': newTime.toIso8601String()}),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ApiResponse<void>.fromJson(json, (data) => null);
      } else {
        throw ApiError.fromResponse(response);
      }
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }

  Future<ApiResponse<void>> submitFeedback(
    String token,
    String sessionId,
    int rating,
    String review,
  ) async {
    try {
      final response = await client.post(
        Uri.parse('${ApiConfig.baseUrl}/sessions/$sessionId/feedback/'),
        headers: ApiConfig.authHeaders(token),
        body: jsonEncode({'rating': rating, 'review': review}),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ApiResponse<void>.fromJson(json, (data) => null);
      } else {
        throw ApiError.fromResponse(response);
      }
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }
}

class HomeRepository {
  final http.Client client;

  HomeRepository(this.client);

  Future<ApiResponse<UserStats>> getUserStats(String token) async {
    try {
      final response = await client.get(
        Uri.parse('${ApiConfig.baseUrl}/achievements/stats/'),
        headers: ApiConfig.authHeaders(token),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ApiResponse<UserStats>.fromJson(
          json,
          (data) => UserStats.fromJson(data),
        );
      } else {
        throw ApiError.fromResponse(response);
      }
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }

  Future<ApiResponse<List<Activity>>> getRecentActivities(
    String token, {
    int limit = 5,
  }) async {
    try {
      final response = await client.get(
        Uri.parse('${ApiConfig.baseUrl}/home/activities/?limit=$limit'),
        headers: ApiConfig.authHeaders(token),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ApiResponse<List<Activity>>.fromJson(
          json,
          (data) => (data as List).map((e) => Activity.fromJson(e)).toList(),
        );
      } else {
        throw ApiError.fromResponse(response);
      }
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }

  Future<ApiResponse<List<Session>>> getUpcomingSessionsPreview(
    String token,
  ) async {
    try {
      final response = await client.get(
        Uri.parse('${ApiConfig.baseUrl}/sessions/upcoming/'),
        headers: ApiConfig.authHeaders(token),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ApiResponse<List<Session>>.fromJson(
          json,
          (data) => (data as List).map((e) => Session.fromJson(e)).toList(),
        );
      } else {
        throw ApiError.fromResponse(response);
      }
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }
}

class TutorRepository {
  final http.Client client;

  TutorRepository(this.client);

  Future<ApiResponse<List<Tutor>>> getTutors({
    String? subject,
    String? availability,
    double? minRating,
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final params = {
        if (subject != null && subject.isNotEmpty) 'subject': subject,
        if (availability != null && availability.isNotEmpty)
          'availability': availability,
        if (minRating != null) 'min_rating': minRating.toString(),
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/tutors/',
      ).replace(queryParameters: params);
      final response = await client.get(uri, headers: ApiConfig.headers);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ApiResponse<List<Tutor>>.fromJson(
          json,
          (data) => List<Tutor>.from(data.map((x) => Tutor.fromJson(x))),
        );
      } else {
        throw ApiError.fromResponse(response);
      }
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }

  Future<ApiResponse<Tutor>> getTutorDetails(String tutorId) async {
    try {
      final response = await client.get(
        Uri.parse('${ApiConfig.baseUrl}/tutors/$tutorId/'),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ApiResponse<Tutor>.fromJson(
          json,
          (data) => Tutor.fromJson(data),
        );
      } else {
        throw ApiError.fromResponse(response);
      }
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }

  Future<ApiResponse<TutorApplication>> submitTutorApplication({
    required String token,
    required Map<String, dynamic> personalInfo,
    required List<String> subjects,
    required Map<String, List<String>> availability,
    String? teachingMode,
    String? venue,
  }) async {
    try {
      final payload = {
        'personal_info': personalInfo,
        'subjects': subjects,
        'availability': availability,
        if (teachingMode != null) 'teaching_mode': teachingMode,
        if (venue != null) 'venue': venue,
      };

      final response = await client.post(
        Uri.parse('${ApiConfig.baseUrl}/tutors/applications/'),
        headers: ApiConfig.authHeaders(token),
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201) {
        final json = jsonDecode(response.body);
        return ApiResponse<TutorApplication>.fromJson(
          json,
          (data) => TutorApplication.fromJson(data),
        );
      } else {
        throw ApiError.fromResponse(response);
      }
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }

  Future<ApiResponse<List<TutorApplication>>> getTutorApplications(
    String token,
  ) async {
    try {
      final response = await client.get(
        Uri.parse('${ApiConfig.baseUrl}/tutors/applications/'),
        headers: ApiConfig.authHeaders(token),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ApiResponse<List<TutorApplication>>.fromJson(
          json,
          (data) => List<TutorApplication>.from(
            data.map((x) => TutorApplication.fromJson(x)),
          ),
        );
      } else {
        throw ApiError.fromResponse(response);
      }
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }

  Future<ApiResponse<void>> bookTutorSession({
    required String token,
    required String tutorId,
    required String subject,
    required DateTime dateTime,
    required String duration,
    required String platform,
    String? description,
  }) async {
    try {
      final payload = {
        'tutor_id': tutorId,
        'subject': subject,
        'date_time': dateTime.toIso8601String(),
        'duration': duration,
        'platform': platform,
        if (description != null) 'description': description,
      };

      final response = await client.post(
        Uri.parse('${ApiConfig.baseUrl}/tutors/$tutorId/book/'),
        headers: ApiConfig.authHeaders(token),
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201) {
        final json = jsonDecode(response.body);
        return ApiResponse<void>.fromJson(json, (data) => null);
      } else {
        throw ApiError.fromResponse(response);
      }
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }

  Future<ApiResponse<void>> requestTutor({
    required String token,
    required String subject,
    required String details,
    String? priority,
  }) async {
    try {
      final payload = {
        'subject': subject,
        'details': details,
        if (priority != null) 'priority': priority,
      };

      final response = await client.post(
        Uri.parse('${ApiConfig.baseUrl}/tutors/requests/'),
        headers: ApiConfig.authHeaders(token),
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201) {
        final json = jsonDecode(response.body);
        return ApiResponse<void>.fromJson(json, (data) => null);
      } else {
        throw ApiError.fromResponse(response);
      }
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }
}

class ChatRepository {
  final http.Client client;
  final String authToken;

  ChatRepository(this.client, this.authToken);

  Future<ApiResponse<List<Chat>>> getChats() async {
    try {
      final response = await client.get(
        Uri.parse('${ApiConfig.baseUrl}/chats/'),
        headers: ApiConfig.authHeaders(authToken),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ApiResponse<List<Chat>>.fromJson(
          json,
          (data) => (data as List).map((e) => Chat.fromJson(e)).toList(),
        );
      } else {
        throw ApiError.fromResponse(response);
      }
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }

  Future<ApiResponse<List<Message>>> getMessages(String chatId) async {
    try {
      final response = await client.get(
        Uri.parse('${ApiConfig.baseUrl}/chats/$chatId/messages/'),
        headers: ApiConfig.authHeaders(authToken),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ApiResponse<List<Message>>.fromJson(
          json,
          (data) => (data as List).map((e) => Message.fromJson(e)).toList(),
        );
      } else {
        throw ApiError.fromResponse(response);
      }
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }

  Future<ApiResponse<Message>> sendMessage(Message message) async {
    try {
      final response = await client.post(
        Uri.parse('${ApiConfig.baseUrl}/chats/${message.chatId}/messages/'),
        headers: ApiConfig.authHeaders(authToken),
        body: jsonEncode(message.toJson()),
      );

      if (response.statusCode == 201) {
        final json = jsonDecode(response.body);
        return ApiResponse<Message>.fromJson(
          json,
          (data) => Message.fromJson(data),
        );
      } else {
        throw ApiError.fromResponse(response);
      }
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }
}

class AnalyticsRepository {
  final http.Client client;
  final String authToken;

  AnalyticsRepository(this.client, this.authToken);

  Future<ApiResponse<List<WeeklyActivity>>> getWeeklyActivity() async {
    try {
      final response = await client.get(
        Uri.parse('${ApiConfig.baseUrl}/analytics/weekly-activity/'),
        headers: ApiConfig.authHeaders(authToken),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ApiResponse<List<WeeklyActivity>>.fromJson(
          json,
          (data) =>
              (data as List).map((e) => WeeklyActivity.fromJson(e)).toList(),
        );
      } else {
        throw ApiError.fromResponse(response);
      }
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }

  Future<ApiResponse<List<SubjectDistribution>>>
  getSubjectDistribution() async {
    try {
      final response = await client.get(
        Uri.parse('${ApiConfig.baseUrl}/analytics/subject-distribution/'),
        headers: ApiConfig.authHeaders(authToken),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ApiResponse<List<SubjectDistribution>>.fromJson(
          json,
          (data) =>
              (data as List)
                  .map((e) => SubjectDistribution.fromJson(e))
                  .toList(),
        );
      } else {
        throw ApiError.fromResponse(response);
      }
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }

  Future<ApiResponse<List<TutorPerformance>>> getTutorPerformance() async {
    try {
      final response = await client.get(
        Uri.parse('${ApiConfig.baseUrl}/analytics/tutor-performance/'),
        headers: ApiConfig.authHeaders(authToken),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ApiResponse<List<TutorPerformance>>.fromJson(
          json,
          (data) =>
              (data as List).map((e) => TutorPerformance.fromJson(e)).toList(),
        );
      } else {
        throw ApiError.fromResponse(response);
      }
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }
}

class SavedItemsRepository {
  final http.Client client;
  final String authToken;

  SavedItemsRepository(this.client, this.authToken);

  Future<ApiResponse<List<SavedItem>>> getSavedItems(String type) async {
    try {
      final response = await client.get(
        Uri.parse('${ApiConfig.baseUrl}/saved-items/?type=$type'),
        headers: ApiConfig.authHeaders(authToken),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ApiResponse<List<SavedItem>>.fromJson(
          json,
          (data) => (data as List).map((e) => SavedItem.fromJson(e)).toList(),
        );
      } else {
        throw ApiError.fromResponse(response);
      }
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }

  Future<ApiResponse<void>> removeSavedItem(String itemId) async {
    try {
      final response = await client.delete(
        Uri.parse('${ApiConfig.baseUrl}/saved-items/$itemId/'),
        headers: ApiConfig.authHeaders(authToken),
      );

      if (response.statusCode == 204) {
        return ApiResponse<void>(
          success: true,
          message: 'Item removed successfully',
        );
      } else {
        throw ApiError.fromResponse(response);
      }
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }
}

class StudyMaterialsRepository {
  final http.Client client;
  final String authToken;

  StudyMaterialsRepository(this.client, this.authToken);

  Future<ApiResponse<List<StudyMaterial>>> getStudyMaterials() async {
    try {
      final response = await client.get(
        Uri.parse('${ApiConfig.baseUrl}/study-materials/'),
        headers: ApiConfig.authHeaders(authToken),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ApiResponse<List<StudyMaterial>>.fromJson(
          json,
          (data) =>
              (data as List).map((e) => StudyMaterial.fromJson(e)).toList(),
        );
      } else {
        throw ApiError.fromResponse(response);
      }
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }
}

class PracticeTestsRepository {
  final http.Client client;
  final String authToken;

  PracticeTestsRepository(this.client, this.authToken);

  Future<ApiResponse<List<PracticeTest>>> getPracticeTests({
    String? subject,
    String? difficulty,
    String? sortBy,
  }) async {
    try {
      final queryParams = {
        if (subject != null && subject != 'All') 'subject': subject,
        if (difficulty != null && difficulty != 'All') 'difficulty': difficulty,
        if (sortBy != null) 'sort_by': sortBy,
      };

      final response = await client.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/practice-tests/',
        ).replace(queryParameters: queryParams),
        headers: ApiConfig.authHeaders(authToken),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ApiResponse<List<PracticeTest>>.fromJson(
          json,
          (data) =>
              (data as List).map((e) => PracticeTest.fromJson(e)).toList(),
        );
      } else {
        throw ApiError.fromResponse(response);
      }
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }

  Future<ApiResponse<List<TestQuestion>>> getTestQuestions(
    String testId,
  ) async {
    try {
      final response = await client.get(
        Uri.parse('${ApiConfig.baseUrl}/practice-tests/$testId/questions/'),
        headers: ApiConfig.authHeaders(authToken),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ApiResponse<List<TestQuestion>>.fromJson(
          json,
          (data) =>
              (data as List).map((e) => TestQuestion.fromJson(e)).toList(),
        );
      } else {
        throw ApiError.fromResponse(response);
      }
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }

  Future<ApiResponse<void>> submitTestAnswers(
    String testId,
    Map<int, String> answers,
  ) async {
    try {
      final response = await client.post(
        Uri.parse('${ApiConfig.baseUrl}/practice-tests/$testId/submit/'),
        headers: ApiConfig.authHeaders(authToken),
        body: jsonEncode({
          'answers': answers.map(
            (key, value) => MapEntry(key.toString(), value),
          ),
        }),
      );

      if (response.statusCode == 200) {
        return ApiResponse<void>(
          success: true,
          message: 'Test submitted successfully',
        );
      } else {
        throw ApiError.fromResponse(response);
      }
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }
}

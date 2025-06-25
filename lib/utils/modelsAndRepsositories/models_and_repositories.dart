// 1. Import Statements
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'dart:convert';

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
  final String? errorCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errorCode,
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
    double? rating,
    List<String>? participantImages,
    bool? isCurrentUser,
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
      rating: rating ?? this.rating,
      participantImages: participantImages ?? this.participantImages,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
    );
  }

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
    startTime:
        json['start_time'] is Timestamp
            ? json['start_time'].toDate()
            : DateTime.parse(json['start_time']),
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
    'start_time': startTime,
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
    'availability': availability,
    'preferred_teaching_mode': preferredTeachingMode,
    'preferred_venue': preferredVenue,
    'created_at': createdAt,
    'updated_at': updatedAt,
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
        reviewNotes: json['review_notes'],
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
    'user_id': userId,
    'status': status,
    'personal_info': personalInfo,
    'subjects': subjects,
    'availability': availability,
    'teaching_mode': teachingMode,
    'venue': venue,
    'submitted_at': submittedAt,
    'reviewed_at': reviewedAt,
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
    id: json['id']?.toString() ?? '',
    name: json['name'] ?? '',
    imageUrl: json['image_url'],
    lastMessage: json['last_message'] ?? '',
    lastMessageTime:
        json['last_message_time'] is Timestamp
            ? json['last_message_time'].toDate()
            : DateTime.parse(json['last_message_time']),
    unreadCount: json['unread_count'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'image_url': imageUrl,
    'last_message': lastMessage,
    'last_message_time': lastMessageTime,
    'unread_count': unreadCount,
  };
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
    id: json['id']?.toString() ?? '',
    chatId: json['chat_id']?.toString() ?? '',
    text: json['text'] ?? '',
    isMe: json['is_me'] ?? false,
    time:
        json['time'] is Timestamp
            ? json['time'].toDate()
            : DateTime.parse(json['time']),
    status: MessageStatus.values.firstWhere(
      (e) => e.toString() == 'MessageStatus.${json['status']}',
      orElse: () => MessageStatus.sent,
    ),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'chat_id': chatId,
    'text': text,
    'is_me': isMe,
    'time': time,
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
// 12. Repositories
// =============================================

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
}

class LeaderboardRepository {
  Future<ApiResponse<List<LeaderboardUser>>> getLeaderboard({
    String filter = 'overall',
  }) async {
    try {
      Query<Map<String, dynamic>> query = FirebaseConfig.firestore
          .collection('leaderboard')
          .orderBy('points', descending: true);

      if (filter != 'overall') {
        query = query.where('subject', isEqualTo: filter);
      }

      final snapshot = await query.get();
      final currentUserId = FirebaseConfig.firebaseAuth.currentUser?.uid;

      final leaderboard =
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
        message: 'Leaderboard retrieved',
        data: leaderboard,
      );
    } catch (e) {
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
  Future<ApiResponse<List<Session>>> getUpcomingSessions(String userId) async {
    try {
      final snapshot =
          await FirebaseConfig.firestore
              .collection('sessions')
              .where('user_id', isEqualTo: userId)
              .where('status', isEqualTo: 'upcoming')
              .get();

      final sessions =
          snapshot.docs
              .map((doc) => Session.fromJson({...doc.data(), 'id': doc.id}))
              .toList();

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
      final snapshot =
          await FirebaseConfig.firestore
              .collection('sessions')
              .where('user_id', isEqualTo: userId)
              .where('status', isEqualTo: 'completed')
              .get();

      final sessions =
          snapshot.docs
              .map((doc) => Session.fromJson({...doc.data(), 'id': doc.id}))
              .toList();

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
      final snapshot =
          await FirebaseConfig.firestore
              .collection('sessions')
              .where('user_id', isEqualTo: userId)
              .where('status', isEqualTo: 'pending')
              .get();

      final sessions =
          snapshot.docs
              .map((doc) => Session.fromJson({...doc.data(), 'id': doc.id}))
              .toList();

      return ApiResponse<List<Session>>(
        success: true,
        message: 'Pending sessions retrieved',
        data: sessions,
      );
    } catch (e) {
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
        throw ApiError(message: 'Session not found');
      }

      return ApiResponse<Session>(
        success: true,
        message: 'Session details retrieved',
        data: Session.fromJson({...doc.data()!, 'id': doc.id}),
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
      await FirebaseConfig.firestore
          .collection('sessions')
          .doc(sessionId)
          .update({'status': 'declined'});

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
      await FirebaseConfig.firestore
          .collection('sessions')
          .doc(sessionId)
          .update({'start_time': Timestamp.fromDate(newTime)});

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
      await FirebaseConfig.firestore
          .collection('sessions')
          .doc(sessionId)
          .update({'rating': rating, 'review': review, 'status': 'completed'});

      return ApiResponse<void>(
        success: true,
        message: 'Feedback submitted successfully',
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
              .where('user_id', isEqualTo: userId)
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
          .limit(limit);

      if (subject != null && subject.isNotEmpty) {
        query = query.where('subjects', arrayContains: subject);
      }
      if (minRating != null) {
        query = query.where('rating', isGreaterThanOrEqualTo: minRating);
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
        throw ApiError(message: 'Tutor not found');
      }

      return ApiResponse<Tutor>(
        success: true,
        message: 'Tutor details retrieved',
        data: Tutor.fromJson({...doc.data()!, 'id': doc.id}),
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
        'user_id': userId,
        'status': 'pending',
        'personal_info': personalInfo,
        'subjects': subjects,
        'availability': availability,
        'teaching_mode': teachingMode,
        'venue': venue,
        'submitted_at': Timestamp.now(),
      };

      final ref = await FirebaseConfig.firestore
          .collection('tutor_applications')
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
              .collection('tutor_applications')
              .where('user_id', isEqualTo: userId)
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

  Future<ApiResponse<void>> bookTutorSession({
    required String userId,
    required String tutorId,
    required String subject,
    required DateTime dateTime,
    required String duration,
    required String platform,
    String? description,
  }) async {
    try {
      final sessionData = {
        'user_id': userId,
        'tutor_id': tutorId,
        'subject': subject,
        'start_time': Timestamp.fromDate(dateTime),
        'duration_minutes': int.parse(duration),
        'platform': platform,
        'description': description,
        'status': 'pending',
        'is_current_user': true,
      };

      await FirebaseConfig.firestore.collection('sessions').add(sessionData);

      return ApiResponse<void>(
        success: true,
        message: 'Session booked successfully',
      );
    } catch (e) {
      throw ApiError.fromFirebaseException(e);
    }
  }

  Future<ApiResponse<void>> requestTutor({
    required String userId,
    required String subject,
    required String details,
    String? priority,
  }) async {
    try {
      final requestData = {
        'user_id': userId,
        'subject': subject,
        'details': details,
        'priority': priority,
        'created_at': Timestamp.now(),
      };

      await FirebaseConfig.firestore
          .collection('tutor_requests')
          .add(requestData);

      return ApiResponse<void>(
        success: true,
        message: 'Tutor request submitted successfully',
      );
    } catch (e) {
      throw ApiError.fromFirebaseException(e);
    }
  }
}

class ChatRepository {
  Future<ApiResponse<List<Chat>>> getChats(String userId) async {
    try {
      final snapshot =
          await FirebaseConfig.firestore
              .collection('users')
              .doc(userId)
              .collection('chats')
              .get();

      final chats =
          snapshot.docs
              .map((doc) => Chat.fromJson({...doc.data(), 'id': doc.id}))
              .toList();

      return ApiResponse<List<Chat>>(
        success: true,
        message: 'Chats retrieved',
        data: chats,
      );
    } catch (e) {
      throw ApiError.fromFirebaseException(e);
    }
  }

  Future<ApiResponse<List<Message>>> getMessages(String chatId) async {
    try {
      final snapshot =
          await FirebaseConfig.firestore
              .collection('chats')
              .doc(chatId)
              .collection('messages')
              .orderBy('time')
              .get();

      final messages =
          snapshot.docs
              .map((doc) => Message.fromJson({...doc.data(), 'id': doc.id}))
              .toList();

      return ApiResponse<List<Message>>(
        success: true,
        message: 'Messages retrieved',
        data: messages,
      );
    } catch (e) {
      throw ApiError.fromFirebaseException(e);
    }
  }

  Future<ApiResponse<Message>> sendMessage(Message message) async {
    try {
      final messageData = message.toJson();
      messageData['time'] = Timestamp.now();

      final ref = await FirebaseConfig.firestore
          .collection('chats')
          .doc(message.chatId)
          .collection('messages')
          .add(messageData);

      return ApiResponse<Message>(
        success: true,
        message: 'Message sent successfully',
        data: Message.fromJson({...messageData, 'id': ref.id}),
      );
    } catch (e) {
      throw ApiError.fromFirebaseException(e);
    }
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

import 'package:flutter/material.dart';

class SessionCard extends StatelessWidget {
  final String title;
  final String status;
  final String dateTime; // Changed from 'date' to match home_page
  final String duration;
  final String tutorName; // Changed from 'tutor' to match home_page
  final String? platform;
  final double? rating;
  final String description;
  final String tutorImage; // Added to match home_page
  final Color statusColor; // Added to match home_page
  final VoidCallback? onJoin; // Added to match home_page
  final VoidCallback? onReschedule; // Added to match home_page
  final List<String> participants;
  final bool showActions;
  final bool showStatusMessage;

  const SessionCard({
    super.key,
    required this.title,
    required this.status,
    required this.dateTime,
    required this.duration,
    required this.tutorName,
    required this.statusColor, // Added to match home_page
    required this.tutorImage, // Added to match home_page
    this.platform,
    this.rating,
    required this.description,
    this.onJoin, // Added to match home_page
    this.onReschedule, // Added to match home_page
    this.participants = const [], // Made optional with default value
    this.showActions = false,
    this.showStatusMessage = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'upcoming':
      case 'today':
      case 'tomorrow':
        statusIcon = Icons.access_time;
        break;
      case 'completed':
        statusIcon = Icons.check_circle;
        break;
      case 'pending':
        statusIcon = Icons.pending;
        break;
      case 'declined':
        statusIcon = Icons.cancel;
        break;
      default:
        statusIcon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      status,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildSessionInfo(Icons.calendar_today, dateTime),
              _buildSessionInfo(Icons.access_time, duration),
              _buildSessionInfo(Icons.person, 'with $tutorName'),
              if (platform != null)
                _buildSessionInfo(Icons.videocam, platform!),
              if (rating != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text('$rating/5.0', style: theme.textTheme.bodySmall),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(description, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(tutorImage),
                  ),
                  if (participants.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    for (int i = 0; i < participants.length; i++)
                      Container(
                        margin: EdgeInsets.only(left: i > 0 ? -10 : 0),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage(participants[i]),
                        ),
                      ),
                  ],
                ],
              ),
              if (showActions && (onJoin != null || onReschedule != null))
                Row(
                  children: [
                    if (onReschedule != null)
                      OutlinedButton(
                        onPressed: onReschedule,
                        child: const Text('Reschedule'),
                      ),
                    if (onJoin != null) ...[
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: onJoin,
                        child: const Text('Join'),
                      ),
                    ],
                  ],
                ),
            ],
          ),
          if (showStatusMessage)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status == 'Pending'
                    ? 'Waiting for tutor confirmation...'
                    : 'Tutor is unavailable at this time',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: status == 'Pending' ? null : Colors.red,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSessionInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [Icon(icon, size: 16), const SizedBox(width: 4), Text(text)],
    );
  }
}

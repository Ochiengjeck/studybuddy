import 'package:flutter/material.dart';

class TutorCard extends StatelessWidget {
  final String name;
  final List<String> subjects;
  final double rating;
  final int sessions;
  final int points;
  final int badges;
  final bool isAvailable;
  final String imageUrl;

  const TutorCard({
    super.key,
    required this.name,
    required this.subjects,
    required this.rating,
    required this.sessions,
    required this.points,
    required this.badges,
    required this.isAvailable,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cover Image
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
              ),
              // Tutor Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tutor Avatar and Name
                      SizedBox(
                        height: 60,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              top: -50,
                              child: CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(imageUrl),
                              ),
                            ),
                            Positioned(
                              top: 10,
                              left: 60,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    subjects.take(2).join(' | '),
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Subjects
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            subjects
                                .take(2)
                                .map(
                                  (subject) => Chip(
                                    label: Text(subject),
                                    labelStyle: theme.textTheme.bodySmall,
                                    backgroundColor: theme.colorScheme.primary
                                        .withOpacity(0.1),
                                    side: BorderSide(
                                      color: theme.colorScheme.primary,
                                      width: 1,
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                      const SizedBox(height: 16),
                      // Rating
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '$rating (${(rating * 20).toInt()} reviews)',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStat('Sessions', sessions.toString()),
                          _buildStat('Points', points.toString()),
                          _buildStat('Badges', badges.toString()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Footer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.circle,
                                size: 12,
                                color:
                                    isAvailable
                                        ? theme.colorScheme.secondary
                                        : Colors.red,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isAvailable
                                    ? 'Available Today'
                                    : 'Available Next Week',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              minimumSize: const Size(0, 36),
                            ),
                            child: Text(
                              isAvailable ? 'Book' : 'View',
                              style: theme.textTheme.labelSmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

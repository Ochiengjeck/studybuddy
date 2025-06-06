import 'package:flutter/material.dart';

import '../../../widgets/tutor_card.dart';

class TutorsScreen extends StatefulWidget {
  const TutorsScreen({super.key});

  @override
  State<TutorsScreen> createState() => _TutorsScreenState();
}

class _TutorsScreenState extends State<TutorsScreen> {
  String? _selectedSubject;
  String? _selectedAvailability;
  String? _selectedRating;

  final List<String> _subjects = [
    'All Subjects',
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'Computer Science',
    'English',
    'History',
    'Economics',
  ];

  final List<String> _availabilityOptions = [
    'Any Time',
    'Morning (9AM - 12PM)',
    'Afternoon (1PM - 5PM)',
    'Evening (6PM - 9PM)',
    'Weekends Only',
  ];

  final List<String> _ratingOptions = [
    'Any Rating',
    '4.5+ Stars',
    '4+ Stars',
    '3.5+ Stars',
    '3+ Stars',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search and Filter
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedSubject ?? _subjects.first,
                    items:
                        _subjects.map((subject) {
                          return DropdownMenuItem(
                            value: subject,
                            child: Text(subject),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSubject = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedAvailability ?? _availabilityOptions.first,
                    items:
                        _availabilityOptions.map((option) {
                          return DropdownMenuItem(
                            value: option,
                            child: Text(option),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedAvailability = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Availability',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedRating ?? _ratingOptions.first,
                    items:
                        _ratingOptions.map((option) {
                          return DropdownMenuItem(
                            value: option,
                            child: Text(option),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedRating = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Minimum Rating',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.search),
              label: const Text('Search'),
            ),
            const SizedBox(height: 24),
            // Tutors Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                return TutorCard(
                  name: _getTutorName(index),
                  subjects: _getTutorSubjects(index),
                  rating: _getTutorRating(index),
                  sessions: _getTutorSessions(index),
                  points: _getTutorPoints(index),
                  badges: _getTutorBadges(index),
                  isAvailable: index % 2 == 0,
                  imageUrl:
                      'https://picsum.photos/200/200?random=${10 + index}',
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Load More Tutors'),
            ),
          ],
        ),
      ),
    );
  }

  String _getTutorName(int index) {
    final names = [
      'Sarah Johnson',
      'Michael Chen',
      'Emily Rodriguez',
      'David Lee',
      'Robert Wilson',
      'Jennifer Adams',
    ];
    return names[index % names.length];
  }

  List<String> _getTutorSubjects(int index) {
    final subjects = [
      ['Calculus', 'Linear Algebra', 'Mechanics'],
      ['Python', 'Java', 'Data Structures', 'Algorithms'],
      ['Microeconomics', 'Macroeconomics', 'Finance', 'Marketing'],
      ['Organic Chemistry', 'Biochemistry', 'Genetics'],
      ['Quantum Physics', 'Thermodynamics', 'Differential Equations'],
      ['Literature', 'Creative Writing', 'European History'],
    ];
    return subjects[index % subjects.length];
  }

  double _getTutorRating(int index) {
    return [4.8, 5.0, 5.0, 4.9, 4.7, 4.9][index % 6];
  }

  int _getTutorSessions(int index) {
    return [250, 180, 95, 320, 210, 175][index % 6];
  }

  int _getTutorPoints(int index) {
    return [2500, 2100, 1500, 3200, 2300, 2000][index % 6];
  }

  int _getTutorBadges(int index) {
    return [15, 12, 8, 18, 14, 11][index % 6];
  }
}

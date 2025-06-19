import 'package:flutter/material.dart';

import '../../../widgets/session_card.dart';
import 'virtual_meeting_screen.dart';
import 'booking_details_screen.dart';
import 'session_details_screen.dart';

class SessionsScreen extends StatefulWidget {
  const SessionsScreen({super.key});

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _navigateToSessionScreen({
    required String sessionTitle,
    required String status,
    required String tutorName,
    required String tutorImage,
    required String platform,
    required String dateTime,
    required String duration,
    required String description,
  }) {
    switch (status.toLowerCase()) {
      case 'tomorrow':
      case 'upcoming':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => VirtualMeetingScreen(
                  sessionTitle: sessionTitle,
                  tutorName: tutorName,
                  tutorImage: tutorImage,
                  platform: platform,
                  dateTime: dateTime,
                  duration: duration,
                  description: description,
                ),
          ),
        );
        break;
      case 'pending':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => BookingDetailsScreen(
                  sessionTitle: sessionTitle,
                  tutorName: tutorName,
                  tutorImage: tutorImage,
                  platform: platform,
                  dateTime: dateTime,
                  duration: duration,
                  description: description,
                ),
          ),
        );
        break;
      case 'completed':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => SessionDetailsScreen(
                  sessionTitle: sessionTitle,
                  tutorName: tutorName,
                  tutorImage: tutorImage,
                  platform: platform,
                  dateTime: dateTime,
                  duration: duration,
                  description: description,
                ),
          ),
        );
        break;
      default:
        // Default to session details for unknown status
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => SessionDetailsScreen(
                  sessionTitle: sessionTitle,
                  tutorName: tutorName,
                  tutorImage: tutorImage,
                  platform: platform,
                  dateTime: dateTime,
                  duration: duration,
                  description: description,
                ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(
              context,
            ).colorScheme.onSurface.withOpacity(0.6),
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: const [
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
              Tab(text: 'Requests'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Upcoming Tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap:
                            () => _navigateToSessionScreen(
                              sessionTitle: 'Python Programming Basics',
                              status: 'Tomorrow',
                              tutorName: 'Michael Chen',
                              tutorImage:
                                  'https://picsum.photos/200/200?random=13',
                              platform: 'Google Meet',
                              dateTime: 'Tomorrow, 5:00 PM',
                              duration: '90 minutes',
                              description:
                                  'Introduction to Python syntax, data structures, and basic algorithms.',
                            ),
                        child: SessionCard(
                          title: 'Python Programming Basics',
                          status: 'Tomorrow',
                          statusColor: Colors.orange,
                          dateTime: 'Tomorrow, 5:00 PM',
                          duration: '90 minutes',
                          tutorName: 'Michael Chen',
                          tutorImage: 'https://picsum.photos/200/200?random=13',
                          platform: 'Google Meet',
                          description:
                              'Introduction to Python syntax, data structures, and basic algorithms.',
                          participants: [
                            'https://picsum.photos/200/200?random=3',
                          ],
                          showActions: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap:
                            () => _navigateToSessionScreen(
                              sessionTitle: 'Advanced JavaScript Concepts',
                              status: 'Tomorrow',
                              tutorName: 'Sarah Johnson',
                              tutorImage:
                                  'https://picsum.photos/200/200?random=14',
                              platform: 'Zoom',
                              dateTime: 'Tomorrow, 7:00 PM',
                              duration: '120 minutes',
                              description:
                                  'Deep dive into closures, async/await, and modern ES6+ features.',
                            ),
                        child: SessionCard(
                          title: 'Advanced JavaScript Concepts',
                          status: 'Tomorrow',
                          statusColor: Colors.orange,
                          dateTime: 'Tomorrow, 7:00 PM',
                          duration: '120 minutes',
                          tutorName: 'Sarah Johnson',
                          tutorImage: 'https://picsum.photos/200/200?random=14',
                          platform: 'Zoom',
                          description:
                              'Deep dive into closures, async/await, and modern ES6+ features.',
                          participants: [
                            'https://picsum.photos/200/200?random=1',
                          ],
                          showActions: true,
                        ),
                      ),
                    ],
                  ),
                ),
                // Past Tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap:
                            () => _navigateToSessionScreen(
                              sessionTitle: 'Organic Chemistry Review',
                              status: 'Completed',
                              tutorName: 'David Lee',
                              tutorImage:
                                  'https://picsum.photos/200/200?random=13',
                              platform: 'Google Meet',
                              dateTime: 'Oct 9, 2:00 PM',
                              duration: '90 minutes',
                              description:
                                  'Covered functional groups, reaction mechanisms, and stereochemistry concepts.',
                            ),
                        child: SessionCard(
                          title: 'Organic Chemistry Review',
                          status: 'Completed',
                          statusColor: Colors.green,
                          dateTime: 'Oct 9, 2:00 PM',
                          duration: '90 minutes',
                          tutorName: 'David Lee',
                          tutorImage: 'https://picsum.photos/200/200?random=13',
                          platform: 'Google Meet',
                          description:
                              'Covered functional groups, reaction mechanisms, and stereochemistry concepts.',
                          participants: [
                            'https://picsum.photos/200/200?random=5',
                          ],
                          showActions: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap:
                            () => _navigateToSessionScreen(
                              sessionTitle: 'Calculus Integration Techniques',
                              status: 'Completed',
                              tutorName: 'Emily Rodriguez',
                              tutorImage:
                                  'https://picsum.photos/200/200?random=15',
                              platform: 'Microsoft Teams',
                              dateTime: 'Oct 7, 3:30 PM',
                              duration: '75 minutes',
                              description:
                                  'Integration by parts, substitution methods, and partial fractions.',
                            ),
                        child: SessionCard(
                          title: 'Calculus Integration Techniques',
                          status: 'Completed',
                          statusColor: Colors.green,
                          dateTime: 'Oct 7, 3:30 PM',
                          duration: '75 minutes',
                          tutorName: 'Emily Rodriguez',
                          tutorImage: 'https://picsum.photos/200/200?random=15',
                          platform: 'Microsoft Teams',
                          description:
                              'Integration by parts, substitution methods, and partial fractions.',
                          participants: [
                            'https://picsum.photos/200/200?random=6',
                          ],
                          showActions: true,
                        ),
                      ),
                    ],
                  ),
                ),
                // Requests Tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap:
                            () => _navigateToSessionScreen(
                              sessionTitle: 'Machine Learning Fundamentals',
                              status: 'Pending',
                              tutorName: 'Alex Kumar',
                              tutorImage:
                                  'https://picsum.photos/200/200?random=16',
                              platform: 'Google Meet',
                              dateTime: 'Oct 15, 4:00 PM',
                              duration: '105 minutes',
                              description:
                                  'Introduction to supervised learning, neural networks, and model evaluation.',
                            ),
                        child: SessionCard(
                          title: 'Machine Learning Fundamentals',
                          status: 'Pending',
                          statusColor: Colors.orange,
                          dateTime: 'Oct 15, 4:00 PM',
                          duration: '105 minutes',
                          tutorName: 'Alex Kumar',
                          tutorImage: 'https://picsum.photos/200/200?random=16',
                          platform: 'Google Meet',
                          description:
                              'Introduction to supervised learning, neural networks, and model evaluation.',
                          participants: [
                            'https://picsum.photos/200/200?random=7',
                          ],
                          showActions: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap:
                            () => _navigateToSessionScreen(
                              sessionTitle: 'Database Design Principles',
                              status: 'Pending',
                              tutorName: 'Maria Santos',
                              tutorImage:
                                  'https://picsum.photos/200/200?random=17',
                              platform: 'Zoom',
                              dateTime: 'Oct 16, 6:00 PM',
                              duration: '90 minutes',
                              description:
                                  'Normalization, indexing, query optimization, and database architecture.',
                            ),
                        child: SessionCard(
                          title: 'Database Design Principles',
                          status: 'Pending',
                          statusColor: Colors.orange,
                          dateTime: 'Oct 16, 6:00 PM',
                          duration: '90 minutes',
                          tutorName: 'Maria Santos',
                          tutorImage: 'https://picsum.photos/200/200?random=17',
                          platform: 'Zoom',
                          description:
                              'Normalization, indexing, query optimization, and database architecture.',
                          participants: [
                            'https://picsum.photos/200/200?random=8',
                          ],
                          showActions: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

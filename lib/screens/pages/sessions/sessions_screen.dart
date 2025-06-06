import 'package:flutter/material.dart';

import '../../../widgets/session_card.dart';

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
                      SessionCard(
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
                      SizedBox(height: 16),
                      SessionCard(
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
                          'https://picsum.photos/200/200?random=1',
                        ],
                        showActions: true,
                      ),
                    ],
                  ),
                ),
                // Past Tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // SessionCard(
                      //   title: 'Organic Chemistry Review',
                      //   status: 'Completed',
                      //   date: 'Oct 9, 2:00 PM',
                      //   duration: '75 minutes',
                      //   tutor: 'David Lee',
                      //   rating: 5.0,
                      //   description:
                      //       'Covered functional groups, reaction mechanisms, and stereochemistry concepts.',
                      //   participants: [
                      //     'https://picsum.photos/200/200?random=5',
                      //   ],
                      // ),
                      SessionCard(
                        title: 'Organic Chemistry Review',
                        status: 'Completed',
                        statusColor: Colors.orange,
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
                      SizedBox(height: 16),
                      SessionCard(
                        title: 'Organic Chemistry Review',
                        status: 'Completed',
                        statusColor: Colors.orange,
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
                    ],
                  ),
                ),
                // Requests Tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SessionCard(
                        title: 'Organic Chemistry Review',
                        status: 'Pending',
                        statusColor: Colors.orange,
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
                      SizedBox(height: 16),
                      SessionCard(
                        title: 'Organic Chemistry Review',
                        status: 'Pending',
                        statusColor: Colors.orange,
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

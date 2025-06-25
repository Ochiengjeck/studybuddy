import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/screens/pages/sessions/sessions_screen.dart';

import '../../../utils/modelsAndRepsositories/models_and_repositories.dart';
import '../../../utils/providers/providers.dart';
import '../../../widgets/session_card.dart';
import '../../../widgets/stats_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);

    if (appProvider.authToken != null) {
      try {
        await homeProvider.loadHomeData(appProvider.authToken!);
      } catch (e) {
        debugPrint('Error loading home data: $e');
        // You could show an error snackbar here if needed
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dashboard',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Stats Cards
              _buildStatsSection(homeProvider),
              const SizedBox(height: 20),
              _buildUpcomingSessionsSection(homeProvider),
              const SizedBox(height: 20),
              _buildRecentActivitiesSection(homeProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(HomeProvider homeProvider) {
    if (homeProvider.isLoading && homeProvider.userStats == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (homeProvider.error != null) {
      return Center(
        child: Column(
          children: [
            Text('Error: ${homeProvider.error}'),
            TextButton(onPressed: _loadData, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (homeProvider.userStats == null) {
      return const Center(child: Text('No stats available'));
    }

    return _buildStatsGrid(homeProvider.userStats!);
  }

  Widget _buildStatsGrid(UserStats stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        StatsCard(
          title: 'Sessions Completed',
          value: stats.sessionsCompleted.toString(),
          icon: Icons.calendar_today,
          iconColor: Theme.of(context).primaryColor,
          progress: stats.sessionsCompleted / 20,
        ),
        StatsCard(
          title: 'Points Earned',
          value: stats.pointsEarned.toString(),
          icon: Icons.star,
          iconColor: Colors.green,
          progress: stats.pointsEarned / 500,
        ),
        StatsCard(
          title: 'Badges Earned',
          value: stats.badgesEarned.toString(),
          icon: Icons.emoji_events,
          iconColor: Colors.amber,
          progress: stats.badgesEarned / 10,
        ),
        StatsCard(
          title: 'Average Rating',
          value: stats.averageRating.toStringAsFixed(1),
          icon: Icons.star_half,
          iconColor: Colors.purple,
          progress: stats.averageRating / 5,
        ),
      ],
    );
  }

  Widget _buildUpcomingSessionsSection(HomeProvider homeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Upcoming Sessions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => Scaffold(
                          appBar: AppBar(),
                          body: const SessionsScreen(),
                        ),
                  ),
                );
              },
              child: const Text("View All"),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (homeProvider.isLoading &&
            homeProvider.upcomingSessionsPreview == null)
          const Center(child: CircularProgressIndicator())
        else if (homeProvider.upcomingSessionsPreview == null ||
            homeProvider.upcomingSessionsPreview!.isEmpty)
          const Text('No upcoming sessions')
        else
          Column(
            children:
                homeProvider.upcomingSessionsPreview!
                    .map(
                      (session) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SessionCard(
                          title: session.title,
                          tutorName: session.tutorName,
                          dateTime: session.formattedDateTime,
                          duration: '${session.duration} minutes',
                          status: session.statusText,
                          statusColor: _getStatusColor(session.statusText),
                          tutorImage: session.tutorImage,
                          description: session.description,
                          onJoin: () => _handleJoinSession(session.id),
                          onReschedule:
                              () => _handleRescheduleSession(session.id),
                        ),
                      ),
                    )
                    .toList(),
          ),
      ],
    );
  }

  Widget _buildRecentActivitiesSection(HomeProvider homeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (homeProvider.isLoading && homeProvider.recentActivities == null)
          const Center(child: CircularProgressIndicator())
        else if (homeProvider.recentActivities == null ||
            homeProvider.recentActivities!.isEmpty)
          const Text('No recent activity')
        else
          Column(
            children:
                homeProvider.recentActivities!
                    .map(
                      (activity) => _buildActivityItem(
                        context,
                        icon: _getActivityIcon(activity.type.toString()),
                        iconColor: _getActivityColor(activity.type.toString()),
                        title: activity.title,
                        subtitle: activity.description,
                        time: activity.formattedTime,
                      ),
                    )
                    .toList(),
          ),
      ],
    );
  }

  // Widget _buildStatsGrid(UserStats stats) {
  //   return GridView.count(
  //     shrinkWrap: true,
  //     physics: const NeverScrollableScrollPhysics(),
  //     crossAxisCount: 2,
  //     crossAxisSpacing: 16,
  //     mainAxisSpacing: 16,
  //     childAspectRatio: 1.2,
  //     children: [
  //       StatsCard(
  //         title: 'Sessions Completed',
  //         value: stats.sessionsCompleted.toString(),
  //         icon: Icons.calendar_today,
  //         iconColor: Theme.of(context).primaryColor,
  //         progress:
  //             stats.sessionsCompleted / 20, // Assuming goal is 20 sessions
  //       ),
  //       StatsCard(
  //         title: 'Points Earned',
  //         value: stats.pointsEarned.toString(),
  //         icon: Icons.star,
  //         iconColor: Colors.green,
  //         progress: stats.pointsEarned / 500, // Assuming goal is 500 points
  //       ),
  //       StatsCard(
  //         title: 'Badges Earned',
  //         value: stats.badgesEarned.toString(),
  //         icon: Icons.emoji_events,
  //         iconColor: Colors.amber,
  //         progress: stats.badgesEarned / 10, // Assuming goal is 10 badges
  //       ),
  //       StatsCard(
  //         title: 'Average Rating',
  //         value: stats.averageRating.toStringAsFixed(1),
  //         icon: Icons.star_half,
  //         iconColor: Colors.purple,
  //         progress: stats.averageRating / 5, // Rating out of 5
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildUpcomingSessionsSection(HomeProvider homeProvider) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Row(
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Text(
  //             'Upcoming Sessions',
  //             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               Navigator.push(
  //                 context,
  //                 MaterialPageRoute(
  //                   builder: (context) {
  //                     return Scaffold(
  //                       appBar: AppBar(),
  //                       body: const SessionsScreen(),
  //                     );
  //                   },
  //                 ),
  //               );
  //             },
  //             child: const Text("View All.."),
  //           ),
  //         ],
  //       ),
  //       const SizedBox(height: 10),
  //       if (homeProvider.upcomingSessionsPreview == null ||
  //           homeProvider.upcomingSessionsPreview!.isEmpty)
  //         const Text('No upcoming sessions')
  //       else
  //         Column(
  //           children:
  //               homeProvider.upcomingSessionsPreview!
  //                   .map(
  //                     (session) => Padding(
  //                       padding: const EdgeInsets.only(bottom: 10),
  //                       child: SessionCard(
  //                         title: session.title,
  //                         tutorName: session.tutorName,
  //                         dateTime: session.formattedDateTime,
  //                         duration: '${session.duration} minutes',
  //                         status: session.statusText,
  //                         statusColor: _getStatusColor(session.statusText),
  //                         tutorImage: session.tutorImage,
  //                         description: session.description,
  //                         onJoin: () => _handleJoinSession(session.id),
  //                         onReschedule:
  //                             () => _handleRescheduleSession(session.id),
  //                       ),
  //                     ),
  //                   )
  //                   .toList(),
  //         ),
  //     ],
  //   );
  // }

  // Widget _buildRecentActivitiesSection(HomeProvider homeProvider) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         'Recent Activity',
  //         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //       ),
  //       const SizedBox(height: 10),
  //       if (homeProvider.recentActivities == null ||
  //           homeProvider.recentActivities!.isEmpty)
  //         const Text('No recent activity')
  //       else
  //         Column(
  //           children:
  //               homeProvider.recentActivities!
  //                   .map(
  //                     (activity) => _buildActivityItem(
  //                       context,
  //                       icon: _getActivityIcon(activity as String),
  //                       iconColor: _getActivityColor(activity.type as String),
  //                       title: activity.title,
  //                       subtitle: activity.description,
  //                       time: activity.formattedTime,
  //                     ),
  //                   )
  //                   .toList(),
  //         ),
  //     ],
  //   );
  // }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getActivityIcon(String activityType) {
    switch (activityType) {
      case 'badge':
        return Icons.emoji_events;
      case 'points':
        return Icons.star;
      case 'session':
        return Icons.calendar_today;
      default:
        return Icons.notifications;
    }
  }

  Color _getActivityColor(String activityType) {
    switch (activityType) {
      case 'badge':
        return Colors.blue;
      case 'points':
        return Colors.green;
      case 'session':
        return Colors.amber;
      default:
        return Colors.purple;
    }
  }

  void _handleJoinSession(String sessionId) {
    // Implement join session logic using SessionProvider
    final authToken = context.read<AppProvider>().authToken;
    if (authToken != null) {
      // TODO: Implement join session functionality
    }
  }

  void _handleRescheduleSession(String sessionId) {
    // Implement reschedule session logic using SessionProvider
    final authToken = context.read<AppProvider>().authToken;
    if (authToken != null) {
      // TODO: Implement reschedule session functionality
    }
  }

  Widget _buildActivityItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle),
            const SizedBox(height: 4),
            Text(time, style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/screens/pages/sessions/sessions_screen.dart';
import 'package:studybuddy/widgets/session_card.dart';
import 'package:studybuddy/widgets/stats_card.dart';

import '../../../utils/providers/providers.dart';
import '../../../widgets/custom_loading.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Load data after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      if (appProvider.currentUser != null) {
        homeProvider.loadHomeData(appProvider.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          if (appProvider.isInitializing) {
            return Center(child: StudyBuddyLoadingWidgets.animatedBookLoader());
          }
          if (appProvider.error != null) {
            return Center(child: Text('Error: ${appProvider.error}'));
          }
          if (appProvider.currentUser == null) {
            return const Center(child: Text('Please log in'));
          }
          return Consumer<HomeProvider>(
            builder: (context, homeProvider, child) {
              if (homeProvider.isLoading) {
                return Center(
                  child: StudyBuddyLoadingWidgets.brainThinkingLoader(),
                );
              }
              if (homeProvider.error != null) {
                return Center(child: Text('Error: ${homeProvider.error}'));
              }
              final userStats = homeProvider.userStats;
              final upcomingSessions =
                  homeProvider.upcomingSessionsPreview ?? [];
              final recentActivities = homeProvider.recentActivities ?? [];
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dashboard',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Stats Cards
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2,
                      children: [
                        StatsCard(
                          title: 'Sessions Completed',
                          value: userStats?.sessionsCompleted.toString() ?? '0',
                          icon: Icons.calendar_today,
                          iconColor: Theme.of(context).primaryColor,
                          progress:
                              (userStats?.sessionsCompleted ?? 0) /
                              20, // Example max
                        ),
                        StatsCard(
                          title: 'Points Earned',
                          value: userStats?.pointsEarned.toString() ?? '0',
                          icon: Icons.star,
                          iconColor: Colors.green,
                          progress:
                              (userStats?.pointsEarned ?? 0) /
                              1000, // Example max
                        ),
                        StatsCard(
                          title: 'Badges Earned',
                          value: userStats?.badgesEarned.toString() ?? '0',
                          icon: Icons.emoji_events,
                          iconColor: Colors.amber,
                          progress:
                              (userStats?.badgesEarned ?? 0) /
                              10, // Example max
                        ),
                        StatsCard(
                          title: 'Average Rating',
                          value:
                              userStats?.averageRating.toStringAsFixed(1) ??
                              '0.0',
                          icon: Icons.star_half,
                          iconColor: Colors.purple,
                          progress:
                              (userStats?.averageRating ?? 0) / 5, // Max 5
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Upcoming Sessions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
                          child: const Text("View All.."),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (upcomingSessions.isEmpty)
                      Center(
                        child: Image.asset("assets/no_data.png", height: 200),
                      )
                    else
                      ...upcomingSessions.take(2).map((session) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: SessionCard(
                            title: session.title,
                            tutorName: session.tutorName,
                            dateTime: session.formattedDateTime,
                            duration: session.formattedDuration,
                            status: session.statusText,
                            statusColor: session.statusColor,
                            description: session.description,
                            tutorImage: session.tutorImage,
                            onJoin: () {
                              // Handle join session (e.g., open platform link)
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Joining ${session.title}'),
                                ),
                              );
                            },
                            onReschedule: () async {
                              // Handle reschedule
                              final sessionProvider =
                                  Provider.of<SessionProvider>(
                                    context,
                                    listen: false,
                                  );
                              try {
                                // Example: Reschedule to tomorrow same time
                                final newTime = session.startTime.add(
                                  Duration(days: 1),
                                );
                                await sessionProvider.rescheduleSession(
                                  appProvider.currentUser!.id,
                                  session.id,
                                  newTime,
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Session rescheduled'),
                                    ),
                                  );
                                }
                                // Refresh data
                                homeProvider?.loadHomeData(
                                  appProvider.currentUser!.id,
                                  forceRefresh: true,
                                );
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              }
                            },
                          ),
                        );
                      }).toList(),
                    const SizedBox(height: 20),
                    const Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (recentActivities.isEmpty)
                      Center(
                        child: Image.asset("assets/empty.png", height: 300),
                      )
                    else if (recentActivities.length == 1)
                      _buildActivityItem(
                        context,
                        icon: recentActivities[0].icon,
                        iconColor: recentActivities[0].iconColor,
                        title: recentActivities[0].title,
                        subtitle: recentActivities[0].description,
                        time: recentActivities[0].formattedTime,
                      )
                    else
                      ...recentActivities.map((activity) {
                        return _buildActivityItem(
                          context,
                          icon: activity.icon,
                          iconColor: activity.iconColor,
                          title: activity.title,
                          subtitle: activity.description,
                          time: activity.formattedTime,
                        );
                      }).toList(),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
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
            Text(
              time,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../widgets/session_card.dart';
import '../../../widgets/stats_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Stats Cards
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                StatsCard(
                  title: 'Sessions Completed',
                  value: '12',
                  icon: Icons.calendar_today,
                  iconColor: Theme.of(context).primaryColor,
                  progress: 0.6,
                ),
                StatsCard(
                  title: 'Points Earned',
                  value: '250',
                  icon: Icons.star,
                  iconColor: Colors.green,
                  progress: 0.4,
                ),
                StatsCard(
                  title: 'Badges Earned',
                  value: '5',
                  icon: Icons.emoji_events,
                  iconColor: Colors.amber,
                  progress: 0.5,
                ),
                StatsCard(
                  title: 'Average Rating',
                  value: '4.8',
                  icon: Icons.star_half,
                  iconColor: Colors.purple,
                  progress: 0.85,
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Upcoming Sessions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            SessionCard(
              title: 'Advanced Calculus Tutoring',
              tutorName: 'Sarah Johnson',
              dateTime: 'Today, 3:00 PM',
              duration: '60 minutes',
              status: 'Upcoming',
              statusColor: Colors.orange,
              description:
                  'Focus on derivatives, integrals, and their applications in real-world problems.',
              tutorImage: 'https://picsum.photos/200/200?random=1',
              onJoin: () {
                // Handle join session
              },
              onReschedule: () {
                // Handle reschedule
              },
            ),
            SizedBox(height: 10),
            SessionCard(
              title: 'Python Programming Basics',
              tutorName: 'Michael Chen',
              dateTime: 'Tomorrow, 5:00 PM',
              duration: '90 minutes',
              status: 'Upcoming',
              statusColor: Colors.orange,
              description:
                  'Introduction to Python syntax, data structures, and basic algorithms.',
              tutorImage: 'https://picsum.photos/200/200?random=3',
              onJoin: () {
                // Handle join session
              },
              onReschedule: () {
                // Handle reschedule
              },
            ),
            SizedBox(height: 20),
            Text(
              'Recent Activity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _buildActivityItem(
              context,
              icon: Icons.emoji_events,
              iconColor: Colors.blue,
              title: 'You earned the "Fast Learner" badge!',
              subtitle: 'Completed 5 tutoring sessions in your first month',
              time: '2 hours ago',
            ),
            _buildActivityItem(
              context,
              icon: Icons.star,
              iconColor: Colors.green,
              title: 'You received 50 points!',
              subtitle: 'Sarah Johnson rated your tutoring session 5 stars',
              time: 'Yesterday',
            ),
            _buildActivityItem(
              context,
              icon: Icons.calendar_today,
              iconColor: Colors.amber,
              title: 'Session completed successfully',
              subtitle:
                  'You completed a Physics tutoring session with David Williams',
              time: '2 days ago',
            ),
          ],
        ),
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
      margin: EdgeInsets.only(bottom: 10),
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
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle),
            SizedBox(height: 4),
            Text(time, style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

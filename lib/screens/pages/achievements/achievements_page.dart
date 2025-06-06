import 'package:flutter/material.dart';

import '../../../widgets/achievement_badge.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Earned Badges
            const Text(
              'Earned Badges',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 0.9,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: const [
                AchievementBadge(
                  icon: Icons.rocket_launch,
                  title: 'Fast Learner',
                  description: 'Complete 5 sessions in your first month',
                  earned: true,
                  progress: 1.0,
                ),
                AchievementBadge(
                  icon: Icons.star,
                  title: '5-Star Student',
                  description: 'Receive 5 perfect ratings',
                  earned: true,
                  progress: 0.6,
                ),
                AchievementBadge(
                  icon: Icons.book,
                  title: 'Bookworm',
                  description: 'Complete 10 study sessions',
                  earned: true,
                  progress: 0.8,
                ),
                AchievementBadge(
                  icon: Icons.forum,
                  title: 'Active Participant',
                  description: 'Send 50 messages',
                  earned: true,
                  progress: 0.45,
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Locked Badges
            const Text(
              'Next Badges',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 0.9,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: const [
                AchievementBadge(
                  icon: Icons.workspace_premium,
                  title: 'Master Tutor',
                  description: 'Complete 50 sessions',
                  earned: false,
                  progress: 0.24,
                ),
                AchievementBadge(
                  icon: Icons.lightbulb,
                  title: 'Subject Expert',
                  description: 'Master 3 subjects',
                  earned: false,
                  progress: 0.66,
                ),
                AchievementBadge(
                  icon: Icons.emoji_events,
                  title: 'Top Performer',
                  description: 'Reach top 10 on leaderboard',
                  earned: false,
                  progress: 0.3,
                ),
                AchievementBadge(
                  icon: Icons.school,
                  title: 'Mentor',
                  description: 'Help 5 other students',
                  earned: false,
                  progress: 0.2,
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Progress Chart
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(child: Text('Progress Chart Placeholder')),
            ),
          ],
        ),
      ),
    );
  }
}

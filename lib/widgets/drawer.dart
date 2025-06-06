import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemSelected;

  const CustomDrawer({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 250,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(16)),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Text(
                      'JD',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'John Doe',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Student',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.home_rounded,
            title: 'Home',
            index: 0,
            isSelected: currentIndex == 0,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.calendar_today_rounded,
            title: 'Sessions',
            index: 1,
            isSelected: currentIndex == 1,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.school_rounded,
            title: 'Find Tutors',
            index: 2,
            isSelected: currentIndex == 2,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.chat_bubble_rounded,
            title: 'Messages',
            index: 3,
            isSelected: currentIndex == 3,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.emoji_events_rounded,
            title: 'Achievements',
            index: 4,
            isSelected: currentIndex == 4,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.leaderboard_rounded,
            title: 'Leaderboard',
            index: 5,
            isSelected: false,
          ),
          const Divider(indent: 16, endIndent: 16),
          _buildDrawerItem(
            context,
            icon: Icons.settings_rounded,
            title: 'Settings',
            index: 6,
            isSelected: false,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.logout_rounded,
            title: 'Logout',
            index: 7,
            isSelected: false,
            color: Theme.of(context).colorScheme.error,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int index,
    required bool isSelected,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Theme.of(context).iconTheme.color),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () => onItemSelected(index),
      tileColor:
          isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      minLeadingWidth: 24,
    );
  }
}

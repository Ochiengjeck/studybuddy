import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/screens/auth/log_in.dart';

import '../utils/modelsAndRepsositories/models_and_repositories.dart';
import '../utils/providers/providers.dart';

class CustomDrawer extends StatefulWidget {
  final int currentIndex;
  final Function(int) onItemSelected;

  const CustomDrawer({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
    _slideController.forward();

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      final sessionProvider = Provider.of<SessionProvider>(
        context,
        listen: false,
      );

      if (appProvider.currentUser != null) {
        homeProvider.loadHomeData(appProvider.currentUser!.id);
        chatProvider.loadMessages(appProvider.currentUser!.id);
        sessionProvider.loadPendingSessions(appProvider.currentUser!.id);
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 10,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.red,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Confirm Logout'),
              ],
            ),
            content: const Text(
              'Are you sure you want to logout from your account?',
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final authProvider = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  // Clear all relevant providers before logout
                  final appProvider = Provider.of<AppProvider>(
                    context,
                    listen: false,
                  );
                  final homeProvider = Provider.of<HomeProvider>(
                    context,
                    listen: false,
                  );
                  final chatProvider = Provider.of<ChatProvider>(
                    context,
                    listen: false,
                  );
                  final sessionProvider = Provider.of<SessionProvider>(
                    context,
                    listen: false,
                  );
                  // Add more providers as needed
                  appProvider.logout();
                  homeProvider.clearError();
                  chatProvider.clearCache();
                  sessionProvider.clearError();
                  // If you have clearCache or similar for other providers, call them here
                  try {
                    await authProvider.logout();
                    if (context.mounted) {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Logout failed: e.toString()')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.horizontal(
            right: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(5, 0),
            ),
          ],
        ),
        child: SafeArea(
          child: Consumer<AppProvider>(
            builder: (context, appProvider, child) {
              if (appProvider.isInitializing) {
                return const Center(child: CircularProgressIndicator());
              }
              if (appProvider.error != null) {
                return Center(child: Text('Error: ${appProvider.error}'));
              }
              if (appProvider.currentUser == null) {
                return const Center(child: Text('Please log in'));
              }
              return Column(
                children: [
                  _buildHeader(context, appProvider.currentUser!),
                  Expanded(
                    child: Consumer2<ChatProvider, SessionProvider>(
                      builder: (context, chatProvider, sessionProvider, child) {
                        return ListView(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          children: [
                            _buildSectionHeader('Navigation'),
                            _buildDrawerItem(
                              context,
                              icon: Icons.dashboard_rounded,
                              title: 'Dashboard',
                              subtitle: 'Overview & Stats',
                              index: 0,
                              isSelected: widget.currentIndex == 0,
                            ),
                            _buildDrawerItem(
                              context,
                              icon: Icons.school_rounded,
                              title: 'My Sessions',
                              subtitle: 'Upcoming & Past',
                              index: 1,
                              isSelected: widget.currentIndex == 1,
                              badge:
                                  sessionProvider.upcomingSessions?.length
                                      .toString(),
                            ),
                            _buildDrawerItem(
                              context,
                              icon: Icons.person_search_rounded,
                              title: 'Find Tutors',
                              subtitle: 'Browse Experts',
                              index: 2,
                              isSelected: widget.currentIndex == 2,
                            ),
                            _buildDrawerItem(
                              context,
                              icon: Icons.chat_bubble_rounded,
                              title: 'Messages',
                              subtitle: 'Chat & Support',
                              index: 3,
                              isSelected: widget.currentIndex == 3,
                              badge: chatProvider.chats?.length.toString(),
                            ),
                            const SizedBox(height: 16),
                            _buildSectionHeader('Progress'),
                            _buildDrawerItem(
                              context,
                              icon: Icons.emoji_events_rounded,
                              title: 'Achievements',
                              subtitle: 'Badges & Rewards',
                              index: 4,
                              isSelected: widget.currentIndex == 4,
                            ),
                            _buildDrawerItem(
                              context,
                              icon: Icons.leaderboard_rounded,
                              title: 'Leaderboard',
                              subtitle: 'Rankings & Stats',
                              index: 5,
                              isSelected: widget.currentIndex == 5,
                            ),
                            const SizedBox(height: 16),
                            _buildSectionHeader('Account'),
                            _buildDrawerItem(
                              context,
                              icon: Icons.settings_rounded,
                              title: 'Settings',
                              subtitle: 'Preferences',
                              index: 6,
                              isSelected: widget.currentIndex == 6,
                            ),
                            _buildDrawerItem(
                              context,
                              icon: Icons.help_outline_rounded,
                              title: 'Help & Support',
                              subtitle: 'FAQ & Contact',
                              index: 11,
                              isSelected: widget.currentIndex == 11,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  _buildFooter(context),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, User user) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        final userStats = homeProvider.userStats;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(24),
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          margin: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Hero(
                    tag: 'drawer_avatar',
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        image:
                            user.profilePicture != null
                                ? DecorationImage(
                                  image: NetworkImage(user.profilePicture!),
                                  fit: BoxFit.cover,
                                )
                                : null,
                      ),
                      child:
                          user.profilePicture == null
                              ? Center(
                                child: Text(
                                  user.fullName.isNotEmpty
                                      ? user.fullName
                                          .split(' ')
                                          .map((e) => e.isNotEmpty ? e[0] : '')
                                          .take(2)
                                          .join()
                                      : 'U',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              )
                              : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              user.userType?.toUpperCase() ?? 'Student',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildStatCard(
                    context,
                    icon: Icons.access_time_rounded,
                    label: 'Study Hours',
                    value:
                        userStats != null
                            ? '${(userStats.sessionsCompleted * 1).toStringAsFixed(1)}h'
                            : '0h',
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    context,
                    icon: Icons.trending_up_rounded,
                    label: 'Progress',
                    value:
                        userStats != null
                            ? '${(userStats.averageRating * 20).toInt()}%'
                            : '0%',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required int index,
    required bool isSelected,
    String? badge,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => widget.onItemSelected(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border:
                  isSelected
                      ? Border.all(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                        width: 1,
                      )
                      : null,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color:
                        isSelected
                            ? Colors.white
                            : Theme.of(context).primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w600,
                          color:
                              isSelected
                                  ? Theme.of(context).primaryColor
                                  : null,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (badge != null && badge != '0')
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _showLogoutDialog(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.logout_rounded,
                          color: Colors.red,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Text(
            'StudyBuddy v2.1.0',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
    );
  }
}

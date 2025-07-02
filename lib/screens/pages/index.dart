import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/screens/pages/Analytics/analytics_page.dart';
import 'package:studybuddy/screens/pages/achievements/achievements_page.dart';
import 'package:studybuddy/screens/pages/achievements/leaderboard/leaderboard_screen.dart';
import 'package:studybuddy/screens/pages/help_support_page.dart';
import 'package:studybuddy/screens/pages/home/home_page.dart';
import 'package:studybuddy/screens/pages/materials/saved_items_page.dart';
import 'package:studybuddy/screens/pages/materials/study_materials_page.dart';
import 'package:studybuddy/screens/pages/messages/chat_list_screen.dart';
import 'package:studybuddy/screens/pages/sessions/sessions_screen.dart';
import 'package:studybuddy/screens/pages/settings/settings_page.dart';
import 'package:studybuddy/screens/pages/test/practice_tests_page.dart';
import 'package:studybuddy/screens/pages/tutors/tutors_screen.dart';
import 'package:studybuddy/utils/providers/providers.dart';
// import 'package:studybuddy/widgets/bottom_navigation_bar.dart';
import 'package:studybuddy/widgets/drawer.dart';

import '../../widgets/maintainance_pop_up.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> with TickerProviderStateMixin {
  int _currentIndexPage = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<Widget> screens = [
    const HomePage(),
    const SessionsScreen(),
    const TutorsScreen(),
    const ChatListScreen(),
    const AchievementsScreen(),
    const LeaderboardPage(),
    const SettingsPage(),
    const AnalyticsPage(),
    const StudyMaterialsPage(),
    const PracticeTestsPage(),
    const SavedItemsPage(),
    const HelpSupportPage(),
  ];

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _navigateToScreen(int index) {
    if (index != _currentIndexPage) {
      _fadeController.reset();
      setState(() {
        _currentIndexPage = index;
      });
      _fadeController.forward();
    }
    // Close the drawer if it's open
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      _scaffoldKey.currentState?.closeDrawer();
    }
  }

  void _showUserMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildUserInfo(),
                  const SizedBox(height: 20),
                  _buildMenuTile(
                    icon: Icons.person_outline_rounded,
                    title: 'Account Settings',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to account settings
                    },
                  ),
                  _buildMenuTile(
                    icon: Icons.apps_rounded,
                    title: 'Applications',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to applications
                    },
                  ),
                  _buildMenuTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Help & Support',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to help
                    },
                  ),
                  _buildMenuTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to privacy policy
                    },
                  ),
                  const Divider(height: 30),
                  _buildMenuTile(
                    icon: Icons.logout_rounded,
                    title: 'Logout',
                    isDestructive: true,
                    onTap: () {
                      Navigator.pop(context);
                      _showLogoutDialog(context);
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildUserInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Hero(
            tag: 'user_avatar',
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'John Doe', // Replace with actual user name
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'john.doe@email.com', // Replace with actual email
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Premium Member',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      isDestructive
                          ? Colors.red.withOpacity(0.1)
                          : Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color:
                      isDestructive
                          ? Colors.red
                          : Theme.of(context).primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDestructive ? Colors.red : null,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey[400],
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Perform logout logic here
                  Provider.of<AppProvider>(context, listen: false).logout();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: CustomDrawer(
        currentIndex: _currentIndexPage,
        onItemSelected: _navigateToScreen,
      ),
      appBar: _buildModernAppBar(context),
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: IndexedStack(index: _currentIndexPage, children: screens),
          );
        },
      ),
      // Uncomment if you want to use bottom navigation
      // bottomNavigationBar: CustomBottomNavigationBar(
      //   currentIndexPage: _currentIndexPage,
      //   onTap: _navigateToScreen,
      // ),
    );
  }

  PreferredSizeWidget _buildModernAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
      leading: Builder(
        builder:
            (context) => Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.menu_rounded,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
      ),
      title: Row(
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getAppBarTitle(_currentIndexPage),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                if (_getAppBarSubtitle(_currentIndexPage).isNotEmpty)
                  Text(
                    _getAppBarSubtitle(_currentIndexPage),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (_currentIndexPage == 3) // Messages screen
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: Icon(
                Icons.search_rounded,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: () {
                // Handle search functionality
              },
            ),
          ),
        // Notification icon
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              IconButton(
                icon: Icon(
                  Icons.notifications_outlined,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  MaintenancePopup.show(context);
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.5),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // User avatar
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () => _showUserMenu(context),
            child: Hero(
              tag: 'user_avatar',
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'StudyBuddy';
      case 1:
        return 'My Sessions';
      case 2:
        return 'Find Tutors';
      case 3:
        return 'Messages';
      case 4:
        return 'Achievements';
      case 5:
        return 'Leaderboard';
      case 6:
        return 'Settings';
      case 7:
        return 'Analytics';
      case 8:
        return 'Study Materials';
      case 9:
        return 'Practice Tests';
      case 10:
        return 'Saved Items';
      case 11:
        return 'Help & Support';
      default:
        return 'StudyBuddy';
    }
  }

  String _getAppBarSubtitle(int index) {
    switch (index) {
      case 0:
        return 'Welcome back!';
      case 1:
        return 'Track your progress';
      case 2:
        return 'Connect with experts';
      case 3:
        return 'Stay connected';
      case 4:
        return 'Celebrate your success';
      case 5:
        return 'See how you rank';
      case 6:
        return 'Customize your experience';
      case 7:
        return 'Study Insights';
      case 8:
        return 'Books & Resources';
      case 9:
        return 'Quizzes & Exams';
      case 10:
        return 'Bookmarks & Notes';
      case 11:
        return 'FAQ & Contact';
      default:
        return '';
    }
  }
}

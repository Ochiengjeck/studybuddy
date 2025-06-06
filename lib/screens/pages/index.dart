import 'package:flutter/material.dart';
import 'package:studybuddy/screens/pages/achievements/achievements_page.dart';
import 'package:studybuddy/screens/pages/achievements/leaderboard/leaderboard_screen.dart';
import 'package:studybuddy/screens/pages/home/home_page.dart';
import 'package:studybuddy/screens/pages/messages/chat_list_screen.dart';
import 'package:studybuddy/screens/pages/sessions/sessions_screen.dart';
import 'package:studybuddy/screens/pages/settings/settings_page.dart';
import 'package:studybuddy/screens/pages/tutors/tutors_screen.dart';
import 'package:studybuddy/widgets/custom_app_bar.dart';
import 'package:studybuddy/widgets/bottom_navigation_bar.dart';
import 'package:studybuddy/widgets/drawer.dart';

class Index extends StatefulWidget {
  const Index({super.key});

  @override
  State<Index> createState() => _IndexState();
}

class _IndexState extends State<Index> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> screens = [
    const HomePage(),
    const SessionsScreen(),
    const TutorsScreen(),
    const ChatListScreen(),
    const AchievementsScreen(),
    const LeaderboardPage(),
    const SettingsPage(),
  ];

  void _navigateToScreen(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Close the drawer if it's open
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      _scaffoldKey.currentState?.closeDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: CustomDrawer(
        currentIndex: _currentIndex,
        onItemSelected: _navigateToScreen,
      ),
      appBar: CustomAppBar(
        title: _getAppBarTitle(_currentIndex),
        actions:
            _currentIndex == 3
                ? [IconButton(icon: const Icon(Icons.search), onPressed: () {})]
                : null,
      ),
      body: IndexedStack(index: _currentIndex, children: screens),
      // bottomNavigationBar: CustomBottomNavigationBar(
      //   currentIndex: _currentIndex,
      //   onTap: _navigateToScreen,
      // ),
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
      default:
        return 'StudyBuddy';
    }
  }
}

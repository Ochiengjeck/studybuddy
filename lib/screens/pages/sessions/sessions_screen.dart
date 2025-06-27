import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/modelsAndRepsositories/models_and_repositories.dart';
import '../../../utils/providers/providers.dart';
import '../../../widgets/session_card.dart';
import 'virtual_meeting_screen.dart';
import 'booking_details_screen.dart';
import 'session_details_screen.dart';
import 'apply_for_session_screen.dart';
import 'organize_session_screen.dart';

class SessionsScreen extends StatefulWidget {
  const SessionsScreen({super.key});

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late SessionProvider _sessionProvider;
  late String _userId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    _userId = appProvider.currentUser?.id ?? '';

    // Load initial data
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    await _sessionProvider.loadUpcomingSessions(_userId);
    await _sessionProvider.loadPastSessions(_userId);
    await _sessionProvider.loadPendingSessions(_userId);
  }

  void _navigateToSessionScreen(Session session) {
    switch (session.status) {
      case SessionStatus.upcoming:
      case SessionStatus.inProgress:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VirtualMeetingScreen(session: session),
          ),
        );
        break;
      case SessionStatus.pending:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookingDetailsScreen(session: session),
          ),
        );
        break;
      case SessionStatus.completed:
      case SessionStatus.declined:
      default:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SessionDetailsScreen(session: session),
          ),
        );
    }
  }

  void _navigateToApplyForSession() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ApplyForSessionScreen()),
    );
  }

  void _navigateToOrganizeSession() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OrganizeSessionScreen()),
    );
  }

  Widget _buildSessionList(List<Session>? sessions) {
    if (sessions == null || sessions.isEmpty) {
      return Center(
        child: Column(
          children: [
            Image.asset('assets/no_session.png', height: 150),
            Text('No sessions found'),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children:
            sessions.map((session) {
              return GestureDetector(
                onTap: () => _navigateToSessionScreen(session),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SessionCard(
                    title: session.title,
                    status: session.statusText,
                    statusColor: session.statusColor,
                    dateTime: session.formattedDateTime,
                    duration: session.formattedDuration,
                    tutorName: session.tutorName,
                    tutorImage: session.tutorImage,
                    platform: session.platform,
                    description: session.description,
                    participants: session.participantImages,
                    showActions: true,
                  ),
                ),
              );
            }).toList(),
      ),
    );
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
            child: Consumer<SessionProvider>(
              builder: (context, sessionProvider, _) {
                if (sessionProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (sessionProvider.error != null) {
                  return Center(child: Text('Error: ${sessionProvider.error}'));
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    // Upcoming Tab
                    _buildSessionList(sessionProvider.upcomingSessions),
                    // Past Tab
                    _buildSessionList(sessionProvider.pastSessions),
                    // Requests Tab
                    _buildSessionList(sessionProvider.pendingSessions),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            onPressed: _navigateToApplyForSession,
            heroTag: "apply_session",
            label: const Text('Apply for Session'),
            icon: const Icon(Icons.person_add),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            onPressed: _navigateToOrganizeSession,
            heroTag: "organize_session",
            label: const Text('Organize Session'),
            icon: const Icon(Icons.add_circle),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

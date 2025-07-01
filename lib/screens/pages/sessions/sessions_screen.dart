import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/screens/pages/tutors/apply_tutor/apply_tutor_flow.dart';
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
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    _userId = appProvider.currentUser?.id ?? '';

    // Defer loading until after build completes to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSessions();
    });

    // Set up periodic refresh every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _loadSessions(forceRefresh: true);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadSessions({bool forceRefresh = false}) async {
    if (!mounted) return;

    try {
      await Future.wait([
        _sessionProvider.loadUpcomingSessions(
          _userId,
          forceRefresh: forceRefresh,
        ),
        _sessionProvider.loadPastSessions(_userId, forceRefresh: forceRefresh),
        _sessionProvider.loadPendingSessions(
          _userId,
          forceRefresh: forceRefresh,
        ),
      ]);
    } catch (e) {
      // Handle error silently or show a snackbar
      debugPrint('Error loading sessions: $e');
    }
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
    if (Provider.of<AppProvider>(
          context,
          listen: false,
        ).currentUser?.userType ==
        'student') {
      _showModernAccessDialog();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OrganizeSessionScreen()),
    );
  }

  void _showModernAccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 300),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 0,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon with animated background
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.1),
                              Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.2),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Icon(
                          Icons.school_outlined,
                          size: 40,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Title
                      Text(
                        'Tutors Only',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 12),

                      // Description
                      Text(
                        'This feature is exclusively available for tutors to organize and manage their sessions.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 24),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Got it',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ApplyTutorFlow(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                foregroundColor:
                                    Theme.of(context).colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Become Tutor',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSessionList(List<Session>? sessions) {
    if (sessions == null || sessions.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/no_session.png', height: 210),
          const Text('No sessions found'),
        ],
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
            label: const Text('Set Session'),
            icon: const Icon(Icons.add_circle),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

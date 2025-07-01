import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/screens/auth/log_in.dart';
import '../screens/pages/tutors/tutor_details_screen.dart';
import '../utils/modelsAndRepsositories/models_and_repositories.dart';
import '../utils/providers/providers.dart';
import 'package:intl/intl.dart';

// Modern Lecturer Dashboard Screen
class LecturerDashboardScreen extends StatelessWidget {
  const LecturerDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (_) =>
              LecturerDashboardProvider()
                ..fetchTutors()
                ..fetchTutorApplications()
                ..fetchStudyMaterials(
                  FirebaseConfig.firebaseAuth.currentUser?.uid ?? '',
                )
                ..fetchAnalytics(
                  FirebaseConfig.firebaseAuth.currentUser?.uid ?? '',
                )
                ..fetchSessions()
                ..startRealTimeSessionMonitoring(),
      child: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366F1),
            brightness: Theme.of(context).brightness,
          ),
        ),
        child: Scaffold(
          backgroundColor:
              Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF0F0F23)
                  : const Color(0xFFF8FAFC),
          body: Consumer<LecturerDashboardProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation(Color(0xFF6366F1)),
                  ),
                );
              }
              if (provider.error != null) {
                return Center(
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red.shade600,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${provider.error}',
                          style: TextStyle(
                            color: Colors.red.shade800,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }
              return _buildModernDashboard(context, provider);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildModernDashboard(
    BuildContext context,
    LecturerDashboardProvider provider,
  ) {
    return DefaultTabController(
      length: 4,
      child: NestedScrollView(
        headerSliverBuilder:
            (context, innerBoxIsScrolled) => [
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF6366F1),
                          const Color(0xFF8B5CF6),
                          const Color(0xFFEC4899),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Instructor Dashboard',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                    ),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.logout_rounded,
                                      color: Colors.white,
                                    ),
                                    onPressed: () async {
                                      _showLogoutDialog(context);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              'Welcome back, Instructor',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(60),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: TabBar(
                      indicatorColor: const Color(0xFF6366F1),
                      indicatorWeight: 3,
                      indicatorSize: TabBarIndicatorSize.label,
                      labelColor: const Color(0xFF6366F1),
                      unselectedLabelColor: Colors.grey.shade600,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      tabs: const [
                        Tab(text: 'Tutors'),
                        Tab(text: 'Applications'),
                        Tab(text: 'Materials'),
                        Tab(text: 'Sessions'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
        body: TabBarView(
          children: [
            _buildModernTutorsTab(context, provider),
            _buildModernApplicationsTab(context, provider),
            _buildModernMaterialsTab(context, provider),
            _buildModernSessionsTab(context, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTutorsTab(
    BuildContext context,
    LecturerDashboardProvider provider,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.tutors.length,
      itemBuilder: (context, index) {
        final tutor = provider.tutors[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder:
                        (context, animation, secondaryAnimation) =>
                            TutorDetailsScreen(tutorId: tutor.id),
                    transitionsBuilder: (
                      context,
                      animation,
                      secondaryAnimation,
                      child,
                    ) {
                      return SlideTransition(
                        position: animation.drive(
                          Tween(
                            begin: const Offset(1.0, 0.0),
                            end: Offset.zero,
                          ).chain(CurveTween(curve: Curves.easeInOut)),
                        ),
                        child: child,
                      );
                    },
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Hero(
                      tag: 'tutor-${tutor.id}',
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient:
                              tutor.profilePicture == null
                                  ? LinearGradient(
                                    colors: [
                                      Color(0xFF6366F1),
                                      Color(0xFF8B5CF6),
                                    ],
                                  )
                                  : null,
                          image:
                              tutor.profilePicture != null
                                  ? DecorationImage(
                                    image: NetworkImage(tutor.profilePicture!),
                                    fit: BoxFit.cover,
                                  )
                                  : null,
                        ),
                        child:
                            tutor.profilePicture == null
                                ? Center(
                                  child: Text(
                                    tutor.name[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
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
                            tutor.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 14,
                                      color: Colors.amber.shade700,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      tutor.rating.toStringAsFixed(1),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.amber.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      tutor.isAvailable
                                          ? Colors.green.shade100
                                          : Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  tutor.isAvailable
                                      ? 'Available'
                                      : 'Unavailable',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        tutor.isAvailable
                                            ? Colors.green.shade700
                                            : Colors.red.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            tutor.subjects.join(', '),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color:
                                tutor.isAvailable
                                    ? Colors.red.shade50
                                    : Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: Icon(
                              tutor.isAvailable
                                  ? Icons.pause_circle
                                  : Icons.play_circle,
                              color:
                                  tutor.isAvailable
                                      ? Colors.red.shade600
                                      : Colors.green.shade600,
                            ),
                            onPressed: () async {
                              await FirebaseConfig.firestore
                                  .collection('tutors')
                                  .doc(tutor.id)
                                  .update({'is_available': !tutor.isAvailable});
                              provider.fetchTutors();
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.person_add,
                              color: Colors.blue.shade600,
                            ),
                            onPressed: () {
                              _showAssignPeerTutorDialog(
                                context,
                                provider,
                                tutor,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAssignPeerTutorDialog(
    BuildContext context,
    LecturerDashboardProvider provider,
    Tutor tutor,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AssignPeerTutorDialog(provider: provider, tutor: tutor),
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
                  Provider.of<AppProvider>(context, listen: false).logout();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
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

  Widget _buildModernApplicationsTab(
    BuildContext context,
    LecturerDashboardProvider provider,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.tutorApplications.length,
      itemBuilder: (context, index) {
        final application = provider.tutorApplications[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          (application.personalInfo['fullName'] ?? 'A')[0]
                              .toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            application.personalInfo['fullName'] ?? 'Applicant',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                application.status,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              application.status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(application.status),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Subjects: ${application.subjects.join(', ')}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                if (application.status == 'pending') ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            await provider.approveTutorApplication(
                              applicationId: application.id,
                            );
                          },
                          child: const Text(
                            'Approve',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            await provider.declineTutorApplication(
                              application.id,
                              application.personalInfo['fullName'] ?? 'Tutor',
                            );
                          },
                          child: const Text(
                            'Decline',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernMaterialsTab(
    BuildContext context,
    LecturerDashboardProvider provider,
  ) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 24,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text(
                    'Add Material',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) =>
                              AddStudyMaterialDialog(provider: provider),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 24,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.upload_file),
                  label: const Text(
                    'Standardize',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) =>
                              StandardizeMaterialsDialog(provider: provider),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: provider.studyMaterials.length,
            itemBuilder: (context, index) {
              final material = provider.studyMaterials[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: material.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          material.icon,
                          color: material.color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    material.subject,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (material.isStandardized)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Standardized',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${material.resourceCount} resources',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: material.progress,
                                      backgroundColor: Colors.grey.shade200,
                                      valueColor: AlwaysStoppedAnimation(
                                        material.color,
                                      ),
                                      minHeight: 6,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '${(material.progress * 100).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: material.color,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red.shade600),
                        onPressed: () async {
                          await provider.deleteStudyMaterial(material.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildModernSessionsTab(
    BuildContext context,
    LecturerDashboardProvider provider,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.sessions.length,
      itemBuilder: (context, index) {
        final session = provider.sessions[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            session.isActive
                                ? Colors.green.shade100
                                : Colors.grey.shade100,
                      ),
                      child: Icon(
                        session.isActive ? Icons.videocam : Icons.history,
                        color:
                            session.isActive
                                ? Colors.green.shade700
                                : Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${session.formattedDateTime} • ${session.statusText}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (session.canCancel)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.cancel_rounded,
                            color: Colors.red.shade600,
                          ),
                          onPressed: () async {
                            await provider.sessionRepository.cancelSession(
                              FirebaseConfig.firebaseAuth.currentUser?.uid ??
                                  '',
                              session.id,
                            );
                            provider.fetchSessions();
                          },
                        ),
                      ),
                  ],
                ),
                if (session.isActive) ...[
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: session.progress,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(Colors.blue.shade600),
                    minHeight: 6,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Progress: ${(session.progress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget _buildModernReportsTab(
  //   BuildContext context,
  //   LecturerDashboardProvider provider,
  // ) {
  //   return SingleChildScrollView(
  //     padding: const EdgeInsets.all(16),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         _buildAnalyticsSection('Tutoring Effectiveness', Icons.trending_up, [
  //           CustomBarChart(
  //             data: provider.tutoringEffectiveness,
  //             isEffectiveness: true,
  //           ),
  //           const SizedBox(height: 16),
  //           _buildEffectivenessSummary(provider.tutoringEffectiveness),
  //         ]),
  //         const SizedBox(height: 32),
  //         _buildAnalyticsSection('Student Progress', Icons.school, [
  //           CustomBarChart(
  //             data: provider.studentProgress,
  //             isEffectiveness: false,
  //           ),
  //           const SizedBox(height: 16),
  //           _buildProgressSummary(provider.studentProgress),
  //         ]),
  //         const SizedBox(height: 32),
  //         ElevatedButton(
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: const Color(0xFF6366F1),
  //             foregroundColor: Colors.white,
  //             elevation: 0,
  //             padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(16),
  //             ),
  //           ),
  //           onPressed: () async {
  //             await provider.generateDetailedReport();
  //             ScaffoldMessenger.of(context).showSnackBar(
  //               SnackBar(content: Text('Report generated and saved')),
  //             );
  //           },
  //           child: const Text(
  //             'Generate Detailed Report',
  //             style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildEffectivenessSummary(List<EffectivenessData> data) {
  //   final avgScore =
  //       data.isNotEmpty
  //           ? data.fold(0.0, (sum, item) => sum + item.effectivenessScore) /
  //               data.length
  //           : 0.0;
  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(12),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.05),
  //           blurRadius: 8,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'Effectiveness Summary',
  //           style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  //         ),
  //         const SizedBox(height: 8),
  //         Text(
  //           'Average Effectiveness: ${avgScore.toStringAsFixed(1)}',
  //           style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
  //         ),
  //         Text(
  //           'Total Tutors: ${data.length}',
  //           style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildProgressSummary(List<ProgressData> data) {
  //   final avgProgress =
  //       data.isNotEmpty
  //           ? data.fold(0.0, (sum, item) => sum + item.progressScore) /
  //               data.length
  //           : 0.0;
  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(12),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.05),
  //           blurRadius: 8,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'Progress Summary',
  //           style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  //         ),
  //         const SizedBox(height: 8),
  //         Text(
  //           'Average Progress: ${(avgProgress * 100).toStringAsFixed(1)}%',
  //           style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
  //         ),
  //         Text(
  //           'Total Students: ${data.length}',
  //           style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildAnalyticsSection(
  //   String title,
  //   IconData icon,
  //   List<Widget> children,
  // ) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Row(
  //         children: [
  //           Container(
  //             padding: const EdgeInsets.all(8),
  //             decoration: BoxDecoration(
  //               color: const Color(0xFF6366F1).withOpacity(0.1),
  //               borderRadius: BorderRadius.circular(8),
  //             ),
  //             child: Icon(icon, color: const Color(0xFF6366F1), size: 20),
  //           ),
  //           const SizedBox(width: 12),
  //           Text(
  //             title,
  //             style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  //           ),
  //         ],
  //       ),
  //       const SizedBox(height: 16),
  //       ...children,
  //     ],
  //   );
  // }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

// Custom Bar Chart Widget
class CustomBarChart extends StatelessWidget {
  final List<dynamic> data;
  final bool isEffectiveness;

  const CustomBarChart({
    Key? key,
    required this.data,
    required this.isEffectiveness,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            isEffectiveness
                ? 'Tutor Effectiveness Scores'
                : 'Student Progress Scores',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: CustomPaint(
              painter: BarChartPainter(
                data: data,
                isEffectiveness: isEffectiveness,
              ),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }
}

class BarChartPainter extends CustomPainter {
  final List<dynamic> data;
  final bool isEffectiveness;

  BarChartPainter({required this.data, required this.isEffectiveness});

  @override
  void paint(Canvas canvas, Size size) {
    final barPaint =
        Paint()
          ..color =
              isEffectiveness ? Colors.blue.shade600 : Colors.green.shade600
          ..style = PaintingStyle.fill;

    final axisPaint =
        Paint()
          ..color = Colors.grey.shade600
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

    final textPainter = TextPainter(textAlign: TextAlign.center);

    const padding = 40.0;
    final barWidth = (size.width - padding * 2) / data.length / 2;
    final maxValue = isEffectiveness ? 5.0 : 1.0;
    final heightScale = (size.height - padding * 2) / maxValue;

    // Draw axes
    canvas.drawLine(
      Offset(padding, size.height - padding),
      Offset(size.width - padding, size.height - padding),
      axisPaint,
    );
    canvas.drawLine(
      Offset(padding, size.height - padding),
      Offset(padding, padding),
      axisPaint,
    );

    // Draw bars and labels
    for (var i = 0; i < data.length; i++) {
      final item = data[i];
      final value =
          isEffectiveness ? item.effectivenessScore : item.progressScore;
      final barHeight = value * heightScale;
      final x = padding + i * (barWidth * 2);
      final y = size.height - padding - barHeight;

      // Draw bar
      canvas.drawRect(Rect.fromLTWH(x, y, barWidth, barHeight), barPaint);

      // Draw name label
      textPainter.text = TextSpan(
        text:
            isEffectiveness
                ? item.tutorName.substring(0, 3)
                : item.studentName.substring(0, 3),
        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          x + barWidth / 2 - textPainter.width / 2,
          size.height - padding + 8,
        ),
      );

      // Draw value label
      textPainter.text = TextSpan(
        text:
            isEffectiveness
                ? value.toStringAsFixed(1)
                : '${(value * 100).toStringAsFixed(0)}%',
        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x + barWidth / 2 - textPainter.width / 2, y - 20),
      );
    }

    // Draw Y-axis labels
    for (var i = 0; i <= 5; i++) {
      final yValue = (maxValue / 5) * i;
      final yPos = size.height - padding - (yValue * heightScale);
      textPainter.text = TextSpan(
        text:
            isEffectiveness
                ? yValue.toStringAsFixed(1)
                : '${(yValue * 100).toInt()}%',
        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(padding - textPainter.width - 8, yPos - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Assign Peer Tutor Dialog
class AssignPeerTutorDialog extends StatefulWidget {
  final LecturerDashboardProvider provider;
  final Tutor tutor;

  const AssignPeerTutorDialog({
    Key? key,
    required this.provider,
    required this.tutor,
  }) : super(key: key);

  @override
  _AssignPeerTutorDialogState createState() => _AssignPeerTutorDialogState();
}

class _AssignPeerTutorDialogState extends State<AssignPeerTutorDialog> {
  final _formKey = GlobalKey<FormState>();
  String _studentId = '';
  String _subject = '';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.person_add,
                    color: Color(0xFF6366F1),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Assign Peer Tutor: ${widget.tutor.name}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Student ID',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF6366F1)),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                    onSaved: (value) => _studentId = value!,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Subject',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF6366F1)),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    items:
                        widget.tutor.subjects
                            .map(
                              (subject) => DropdownMenuItem(
                                value: subject,
                                child: Text(subject),
                              ),
                            )
                            .toList(),
                    onChanged: (value) => _subject = value!,
                    validator: (value) => value == null ? 'Required' : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        await widget.provider.assignPeerTutor(
                          widget.tutor.id,
                          _studentId,
                          _subject,
                        );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Tutor assigned successfully'),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Assign Tutor',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Standardize Materials Dialog
class StandardizeMaterialsDialog extends StatefulWidget {
  final LecturerDashboardProvider provider;

  const StandardizeMaterialsDialog({Key? key, required this.provider})
    : super(key: key);

  @override
  _StandardizeMaterialsDialogState createState() =>
      _StandardizeMaterialsDialogState();
}

class _StandardizeMaterialsDialogState
    extends State<StandardizeMaterialsDialog> {
  final _formKey = GlobalKey<FormState>();
  String _materialId = '';
  String _standardNotes = '';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.upload_file,
                    color: Color(0xFF6366F1),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Standardize Study Material',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Select Material',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF6366F1)),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    items:
                        widget.provider.studyMaterials
                            .map(
                              (material) => DropdownMenuItem(
                                value: material.id,
                                child: Text(material.subject),
                              ),
                            )
                            .toList(),
                    onChanged: (value) => _materialId = value!,
                    validator: (value) => value == null ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Standardization Notes',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF6366F1)),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    maxLines: 3,
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                    onSaved: (value) => _standardNotes = value!,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        await widget.provider.standardizeStudyMaterial(
                          _materialId,
                          _standardNotes,
                        );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Material standardized successfully'),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Standardize',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Modern Tutor Details Screen

// Modern Add Study Material Dialog
class AddStudyMaterialDialog extends StatefulWidget {
  final LecturerDashboardProvider provider;

  const AddStudyMaterialDialog({Key? key, required this.provider})
    : super(key: key);

  @override
  _AddStudyMaterialDialogState createState() => _AddStudyMaterialDialogState();
}

class _AddStudyMaterialDialogState extends State<AddStudyMaterialDialog> {
  final _formKey = GlobalKey<FormState>();
  String _subject = '';
  int _resourceCount = 0;
  double _progress = 0.0;
  final _icons = [
    Icons.calculate,
    Icons.science,
    Icons.eco,
    Icons.biotech,
    Icons.code,
    Icons.menu_book,
    Icons.book,
  ];
  late IconData _selectedIcon;
  final _colors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.purple,
    Colors.orange,
  ];
  Color _selectedColor = Colors.blue;
  bool _isStandardized = false;
  @override
  void initState() {
    super.initState();
    _selectedIcon = _icons.first;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.add_circle_outline,
                    color: Color(0xFF6366F1),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Add Study Material',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Subject',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF6366F1)),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                    onSaved: (value) => _subject = value!,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Resource Count',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF6366F1)),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                    onSaved: (value) => _resourceCount = int.parse(value!),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Progress (0-1)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF6366F1)),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) return 'Required';
                      final progress = double.tryParse(value);
                      if (progress == null || progress < 0 || progress > 1) {
                        return 'Must be between 0 and 1';
                      }
                      return null;
                    },
                    onSaved: (value) => _progress = double.parse(value!),
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Standardized Material'),
                    value: _isStandardized,
                    onChanged:
                        (value) => setState(() => _isStandardized = value!),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Icon',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<IconData>(
                                  value: _selectedIcon,
                                  isExpanded: true,
                                  items:
                                      _icons
                                          .map(
                                            (icon) => DropdownMenuItem(
                                              value: icon,
                                              child: Icon(icon),
                                            ),
                                          )
                                          .toList(),
                                  onChanged:
                                      (value) => setState(
                                        () => _selectedIcon = value!,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Color',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<Color>(
                                  value: _selectedColor,
                                  isExpanded: true,
                                  items:
                                      _colors
                                          .map(
                                            (color) => DropdownMenuItem(
                                              value: color,
                                              child: Container(
                                                width: 24,
                                                height: 24,
                                                decoration: BoxDecoration(
                                                  color: color,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                  onChanged:
                                      (value) => setState(
                                        () => _selectedColor = value!,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        await widget.provider.addStudyMaterial(
                          userId:
                              FirebaseConfig.firebaseAuth.currentUser?.uid ??
                              '',
                          subject: _subject,
                          resourceCount: _resourceCount,
                          progress: _progress,
                          color: _selectedColor,
                          icon: _selectedIcon,
                          isStandardized: _isStandardized,
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      'Add Material',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

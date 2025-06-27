import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/providers/providers.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Define default badges
  final List<Map<String, dynamic>> _defaultBadges = [
    {
      'id': 'fast_learner',
      'title': 'Fast Learner',
      'description': 'Complete 5 sessions in your first month',
      'icon': 'rocket_launch',
      'points': 100,
      'gradient': [Colors.orange, Colors.deepOrange],
    },
    {
      'id': 'five_star_student',
      'title': '5-Star Student',
      'description': 'Receive 5 perfect ratings',
      'icon': 'star',
      'points': 150,
      'gradient': [Colors.amber, Colors.yellow],
    },
    {
      'id': 'bookworm',
      'title': 'Bookworm',
      'description': 'Complete 10 study sessions',
      'icon': 'book',
      'points': 120,
      'gradient': [Colors.green, Colors.lightGreen],
    },
    {
      'id': 'active_participant',
      'title': 'Active Participant',
      'description': 'Send 50 messages',
      'icon': 'forum',
      'points': 80,
      'gradient': [Colors.blue, Colors.lightBlue],
    },
    {
      'id': 'master_tutor',
      'title': 'Master Tutor',
      'description': 'Complete 50 sessions',
      'icon': 'workspace_premium',
      'points': 200,
      'gradient': [Colors.purple, Colors.deepPurple],
    },
    {
      'id': 'subject_expert',
      'title': 'Subject Expert',
      'description': 'Master 3 subjects',
      'icon': 'lightbulb',
      'points': 180,
      'gradient': [Colors.indigo, Colors.blue],
    },
    {
      'id': 'top_performer',
      'title': 'Top Performer',
      'description': 'Reach top 10 on leaderboard',
      'icon': 'emoji_events',
      'points': 250,
      'gradient': [Colors.teal, Colors.cyan],
    },
    {
      'id': 'mentor',
      'title': 'Mentor',
      'description': 'Help 5 other students',
      'icon': 'school',
      'points': 130,
      'gradient': [Colors.pink, Colors.red],
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();

    // Load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AppProvider>().currentUser?.id;
      debugPrint('AchievementsScreen initState: userId=$userId');
      if (userId != null) {
        final provider = context.read<AchievementsProvider>();
        provider.loadUserStats(userId, forceRefresh: true);
        provider.loadAchievements(userId, forceRefresh: true).then((_) {
          debugPrint(
            'Achievements loaded in initState: ${provider.achievements?.length}',
          );
          if (provider.achievements == null || provider.achievements!.isEmpty) {
            debugPrint('Initializing default badges for userId=$userId');
            provider.initializeDefaultBadges(userId, _defaultBadges).then((_) {
              debugPrint('Default badges initialized, reloading achievements');
              provider.loadAchievements(userId, forceRefresh: true);
            });
          }
        });
      } else {
        debugPrint('No userId found, cannot load achievements');
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // Map string icons to IconData
  IconData _getIconData(String iconName) {
    const iconMap = {
      'emoji_events': Icons.emoji_events,
      'rocket_launch': Icons.rocket_launch,
      'star': Icons.star,
      'book': Icons.book,
      'forum': Icons.forum,
      'workspace_premium': Icons.workspace_premium,
      'lightbulb': Icons.lightbulb,
      'school': Icons.school,
    };
    return iconMap[iconName] ?? Icons.emoji_events;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appProvider = context.watch<AppProvider>();

    if (appProvider.currentUser == null) {
      debugPrint('No user logged in');
      return const Scaffold(
        body: Center(child: Text('Please sign in to view achievements')),
      );
    }

    return Consumer<AchievementsProvider>(
      builder: (context, provider, child) {
        debugPrint(
          'AchievementsScreen build: isLoading=${provider.isLoading}, '
          'achievements=${provider.achievements?.length ?? 0}, '
          'error=${provider.error}',
        );

        if (provider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.error != null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${provider.error}',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.clearError();
                      final userId =
                          context.read<AppProvider>().currentUser?.id;
                      if (userId != null) {
                        provider.loadUserStats(userId, forceRefresh: true);
                        provider
                            .loadAchievements(userId, forceRefresh: true)
                            .then((_) {
                              if (provider.achievements == null ||
                                  provider.achievements!.isEmpty) {
                                provider
                                    .initializeDefaultBadges(
                                      userId,
                                      _defaultBadges,
                                    )
                                    .then((_) {
                                      provider.loadAchievements(
                                        userId,
                                        forceRefresh: true,
                                      );
                                    });
                              }
                            });
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final userStats = provider.userStats;
        final achievements = provider.achievements ?? [];
        final earnedBadges = achievements.where((a) => a.earned).toList();
        final nextBadges = achievements.where((a) => !a.earned).toList();
        debugPrint(
          'Earned Badges: ${earnedBadges.length}, Next Badges: ${nextBadges.length}',
        );

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors:
                    isDark
                        ? [
                          const Color(0xFF0F0F23),
                          const Color(0xFF1A1A2E),
                          const Color(0xFF16213E),
                        ]
                        : [
                          const Color(0xFFF8FAFF),
                          const Color(0xFFE8F2FF),
                          const Color(0xFFF0F8FF),
                        ],
              ),
            ),
            child: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          theme.primaryColor,
                                          theme.primaryColor.withOpacity(0.7),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: theme.primaryColor.withOpacity(
                                            0.3,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.emoji_events,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Your Milestones',
                                          style: theme.textTheme.headlineMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    isDark
                                                        ? Colors.white
                                                        : const Color(
                                                          0xFF1A1A2E,
                                                        ),
                                              ),
                                        ),
                                        Text(
                                          'Your learning milestones',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color:
                                                    isDark
                                                        ? Colors.grey[400]
                                                        : Colors.grey[600],
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              // Stats Cards
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      context,
                                      'Earned',
                                      userStats?.badgesEarned.toString() ?? '0',
                                      Icons.star,
                                      Colors.amber,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildStatCard(
                                      context,
                                      'In Progress',
                                      nextBadges.length.toString(),
                                      Icons.trending_up,
                                      Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildStatCard(
                                      context,
                                      'Total Points',
                                      userStats?.pointsEarned.toString() ?? '0',
                                      Icons.diamond,
                                      Colors.purple,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Earned Badges Section
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Colors.amber, Colors.orange],
                                      ),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Earned Badges',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          isDark
                                              ? Colors.white
                                              : const Color(0xFF1A1A2E),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (earnedBadges.isEmpty)
                                Center(
                                  child: Text(
                                    'No badges earned yet',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color:
                                          isDark
                                              ? Colors.grey[400]
                                              : Colors.grey[600],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      // Earned Badges Grid
                      if (earnedBadges.isNotEmpty)
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          sliver: SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: _getCrossAxisCount(context),
                                  childAspectRatio: 1.1,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                ),
                            delegate: SliverChildListDelegate(
                              earnedBadges
                                  .map(
                                    (badge) => _buildModernAchievementBadge(
                                      context,
                                      icon: _getIconData(badge.icon),
                                      title: badge.title,
                                      description: badge.description,
                                      earned: badge.earned,
                                      progress: badge.progress,
                                      gradient: _getGradientForBadge(
                                        badge.icon,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),

                      // Next Badges Section
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 20,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Colors.purple, Colors.deepPurple],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Next Badges',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isDark
                                          ? Colors.white
                                          : const Color(0xFF1A1A2E),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Next Badges Grid
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: _getCrossAxisCount(context),
                                childAspectRatio: 0.9,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                              ),
                          delegate: SliverChildListDelegate(
                            nextBadges
                                .map(
                                  (badge) => _buildModernAchievementBadge(
                                    context,
                                    icon: _getIconData(badge.icon),
                                    title: badge.title,
                                    description: badge.description,
                                    earned: badge.earned,
                                    progress: badge.progress,
                                    gradient: _getGradientForBadge(badge.icon),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),

                      // Progress Chart
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Colors.blue, Colors.cyan],
                                      ),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Progress Overview',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          isDark
                                              ? Colors.white
                                              : const Color(0xFF1A1A2E),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                height: 300,
                                decoration: BoxDecoration(
                                  color:
                                      isDark
                                          ? Colors.grey[900]?.withOpacity(0.5)
                                          : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color:
                                        isDark
                                            ? Colors.grey[800]!
                                            : Colors.grey[200]!,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.analytics,
                                        size: 48,
                                        color: theme.primaryColor,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Progress Chart',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Visual representation of your learning journey',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(color: Colors.grey),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 2;
  }

  List<Color> _getGradientForBadge(String icon) {
    const gradientMap = {
      'rocket_launch': [Colors.orange, Colors.deepOrange],
      'star': [Colors.amber, Colors.yellow],
      'book': [Colors.green, Colors.lightGreen],
      'forum': [Colors.blue, Colors.lightBlue],
      'workspace_premium': [Colors.purple, Colors.deepPurple],
      'lightbulb': [Colors.indigo, Colors.blue],
      'emoji_events': [Colors.teal, Colors.cyan],
      'school': [Colors.pink, Colors.red],
    };
    return gradientMap[icon] ?? [Colors.grey, Colors.grey[700]!];
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900]?.withOpacity(0.5) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildModernAchievementBadge(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required bool earned,
    required double progress,
    required List<Color> gradient,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900]?.withOpacity(0.5) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              earned
                  ? gradient.first.withOpacity(0.3)
                  : isDark
                  ? Colors.grey[800]!
                  : Colors.grey[200]!,
          width: earned ? 2 : 1,
        ),
        boxShadow: [
          if (earned)
            BoxShadow(
              color: gradient.first.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 6),
            )
          else
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            if (earned)
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradient),
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient:
                              earned
                                  ? LinearGradient(colors: gradient)
                                  : LinearGradient(
                                    colors: [
                                      Colors.grey[400]!,
                                      Colors.grey[500]!,
                                    ],
                                  ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow:
                              earned
                                  ? [
                                    BoxShadow(
                                      color: gradient.first.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                  : null,
                        ),
                        child: Icon(icon, color: Colors.white, size: 24),
                      ),
                      const Spacer(),
                      if (earned)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: gradient),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color:
                          earned
                              ? (isDark
                                  ? Colors.white
                                  : const Color(0xFF1A1A2E))
                              : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: earned ? Colors.grey[600] : Colors.grey[500],
                      height: 1.3,
                    ),
                  ),
                  const Spacer(),
                  if (!earned) ...[
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: gradient.first,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation(gradient.first),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

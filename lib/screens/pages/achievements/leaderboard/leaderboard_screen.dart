import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../utils/providers/providers.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String selectedFilter = 'overall';
  final List<String> filters = ['Overall', 'This Month', 'By Subject'];

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

    // Load leaderboard data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<LeaderboardProvider>();
      debugPrint(
        'LeaderboardPage initState: Loading data with filter=$selectedFilter',
      );
      provider.loadTopPerformers(forceRefresh: true);
      provider.loadLeaderboard(filter: selectedFilter, forceRefresh: true);
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
              child: Consumer<LeaderboardProvider>(
                builder: (context, provider, child) {
                  debugPrint(
                    'LeaderboardPage build: isLoading=${provider.isLoading}, '
                    'topPerformers=${provider.topPerformers?.length ?? 0}, '
                    'leaderboard=${provider.leaderboard?.length ?? 0}, '
                    'hasMore=${provider.hasMore}, '
                    'error=${provider.error}',
                  );

                  if (provider.isLoading &&
                      (provider.leaderboard?.isEmpty ?? true)) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.error != null) {
                    return Center(
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
                              provider.loadTopPerformers(forceRefresh: true);
                              provider.loadLeaderboard(
                                filter: selectedFilter,
                                forceRefresh: true,
                              );
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final topPerformers = provider.topPerformers ?? [];
                  final leaderboard = provider.leaderboard ?? [];

                  return CustomScrollView(
                    slivers: [
                      // Header Section
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 24),
                              // Filter Chips
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children:
                                      filters
                                          .map(
                                            (filter) => Padding(
                                              padding: const EdgeInsets.only(
                                                right: 8,
                                              ),
                                              child: FilterChip(
                                                label: Text(filter),
                                                selected:
                                                    selectedFilter == filter,
                                                onSelected: (selected) {
                                                  if (selected) {
                                                    setState(() {
                                                      selectedFilter = filter;
                                                      final provider =
                                                          context
                                                              .read<
                                                                LeaderboardProvider
                                                              >();
                                                      provider.loadLeaderboard(
                                                        filter:
                                                            filter
                                                                .toLowerCase(),
                                                        forceRefresh: true,
                                                      );
                                                    });
                                                  }
                                                },
                                                backgroundColor:
                                                    isDark
                                                        ? Colors.grey[800]
                                                        : Colors.grey[100],
                                                selectedColor: theme
                                                    .primaryColor
                                                    .withOpacity(0.2),
                                                checkmarkColor:
                                                    theme.primaryColor,
                                                labelStyle: TextStyle(
                                                  color:
                                                      selectedFilter == filter
                                                          ? theme.primaryColor
                                                          : (isDark
                                                              ? Colors.grey[300]
                                                              : Colors
                                                                  .grey[700]),
                                                  fontWeight:
                                                      selectedFilter == filter
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                ),
                                                side: BorderSide(
                                                  color:
                                                      selectedFilter == filter
                                                          ? theme.primaryColor
                                                          : Colors.transparent,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Top 3 Podium
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            height: 400,
                            decoration: BoxDecoration(
                              color:
                                  isDark
                                      ? Colors.grey[900]?.withOpacity(0.5)
                                      : Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color:
                                    isDark
                                        ? Colors.grey[800]!
                                        : Colors.grey[200]!,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                // Background decoration
                                Positioned(
                                  top: -50,
                                  right: -50,
                                  child: Container(
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.amber.withOpacity(0.1),
                                          Colors.orange.withOpacity(0.05),
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.emoji_events,
                                            color: Colors.amber,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Top Performers',
                                            style: theme.textTheme.titleLarge
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
                                        ],
                                      ),
                                      Expanded(
                                        child:
                                            topPerformers.isEmpty
                                                ? Center(
                                                  child: Text(
                                                    'No top performers available',
                                                    style: theme
                                                        .textTheme
                                                        .bodyLarge
                                                        ?.copyWith(
                                                          color:
                                                              isDark
                                                                  ? Colors
                                                                      .grey[400]
                                                                  : Colors
                                                                      .grey[600],
                                                        ),
                                                  ),
                                                )
                                                : Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    if (topPerformers.length >
                                                        1)
                                                      _buildPodiumPosition(
                                                        context,
                                                        position: 2,
                                                        name:
                                                            topPerformers[1]
                                                                .name,
                                                        subject:
                                                            topPerformers[1]
                                                                .subject ??
                                                            "",
                                                        points:
                                                            topPerformers[1]
                                                                .points
                                                                .toString(),
                                                        imageUrl:
                                                            topPerformers[1]
                                                                .profilePicture ??
                                                            'https://picsum.photos/200/200?random=16',
                                                        height: 140,
                                                      ),
                                                    if (topPerformers
                                                        .isNotEmpty)
                                                      _buildPodiumPosition(
                                                        context,
                                                        position: 1,
                                                        name:
                                                            topPerformers[0]
                                                                .name,
                                                        subject:
                                                            topPerformers[0]
                                                                .subject ??
                                                            '',
                                                        points:
                                                            topPerformers[0]
                                                                .points
                                                                .toString(),
                                                        imageUrl:
                                                            topPerformers[0]
                                                                .profilePicture ??
                                                            'https://picsum.photos/200/200?random=10',
                                                        height: 180,
                                                        isFirst: true,
                                                      ),
                                                    if (topPerformers.length >
                                                        2)
                                                      _buildPodiumPosition(
                                                        context,
                                                        position: 3,
                                                        name:
                                                            topPerformers[2]
                                                                .name,
                                                        subject:
                                                            topPerformers[2]
                                                                .subject ??
                                                            '',
                                                        points:
                                                            topPerformers[2]
                                                                .points
                                                                .toString(),
                                                        imageUrl:
                                                            topPerformers[2]
                                                                .profilePicture ??
                                                            'https://picsum.photos/200/200?random=13',
                                                        height: 120,
                                                      ),
                                                  ],
                                                ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SliverToBoxAdapter(child: SizedBox(height: 24)),

                      // Leaderboard List
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 20,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.blue, Colors.cyan],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Full Rankings',
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

                      const SliverToBoxAdapter(child: SizedBox(height: 16)),

                      // Leaderboard Items
                      leaderboard.isEmpty
                          ? SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  'No leaderboard data available',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color:
                                        isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                  ),
                                ),
                              ),
                            ),
                          )
                          : SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final user = leaderboard[index];
                              final currentUserId =
                                  context.read<AppProvider>().currentUser?.id;
                              return _buildModernLeaderboardItem(
                                context,
                                position: index + 4, // Start from 4th place
                                name: user.name,
                                subject: user.subject ?? '',
                                points: user.points.toString(),
                                imageUrl:
                                    user.profilePicture ??
                                    'https://picsum.photos/200/200?random=${index + 4}',
                                isCurrentUser: user.id == currentUserId,
                              );
                            }, childCount: leaderboard.length),
                          ),

                      // Load More Button
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Center(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    theme.primaryColor,
                                    theme.primaryColor.withOpacity(0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.primaryColor.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                onPressed:
                                    provider.hasMore
                                        ? () {
                                          debugPrint(
                                            'Loading more leaderboard data, filter=$selectedFilter',
                                          );
                                          provider.loadLeaderboard(
                                            filter:
                                                selectedFilter.toLowerCase(),
                                            forceRefresh: false,
                                          );
                                        }
                                        : null,
                                icon: const Icon(
                                  Icons.expand_more,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'View Full Leaderboard',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPodiumPosition(
    BuildContext context, {
    required int position,
    required String name,
    required String subject,
    required String points,
    required String imageUrl,
    required double height,
    bool isFirst = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color positionColor;
    List<Color> gradientColors;
    switch (position) {
      case 1:
        positionColor = Colors.amber;
        gradientColors = [Colors.amber, Colors.orange];
        break;
      case 2:
        positionColor = Colors.grey[400]!;
        gradientColors = [Colors.grey[400]!, Colors.grey[500]!];
        break;
      case 3:
        positionColor = Colors.brown;
        gradientColors = [Colors.brown, Colors.brown[400]!];
        break;
      default:
        positionColor = Colors.grey;
        gradientColors = [Colors.grey, Colors.grey[600]!];
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Avatar with position badge
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: isFirst ? 80 : 70,
              height: isFirst ? 80 : 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: positionColor,
                  width: isFirst ? 3 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: positionColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: isFirst ? 40 : 35,
                backgroundImage: NetworkImage(imageUrl),
              ),
            ),
            Positioned(
              bottom: -8,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradientColors),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: positionColor.withOpacity(0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      position.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (isFirst)
              Positioned(
                top: -10,
                left: 0,
                right: 0,
                child: Center(
                  child: Icon(
                    Icons.workspace_premium,
                    color: Colors.amber,
                    size: 24,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        // Podium
        Container(
          width: isFirst ? 120 : 90,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                gradientColors.first.withOpacity(0.8),
                gradientColors.last.withOpacity(0.6),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            boxShadow: [
              BoxShadow(
                color: positionColor.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name.split(' ').first,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isFirst ? 18 : 12,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  subject,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isFirst ? 12 : 10,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    points,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isFirst ? 12 : 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernLeaderboardItem(
    BuildContext context, {
    required int position,
    required String name,
    required String subject,
    required String points,
    required String imageUrl,
    bool isCurrentUser = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color positionColor = Colors.grey;
    if (position <= 3) {
      switch (position) {
        case 1:
          positionColor = Colors.amber;
          break;
        case 2:
          positionColor = Colors.grey[400]!;
          break;
        case 3:
          positionColor = Colors.brown;
          break;
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color:
            isCurrentUser
                ? theme.primaryColor.withOpacity(0.1)
                : (isDark ? Colors.grey[900]?.withOpacity(0.5) : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isCurrentUser
                  ? theme.primaryColor.withOpacity(0.3)
                  : (isDark ? Colors.grey[800]! : Colors.grey[200]!),
          width: isCurrentUser ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color:
                isCurrentUser
                    ? theme.primaryColor.withOpacity(0.1)
                    : Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Position
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color:
                    position <= 3
                        ? positionColor.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  position.toString(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: position <= 3 ? positionColor : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Avatar
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      isCurrentUser
                          ? theme.primaryColor.withOpacity(0.3)
                          : Colors.transparent,
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(imageUrl),
              ),
            ),
            const SizedBox(width: 16),

            // Name and Subject
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              isCurrentUser
                                  ? theme.primaryColor
                                  : (isDark
                                      ? Colors.white
                                      : const Color(0xFF1A1A2E)),
                        ),
                      ),
                      if (isCurrentUser) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'You',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.school, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        subject,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Points
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          isCurrentUser
                              ? [
                                theme.primaryColor,
                                theme.primaryColor.withOpacity(0.8),
                              ]
                              : [Colors.grey[300]!, Colors.grey[400]!],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    points,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isCurrentUser ? Colors.white : Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'points',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                    fontSize: 10,
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

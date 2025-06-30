import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/providers/providers.dart';
import 'apply_tutor/apply_tutor_flow.dart';
import 'tutor_details_screen.dart';
import '../../../widgets/tutor_card.dart';

class TutorsScreen extends StatefulWidget {
  const TutorsScreen({super.key});

  @override
  State<TutorsScreen> createState() => _TutorsScreenState();
}

class _TutorsScreenState extends State<TutorsScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedSubject;
  String? _selectedAvailability;
  String? _selectedRating;
  bool _isFilterExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _subjects = [
    'All Subjects',
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'Computer Science',
    'English',
    'History',
    'Economics',
  ];

  final List<String> _availabilityOptions = [
    'Any Time',
    'Morning (9AM - 12PM)',
    'Afternoon (1PM - 5PM)',
    'Evening (6PM - 9PM)',
    'Weekends Only',
  ];

  final List<String> _ratingOptions = [
    'Any Rating',
    '4.5+ Stars',
    '4+ Stars',
    '3.5+ Stars',
    '3+ Stars',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TutorProvider>(context, listen: false).loadTutors();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;
    final crossAxisCount = isTablet ? 3 : 1;
    final tutorProvider = Provider.of<TutorProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            // Search and Filter Section
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search tutors by name or subject...',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey[400],
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(20),
                        ),
                        onSubmitted: (value) {
                          tutorProvider.loadTutors(
                            subject: value.trim().isEmpty ? null : value.trim(),
                            availability:
                                _selectedAvailability == 'Any Time'
                                    ? null
                                    : _selectedAvailability,
                            minRating:
                                _selectedRating == null ||
                                        _selectedRating == 'Any Rating'
                                    ? null
                                    : double.parse(
                                      _selectedRating!.split('+')[0],
                                    ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Filter Toggle Button
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            setState(() {
                              _isFilterExpanded = !_isFilterExpanded;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.tune,
                                        color: Colors.blue.shade600,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Filters',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ],
                                ),
                                AnimatedRotation(
                                  turns: _isFilterExpanded ? 0.5 : 0,
                                  duration: const Duration(milliseconds: 200),
                                  child: Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Expandable Filters
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child:
                          _isFilterExpanded
                              ? Container(
                                margin: const EdgeInsets.only(top: 16),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 20,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    if (screenWidth > 600)
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildFilterDropdown(
                                              'Subject',
                                              _subjects,
                                              _selectedSubject,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: _buildFilterDropdown(
                                              'Availability',
                                              _availabilityOptions,
                                              _selectedAvailability,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: _buildFilterDropdown(
                                              'Rating',
                                              _ratingOptions,
                                              _selectedRating,
                                            ),
                                          ),
                                        ],
                                      )
                                    else
                                      Column(
                                        children: [
                                          _buildFilterDropdown(
                                            'Subject',
                                            _subjects,
                                            _selectedSubject,
                                          ),
                                          const SizedBox(height: 16),
                                          _buildFilterDropdown(
                                            'Availability',
                                            _availabilityOptions,
                                            _selectedAvailability,
                                          ),
                                          const SizedBox(height: 16),
                                          _buildFilterDropdown(
                                            'Rating',
                                            _ratingOptions,
                                            _selectedRating,
                                          ),
                                        ],
                                      ),
                                    const SizedBox(height: 20),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () {
                                              setState(() {
                                                _selectedSubject = null;
                                                _selectedAvailability = null;
                                                _selectedRating = null;
                                              });
                                              tutorProvider.loadTutors();
                                            },
                                            style: OutlinedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 16,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: const Text('Clear'),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          flex: 2,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              tutorProvider.loadTutors(
                                                subject:
                                                    _selectedSubject ==
                                                            'All Subjects'
                                                        ? null
                                                        : _selectedSubject,
                                                availability:
                                                    _selectedAvailability ==
                                                            'Any Time'
                                                        ? null
                                                        : _selectedAvailability,
                                                minRating:
                                                    _selectedRating == null ||
                                                            _selectedRating ==
                                                                'Any Rating'
                                                        ? null
                                                        : double.parse(
                                                          _selectedRating!
                                                              .split('+')[0],
                                                        ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.blue.shade600,
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 16,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              elevation: 0,
                                            ),
                                            child: const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.search, size: 20),
                                                SizedBox(width: 8),
                                                Text(
                                                  'Apply Filters',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                              : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),

            // Tutors Grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: _buildTutorsList(
                  tutorProvider,
                  crossAxisCount,
                  isTablet,
                ),
              ),
            ),

            // Load More Button - Only show if there are tutors and more to load
            if (tutorProvider.tutors != null &&
                tutorProvider.tutors!.isNotEmpty &&
                tutorProvider.hasMore)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    onPressed:
                        tutorProvider.isLoading
                            ? null
                            : () {
                              tutorProvider.loadMoreTutors();
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue.shade600,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 32,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.blue.shade200),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (tutorProvider.isLoading)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          const Icon(Icons.refresh, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          tutorProvider.isLoading
                              ? 'Loading...'
                              : 'Load More Tutors',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            tooltip: "Apply to be a Tutor",
            heroTag: 'apply_tutor',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ApplyTutorFlow()),
              );
            },
            backgroundColor: Colors.green,
            child: const Icon(Icons.person_add_alt_1, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorsList(
    TutorProvider tutorProvider,
    int crossAxisCount,
    bool isTablet,
  ) {
    // Loading state
    if (tutorProvider.isLoading && tutorProvider.tutors == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(50),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Error state
    if (tutorProvider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(50),
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Error: ${tutorProvider.error}',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => tutorProvider.loadTutors(),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    // Empty state
    if (tutorProvider.tutors == null || tutorProvider.tutors!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/no_results.png',
                height: 200,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.person_search,
                    size: 100,
                    color: Colors.grey[300],
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(
                tutorProvider.tutors != null && tutorProvider.tutors!.isEmpty
                    ? 'No tutors match your filters'
                    : 'No tutors found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your search criteria or check back later',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Tutors grid
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: isTablet ? 0.55 : 0.9,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: tutorProvider.tutors!.length,
      itemBuilder: (context, index) {
        final tutor = tutorProvider.tutors![index];
        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + (index * 50)),
          curve: Curves.easeOutBack,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TutorDetailsScreen(tutorId: tutor.id),
                ),
              );
            },
            child: TutorCard(
              name: tutor.name,
              subjects: tutor.subjects,
              rating: tutor.rating,
              sessions: tutor.sessionsCompleted,
              points: tutor.points,
              badges: tutor.badges,
              isAvailable: tutor.isAvailable,
              imageUrl:
                  tutor.profilePicture ??
                  'https://picsum.photos/200/200?random=$index',
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterDropdown(
    String label,
    List<String> items,
    String? selectedValue,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedValue ?? items.first,
        items:
            items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(
                  item,
                  style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                ),
              );
            }).toList(),
        onChanged: (value) {
          setState(() {
            switch (label) {
              case 'Subject':
                _selectedSubject = value;
                break;
              case 'Availability':
                _selectedAvailability = value;
                break;
              case 'Rating':
                _selectedRating = value;
                break;
            }
          });
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600], fontSize: 12),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: InputBorder.none,
        ),
        dropdownColor: Colors.white,
        icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
      ),
    );
  }
}

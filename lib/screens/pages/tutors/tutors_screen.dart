import 'package:flutter/material.dart';
import 'package:studybuddy/screens/pages/tutors/apply_tutor/apply_tutor_flow.dart';
import 'package:studybuddy/screens/pages/tutors/request_tutor_screen.dart';
import 'package:studybuddy/screens/pages/tutors/tutor_details_screen.dart';

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
                                            onPressed: () {},
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
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: isTablet? .55 : .9,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300 + (index * 50)),
                    curve: Curves.easeOutBack,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => TutorDetailsScreen(
                                  name: _getTutorName(index),
                                  subjects: _getTutorSubjects(index),
                                  rating: _getTutorRating(index),
                                  sessions: _getTutorSessions(index),
                                  points: _getTutorPoints(index),
                                  badges: _getTutorBadges(index),
                                  isAvailable: index % 2 == 0,
                                  imageUrl:
                                      'https://picsum.photos/200/200?random=${10 + index}',
                                ),
                          ),
                        );
                      },
                      child: TutorCard(
                        name: _getTutorName(index),
                        subjects: _getTutorSubjects(index),
                        rating: _getTutorRating(index),
                        sessions: _getTutorSessions(index),
                        points: _getTutorPoints(index),
                        badges: _getTutorBadges(index),
                        isAvailable: index % 2 == 0,
                        imageUrl:
                            'https://picsum.photos/200/200?random=${10 + index}',
                      ),
                    ),
                  );
                }, childCount: 6),
              ),
            ),

            // Load More Button
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: () {},
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
                      Icon(Icons.refresh, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Load More Tutors',
                        style: TextStyle(fontWeight: FontWeight.w600),
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
            tooltip: "Request a Tutor",
            heroTag: 'request_tutor',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RequestTutorScreen(),
                ),
              );
            },
            backgroundColor: Colors.blue.shade600,
            child: const Icon(Icons.request_quote, color: Colors.white),
          ),
          const SizedBox(height: 16),
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

  String _getTutorName(int index) {
    final names = [
      'Sarah Johnson',
      'Michael Chen',
      'Emily Rodriguez',
      'David Lee',
      'Robert Wilson',
      'Jennifer Adams',
    ];
    return names[index % names.length];
  }

  List<String> _getTutorSubjects(int index) {
    final subjects = [
      ['Calculus', 'Linear Algebra', 'Mechanics'],
      ['Python', 'Java', 'Data Structures', 'Algorithms'],
      ['Microeconomics', 'Macroeconomics', 'Finance', 'Marketing'],
      ['Organic Chemistry', 'Biochemistry', 'Genetics'],
      ['Quantum Physics', 'Thermodynamics', 'Differential Equations'],
      ['Literature', 'Creative Writing', 'European History'],
    ];
    return subjects[index % subjects.length];
  }

  double _getTutorRating(int index) {
    return [4.8, 5.0, 5.0, 4.9, 4.7, 4.9][index % 6];
  }

  int _getTutorSessions(int index) {
    return [250, 180, 95, 320, 210, 175][index % 6];
  }

  int _getTutorPoints(int index) {
    return [2500, 2100, 1500, 3200, 2300, 2000][index % 6];
  }

  int _getTutorBadges(int index) {
    return [15, 12, 8, 18, 14, 11][index % 6];
  }
}

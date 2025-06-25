import 'package:flutter/material.dart';
import '../sessions/booking_details_screen.dart';
import 'tutor_details_screen.dart';

class TutorBookingScreen extends StatefulWidget {
  final String tutorName;
  final String tutorImage;
  final List<String> subjects;

  const TutorBookingScreen({
    super.key,
    required this.tutorName,
    required this.tutorImage,
    required this.subjects,
  });

  @override
  State<TutorBookingScreen> createState() => _TutorBookingScreenState();
}

class _TutorBookingScreenState extends State<TutorBookingScreen>
    with TickerProviderStateMixin {
  DateTime? _selectedDate;
  String? _selectedTime;
  String? _selectedSubject;
  String _sessionDescription = '';
  String _selectedPlatform = 'Zoom';
  String _selectedDuration = '60 minutes';
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> _availableTimes = [
    '9:00 AM',
    '10:00 AM',
    '11:00 AM',
    '1:00 PM',
    '2:00 PM',
    '3:00 PM',
    '4:00 PM',
  ];
  final List<String> _platforms = ['Zoom', 'Google Meet', 'Microsoft Teams'];
  final List<String> _durations = ['30 minutes', '60 minutes', '90 minutes'];

  final Map<String, IconData> _platformIcons = {
    'Zoom': Icons.video_call,
    'Google Meet': Icons.duo,
    'Microsoft Teams': Icons.groups,
  };

  final Map<String, Color> _platformColors = {
    'Zoom': Colors.blue,
    'Google Meet': Colors.green,
    'Microsoft Teams': Colors.purple,
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade600,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedTime = null;
      });
    }
  }

  Widget _buildAnimatedCard({required Widget child}) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(opacity: _fadeAnimation, child: child),
    );
  }

  Widget _buildTutorHeader() {
    return _buildAnimatedCard(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade600, Colors.blue.shade400],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Hero(
              tag: 'tutor_avatar_${widget.tutorName}',
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(17),
                  child: Image.network(
                    widget.tutorImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 35,
                          color: Colors.grey[600],
                        ),
                      );
                    },
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
                    widget.tutorName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.subjects.join(' • '),
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Available Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => TutorDetailsScreen(
                          name: widget.tutorName,
                          subjects: widget.subjects,
                          rating: 4.9,
                          sessions: 127,
                          points: 1500,
                          badges: 5,
                          isAvailable: true,
                          imageUrl: widget.tutorImage,
                        ),
                  ),
                );
              },
              icon: const Icon(
                Icons.info_outline,
                color: Colors.white,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Colors.blue.shade600),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectSelection() {
    return _buildAnimatedCard(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  widget.subjects.map((subject) {
                    final isSelected = _selectedSubject == subject;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedSubject = subject;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected ? Colors.blue.shade600 : Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color:
                                isSelected
                                    ? Colors.blue.shade600
                                    : Colors.grey.shade300,
                            width: 2,
                          ),
                          boxShadow:
                              isSelected
                                  ? [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                  : [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSelected ? Icons.check_circle : Icons.school,
                              size: 18,
                              color:
                                  isSelected
                                      ? Colors.white
                                      : Colors.blue.shade600,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              subject,
                              style: TextStyle(
                                color:
                                    isSelected
                                        ? Colors.white
                                        : Colors.grey[800],
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeSelection() {
    return _buildAnimatedCard(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Date Selection
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      _selectedDate != null
                          ? Colors.blue.shade50
                          : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        _selectedDate != null
                            ? Colors.blue.shade300
                            : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color:
                          _selectedDate != null
                              ? Colors.blue.shade600
                              : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedDate == null
                            ? 'Select date'
                            : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                        style: TextStyle(
                          fontSize: 16,
                          color:
                              _selectedDate != null
                                  ? Colors.blue.shade800
                                  : Colors.grey,
                          fontWeight:
                              _selectedDate != null
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Time Selection
            if (_selectedDate != null) ...[
              Text(
                'Available Times',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    _availableTimes.map((time) {
                      final isSelected = _selectedTime == time;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTime = time;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? Colors.blue.shade600
                                    : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? Colors.blue.shade600
                                      : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            time,
                            style: TextStyle(
                              color:
                                  isSelected ? Colors.white : Colors.grey[700],
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSessionDetails() {
    return _buildAnimatedCard(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Platform Selection
            Text(
              'Platform',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children:
                  _platforms.map((platform) {
                    final isSelected = _selectedPlatform == platform;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPlatform = platform;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? _platformColors[platform]!
                                    : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? _platformColors[platform]!
                                      : Colors.grey.shade300,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                _platformIcons[platform],
                                color:
                                    isSelected
                                        ? Colors.white
                                        : _platformColors[platform],
                                size: 20,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                platform.split(' ').first,
                                style: TextStyle(
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : Colors.grey[700],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 20),
            // Duration Selection
            Text(
              'Duration',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children:
                  _durations.map((duration) {
                    final isSelected = _selectedDuration == duration;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDuration = duration;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? Colors.orange.shade500
                                    : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? Colors.orange.shade500
                                      : Colors.grey.shade300,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.access_time,
                                color:
                                    isSelected ? Colors.white : Colors.orange,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                duration.split(' ').first,
                                style: TextStyle(
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : Colors.grey[700],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 20),
            // Description
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Session Description',
                hintText: 'What would you like to focus on?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                ),
                prefixIcon: Icon(
                  Icons.description,
                  color: Colors.blue.shade600,
                ),
              ),
              onChanged: (value) {
                _sessionDescription = value;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookButton() {
    final isFormValid =
        _selectedSubject != null &&
        _selectedDate != null &&
        _selectedTime != null;

    return _buildAnimatedCard(
      child: Container(
        margin: const EdgeInsets.all(20),
        width: double.infinity,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: ElevatedButton(
            onPressed: isFormValid && !_isLoading ? _handleBooking : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: isFormValid ? 8 : 2,
              shadowColor: Colors.blue.withOpacity(0.3),
            ),
            child:
                _isLoading
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outline, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Confirm Booking',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleBooking() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => BookingDetailsScreen(
                sessionTitle: _selectedSubject!,
                tutorName: widget.tutorName,
                tutorImage: widget.tutorImage,
                platform: _selectedPlatform,
                dateTime:
                    '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year} at $_selectedTime',
                duration: _selectedDuration,
                description:
                    _sessionDescription.isEmpty
                        ? 'No specific description provided'
                        : _sessionDescription,
              ),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Booking submitted successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Book a Session',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTutorHeader(),
            _buildSectionTitle('Choose Subject', Icons.school),
            _buildSubjectSelection(),
            const SizedBox(height: 16),
            _buildSectionTitle('Select Date & Time', Icons.schedule),
            _buildDateTimeSelection(),
            const SizedBox(height: 16),
            _buildSectionTitle('Session Details', Icons.settings),
            _buildSessionDetails(),
            _buildBookButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

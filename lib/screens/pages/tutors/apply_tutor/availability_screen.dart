import 'package:flutter/material.dart';

class AvailabilityScreen extends StatefulWidget {
  final Function(Map<String, List<String>>) onDataChanged;
  final Map<String, List<String>> initialData;

  const AvailabilityScreen({
    super.key,
    required this.onDataChanged,
    required this.initialData,
  });

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen>
    with SingleTickerProviderStateMixin {
  late Map<String, List<String>> _selectedSlots;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final List<String> _timeSlots = ['9AM - 12PM', '1PM - 5PM', '6PM - 9PM'];

  @override
  void initState() {
    super.initState();
    _selectedSlots = Map<String, List<String>>.from(widget.initialData);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleTimeSlot(String day, String timeSlot) {
    setState(() {
      _selectedSlots[day] ??= [];
      if (_selectedSlots[day]!.contains(timeSlot)) {
        _selectedSlots[day]!.remove(timeSlot);
        if (_selectedSlots[day]!.isEmpty) {
          _selectedSlots.remove(day);
        }
      } else {
        _selectedSlots[day]!.add(timeSlot);
      }
      widget.onDataChanged(_selectedSlots);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue.shade50,
            Colors.indigo.shade50,
            Colors.purple.shade50,
          ],
        ),
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.teal.shade600, Colors.cyan.shade600],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.shade200.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.calendar_today_outlined,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Set Your Availability',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select the time slots when you\'re available to tutor',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Availability Grid
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Your Availability',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Days Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children:
                          _days.map((day) {
                            return Expanded(
                              child: Center(
                                child: Text(
                                  day,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 16),
                    // Time Slots Grid
                    ..._timeSlots.map((timeSlot) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children:
                              _days.map((day) {
                                final isSelected =
                                    _selectedSlots[day]?.contains(timeSlot) ??
                                    false;
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => _toggleTimeSlot(day, timeSlot),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        gradient:
                                            isSelected
                                                ? LinearGradient(
                                                  colors: [
                                                    Colors.teal.shade400,
                                                    Colors.cyan.shade400,
                                                  ],
                                                )
                                                : null,
                                        color:
                                            isSelected
                                                ? null
                                                : Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color:
                                              isSelected
                                                  ? Colors.teal.shade600
                                                  : Colors.grey.shade300,
                                          width: isSelected ? 2 : 1,
                                        ),
                                        boxShadow:
                                            isSelected
                                                ? [
                                                  BoxShadow(
                                                    color: Colors.teal.shade200
                                                        .withOpacity(0.5),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ]
                                                : [],
                                      ),
                                      child: Center(
                                        child: Text(
                                          timeSlot,
                                          style: TextStyle(
                                            color:
                                                isSelected
                                                    ? Colors.white
                                                    : Colors.grey.shade700,
                                            fontSize: 12,
                                            fontWeight:
                                                isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Tips Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.amber.shade50, Colors.orange.shade50],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange.shade200, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.lightbulb_outline_rounded,
                            color: Colors.orange.shade700,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Availability Tips',
                          style: TextStyle(
                            color: Colors.orange.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTip(
                      'Select multiple time slots to increase your booking chances',
                      Icons.schedule_outlined,
                    ),
                    _buildTip(
                      'Ensure your availability aligns with your teaching mode',
                      Icons.sync_alt_outlined,
                    ),
                    _buildTip(
                      'Update your availability regularly for accurate scheduling',
                      Icons.update_outlined,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTip(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.orange.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.orange.shade800,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

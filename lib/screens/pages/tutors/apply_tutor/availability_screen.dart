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

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  late Map<String, List<String>> _selectedSlots;

  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final List<String> _timeSlots = ['9AM - 12PM', '1PM - 5PM', '6PM - 9PM'];

  @override
  void initState() {
    super.initState();
    _selectedSlots = Map<String, List<String>>.from(widget.initialData);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set Your Availability',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          Text(
            'Select the time slots when you\'re available to tutor',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  GridView.count(
                    crossAxisCount: 7,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children:
                        _days.map((day) {
                          return Center(
                            child: Text(
                              day,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 10),
                  GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          childAspectRatio: 1.5,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                        ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _timeSlots.length * 7,
                    itemBuilder: (context, index) {
                      final dayIndex = index % 7;
                      final timeSlotIndex = index ~/ 7;
                      final day = _days[dayIndex];
                      final timeSlot = _timeSlots[timeSlotIndex];
                      final isSelected =
                          _selectedSlots[day]?.contains(timeSlot) ?? false;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedSlots[day]?.remove(timeSlot);
                              if (_selectedSlots[day]?.isEmpty ?? false) {
                                _selectedSlots.remove(day);
                              }
                            } else {
                              _selectedSlots[day] ??= [];
                              _selectedSlots[day]!.add(timeSlot);
                            }
                            widget.onDataChanged(_selectedSlots);
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              timeSlot,
                              style: TextStyle(
                                color:
                                    isSelected ? Colors.white : Colors.black87,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

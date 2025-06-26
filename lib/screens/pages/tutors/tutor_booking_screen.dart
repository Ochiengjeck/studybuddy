import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/providers/providers.dart';

class TutorBookingScreen extends StatefulWidget {
  final String tutorId;

  const TutorBookingScreen({super.key, required this.tutorId});

  @override
  State<TutorBookingScreen> createState() => _TutorBookingScreenState();
}

class _TutorBookingScreenState extends State<TutorBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDateTime;
  String? _selectedDuration;
  String? _selectedPlatform;

  final List<String> _durations = ['30', '60', '90', '120'];
  final List<String> _platforms = ['Google Meet', 'Zoom', 'Microsoft Teams'];

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _bookSession(BuildContext context) async {
    if (_formKey.currentState!.validate() && _selectedDateTime != null) {
      final tutorProvider = Provider.of<TutorProvider>(context, listen: false);
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final userId = appProvider.currentUser?.id;

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to book a session')),
        );
        return;
      }

      try {
        await tutorProvider.bookTutorSession(
          userId: userId,
          tutorId: widget.tutorId,
          subject: _subjectController.text.trim(),
          dateTime: _selectedDateTime!,
          duration: _selectedDuration!,
          platform: _selectedPlatform!,
          description: _descriptionController.text.trim(),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session booked successfully')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${tutorProvider.error ?? e.toString()}'),
          ),
        );
      }
    }
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tutorProvider = Provider.of<TutorProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Book Tutor Session')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value?.isEmpty ?? true
                            ? 'Please enter a subject'
                            : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _selectDateTime(context),
                child: Text(
                  _selectedDateTime == null
                      ? 'Select Date & Time'
                      : 'Date: ${_selectedDateTime!.toString().substring(0, 16)}',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedDuration,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                  border: OutlineInputBorder(),
                ),
                items:
                    _durations
                        .map(
                          (duration) => DropdownMenuItem(
                            value: duration,
                            child: Text(duration),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDuration = value;
                  });
                },
                validator:
                    (value) =>
                        value == null ? 'Please select a duration' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedPlatform,
                decoration: const InputDecoration(
                  labelText: 'Platform',
                  border: OutlineInputBorder(),
                ),
                items:
                    _platforms
                        .map(
                          (platform) => DropdownMenuItem(
                            value: platform,
                            child: Text(platform),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPlatform = value;
                  });
                },
                validator:
                    (value) =>
                        value == null ? 'Please select a platform' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed:
                    tutorProvider.isLoading
                        ? null
                        : () => _bookSession(context),
                child:
                    tutorProvider.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Book Session'),
              ),
              if (tutorProvider.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    tutorProvider.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

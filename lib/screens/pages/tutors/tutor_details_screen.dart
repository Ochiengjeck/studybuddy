import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/providers/providers.dart';
import 'tutor_booking_screen.dart';

class TutorDetailsScreen extends StatefulWidget {
  final String tutorId;

  const TutorDetailsScreen({super.key, required this.tutorId});

  @override
  State<TutorDetailsScreen> createState() => _TutorDetailsScreenState();
}

class _TutorDetailsScreenState extends State<TutorDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TutorProvider>(
        context,
        listen: false,
      ).loadTutorDetails(widget.tutorId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tutorProvider = Provider.of<TutorProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Tutor Details')),
      body:
          tutorProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : tutorProvider.error != null
              ? Center(child: Text('Error: ${tutorProvider.error}'))
              : tutorProvider.selectedTutor == null
              ? const Center(child: Text('No tutor data available'))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            tutorProvider.selectedTutor!.profilePicture != null
                                ? NetworkImage(
                                  tutorProvider.selectedTutor!.profilePicture!,
                                )
                                : null,
                        child:
                            tutorProvider.selectedTutor!.profilePicture == null
                                ? const Icon(Icons.person, size: 50)
                                : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        tutorProvider.selectedTutor!.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Rating: ${tutorProvider.selectedTutor!.rating.toStringAsFixed(1)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Bio',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(tutorProvider.selectedTutor!.bio ?? 'No bio'),
                    const SizedBox(height: 16),
                    const Text(
                      'Education',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      tutorProvider.selectedTutor!.education ??
                          'No education details',
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Subjects',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      children:
                          tutorProvider.selectedTutor!.subjects
                              .map((subject) => Chip(label: Text(subject)))
                              .toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Availability',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ...tutorProvider.selectedTutor!.availability.entries.map(
                      (entry) =>
                          Text('${entry.key}: ${entry.value.join(", ")}'),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => TutorBookingScreen(
                                    tutorId: widget.tutorId,
                                  ),
                            ),
                          );
                        },
                        child: const Text('Book Session'),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}

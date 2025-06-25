import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/modelsAndRepsositories/models_and_repositories.dart';
import '../../../utils/providers/providers.dart';

class BookingDetailsScreen extends StatelessWidget {
  final Session session;

  const BookingDetailsScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final sessionProvider = Provider.of<SessionProvider>(
      context,
      listen: false,
    );
    final userId =
        Provider.of<AppProvider>(context, listen: false).currentUser?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implement edit functionality
            },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.schedule,
                      color: Colors.orange,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Booking Pending',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        Text(
                          'Waiting for tutor confirmation',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Session Details Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Session Details',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      session.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      session.description,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),

                    const SizedBox(height: 16),

                    _buildDetailRow(
                      Icons.schedule,
                      'Date & Time',
                      session.formattedDateTime,
                    ),
                    _buildDetailRow(
                      Icons.timer,
                      'Duration',
                      session.formattedDuration,
                    ),
                    _buildDetailRow(
                      Icons.video_call,
                      'Platform',
                      session.platform,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Tutor Information Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tutor Information',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(session.tutorImage),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                session.tutorName,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text('4.9'),
                                  const SizedBox(width: 8),
                                  Text(
                                    '127 sessions',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            // TODO: Navigate to tutor profile
                          },
                          icon: const Icon(Icons.arrow_forward_ios, size: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Booking Options Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking Options',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    ListTile(
                      leading: const Icon(Icons.edit_calendar),
                      title: const Text('Reschedule Session'),
                      subtitle: const Text('Choose a different time slot'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // TODO: Implement reschedule functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Reschedule feature coming soon'),
                          ),
                        );
                      },
                    ),

                    const Divider(),

                    ListTile(
                      leading: const Icon(Icons.chat),
                      title: const Text('Message Tutor'),
                      subtitle: const Text('Send a message about your session'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // TODO: Navigate to chat with tutor
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Cancel Booking'),
                              content: const Text(
                                'Are you sure you want to cancel this booking? This action cannot be undone.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Keep Booking'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    try {
                                      await sessionProvider.cancelSession(
                                        userId,
                                        session.id,
                                      );
                                      Navigator.pop(context); // Close dialog
                                      Navigator.pop(context); // Go back
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Booking cancelled'),
                                        ),
                                      );
                                    } catch (e) {
                                      Navigator.pop(context); // Close dialog
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Error cancelling booking: ${e.toString()}',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  child: const Text('Cancel Booking'),
                                ),
                              ],
                            ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text('Cancel Booking'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Reminder set successfully'),
                        ),
                      );
                    },
                    child: const Text('Set Reminder'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey[600])),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../utils/modelsAndRepsositories/models_and_repositories.dart';

class SessionDetailsScreen extends StatelessWidget {
  final Session session;

  const SessionDetailsScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Session Details'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showShareOptions(context),
            icon: const Icon(Icons.share),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'report':
                  _showReportDialog(context);
                  break;
                case 'download':
                  _downloadSessionSummary(context);
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'download',
                    child: ListTile(
                      leading: Icon(Icons.download),
                      title: Text('Download Summary'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'report',
                    child: ListTile(
                      leading: Icon(Icons.flag),
                      title: Text('Report Issue'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section with Completion Status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.green.withOpacity(0.1),
                    Colors.green.withOpacity(0.05),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Session Completed Successfully',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Completed on ${session.formattedDateTime}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    session.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    session.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Session Overview Card
            Container(
              margin: const EdgeInsets.all(16),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Session Overview',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildInfoRow(
                        Icons.access_time,
                        'Duration',
                        session.formattedDuration,
                        Colors.blue,
                      ),
                      const SizedBox(height: 16),

                      _buildInfoRow(
                        Icons.videocam,
                        'Platform',
                        session.platform,
                        Colors.purple,
                      ),
                      const SizedBox(height: 16),

                      _buildInfoRow(
                        Icons.calendar_today,
                        'Date & Time',
                        session.formattedDateTime,
                        Colors.orange,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Tutor Information Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Tutor',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Hero(
                            tag: 'tutor_${session.tutorName}',
                            child: CircleAvatar(
                              radius: 35,
                              backgroundImage: NetworkImage(session.tutorImage),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  session.tutorName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Row(
                                      children: List.generate(5, (index) {
                                        return Icon(
                                          Icons.star,
                                          size: 16,
                                          color:
                                              index < 5
                                                  ? Colors.amber
                                                  : Colors.grey[300],
                                        );
                                      }),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('4.9'),
                                    const SizedBox(width: 12),
                                    Container(
                                      width: 80,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        '127+ sessions',
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue,
                                          fontWeight: FontWeight.w500,
                                        ),
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Opening tutor profile...'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.arrow_forward_ios, size: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Session Materials & Resources
            Container(
              margin: const EdgeInsets.all(16),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Session Materials & Resources',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildMaterialTile(
                        context,
                        icon: Icons.library_books,
                        title: 'Study Materials',
                        subtitle: 'Notes, slides, and course resources',
                        color: Colors.indigo,
                        onTap: () {
                          Navigator.pushNamed(context, '/study-materials');
                        },
                      ),

                      const SizedBox(height: 12),

                      _buildMaterialTile(
                        context,
                        icon: Icons.bookmark,
                        title: 'Saved Items',
                        subtitle: 'Your bookmarked content and highlights',
                        color: Colors.amber[700]!,
                        onTap: () {
                          Navigator.pushNamed(context, '/saved-items');
                        },
                      ),

                      const SizedBox(height: 12),

                      _buildMaterialTile(
                        context,
                        icon: Icons.play_circle_filled,
                        title: 'Session Recording',
                        subtitle: 'Rewatch this session anytime',
                        color: Colors.red,
                        onTap: () {
                          _showRecordingDialog(context);
                        },
                      ),

                      const SizedBox(height: 12),

                      _buildMaterialTile(
                        context,
                        icon: Icons.assignment,
                        title: 'Session Notes',
                        subtitle: 'AI-generated summary and key points',
                        color: Colors.teal,
                        onTap: () {
                          _showSessionNotes(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Feedback Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Your Feedback',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () => _showFeedbackDialog(context),
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('Edit'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          const Text(
                            'Rating: ',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                Icons.star,
                                color:
                                    index < 5 ? Colors.amber : Colors.grey[300],
                                size: 20,
                              );
                            }),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${session.rating?.toStringAsFixed(1) ?? '5.0'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Text(
                          'Excellent session! The tutor explained complex concepts clearly and provided helpful examples. The interactive approach made learning enjoyable and effective.',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons
            Container(
              margin: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _showBookAgainDialog(context);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.calendar_today),
                          label: const Text('Book Again'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _downloadCertificate(context);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.workspace_premium),
                          label: const Text('Certificate'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () {
                        _shareSession(context);
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.share),
                      label: const Text('Share Session Details'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMaterialTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    int rating = session.rating?.round() ?? 5;
    final TextEditingController reviewController = TextEditingController(
      text:
          'Excellent session! The tutor explained complex concepts clearly and provided helpful examples. The interactive approach made learning enjoyable and effective.',
    );

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Edit Your Feedback'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rating:',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: List.generate(5, (index) {
                            return GestureDetector(
                              onTap: () => setState(() => rating = index + 1),
                              child: Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Icon(
                                  index < rating
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 28,
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Your Review:',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: reviewController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            hintText:
                                'Share your experience with this session...',
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Save feedback to backend
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Feedback updated successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showRecordingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Session Recording'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.videocam, color: Colors.red),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recording Available',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('Duration: 90 minutes'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Would you like to watch the session recording?'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Later'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Opening session recording...'),
                    ),
                  );
                },
                child: const Text('Watch Now'),
              ),
            ],
          ),
    );
  }

  void _showSessionNotes(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            builder:
                (context, scrollController) => Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Session Notes',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildNoteSection('Key Topics Covered', [
                                'Python syntax and basic structures',
                                'Data types: strings, integers, lists, dictionaries',
                                'Control flow: if statements, loops',
                                'Functions and parameter passing',
                                'Error handling basics',
                              ]),
                              const SizedBox(height: 20),
                              _buildNoteSection('Important Code Examples', [
                                'List comprehensions for data processing',
                                'Dictionary methods and manipulation',
                                'Function definitions with default parameters',
                                'Try-except blocks for error handling',
                              ]),
                              const SizedBox(height: 20),
                              _buildNoteSection('Homework & Next Steps', [
                                'Complete practice exercises 1-5',
                                'Read Chapter 3 of Python textbook',
                                'Practice writing functions',
                                'Prepare questions for next session',
                              ]),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Widget _buildNoteSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontSize: 16)),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 15, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showBookAgainDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Book Another Session with ${session.tutorName}'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: const Text(
              'Would you like to book another session with this tutor?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Maybe Later'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Redirecting to booking page...'),
                    ),
                  );
                },
                child: const Text('Book Now'),
              ),
            ],
          ),
    );
  }

  void _downloadCertificate(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Certificate downloaded successfully!'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {
            // TODO: Open certificate viewer
          },
        ),
      ),
    );
  }

  void _shareSession(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Sharing session details...')));
  }

  void _showShareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Share Session',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.link),
                  title: const Text('Copy Link'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Link copied to clipboard')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Share via Email'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening email app...')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.message),
                  title: const Text('Share via Message'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening messages app...')),
                    );
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Report an Issue'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('What type of issue would you like to report?'),
                const SizedBox(height: 16),
                Column(
                  children: [
                    ListTile(
                      title: const Text('Technical Issue'),
                      leading: const Icon(Icons.bug_report),
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Technical report submitted'),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      title: const Text('Content Issue'),
                      leading: const Icon(Icons.report_problem),
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Content report submitted'),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      title: const Text('Other'),
                      leading: const Icon(Icons.help),
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Report submitted')),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  void _downloadSessionSummary(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Session summary downloaded!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

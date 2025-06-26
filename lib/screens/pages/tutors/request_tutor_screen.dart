import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/providers/providers.dart';

class RequestTutorScreen extends StatefulWidget {
  const RequestTutorScreen({super.key});

  @override
  State<RequestTutorScreen> createState() => _RequestTutorScreenState();
}

class _RequestTutorScreenState extends State<RequestTutorScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _detailsController = TextEditingController();
  String? _selectedPriority;

  final List<String> _priorities = ['Low', 'Medium', 'High'];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
    _animationController.forward();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _detailsController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final tutorProvider = Provider.of<TutorProvider>(context, listen: false);
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final userId = appProvider.currentUser?.id;

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          _buildSnackBar('Please log in to request a tutor', isError: true),
        );
        return;
      }

      try {
        await tutorProvider.requestTutor(
          userId: userId,
          subject: _subjectController.text.trim(),
          details: _detailsController.text.trim(),
          priority: _selectedPriority,
        );

        // Show success message
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(_buildSnackBar('Tutor request submitted successfully!'));

        // Close the screen after a short delay to allow the user to see the message
        await Future.delayed(const Duration(milliseconds: 1500));

        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          _buildSnackBar(tutorProvider.error ?? e.toString(), isError: true),
        );
      }
    }
  }

  SnackBar _buildSnackBar(String message, {bool isError = false}) {
    return SnackBar(
      content: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: isError ? Colors.red[600] : Colors.green[600],
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red[500]!;
      case 'medium':
        return Colors.orange[500]!;
      case 'low':
        return Colors.green[500]!;
      default:
        return Colors.grey[500]!;
    }
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Icons.priority_high;
      case 'medium':
        return Icons.remove;
      case 'low':
        return Icons.low_priority;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tutorProvider = Provider.of<TutorProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
        title: const Text(
          'Request a Tutor',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section with Gradient
              Container(
                height: 160,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withOpacity(0.8),
                      theme.colorScheme.secondary,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.school_outlined,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Find Your Perfect Tutor',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Form Section
              Transform.translate(
                offset: const Offset(0, -30),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Subject Field
                          _buildSectionTitle('Subject', Icons.book),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _subjectController,
                            decoration: InputDecoration(
                              hintText: 'e.g., Mathematics, Physics, Chemistry',
                              prefixIcon: Icon(
                                Icons.subject,
                                color: theme.colorScheme.primary,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor:
                                  isDark ? Colors.grey[800] : Colors.grey[100],
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                            validator:
                                (value) =>
                                    value?.isEmpty ?? true
                                        ? 'Please enter a subject'
                                        : null,
                          ),

                          const SizedBox(height: 24),

                          // Details Field
                          _buildSectionTitle('Details', Icons.description),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _detailsController,
                            decoration: InputDecoration(
                              hintText: 'Describe what you need help with...',
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(bottom: 60),
                                child: Icon(
                                  Icons.edit_note,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor:
                                  isDark ? Colors.grey[800] : Colors.grey[100],
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                            maxLines: 4,
                            validator:
                                (value) =>
                                    value?.isEmpty ?? true
                                        ? 'Please enter details'
                                        : null,
                          ),

                          const SizedBox(height: 24),

                          // Priority Field
                          _buildSectionTitle('Priority', Icons.flag),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color:
                                  isDark ? Colors.grey[800] : Colors.grey[100],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: DropdownButtonFormField<String>(
                              value: _selectedPriority,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              hint: Row(
                                children: [
                                  Icon(
                                    Icons.priority_high,
                                    color: Colors.grey[500],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Select priority level',
                                    style: TextStyle(color: Colors.grey[500]),
                                  ),
                                ],
                              ),
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: theme.colorScheme.primary,
                              ),
                              items:
                                  _priorities
                                      .map(
                                        (priority) => DropdownMenuItem(
                                          value: priority,
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: _getPriorityColor(
                                                    priority,
                                                  ).withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Icon(
                                                  _getPriorityIcon(priority),
                                                  color: _getPriorityColor(
                                                    priority,
                                                  ),
                                                  size: 16,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Text(priority),
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedPriority = value;
                                });
                              },
                              validator:
                                  (value) =>
                                      value == null
                                          ? 'Please select a priority'
                                          : null,
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Submit Button
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 56,
                            child: ElevatedButton(
                              onPressed:
                                  tutorProvider.isLoading
                                      ? null
                                      : () => _submitRequest(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                                shadowColor: Colors.transparent,
                              ).copyWith(
                                backgroundColor:
                                    MaterialStateProperty.resolveWith((states) {
                                      if (states.contains(
                                        MaterialState.disabled,
                                      )) {
                                        return Colors.grey[300];
                                      }
                                      return theme.colorScheme.primary;
                                    }),
                              ),
                              child:
                                  tutorProvider.isLoading
                                      ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                      : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.send, size: 20),
                                          SizedBox(width: 8),
                                          Text(
                                            'Submit Request',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                            ),
                          ),

                          // Error Display
                          if (tutorProvider.error != null)
                            Container(
                              margin: const EdgeInsets.only(top: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.red[200]!,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red[600],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      tutorProvider.error!,
                                      style: TextStyle(
                                        color: Colors.red[700],
                                        fontSize: 14,
                                      ),
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
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

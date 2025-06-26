import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../utils/providers/providers.dart';

class SubmitApplicationScreen extends StatefulWidget {
  final Map<String, dynamic> personalInfo;
  final List<String> subjects;
  final Map<String, List<String>> availability;
  final String? teachingMode;
  final String? venue;
  final bool agreementChecked;
  final bool accuracyChecked;
  final ValueChanged<bool> onAgreementChanged;
  final ValueChanged<bool> onAccuracyChanged;

  const SubmitApplicationScreen({
    super.key,
    required this.personalInfo,
    required this.subjects,
    required this.availability,
    required this.agreementChecked,
    required this.accuracyChecked,
    required this.onAgreementChanged,
    required this.onAccuracyChanged,
    this.teachingMode,
    this.venue,
  });

  @override
  State<SubmitApplicationScreen> createState() =>
      _SubmitApplicationScreenState();
}

class _SubmitApplicationScreenState extends State<SubmitApplicationScreen>
    with SingleTickerProviderStateMixin {
  late bool _agreementChecked;
  late bool _accuracyChecked;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _agreementChecked = false;
    _accuracyChecked = false;
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

  Future<void> _submitApplication(BuildContext context) async {
    if (!_agreementChecked || !_accuracyChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to all terms and confirm accuracy'),
        ),
      );
      return;
    }

    final tutorProvider = Provider.of<TutorProvider>(context, listen: false);
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final userId = appProvider.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to submit application')),
      );
      return;
    }

    try {
      await tutorProvider.submitTutorApplication(
        userId: userId,
        personalInfo: widget.personalInfo,
        subjects: widget.subjects,
        availability: widget.availability,
        teachingMode: widget.teachingMode,
        venue: widget.venue,
      );

      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              contentPadding: const EdgeInsets.all(24),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.teal.shade600,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Application Submitted!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Thank you for your tutor application. We will review it and get back to you within 2-5 working days.',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Reference: #${DateTime.now().millisecondsSinceEpoch}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              actions: [
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${tutorProvider.error ?? e.toString()}'),
        ),
      );
    }
  }

  Widget _buildFormField({
    required String label,
    required String value,
    int maxLines = 1,
    IconData? icon,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        initialValue: value.isNotEmpty ? value : 'Not provided',
        enabled: false,
        maxLines: maxLines,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: value.isNotEmpty ? Colors.black87 : Colors.grey.shade500,
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon:
              icon != null
                  ? Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (iconColor ?? Colors.blue).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor ?? Colors.blue,
                      size: 20,
                    ),
                  )
                  : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          labelStyle: TextStyle(
            color: Colors.grey[700],
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20, top: 32),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectChips(List<String> subjects) {
    if (subjects.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Text(
          'No subjects selected',
          style: TextStyle(color: Colors.grey.shade500),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children:
            subjects.map((subject) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  subject,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildAvailabilityDisplay(Map<String, List<String>> availability) {
    if (availability.isEmpty ||
        availability.values.every((slots) => slots.isEmpty)) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Text(
          'No availability selected',
          style: TextStyle(color: Colors.grey.shade500),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            availability.entries.where((entry) => entry.value.isNotEmpty).map((
              entry,
            ) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children:
                          entry.value.map((slot) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.green.shade300,
                                ),
                              ),
                              child: Text(
                                slot,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tutorProvider = Provider.of<TutorProvider>(context);

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
              // Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.green.shade600, Colors.teal.shade600],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.shade200.withOpacity(0.5),
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
                        Icons.assignment_turned_in_outlined,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Review Your Application',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please review all information before submitting',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Personal Information Section
              Container(
                margin: const EdgeInsets.only(top: 32),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      'Personal Information',
                      Icons.person_outline_rounded,
                      Colors.blue.shade600,
                    ),
                    // Update the personal info display to match what's collected:
                    _buildFormField(
                      label: 'Full Name',
                      value: widget.personalInfo['fullName'] ?? '',
                      icon: Icons.person_outline_rounded,
                      iconColor: Colors.blue.shade600,
                    ),
                    _buildFormField(
                      label: 'Email',
                      value: widget.personalInfo['email'] ?? '',
                      icon: Icons.email_outlined,
                      iconColor: Colors.green.shade600,
                    ),
                    _buildFormField(
                      label: 'Phone',
                      value: widget.personalInfo['phone'] ?? '',
                      icon: Icons.phone_outlined,
                      iconColor: Colors.orange.shade600,
                    ),
                    _buildFormField(
                      label: 'Year of Study',
                      value: widget.personalInfo['yearOfStudy'] ?? '',
                      icon: Icons.school_outlined,
                      iconColor: Colors.teal.shade600,
                    ),
                    _buildFormField(
                      label: 'Field of Study',
                      value: widget.personalInfo['fieldOfStudy'] ?? '',
                      icon: Icons.work_outline_rounded,
                      iconColor: Colors.pink.shade600,
                    ),
                  ],
                ),
              ),

              // Subjects Section
              Container(
                margin: const EdgeInsets.only(top: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      'Teaching Subjects',
                      Icons.subject_outlined,
                      Colors.indigo.shade600,
                    ),
                    _buildSubjectChips(widget.subjects),
                  ],
                ),
              ),

              // Availability Section
              Container(
                margin: const EdgeInsets.only(top: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      'Availability Schedule',
                      Icons.schedule_outlined,
                      Colors.green.shade600,
                    ),
                    _buildAvailabilityDisplay(widget.availability),
                  ],
                ),
              ),

              // Teaching Mode Section
              Container(
                margin: const EdgeInsets.only(top: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      'Teaching Mode',
                      Icons.computer_outlined,
                      Colors.orange.shade600,
                    ),
                    _buildFormField(
                      label: 'Preferred Teaching Mode',
                      value: widget.teachingMode ?? '',
                      icon: Icons.computer_outlined,
                      iconColor: Colors.orange.shade600,
                    ),
                    if (widget.venue != null && widget.venue!.isNotEmpty)
                      _buildFormField(
                        label: 'Preferred Venue/Address',
                        value: widget.venue!,
                        maxLines: 2,
                        icon: Icons.location_on_outlined,
                        iconColor: Colors.red.shade600,
                      ),
                  ],
                ),
              ),

              // Agreement Section
              Container(
                margin: const EdgeInsets.only(top: 32),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      'Final Confirmation',
                      Icons.fact_check_outlined,
                      Colors.purple.shade600,
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.yellow.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.yellow.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_outlined,
                            color: Colors.orange.shade600,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Please read and accept the terms below to proceed with your application.',
                              style: TextStyle(
                                color: Colors.orange.shade800,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    CheckboxListTile(
                      title: const Text('I agree to the Terms and Conditions'),
                      value: widget.agreementChecked,
                      onChanged: (value) {
                        if (value != null) widget.onAgreementChanged(value);
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),

                    CheckboxListTile(
                      title: const Text(
                        'I confirm all information is accurate',
                      ),
                      value: widget.accuracyChecked,
                      onChanged: (value) {
                        if (value != null) widget.onAccuracyChanged(value);
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ],
                ),
              ),

              // Error Display
              if (tutorProvider.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    tutorProvider.error!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

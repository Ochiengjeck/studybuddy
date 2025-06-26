import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../utils/providers/providers.dart';
import 'personal_info_screen.dart';
import 'subject_selection_screen.dart';
import 'availability_screen.dart';
import 'mode_selection_screen.dart';
import 'submit_application_screen.dart';

class ApplyTutorFlow extends StatefulWidget {
  const ApplyTutorFlow({super.key});

  @override
  State<ApplyTutorFlow> createState() => _ApplyTutorFlowState();
}

class _ApplyTutorFlowState extends State<ApplyTutorFlow>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _agreementChecked = false;
  bool _accuracyChecked = false;

  // Application data storage
  final Map<String, dynamic> applicationData = {
    'personalInfo': <String, dynamic>{},
    'subjects': <String>[],
    'availability': <String, List<String>>{
      'Monday': [],
      'Tuesday': [],
      'Wednesday': [],
      'Thursday': [],
      'Friday': [],
      'Saturday': [],
      'Sunday': [],
    },
    'teachingMode': null,
    'venue': null,
  };

  final List<String> _stepTitles = [
    'Personal Information',
    'Subject Selection',
    'Availability',
    'Teaching Mode',
    'Review & Submit',
  ];

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
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  List<Widget> get _steps => [
    PersonalInfoScreen(
      onDataChanged: (Map<String, dynamic> data) {
        applicationData['personalInfo'] = Map<String, dynamic>.from(data);
        _updateDataAndValidate();
      },
      initialData: Map<String, dynamic>.from(applicationData['personalInfo']),
    ),
    SubjectSelectionScreen(
      onDataChanged: (List<String> subjects) {
        applicationData['subjects'] = List<String>.from(subjects);
        _updateDataAndValidate();
      },
      initialData: List<String>.from(applicationData['subjects']),
    ),
    AvailabilityScreen(
      onDataChanged: (Map<String, List<String>> availability) {
        applicationData['availability'] = Map<String, List<String>>.from(
          availability,
        );
        _updateDataAndValidate();
      },
      initialData: Map<String, List<String>>.from(
        applicationData['availability'],
      ),
    ),
    ModeSelectionScreen(
      onDataChanged: (String? mode, String? venue) {
        applicationData['teachingMode'] = mode;
        applicationData['venue'] = venue;
        _updateDataAndValidate();
      },
      initialMode: applicationData['teachingMode'] as String?,
      initialVenue: applicationData['venue'] as String?,
    ),
    SubmitApplicationScreen(
      personalInfo: Map<String, dynamic>.from(applicationData['personalInfo']),
      subjects: List<String>.from(applicationData['subjects']),
      availability: Map<String, List<String>>.from(
        applicationData['availability'],
      ),
      teachingMode: applicationData['teachingMode'] as String?,
      venue: applicationData['venue'] as String?,
      // Pass down the agreement states and callbacks
      agreementChecked: _agreementChecked,
      accuracyChecked: _accuracyChecked,
      onAgreementChanged: (value) => setState(() => _agreementChecked = value),
      onAccuracyChanged: (value) => setState(() => _accuracyChecked = value),
    ),
  ];

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        final personalInfo =
            applicationData['personalInfo'] as Map<String, dynamic>;
        return personalInfo['fullName']?.isNotEmpty == true &&
            personalInfo['email']?.isNotEmpty == true &&
            personalInfo['phone']?.isNotEmpty == true;
      case 1:
        return (applicationData['subjects'] as List<String>).isNotEmpty;
      case 2:
        return (applicationData['availability'] as Map<String, List<String>>)
            .values
            .any((slots) => slots.isNotEmpty);
      case 3:
        return applicationData['teachingMode'] != null;
      case 4:
        return _agreementChecked && _accuracyChecked; // Check agreements
      default:
        return false;
    }
  }

  void _updateDataAndValidate() {
    setState(() {}); // Force rebuild to update button state
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1 && _canProceed()) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    }
  }

  Future<void> _submitApplication() async {
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
        personalInfo: applicationData['personalInfo'] as Map<String, dynamic>,
        subjects: applicationData['subjects'] as List<String>,
        availability:
            applicationData['availability'] as Map<String, List<String>>,
        teachingMode: applicationData['teachingMode'] as String?,
        venue: applicationData['venue'] as String?,
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.teal.shade600, Colors.cyan.shade600],
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.shade200.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed:
                          _currentStep > 0
                              ? _previousStep
                              : () => Navigator.pop(context),
                    ),
                    const Text(
                      'Apply as Tutor',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 48), // Placeholder for symmetry
                  ],
                ),
              ),
            ),

            // Progress Indicator
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Step ${_currentStep + 1} of ${_steps.length}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _stepTitles[_currentStep],
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: (_currentStep + 1) / _steps.length,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.teal.shade600,
                    ),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),

            // Step Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _steps.length,
                itemBuilder: (context, index) => _steps[index],
              ),
            ),

            // Navigation Buttons
            Container(
              padding: const EdgeInsets.only(right: 40, left: 40, bottom: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    if (_currentStep > 0) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _previousStep,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: Colors.grey.shade300),
                            foregroundColor: Colors.grey.shade800,
                          ),
                          child: const Text(
                            'Back',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    Expanded(
                      flex: _currentStep > 0 ? 2 : 1,
                      child:
                      // In the button section of ApplyTutorFlow's build():
                      ElevatedButton(
                        onPressed:
                            _canProceed()
                                ? (_currentStep == _steps.length - 1
                                    ? _submitApplication // Handle submission here
                                    : _nextStep)
                                : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _canProceed()
                                  ? Colors.teal.shade600
                                  : Colors.grey.shade300,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: _canProceed() ? 4 : 0,
                        ),
                        child: Text(
                          _currentStep == _steps.length - 1
                              ? 'Submit Application'
                              : 'Continue',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

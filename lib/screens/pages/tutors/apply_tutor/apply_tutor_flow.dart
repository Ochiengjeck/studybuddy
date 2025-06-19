import 'package:flutter/material.dart';
import 'package:studybuddy/screens/pages/tutors/apply_tutor/mode_selection_screen.dart';
import 'package:studybuddy/screens/pages/tutors/apply_tutor/personal_info_screen.dart';
import 'package:studybuddy/screens/pages/tutors/apply_tutor/submit_application_screen.dart';
import 'package:studybuddy/screens/pages/tutors/apply_tutor/availability_screen.dart';
import 'package:studybuddy/screens/pages/tutors/apply_tutor/subject_selection_screen.dart';

class ApplyTutorFlow extends StatefulWidget {
  const ApplyTutorFlow({super.key});

  @override
  State<ApplyTutorFlow> createState() => _ApplyTutorFlowState();
}

class _ApplyTutorFlowState extends State<ApplyTutorFlow> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Application data storage with explicit types
  final Map<String, dynamic> applicationData = {
    'personalInfo': <String, dynamic>{},
    'subjects': <String>[],
    'availability': <String, List<String>>{},
    'teachingMode': null,
    'venue': null,
    'agreementChecked': false,
    'accuracyChecked': false,
  };

  final List<String> _stepTitles = [
    'Personal Information',
    'Subject Selection',
    'Availability',
    'Teaching Mode',
    'Review & Submit',
  ];

  // Update the _steps getter in apply_tutor_flow.dart to properly connect all screens:

  void _updateDataAndValidate() {
    setState(() {}); // Force rebuild to update button state
  }

  // Update the _steps getter to include the validation callback:
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
      applicationData: applicationData,
      onAgreementChanged: (bool checked) {
        applicationData['agreementChecked'] = checked;
        _updateDataAndValidate();
      },
      onAccuracyChanged: (bool checked) {
        applicationData['accuracyChecked'] = checked;
        _updateDataAndValidate();
      },
      onSubmit: _submitApplication,
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
            .isNotEmpty;
      case 3:
        return applicationData['teachingMode'] != null;
      case 4:
        return applicationData['agreementChecked'] == true &&
            applicationData['accuracyChecked'] == true;
      default:
        return true;
    }
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

  void _submitApplication() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Column(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green.shade600,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Application Submitted!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Thank you for your tutor application.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'We will review your application and get back to you within 2-5 working days.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 16),
                Text(
                  'Application Reference: #${DateTime.now().millisecondsSinceEpoch}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Close flow
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Apply as Tutor'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          // Progress Indicator
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Step ${_currentStep + 1} of ${_steps.length}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _stepTitles[_currentStep],
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: (_currentStep + 1) / _steps.length,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.blue.shade600,
                  ),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
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
            color: Colors.white,
            padding: const EdgeInsets.all(20),
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
                          side: BorderSide(color: Colors.grey[300]!),
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
                    child: ElevatedButton(
                      onPressed:
                          _canProceed()
                              ? (_currentStep == _steps.length - 1
                                  ? _submitApplication
                                  : _nextStep)
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _canProceed()
                                ? Colors.blue.shade600
                                : Colors.grey.shade300,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
    );
  }
}

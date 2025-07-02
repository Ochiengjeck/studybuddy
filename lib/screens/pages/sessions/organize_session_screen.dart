import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrganizeSessionScreen extends StatefulWidget {
  const OrganizeSessionScreen({super.key});

  @override
  State<OrganizeSessionScreen> createState() => _OrganizeSessionScreenState();
}

class _OrganizeSessionScreenState extends State<OrganizeSessionScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _maxParticipantsController = TextEditingController(text: '10');
  final _priceController = TextEditingController(text: '0');

  String _selectedSubject = 'Mathematics';
  String _selectedLevel = 'Beginner';
  String _selectedPlatform = 'Virtual';
  String _recurringPattern = 'Weekly';
  DateTime? _scheduledDateTime;
  Duration _duration = const Duration(hours: 1);
  bool _isRecurring = false;
  bool _isPaid = false;

  final List<String> _subjects = [
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'Computer Science',
    'English',
    'History',
    'Geography',
    'Languages',
    'Art & Design',
    'Music',
    'Business',
    'Other',
  ];

  final List<String> _levels = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'All Levels',
  ];

  final List<String> _platforms = ['Physical', 'Virtual', 'Hybrid', 'Others'];

  final List<String> _recurringPatterns = [
    'Daily',
    'Weekly',
    'Bi-weekly',
    'Monthly',
  ];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _maxParticipantsController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Theme.of(context).colorScheme.primary,
                onPrimary: Colors.white,
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        setState(() {
          _scheduledDateTime = DateTime(
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

  Future<void> _selectDuration() async {
    final duration = await showDialog<Duration>(
      context: context,
      builder: (context) => _DurationPickerDialog(initialDuration: _duration),
    );

    if (duration != null) {
      setState(() {
        _duration = duration;
      });
    }
  }

  Future<void> _submitSession() async {
    if (!_formKey.currentState!.validate() || _scheduledDateTime == null) {
      _showErrorSnackBar(context, 'Please fill in all required fields');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showErrorSnackBar(context, 'User not logged in');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('sessions').add({
        'userId': user.uid,
        'title': _titleController.text,
        'subject': _selectedSubject,
        'level': _selectedLevel,
        'description': _descriptionController.text,
        'scheduledDateTime': Timestamp.fromDate(_scheduledDateTime!),
        'start_time': Timestamp.fromDate(_scheduledDateTime!),
        'duration': _duration.inMinutes,
        'platform': _selectedPlatform,
        'maxParticipants': int.parse(_maxParticipantsController.text),
        'isRecurring': _isRecurring,
        'recurringPattern': _isRecurring ? _recurringPattern : null,
        'isPaid': _isPaid,
        'price': _isPaid ? double.parse(_priceController.text) : 0.0,
        'status': 'upcoming',
        'createdAt': Timestamp.now(),
        'type': 'organized',
      });

      _showSuccessSnackBar(context, 'Session set successfully!');
      Navigator.pop(context);
    } catch (e) {
      _showErrorSnackBar(context, 'Error: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: const Text('Set Session'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withOpacity(0.8),
              ],
            ),
          ),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Form(
                    key: _formKey,
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSection(
                                  context,
                                  title: 'Session Details',
                                  icon: Icons.info_outline,
                                  children: [
                                    _buildModernTextField(
                                      controller: _titleController,
                                      label: 'Session Title *',
                                      icon: Icons.title,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a session title';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    LayoutBuilder(
                                      builder: (context, constraints) {
                                        final isWide =
                                            constraints.maxWidth > 600;
                                        return isWide
                                            ? Row(
                                              children: [
                                                Expanded(
                                                  child: _buildModernDropdown(
                                                    value: _selectedSubject,
                                                    label: 'Subject *',
                                                    items: _subjects,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _selectedSubject =
                                                            value!;
                                                      });
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: _buildModernDropdown(
                                                    value: _selectedLevel,
                                                    label: 'Level *',
                                                    items: _levels,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _selectedLevel = value!;
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ],
                                            )
                                            : Column(
                                              children: [
                                                _buildModernDropdown(
                                                  value: _selectedSubject,
                                                  label: 'Subject *',
                                                  items: _subjects,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _selectedSubject = value!;
                                                    });
                                                  },
                                                ),
                                                const SizedBox(height: 16),
                                                _buildModernDropdown(
                                                  value: _selectedLevel,
                                                  label: 'Level *',
                                                  items: _levels,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _selectedLevel = value!;
                                                    });
                                                  },
                                                ),
                                              ],
                                            );
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    _buildModernTextField(
                                      controller: _descriptionController,
                                      label: 'Description *',
                                      icon: Icons.description,
                                      maxLines: 3,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a description';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildSection(
                                  context,
                                  title: 'Schedule & Settings',
                                  icon: Icons.schedule,
                                  children: [
                                    _buildModernListTile(
                                      title:
                                          _scheduledDateTime == null
                                              ? 'Select Date & Time *'
                                              : 'Scheduled Date & Time',
                                      subtitle:
                                          _scheduledDateTime == null
                                              ? null
                                              : '${_scheduledDateTime!.day}/${_scheduledDateTime!.month}/${_scheduledDateTime!.year} at ${_scheduledDateTime!.hour}:${_scheduledDateTime!.minute.toString().padLeft(2, '0')}',
                                      icon: Icons.calendar_today,
                                      onTap: _selectDateTime,
                                      hasError: _scheduledDateTime == null,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildModernListTile(
                                      title: 'Duration',
                                      subtitle:
                                          '${_duration.inHours} hour${_duration.inHours != 1 ? 's' : ''} ${_duration.inMinutes.remainder(60)} min',
                                      icon: Icons.access_time,
                                      onTap: _selectDuration,
                                    ),
                                    const SizedBox(height: 16),
                                    LayoutBuilder(
                                      builder: (context, constraints) {
                                        final isWide =
                                            constraints.maxWidth > 600;
                                        return isWide
                                            ? Row(
                                              children: [
                                                Expanded(
                                                  child: _buildModernDropdown(
                                                    value: _selectedPlatform,
                                                    label: 'Platform *',
                                                    items: _platforms,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _selectedPlatform =
                                                            value!;
                                                      });
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: _buildModernTextField(
                                                    controller:
                                                        _maxParticipantsController,
                                                    label: 'Max Participants',
                                                    icon: Icons.group,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return 'Required';
                                                      }
                                                      final number =
                                                          int.tryParse(value);
                                                      if (number == null ||
                                                          number <= 0) {
                                                        return 'Invalid number';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                ),
                                              ],
                                            )
                                            : Column(
                                              children: [
                                                _buildModernDropdown(
                                                  value: _selectedPlatform,
                                                  label: 'Platform *',
                                                  items: _platforms,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _selectedPlatform =
                                                          value!;
                                                    });
                                                  },
                                                ),
                                                const SizedBox(height: 16),
                                                _buildModernTextField(
                                                  controller:
                                                      _maxParticipantsController,
                                                  label: 'Max Participants',
                                                  icon: Icons.group,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Required';
                                                    }
                                                    final number = int.tryParse(
                                                      value,
                                                    );
                                                    if (number == null ||
                                                        number <= 0) {
                                                      return 'Invalid number';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ],
                                            );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildSection(
                                  context,
                                  title: 'Additional Options',
                                  icon: Icons.settings,
                                  children: [
                                    SwitchListTile(
                                      title: Text(
                                        'Recurring Session',
                                        style: TextStyle(
                                          color:
                                              isDark
                                                  ? Colors.white
                                                  : Colors.grey[800],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Repeat this session regularly',
                                        style: TextStyle(
                                          color:
                                              isDark
                                                  ? Colors.grey[400]
                                                  : Colors.grey[600],
                                        ),
                                      ),
                                      value: _isRecurring,
                                      onChanged: (value) {
                                        setState(() {
                                          _isRecurring = value;
                                        });
                                      },
                                      activeColor:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    if (_isRecurring) ...[
                                      const SizedBox(height: 16),
                                      _buildModernDropdown(
                                        value: _recurringPattern,
                                        label: 'Recurring Pattern',
                                        items: _recurringPatterns,
                                        onChanged: (value) {
                                          setState(() {
                                            _recurringPattern = value!;
                                          });
                                        },
                                      ),
                                    ],
                                    const SizedBox(height: 16),
                                    SwitchListTile(
                                      title: Text(
                                        'Paid Session',
                                        style: TextStyle(
                                          color:
                                              isDark
                                                  ? Colors.white
                                                  : Colors.grey[800],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Charge participants for this session',
                                        style: TextStyle(
                                          color:
                                              isDark
                                                  ? Colors.grey[400]
                                                  : Colors.grey[600],
                                        ),
                                      ),
                                      value: _isPaid,
                                      onChanged: (value) {
                                        AlertDialog(
                                          title: Text("No paid services yet"),
                                        );
                                        // setState(() {
                                        //   _isPaid = value;
                                        // });
                                      },
                                      activeColor:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    if (_isPaid) ...[
                                      const SizedBox(height: 16),
                                      _buildModernTextField(
                                        controller: _priceController,
                                        label: 'Price per Session (\$)',
                                        icon: Icons.attach_money,
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter a price';
                                          }
                                          final price = double.tryParse(value);
                                          if (price == null || price < 0) {
                                            return 'Please enter a valid price';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 24),
                                _buildActionButton(
                                  text: 'Set Session',
                                  icon: Icons.event,
                                  onPressed: _submitSession,
                                  isLoading: _isLoading,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.grey[800],
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
          prefixIcon: Icon(
            icon,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildModernDropdown({
    required String value,
    required String label,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
          prefixIcon: Icon(
            Icons.arrow_drop_down,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
        ),
        items:
            items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(
                  item,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.grey[800],
                    fontSize: 16,
                  ),
                ),
              );
            }).toList(),
        onChanged: onChanged,
        dropdownColor: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildModernListTile({
    required String title,
    String? subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool hasError = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              hasError
                  ? Colors.red.withOpacity(0.5)
                  : isDark
                  ? Colors.grey[700]!
                  : Colors.grey[200]!,
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle:
            subtitle != null
                ? Text(
                  subtitle,
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                )
                : null,
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: Icon(icon, size: 20, color: Colors.white),
        label:
            isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _DurationPickerDialog extends StatefulWidget {
  final Duration initialDuration;

  const _DurationPickerDialog({required this.initialDuration});

  @override
  State<_DurationPickerDialog> createState() => _DurationPickerDialogState();
}

class _DurationPickerDialogState extends State<_DurationPickerDialog> {
  late int _hours;
  late int _minutes;

  @override
  void initState() {
    super.initState();
    _hours = widget.initialDuration.inHours;
    _minutes = widget.initialDuration.inMinutes.remainder(60);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AlertDialog(
      backgroundColor: isDark ? Colors.grey[850] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Select Duration'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    'Hours',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                      ),
                    ),
                    child: DropdownButton<int>(
                      value: _hours,
                      items:
                          List.generate(6, (index) => index + 1)
                              .map(
                                (hour) => DropdownMenuItem(
                                  value: hour,
                                  child: Text(
                                    hour.toString(),
                                    style: TextStyle(
                                      color:
                                          isDark
                                              ? Colors.white
                                              : Colors.grey[800],
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          _hours = value!;
                        });
                      },
                      underline: const SizedBox(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      dropdownColor: isDark ? Colors.grey[850] : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    'Minutes',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                      ),
                    ),
                    child: DropdownButton<int>(
                      value: _minutes,
                      items:
                          [0, 15, 30, 45]
                              .map(
                                (minute) => DropdownMenuItem(
                                  value: minute,
                                  child: Text(
                                    minute.toString(),
                                    style: TextStyle(
                                      color:
                                          isDark
                                              ? Colors.white
                                              : Colors.grey[800],
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          _minutes = value!;
                        });
                      },
                      underline: const SizedBox(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      dropdownColor: isDark ? Colors.grey[850] : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, Duration(hours: _hours, minutes: _minutes));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('OK'),
        ),
      ],
    );
  }
}

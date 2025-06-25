import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Controllers for form fields
  final _nameController = TextEditingController(text: 'John Doe');
  final _emailController = TextEditingController(text: 'john.doe@example.com');
  final _phoneController = TextEditingController(text: '+1 (555) 123-4567');
  final _locationController = TextEditingController(text: 'San Francisco, CA');
  final _bioController = TextEditingController(
    text:
        'Computer Science major at University of California, specializing in artificial intelligence and data structures.',
  );

  // Password controllers
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Edit mode states
  bool _isEditingAccount = false;
  bool _isEditingSecurity = false;

  // Notification preferences
  Map<String, bool> notificationSettings = {
    'sessionReminders': true,
    'newMessages': true,
    'sessionRequests': true,
    'achievements': true,
    'newsletter': false,
    'promotions': false,
  };

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
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            slivers: [
              // Account Information Section
              SliverToBoxAdapter(
                child: _buildSection(
                  title: 'Account Information',
                  icon: Icons.person_outline,
                  child: Column(
                    children: [
                      _buildModernTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        icon: Icons.person,
                        enabled: _isEditingAccount,
                      ),
                      const SizedBox(height: 16),
                      _buildModernTextField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        enabled: _isEditingAccount,
                      ),
                      const SizedBox(height: 16),
                      _buildModernTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        enabled: _isEditingAccount,
                      ),
                      const SizedBox(height: 16),
                      _buildModernTextField(
                        controller: _locationController,
                        label: 'Location',
                        icon: Icons.location_on_outlined,
                        enabled: _isEditingAccount,
                      ),
                      const SizedBox(height: 16),
                      _buildModernTextField(
                        controller: _bioController,
                        label: 'Bio',
                        icon: Icons.info_outline,
                        maxLines: 4,
                        enabled: _isEditingAccount,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          if (!_isEditingAccount) ...[
                            Expanded(
                              child: _buildActionButton(
                                text: 'Edit Information',
                                icon: Icons.edit_outlined,
                                onPressed:
                                    () => setState(
                                      () => _isEditingAccount = true,
                                    ),
                                isPrimary: false,
                              ),
                            ),
                          ] else ...[
                            Expanded(
                              child: _buildActionButton(
                                text: 'Cancel',
                                icon: Icons.close,
                                onPressed: () => _cancelAccountEdit(),
                                isPrimary: false,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildActionButton(
                                text: 'Save Changes',
                                icon: Icons.save_outlined,
                                onPressed: () => _saveAccountChanges(context),
                                isPrimary: true,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Security Section
              SliverToBoxAdapter(
                child: _buildSection(
                  title: 'Security',
                  icon: Icons.security_outlined,
                  child: Column(
                    children: [
                      if (!_isEditingSecurity) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.lock_outline,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Password',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '••••••••••••',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[800],
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Last updated: 2 months ago',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildActionButton(
                          text: 'Change Password',
                          icon: Icons.security,
                          onPressed:
                              () => setState(() => _isEditingSecurity = true),
                          isPrimary: false,
                        ),
                      ] else ...[
                        _buildModernTextField(
                          controller: _currentPasswordController,
                          label: 'Current Password',
                          icon: Icons.lock_outline,
                          obscureText: true,
                          enabled: true,
                        ),
                        const SizedBox(height: 16),
                        _buildModernTextField(
                          controller: _newPasswordController,
                          label: 'New Password',
                          icon: Icons.lock_reset,
                          obscureText: true,
                          enabled: true,
                        ),
                        const SizedBox(height: 16),
                        _buildModernTextField(
                          controller: _confirmPasswordController,
                          label: 'Confirm New Password',
                          icon: Icons.lock_outline,
                          obscureText: true,
                          enabled: true,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: _buildActionButton(
                                text: 'Cancel',
                                icon: Icons.close,
                                onPressed: () => _cancelSecurityEdit(),
                                isPrimary: false,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildActionButton(
                                text: 'Update Password',
                                icon: Icons.security,
                                onPressed: () => _updatePassword(context),
                                isPrimary: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Notification Preferences Section
              SliverToBoxAdapter(
                child: _buildSection(
                  title: 'Notification Preferences',
                  icon: Icons.notifications_outlined,
                  child: Column(
                    children: [
                      _buildNotificationTile(
                        'Session Reminders',
                        'Get notified before upcoming sessions',
                        Icons.schedule,
                        'sessionReminders',
                      ),
                      _buildNotificationTile(
                        'New Messages',
                        'Receive notifications for new messages',
                        Icons.message_outlined,
                        'newMessages',
                      ),
                      _buildNotificationTile(
                        'Session Requests',
                        'Get notified when students request sessions',
                        Icons.person_add_outlined,
                        'sessionRequests',
                      ),
                      _buildNotificationTile(
                        'Achievements',
                        'Receive notifications when you earn badges',
                        Icons.emoji_events_outlined,
                        'achievements',
                      ),
                      _buildNotificationTile(
                        'Newsletter',
                        'Receive weekly updates and tips',
                        Icons.newspaper_outlined,
                        'newsletter',
                      ),
                      _buildNotificationTile(
                        'Promotional Offers',
                        'Receive special offers and discounts',
                        Icons.local_offer_outlined,
                        'promotions',
                      ),
                      const SizedBox(height: 24),
                      _buildActionButton(
                        text: 'Save Preferences',
                        icon: Icons.check_circle_outline,
                        onPressed: () => _showPreferencesSaved(context),
                        isPrimary: true,
                      ),
                    ],
                  ),
                ),
              ),

              // Account Actions Section
              SliverToBoxAdapter(
                child: _buildSection(
                  title: 'Account Actions',
                  icon: Icons.settings_outlined,
                  child: Column(
                    children: [
                      _buildActionTile(
                        'Export My Data',
                        'Download a copy of your account data',
                        Icons.download_outlined,
                        Colors.blue,
                        () => _showExportDialog(context),
                      ),
                      const SizedBox(height: 12),
                      _buildActionTile(
                        'Pause Notifications',
                        'Temporarily disable all notifications',
                        Icons.pause_circle_outline,
                        Colors.orange,
                        () => _showPauseDialog(context),
                      ),
                      const SizedBox(height: 12),
                      _buildActionTile(
                        'Deactivate Account',
                        'Temporarily disable your account',
                        Icons.person_off_outlined,
                        Colors.red,
                        () => _showDeactivateDialog(context),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom spacing
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
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
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.indigo.shade600, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    TextEditingController? controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? Colors.grey[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: enabled ? Colors.grey[200]! : Colors.grey[300]!,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        maxLines: maxLines,
        keyboardType: keyboardType,
        enabled: enabled,
        style: TextStyle(
          color: enabled ? Colors.grey[800] : Colors.grey[600],
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: enabled ? Colors.grey[600] : Colors.grey[500],
          ),
          prefixIcon: Icon(
            icon,
            color: enabled ? Colors.grey[600] : Colors.grey[500],
          ),
          suffixIcon:
              !enabled
                  ? Icon(Icons.lock_outline, color: Colors.grey[400], size: 18)
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isPrimary ? Colors.indigo.shade600 : Colors.grey[100],
          foregroundColor: isPrimary ? Colors.white : Colors.grey[800],
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildNotificationTile(
    String title,
    String description,
    IconData icon,
    String key,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.indigo.shade600, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: notificationSettings[key] ?? false,
              onChanged: (value) {
                setState(() {
                  notificationSettings[key] = value;
                });
              },
              activeColor: Colors.indigo.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color:
                              color == Colors.red
                                  ? Colors.red
                                  : Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Edit mode handling methods
  void _cancelAccountEdit() {
    setState(() {
      _isEditingAccount = false;
      // Reset controllers to original values
      _nameController.text = 'John Doe';
      _emailController.text = 'john.doe@example.com';
      _phoneController.text = '+1 (555) 123-4567';
      _locationController.text = 'San Francisco, CA';
      _bioController.text =
          'Computer Science major at University of California, specializing in artificial intelligence and data structures.';
    });
  }

  void _saveAccountChanges(BuildContext context) {
    setState(() {
      _isEditingAccount = false;
    });
    _showSuccessSnackBar(context, 'Account information saved successfully!');
  }

  void _cancelSecurityEdit() {
    setState(() {
      _isEditingSecurity = false;
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    });
  }

  void _updatePassword(BuildContext context) {
    // Basic validation
    if (_currentPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('Please fill in all password fields'),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('New passwords do not match'),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    // If validation passes
    setState(() {
      _isEditingSecurity = false;
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    });
    _showSuccessSnackBar(context, 'Password updated successfully!');
  }

  // Existing dialog methods
  void _showPreferencesSaved(BuildContext context) {
    _showSuccessSnackBar(context, 'Notification preferences saved!');
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.download, color: Colors.blue),
                SizedBox(width: 8),
                Text('Export Data'),
              ],
            ),
            content: const Text(
              'Your data export will be sent to your email address within 24 hours.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showSuccessSnackBar(
                    context,
                    'Data export requested successfully!',
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Export'),
              ),
            ],
          ),
    );
  }

  void _showPauseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.pause_circle, color: Colors.orange),
                SizedBox(width: 8),
                Text('Pause Notifications'),
              ],
            ),
            content: const Text(
              'How long would you like to pause notifications?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showSuccessSnackBar(
                    context,
                    'Notifications paused for 24 hours',
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600,
                  foregroundColor: Colors.white,
                ),
                child: const Text('24 Hours'),
              ),
            ],
          ),
    );
  }

  void _showDeactivateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.warning, color: Colors.red),
                SizedBox(width: 8),
                Text('Deactivate Account'),
              ],
            ),
            content: const Text(
              'Are you sure you want to deactivate your account? This action can be reversed later.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showSuccessSnackBar(
                    context,
                    'Account deactivation process started',
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Deactivate'),
              ),
            ],
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
}

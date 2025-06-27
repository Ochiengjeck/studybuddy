import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../utils/modelsAndRepsositories/models_and_repositories.dart';
import '../../../utils/providers/providers.dart';

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

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  bool _isEditingProfile = false;
  bool _isChangingPassword = false;
  String? _errorMessage;

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

    final user = context.read<AppProvider>().currentUser;
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    _loadUserData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final appProvider = context.read<AppProvider>();
    final userId = appProvider.currentUser?.id;
    if (userId != null) {
      try {
        final response = await UserRepository().getUser(userId);
        if (response.success && response.data != null) {
          appProvider.setCurrentUser(response.data);
          setState(() {
            _firstNameController.text = response.data!.firstName ?? '';
            _lastNameController.text = response.data!.lastName ?? '';
            _phoneController.text = response.data!.phone ?? '';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final appProvider = context.read<AppProvider>();
      final userId = appProvider.currentUser?.id;
      if (userId != null) {
        try {
          final updates = {
            'first_name': _firstNameController.text.trim(),
            'last_name': _lastNameController.text.trim(),
            'phone': _phoneController.text.trim(),
          };
          final response = await UserRepository().updateUser(userId, updates);
          if (response.success) {
            final updatedUser = appProvider.currentUser!.copyWith(
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              phone: _phoneController.text.trim(),
            );
            appProvider.setCurrentUser(updatedUser);
            setState(() {
              _isEditingProfile = false;
              _errorMessage = null;
            });
            _showSuccessSnackBar('Profile updated successfully');
          }
        } catch (e) {
          setState(() {
            _errorMessage = e.toString();
          });
        }
      }
    }
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await UserRepository().updatePassword(
          _currentPasswordController.text,
          _newPasswordController.text,
        );
        if (response.success) {
          setState(() {
            _isChangingPassword = false;
            _currentPasswordController.clear();
            _newPasswordController.clear();
            _confirmPasswordController.clear();
            _errorMessage = null;
          });
          _showSuccessSnackBar('Password changed successfully');
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _pauseNotifications(Duration duration) async {
    final userId = context.read<AppProvider>().currentUser?.id;
    if (userId != null) {
      try {
        final response = await UserRepository().pauseNotifications(
          userId,
          duration,
        );
        if (response.success) {
          _showSuccessSnackBar(
            'Notifications paused for ${duration.inHours} hours',
          );
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _deactivateAccount() async {
    final userId = context.read<AppProvider>().currentUser?.id;
    if (userId != null) {
      try {
        final response = await UserRepository().deactivateAccount(userId);
        if (response.success) {
          context.read<AuthProvider>().logout();
          _showSuccessSnackBar('Account deactivated successfully');
          Navigator.of(context).pop();
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _requestDataExport() async {
    final userId = context.read<AppProvider>().currentUser?.id;
    if (userId != null) {
      try {
        final response = await UserRepository().requestDataExport(userId);
        if (response.success) {
          _showSuccessSnackBar('Data export request sent');
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final user = appProvider.currentUser;

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
                        controller: _firstNameController,
                        label: 'First Name',
                        icon: Icons.person,
                        enabled: _isEditingProfile,
                      ),
                      const SizedBox(height: 16),
                      _buildModernTextField(
                        controller: _lastNameController,
                        label: 'Last Name',
                        icon: Icons.person_outline,
                        enabled: _isEditingProfile,
                      ),
                      const SizedBox(height: 16),
                      _buildModernTextField(
                        label: 'Email',
                        icon: Icons.email_outlined,
                        enabled: false,
                        initialValue: user?.email ?? '',
                      ),
                      const SizedBox(height: 16),
                      _buildModernTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        enabled: _isEditingProfile,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          if (!_isEditingProfile) ...[
                            Expanded(
                              child: _buildActionButton(
                                text: 'Edit Information',
                                icon: Icons.edit_outlined,
                                onPressed:
                                    () => setState(
                                      () => _isEditingProfile = true,
                                    ),
                                isPrimary: false,
                              ),
                            ),
                          ] else ...[
                            Expanded(
                              child: _buildActionButton(
                                text: 'Cancel',
                                icon: Icons.close,
                                onPressed: () {
                                  setState(() {
                                    _isEditingProfile = false;
                                    _firstNameController.text =
                                        user?.firstName ?? '';
                                    _lastNameController.text =
                                        user?.lastName ?? '';
                                    _phoneController.text = user?.phone ?? '';
                                  });
                                },
                                isPrimary: false,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildActionButton(
                                text: 'Save Changes',
                                icon: Icons.save_outlined,
                                onPressed: _updateProfile,
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
                      if (!_isChangingPassword) ...[
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
                                'Last updated: ${DateFormat('MMMM d, y').format(DateTime.now())}',
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
                              () => setState(() => _isChangingPassword = true),
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
                                onPressed: () {
                                  setState(() {
                                    _isChangingPassword = false;
                                    _currentPasswordController.clear();
                                    _newPasswordController.clear();
                                    _confirmPasswordController.clear();
                                  });
                                },
                                isPrimary: false,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildActionButton(
                                text: 'Update Password',
                                icon: Icons.security,
                                onPressed: _changePassword,
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
                        onPressed:
                            () => _showSuccessSnackBar(
                              'Notification preferences saved',
                            ),
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
                        _requestDataExport,
                      ),
                      const SizedBox(height: 12),
                      _buildActionTile(
                        'Pause Notifications',
                        'Temporarily disable all notifications',
                        Icons.pause_circle_outline,
                        Colors.orange,
                        () => _pauseNotifications(const Duration(hours: 24)),
                      ),
                      const SizedBox(height: 12),
                      _buildActionTile(
                        'Deactivate Account',
                        'Temporarily disable your account',
                        Icons.person_off_outlined,
                        Colors.red,
                        _deactivateAccount,
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
    String? initialValue,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? Colors.grey[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: enabled ? Colors.grey[200]! : Colors.grey[300]!,
        ),
      ),
      child:
          initialValue != null
              ? Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  initialValue,
                  style: TextStyle(
                    color: enabled ? Colors.grey[800] : Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              )
              : TextField(
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
                          ? Icon(
                            Icons.lock_outline,
                            color: Colors.grey[400],
                            size: 18,
                          )
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
}

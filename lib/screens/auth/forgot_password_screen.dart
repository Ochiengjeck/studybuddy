import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'log_in.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  bool _isLoading = false;
  bool _isOtpSent = false;
  bool _isOtpVerified = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int _resendTimer = 0;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? size.width * 0.2 : 24.0,
              vertical: 24.0,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    size.height - MediaQuery.of(context).padding.top - 48,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: size.height * 0.05),
                    _buildHeaderSection(theme),
                    SizedBox(height: size.height * 0.05),
                    if (!_isOtpSent)
                      _buildEmailForm(theme)
                    else if (!_isOtpVerified)
                      _buildOtpForm(theme)
                    else
                      _buildPasswordResetForm(theme),
                    const Spacer(),
                    _buildBackToLoginLink(theme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(ThemeData theme) {
    String title;
    String subtitle;
    IconData icon;

    if (!_isOtpSent) {
      title = 'Forgot Password?';
      subtitle = 'Enter your email to receive an OTP';
      icon = Icons.lock_reset_rounded;
    } else if (!_isOtpVerified) {
      title = 'Verify OTP';
      subtitle = 'Enter the 6-digit code sent to ${_emailController.text}';
      icon = Icons.verified_user_rounded;
    } else {
      title = 'Reset Password';
      subtitle = 'Create your new password';
      icon = Icons.security_rounded;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, size: 48, color: theme.colorScheme.primary),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildEmailField(theme),
          const SizedBox(height: 32),
          _buildSendOtpButton(theme),
        ],
      ),
    );
  }

  Widget _buildEmailField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Enter your email',
            prefixIcon: Icon(
              Icons.email_outlined,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(
              0.3,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.colorScheme.error),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSendOtpButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            _isLoading
                ? null
                : () {
                  if (_formKey.currentState!.validate()) {
                    _sendOtp();
                  }
                },
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child:
            _isLoading
                ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: theme.colorScheme.onPrimary,
                  ),
                )
                : Text(
                  'Send OTP',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
      ),
    );
  }

  Widget _buildOtpForm(ThemeData theme) {
    return Column(
      children: [
        _buildOtpFields(theme),
        const SizedBox(height: 24),
        _buildResendOtpSection(theme),
        const SizedBox(height: 32),
        _buildVerifyOtpButton(theme),
      ],
    );
  }

  Widget _buildOtpFields(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter OTP',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 50,
              height: 60,
              child: TextFormField(
                controller: _otpControllers[index],
                focusNode: _otpFocusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  if (value.isNotEmpty && index < 5) {
                    _otpFocusNodes[index + 1].requestFocus();
                  } else if (value.isEmpty && index > 0) {
                    _otpFocusNodes[index - 1].requestFocus();
                  }
                },
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest
                      .withOpacity(0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildResendOtpSection(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Didn't receive the code? ",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        if (_resendTimer > 0)
          Text(
            'Resend in ${_resendTimer}s',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          )
        else
          TextButton(
            onPressed: _sendOtp,
            child: Text(
              'Resend',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVerifyOtpButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _verifyOtp,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child:
            _isLoading
                ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: theme.colorScheme.onPrimary,
                  ),
                )
                : Text(
                  'Verify OTP',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
      ),
    );
  }

  Widget _buildPasswordResetForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildPasswordField(theme),
          const SizedBox(height: 16),
          _buildConfirmPasswordField(theme),
          const SizedBox(height: 32),
          _buildResetPasswordButton(theme),
        ],
      ),
    );
  }

  Widget _buildPasswordField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'New Password',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a password';
            }
            if (value.length < 8) {
              return 'Password must be at least 8 characters';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Enter new password',
            prefixIcon: Icon(
              Icons.lock_outline,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              onPressed:
                  () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(
              0.3,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.colorScheme.error),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confirm Password',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm your password';
            }
            if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Confirm new password',
            prefixIcon: Icon(
              Icons.lock_outline,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              onPressed:
                  () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  ),
            ),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(
              0.3,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.colorScheme.error),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResetPasswordButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            _isLoading
                ? null
                : () {
                  if (_formKey.currentState!.validate()) {
                    _resetPassword();
                  }
                },
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child:
            _isLoading
                ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: theme.colorScheme.onPrimary,
                  ),
                )
                : Text(
                  'Reset Password',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
      ),
    );
  }

  Widget _buildBackToLoginLink(ThemeData theme) {
    return Center(
      child: TextButton(
        onPressed:
            () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            ),
        child: Text(
          'Back to Sign In',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _sendOtp() async {
    setState(() => _isLoading = true);
    try {
      // Simulate API call to send OTP
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _isOtpSent = true;
          _isLoading = false;
        });

        _startResendTimer();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP sent to ${_emailController.text}'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send OTP: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpControllers.map((controller) => controller.text).join();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter the complete 6-digit OTP'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Simulate API call to verify OTP
      await Future.delayed(const Duration(seconds: 2));

      // For demo purposes, accept any 6-digit OTP
      // In real implementation, verify with your backend
      if (mounted) {
        setState(() {
          _isOtpVerified = true;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('OTP verified successfully'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid OTP: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _resetPassword() async {
    setState(() => _isLoading = true);
    try {
      // Simulate API call to reset password
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Password reset successfully'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        // Navigate back to login screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reset password: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  void _startResendTimer() {
    setState(() => _resendTimer = 60);

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() => _resendTimer--);
        return _resendTimer > 0;
      }
      return false;
    });
  }
}

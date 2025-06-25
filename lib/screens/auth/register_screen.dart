import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/screens/pages/index.dart';
import '../../utils/modelsAndRepsositories/models_and_repositories.dart';
import '../../utils/providers/providers.dart';
import 'log_in.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegistration(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    String fullName = nameController.text.trim();
    List<String> nameParts = fullName.split(' ');

    // Initialize variables for firstName and lastName
    String firstName = nameParts.isNotEmpty ? nameParts[0] : '';
    String lastName =
        nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    setState(() => _isLoading = true);

    try {
      final response = await authProvider.register(
        RegisterRequest(
          email: emailController.text,
          password: passwordController.text,
          confirmPassword: confirmPasswordController.text,
          firstName: firstName,
          lastName: lastName,
          phone: '', // You can add a phone field if needed
        ),
      );

      if (response.success && response.data != null) {
        // Save the auth token and user data
        appProvider.setAuthToken(response.data!.authToken ?? '');
        appProvider.setCurrentUser(response.data!);

        // Navigating to home screen after successful registration
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Index()),
        );
      }
    } on ApiError catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
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
                    _buildWelcomeSection(theme),
                    SizedBox(height: size.height * 0.05),
                    _buildRegisterForm(theme),
                    const Spacer(),
                    _buildLoginLink(theme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Image.asset("assets/logo.png", height: 100, fit: BoxFit.cover),
          // Icon(
          //   Icons.school_rounded,
          //   size: 48,
          //   color: theme.colorScheme.primary,
          // ),
        ),
        const SizedBox(height: 24),
        Text(
          'Create Account',
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Join us to start your learning journey',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildNameField(theme),
          const SizedBox(height: 20),
          _buildEmailField(theme),
          const SizedBox(height: 20),
          _buildPasswordField(theme),
          const SizedBox(height: 20),
          _buildConfirmPasswordField(theme),
          const SizedBox(height: 32),
          _buildSignUpButton(theme, context),
          const SizedBox(height: 24),
          _buildDivider(theme),
          const SizedBox(height: 24),
          _buildGoogleSignInButton(theme),
        ],
      ),
    );
  }

  Widget _buildNameField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Full Name',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: nameController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your name';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Enter your full name',
            prefixIcon: Icon(
              Icons.person_outlined,
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
          controller: emailController,
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

  Widget _buildPasswordField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: passwordController,
          obscureText: _obscurePassword,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Enter your password',
            prefixIcon: Icon(
              Icons.lock_outlined,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
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
          controller: confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm your password';
            }
            if (value != passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Confirm your password',
            prefixIcon: Icon(
              Icons.lock_outlined,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
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

  Widget _buildSignUpButton(ThemeData theme, BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            authProvider.isLoading ? null : () => _handleRegistration(context),
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
            authProvider.isLoading
                ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: theme.colorScheme.onPrimary,
                  ),
                )
                : Text(
                  'Sign Up',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
      ),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Divider(color: theme.colorScheme.outline.withOpacity(0.2)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(color: theme.colorScheme.outline.withOpacity(0.2)),
        ),
      ],
    );
  }

  Widget _buildGoogleSignInButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.g_mobiledata, size: 24),
        label: Text(
          'Continue with Google',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
        ),
        onPressed: () {},
      ),
    );
  }

  Widget _buildLoginLink(ThemeData theme) {
    return Center(
      child: TextButton(
        onPressed:
            () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            ),
        child: RichText(
          text: TextSpan(
            text: 'Already have an account? ',
            style: theme.textTheme.bodyMedium,
            children: [
              TextSpan(
                text: 'Sign In',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _register() async {
    setState(() => _isLoading = true);
    try {
      await Future.delayed(const Duration(seconds: 3));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Index()),
      );
      // TODO: Implement actual registration logic
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

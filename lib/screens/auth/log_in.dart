import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/utils/modelsAndRepsositories/models_and_repositories.dart';
import '../../utils/providers/providers.dart';
import '../pages/index.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    try {
      final response = await authProvider.login(
        LoginRequest(
          email: _emailController.text,
          password: _passwordController.text,
        ),
      );

      if (response.success && response.data != null) {
        // appProvider.setAuthToken(response.data!.token);
        appProvider.setCurrentUser(response.data!);

        // Navigating to home screen after successful login
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
                    _buildHeaderSection(theme),
                    SizedBox(height: size.height * 0.05),
                    _buildLoginForm(theme, context),
                    const Spacer(),
                    _buildSignUpLink(theme),
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
        ),
        const SizedBox(height: 24),
        Text(
          'Welcome Back',
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to continue your learning journey',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(ThemeData theme, BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildEmailField(theme),
          const SizedBox(height: 20),
          _buildPasswordField(theme),
          const SizedBox(height: 16),
          _buildRememberMeRow(theme),
          const SizedBox(height: 32),
          _buildSignInButton(theme, context),
          const SizedBox(height: 24),
          _buildDivider(theme),
          const SizedBox(height: 24),
          _buildGoogleSignInButton(theme),
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
          validator: _validateEmail,
          decoration: _inputDecoration(
            theme,
            hintText: 'Enter your email',
            prefixIcon: Icons.email_outlined,
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
          controller: _passwordController,
          obscureText: _obscurePassword,
          validator: _validatePassword,
          decoration: _inputDecoration(
            theme,
            hintText: 'Enter your password',
            prefixIcon: Icons.lock_outlined,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed:
                  () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRememberMeRow(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged:
                  (value) => setState(() => _rememberMe = value ?? false),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Remember me',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ],
        ),
        TextButton(
          onPressed:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ForgotPasswordScreen(),
                ),
              ),
          child: Text(
            'Forgot Password?',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInButton(ThemeData theme, BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: authProvider.isLoading ? null : () => _handleLogin(context),
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
                  'Sign In',
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

  Widget _buildSignUpLink(ThemeData theme) {
    return Center(
      child: TextButton(
        onPressed:
            () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const RegisterScreen()),
            ),
        child: RichText(
          text: TextSpan(
            text: "Don't have an account? ",
            style: theme.textTheme.bodyMedium,
            children: [
              TextSpan(
                text: 'Sign Up',
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

  InputDecoration _inputDecoration(
    ThemeData theme, {
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(
        prefixIcon,
        color: theme.colorScheme.onSurface.withOpacity(0.6),
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.colorScheme.error),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}

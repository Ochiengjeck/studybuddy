import 'package:flutter/material.dart';

import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final authProvider = Provider.of<AuthProvider>(context);
    // final theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  // color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      'Create Account',
                      // style: theme.textTheme.headlineLarge?.copyWith(
                      //   color: Colors.white,
                      //   fontWeight: FontWeight.bold,
                      // ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Join StudyBuddy today',
                      // style: theme.textTheme.bodyMedium?.copyWith(
                      //   color: Colors.white.withOpacity(0.8),
                      // ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Form(
                child: Column(
                  children: [
                    CustomTextField(
                      label: 'Full Name',
                      hintText: 'Enter your full name',
                      // onChanged: (value) => authProvider.name = value,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'Email',
                      hintText: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                      // onChanged: (value) => authProvider.email = value,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'Password',
                      hintText: 'Create a password',
                      obscureText: true,
                      // onChanged: (value) => authProvider.password = value,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'Confirm Password',
                      hintText: 'Confirm your password',
                      obscureText: true,
                      // onChanged:
                      //     (value) => authProvider.confirmPassword = value,
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      text: 'Create Account',
                      onPressed: () {
                        // authProvider.register();
                        // Navigate to onboarding after successful registration
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      'OR',
                      // style: theme.textTheme.bodyMedium
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Google',
                      icon: Icons.g_mobiledata,
                      // backgroundColor: Colors.grey[200],
                      // textColor: Colors.black,
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomButton(
                      text: 'Microsoft',
                      icon: Icons.mail_outline,
                      // backgroundColor: Colors.grey[200],
                      // textColor: Colors.black,
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {},
                child: RichText(
                  text: TextSpan(
                    text: "Already have an account? ",
                    // style: theme.textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: 'Login',
                        style: TextStyle(
                          // color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../widgets/custom_button.dart';
import 'subject_selection_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String? selectedRole;

    return Scaffold(
      appBar: AppBar(
        title: const Text('StudyBuddy'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Select Your Role',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Choose how you want to use StudyBuddy',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 0.9,
                children: [
                  _buildRoleCard(
                    context,
                    icon: Icons.school,
                    title: 'Student',
                    description:
                        'Find tutors, book sessions, and improve your skills',
                    isSelected: selectedRole == 'student',
                    onTap: () => selectedRole = 'student',
                  ),
                  _buildRoleCard(
                    context,
                    icon: Icons.people,
                    title: 'Tutor',
                    description:
                        'Help others learn, share your knowledge, and earn points',
                    isSelected: selectedRole == 'tutor',
                    onTap: () => selectedRole = 'tutor',
                  ),
                  _buildRoleCard(
                    context,
                    icon: Icons.badge,
                    title: 'Instructor',
                    description:
                        'Supervise tutoring sessions and track student progress',
                    isSelected: selectedRole == 'instructor',
                    onTap: () => selectedRole = 'instructor',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Back',
                    // variant: ButtonVariant.outline,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomButton(
                    text: 'Continue',
                    onPressed: () {
                      // selectedRole == null
                      //     ? print("No subject selected")
                      //     : () {
                      //       print(selectedRole);
                      //       Navigator.push(
                      //         context,
                      //         MaterialPageRoute(
                      //           builder:
                      //               (context) => const SubjectSelectionScreen(),
                      //         ),
                      //       );
                      //     };
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SubjectSelectionScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color:
              isSelected
                  ? theme.colorScheme.primary.withOpacity(0.1)
                  : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            width: 2,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            CustomTextField(
              label: 'Full Name',
              hintText: 'Enter your full name',
              controller: TextEditingController(text: 'John Doe'),
            ),
            CustomTextField(
              label: 'Email',
              hintText: 'Enter your email',
              controller: TextEditingController(text: 'john.doe@example.com'),
            ),
            CustomTextField(
              label: 'Phone Number',
              hintText: 'Enter your phone number',
              controller: TextEditingController(text: '(555) 123-4567'),
            ),
            CustomTextField(
              label: 'Location',
              hintText: 'Enter your location',
              controller: TextEditingController(text: 'San Francisco, CA'),
            ),
            CustomTextField(
              label: 'Bio',
              hintText: 'Tell us about yourself',
              controller: TextEditingController(
                text:
                    'Computer Science major at University of California, specializing in artificial intelligence and data structures.',
              ),
              maxLines: 4,
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: CustomButton(
                text: 'Save Changes',
                onPressed: () {},
                isPrimary: true,
              ),
            ),
            Divider(height: 40),
            Text(
              'Security',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            CustomTextField(
              label: 'Current Password',
              hintText: 'Enter current password',
              obscureText: true,
            ),
            CustomTextField(
              label: 'New Password',
              hintText: 'Enter new password',
              obscureText: true,
            ),
            CustomTextField(
              label: 'Confirm New Password',
              hintText: 'Confirm new password',
              obscureText: true,
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: CustomButton(
                text: 'Update Password',
                onPressed: () {},
                isPrimary: true,
              ),
            ),
            Divider(height: 40),
            Text(
              'Notification Preferences',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildNotificationOption(
              title: 'Session Reminders',
              description: 'Get notified before upcoming sessions',
              value: true,
            ),
            _buildNotificationOption(
              title: 'New Messages',
              description: 'Receive notifications for new messages',
              value: true,
            ),
            _buildNotificationOption(
              title: 'Session Requests',
              description: 'Get notified when students request sessions',
              value: true,
            ),
            _buildNotificationOption(
              title: 'Achievements',
              description: 'Receive notifications when you earn badges',
              value: true,
            ),
            _buildNotificationOption(
              title: 'Newsletter',
              description: 'Receive weekly updates and tips',
              value: false,
            ),
            _buildNotificationOption(
              title: 'Promotional Offers',
              description: 'Receive special offers and discounts',
              value: false,
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: CustomButton(
                text: 'Save Preferences',
                onPressed: () {},
                isPrimary: true,
              ),
            ),
            Divider(height: 40),
            Text(
              'Account Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.import_export),
              title: Text('Export My Data'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.notifications_off),
              title: Text('Pause Notifications'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.person_off, color: Colors.red),
              title: Text(
                'Deactivate Account',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationOption({
    required String title,
    required String description,
    required bool value,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(description, style: TextStyle(fontSize: 12)),
      value: value,
      onChanged: (bool newValue) {
        // Handle toggle
      },
    );
  }
}

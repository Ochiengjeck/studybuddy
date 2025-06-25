import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Frequently Asked Questions'),
          _buildFAQItem(
            question: 'How do I schedule a tutoring session?',
            answer:
                'Go to the Find Tutors page, select a tutor, and choose an available time slot.',
          ),
          _buildFAQItem(
            question: 'How does the points system work?',
            answer:
                'You earn points by completing sessions, helping others, and achieving milestones.',
          ),
          _buildFAQItem(
            question: 'Can I cancel a session?',
            answer:
                'Yes, you can cancel up to 24 hours before the session without penalty.',
          ),
          Divider(height: 40),
          _buildSectionTitle('Contact Support'),
          _buildContactOption(
            icon: Icons.email,
            title: 'Email Us',
            subtitle: 'support@studybuddy.com',
            onTap: () {},
          ),
          _buildContactOption(
            icon: Icons.phone,
            title: 'Call Us',
            subtitle: '+1 (555) 123-4567',
            onTap: () {},
          ),
          _buildContactOption(
            icon: Icons.chat,
            title: 'Live Chat',
            subtitle: 'Available 9AM-5PM EST',
            onTap: () {},
          ),
          Divider(height: 40),
          _buildSectionTitle('App Information'),
          ListTile(title: Text('Version'), trailing: Text('1.0.0')),
          ListTile(
            title: Text('Terms of Service'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            title: Text('Privacy Policy'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildFAQItem({required String question, required String answer}) {
    return ExpansionTile(
      title: Text(question, style: TextStyle(fontWeight: FontWeight.w500)),
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(answer),
        ),
      ],
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

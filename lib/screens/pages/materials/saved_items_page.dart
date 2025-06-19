import 'package:flutter/material.dart';

class SavedItemsPage extends StatelessWidget {
  const SavedItemsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(text: 'Sessions'),
              Tab(text: 'Materials'),
              Tab(text: 'Tests'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildSavedSessions(),
            _buildSavedMaterials(),
            _buildSavedTests(),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedSessions() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildSavedItem(
          icon: Icons.video_library,
          title: 'Calculus Review Session',
          subtitle: 'Saved Oct 12, 2023',
          type: 'Session',
        ),
        _buildSavedItem(
          icon: Icons.video_library,
          title: 'Python Data Structures',
          subtitle: 'Saved Oct 5, 2023',
          type: 'Session',
        ),
      ],
    );
  }

  Widget _buildSavedMaterials() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildSavedItem(
          icon: Icons.article,
          title: 'Organic Chemistry Notes',
          subtitle: 'PDF • 2.4MB',
          type: 'Material',
        ),
        _buildSavedItem(
          icon: Icons.article,
          title: 'Linear Algebra Cheat Sheet',
          subtitle: 'PDF • 1.1MB',
          type: 'Material',
        ),
      ],
    );
  }

  Widget _buildSavedTests() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildSavedItem(
          icon: Icons.quiz,
          title: 'Physics Practice Test',
          subtitle: '20 questions • 25 mins',
          type: 'Test',
        ),
        _buildSavedItem(
          icon: Icons.quiz,
          title: 'English Literature Quiz',
          subtitle: '15 questions • 20 mins',
          type: 'Test',
        ),
      ],
    );
  }

  Widget _buildSavedItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String type,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: PopupMenuButton(
          icon: Icon(Icons.more_vert),
          itemBuilder:
              (context) => [
                PopupMenuItem(child: Text('Remove from saved')),
                PopupMenuItem(child: Text('Share')),
              ],
        ),
      ),
    );
  }
}

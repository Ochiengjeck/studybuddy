import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/modelsAndRepsositories/models_and_repositories.dart';
import '../../../utils/providers/providers.dart';

class SavedItemsPage extends StatefulWidget {
  const SavedItemsPage({super.key});

  @override
  _SavedItemsPageState createState() => _SavedItemsPageState();
}

class _SavedItemsPageState extends State<SavedItemsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        Provider.of<SavedItemsProvider>(
          context,
          listen: false,
        ).loadSavedItems(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Sessions'),
              Tab(text: 'Materials'),
              Tab(text: 'Tests'),
            ],
          ),
        ),
        body: Consumer<SavedItemsProvider>(
          builder: (context, provider, child) {
            if (FirebaseAuth.instance.currentUser == null) {
              return const Center(
                child: Text('Please log in to view saved items.'),
              );
            }

            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null) {
              return Center(child: Text('Error: ${provider.error}'));
            }

            final sessions = provider.savedSessions ?? [];
            final materials = provider.savedMaterials ?? [];
            final tests = provider.savedTests ?? [];

            return TabBarView(
              children: [
                _buildSavedSessions(sessions),
                _buildSavedMaterials(materials),
                _buildSavedTests(tests),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSavedSessions(List<SavedItem> sessions) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children:
          sessions.isEmpty
              ? [const Center(child: Text('No saved sessions'))]
              : sessions.map((item) => _buildSavedItem(item)).toList(),
    );
  }

  Widget _buildSavedMaterials(List<SavedItem> materials) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children:
          materials.isEmpty
              ? [const Center(child: Text('No saved materials'))]
              : materials.map((item) => _buildSavedItem(item)).toList(),
    );
  }

  Widget _buildSavedTests(List<SavedItem> tests) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children:
          tests.isEmpty
              ? [const Center(child: Text('No saved tests'))]
              : tests.map((item) => _buildSavedItem(item)).toList(),
    );
  }

  Widget _buildSavedItem(SavedItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(item.icon, color: Colors.blue),
        ),
        title: Text(item.title),
        subtitle: Text(item.subtitle),
        trailing: PopupMenuButton<String>(
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'remove',
                  child: Text('Remove from saved'),
                ),
                const PopupMenuItem(value: 'share', child: Text('Share')),
              ],
          onSelected: (value) async {
            if (value == 'remove') {
              final userId = FirebaseAuth.instance.currentUser?.uid;
              if (userId != null) {
                try {
                  await Provider.of<SavedItemsProvider>(
                    context,
                    listen: false,
                  ).removeSavedItem(userId, item.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Item removed successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to remove item: $e')),
                  );
                }
              }
            }
          },
        ),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/modelsAndRepsositories/models_and_repositories.dart';
import '../../../utils/providers/providers.dart';

class StudyMaterialsPage extends StatefulWidget {
  const StudyMaterialsPage({super.key});

  @override
  _StudyMaterialsPageState createState() => _StudyMaterialsPageState();
}

class _StudyMaterialsPageState extends State<StudyMaterialsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        Provider.of<StudyMaterialsProvider>(
          context,
          listen: false,
        ).loadStudyMaterials(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudyMaterialsProvider>(
      builder: (context, provider, child) {
        if (FirebaseAuth.instance.currentUser == null) {
          return const Scaffold(
            body: Center(child: Text('Please log in to view study materials.')),
          );
        }

        if (provider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.error != null) {
          return Scaffold(
            body: Center(child: Text('Error: ${provider.error}')),
          );
        }

        final materials = provider.studyMaterials ?? [];

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _buildMaterialCard(context, materials[index]),
                    childCount: materials.length,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMaterialCard(BuildContext context, StudyMaterial material) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: material.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(material.icon, color: material.color),
              ),
              const SizedBox(height: 16),
              Text(
                material.subject,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${material.resourceCount} resources available',
                style: const TextStyle(color: Colors.grey),
              ),
              const Spacer(),
              LinearProgressIndicator(
                value: material.progress,
                backgroundColor: material.color.withOpacity(0.2),
                color: material.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class StudyMaterialsPage extends StatelessWidget {
  const StudyMaterialsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildMaterialCard(context, index),
                childCount: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialCard(BuildContext context, int index) {
    final subjects = [
      'Mathematics',
      'Physics',
      'Chemistry',
      'Biology',
      'Computer Science',
      'English',
    ];
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
    ];
    final icons = [
      Icons.calculate,
      Icons.science,
      Icons.eco,
      Icons.biotech,
      Icons.code,
      Icons.menu_book,
    ];

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors[index].withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icons[index], color: colors[index]),
              ),
              SizedBox(height: 16),
              Text(
                subjects[index],
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '${(index + 3) * 5} resources available',
                style: TextStyle(color: Colors.grey),
              ),
              Spacer(),
              LinearProgressIndicator(
                value: (index + 1) * 0.15,
                backgroundColor: colors[index].withOpacity(0.2),
                color: colors[index],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class PracticeTestsPage extends StatelessWidget {
  const PracticeTestsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildTestCard(
            context,
            title: 'Calculus Fundamentals',
            subject: 'Mathematics',
            questions: 25,
            duration: '30 mins',
            difficulty: 'Medium',
            completion: 0.4,
          ),
          _buildTestCard(
            context,
            title: 'Organic Chemistry',
            subject: 'Chemistry',
            questions: 20,
            duration: '25 mins',
            difficulty: 'Hard',
            completion: 0.8,
          ),
          _buildTestCard(
            context,
            title: 'Python Basics',
            subject: 'Computer Science',
            questions: 15,
            duration: '20 mins',
            difficulty: 'Easy',
            completion: 0.2,
          ),
          _buildTestCard(
            context,
            title: 'Literary Analysis',
            subject: 'English',
            questions: 10,
            duration: '15 mins',
            difficulty: 'Medium',
            completion: 0.0,
          ),
        ],
      ),
    );
  }

  Widget _buildTestCard(
    BuildContext context, {
    required String title,
    required String subject,
    required int questions,
    required String duration,
    required String difficulty,
    required double completion,
  }) {
    Color difficultyColor;
    switch (difficulty.toLowerCase()) {
      case 'easy':
        difficultyColor = Colors.green;
        break;
      case 'medium':
        difficultyColor = Colors.orange;
        break;
      case 'hard':
        difficultyColor = Colors.red;
        break;
      default:
        difficultyColor = Colors.grey;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      subject,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Spacer(),
                  Chip(
                    label: Text(difficulty),
                    backgroundColor: difficultyColor.withOpacity(0.1),
                    labelStyle: TextStyle(color: difficultyColor),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.help_outline, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text('$questions questions'),
                  SizedBox(width: 16),
                  Icon(Icons.timer, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(duration),
                ],
              ),
              SizedBox(height: 16),
              if (completion > 0)
                Column(
                  children: [
                    LinearProgressIndicator(
                      value: completion,
                      backgroundColor: Colors.grey[200],
                      color: Theme.of(context).primaryColor,
                    ),
                    SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${(completion * 100).toInt()}% completed',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                )
              else
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Start Test'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 40),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

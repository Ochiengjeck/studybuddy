import 'package:flutter/material.dart';

class AchievementBadge extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final double progress;
  final bool earned;

  const AchievementBadge({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.progress = 0.0,
    this.earned = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                earned
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              Center(
                child: Icon(
                  icon,
                  size: 32,
                  color: earned ? Colors.white : Colors.grey,
                ),
              ),
              if (!earned)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                    child: Icon(Icons.lock, size: 12, color: Colors.grey),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 12),
        Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        Text(
          description,
          style: TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }
}

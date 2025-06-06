import 'package:flutter/material.dart';

import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return _buildChatItem(context, index);
        },
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, int index) {
    final names = [
      'Sarah Johnson',
      'Michael Chen',
      'David Lee',
      'Jennifer Adams',
      'Maria Garcia',
    ];
    final previews = [
      'Sure, we can meet at 3pm tomorrow for the calculus session',
      'I\'ve attached the Python exercises we discussed',
      'The organic chemistry notes are ready for review',
      'Thanks for your feedback on my essay!',
      'Can we reschedule our session to Friday?',
    ];
    final times = ['2:45 PM', 'Yesterday', 'Oct 10', 'Oct 8', 'Oct 5'];
    final unreadCounts = [3, 0, 0, 0, 0];
    final imageUrls = [
      'https://picsum.photos/200/200?random=1',
      'https://picsum.photos/200/200?random=3',
      'https://picsum.photos/200/200?random=5',
      'https://picsum.photos/200/200?random=7',
      'https://picsum.photos/200/200?random=9',
    ];

    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    ChatScreen(name: names[index], imageUrl: imageUrls[index]),
          ),
        );
      },
      leading: CircleAvatar(backgroundImage: NetworkImage(imageUrls[index])),
      title: Text(names[index]),
      subtitle: Text(
        previews[index],
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(times[index], style: Theme.of(context).textTheme.bodySmall),
          if (unreadCounts[index] > 0)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                unreadCounts[index].toString(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String name;
  final String imageUrl;

  const ChatScreen({super.key, required this.name, required this.imageUrl});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Hi John! How\'s the calculus assignment going?',
      'isMe': false,
      'time': '2:30 PM',
    },
    {
      'text': 'It\'s going okay, but I\'m stuck on the optimization problems',
      'isMe': true,
      'time': '2:32 PM',
    },
    {
      'text':
          'No worries! We can go through them together in our session tomorrow',
      'isMe': false,
      'time': '2:33 PM',
    },
    {
      'text':
          'That would be great. I\'ve attached the problems I\'m having trouble with',
      'isMe': true,
      'time': '2:35 PM',
    },
    {
      'text':
          'I\'ll review them before our session. Let\'s meet at 3pm as planned?',
      'isMe': false,
      'time': '2:36 PM',
    },
    {'text': 'Sounds perfect. Thanks Sarah!', 'isMe': true, 'time': '2:37 PM'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(backgroundImage: NetworkImage(widget.imageUrl)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.name),
                const Text('Online', style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.phone), onPressed: () {}),
          IconButton(icon: const Icon(Icons.videocam), onPressed: () {}),
          IconButton(icon: const Icon(Icons.info_outline), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages.reversed.toList()[index];
                return MessageBubble(
                  message: message['text'],
                  isMe: message['isMe'],
                  time: message['time'],
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.emoji_emotions),
                  onPressed: () {},
                ),
                IconButton(icon: const Icon(Icons.mic), onPressed: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

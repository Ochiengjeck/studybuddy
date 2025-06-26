import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../../utils/modelsAndRepsositories/models_and_repositories.dart';
import '../../../utils/providers/providers.dart';
import '../../../widgets/message_bubble.dart'; // Update with your actual import path

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String name;
  final String imageUrl;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.name,
    required this.imageUrl,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Validate if a string is a valid URL
  Future<bool> _isValidUrl(String? url) async {
    if (url == null || url.isEmpty) return false;
    try {
      final uri = Uri.parse(url);
      if (uri.scheme != 'http' && uri.scheme != 'https') return false;
      final response = await http.head(uri);
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      return false;
    }
  }

  // Get a valid image URL or fallback
  Future<String> _getImageUrl() async {
    if (await _isValidUrl(widget.imageUrl)) {
      return widget.imageUrl;
    }
    return 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(widget.name)}&background=random';
  }

  @override
  void initState() {
    super.initState();
    // Load messages when the screen is initialized
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.loadMessages(widget.chatId);
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: _getImageUrl(),
          builder: (context, snapshot) {
            final imageUrl =
                snapshot.data ??
                'https://ui-avatars.com/api/?name=${Uri.encodeComponent(widget.name)}&background=random';
            return Row(
              children: [
                CircleAvatar(backgroundImage: NetworkImage(imageUrl)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        widget.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                      ),
                    ),
                    const Text('Online', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            );
          },
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
            child: StreamBuilder(
              stream:
                  FirebaseConfig.firestore
                      .collection('chats')
                      .doc(widget.chatId)
                      .collection('messages')
                      .orderBy('time', descending: true)
                      .snapshots(),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No messages yet'));
                }

                final messages =
                    snapshot.data!.docs
                        .map(
                          (doc) =>
                              Message.fromJson({...doc.data(), 'id': doc.id}),
                        )
                        .toList();

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return MessageBubble(
                      message: message.text,
                      isMe: message.senderId == appProvider.currentUser?.id,
                      time: _formatTime(message.time),
                    );
                  },
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
                    onSubmitted: (value) => _sendMessage(context),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.emoji_emotions),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendMessage(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(BuildContext context) async {
    if (_messageController.text.trim().isEmpty) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    final message = Message(
      id: '', // Will be set by Firestore
      chatId: widget.chatId,
      text: _messageController.text.trim(),
      senderId: appProvider.currentUser!.id,
      isMe: true,
      time: DateTime.now(),
      status: MessageStatus.sent,
    );

    try {
      await chatProvider.sendMessage(message);
      _messageController.clear();
      // Scroll to bottom after sending message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

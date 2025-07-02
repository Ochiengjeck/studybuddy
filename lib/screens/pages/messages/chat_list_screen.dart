import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../../../utils/modelsAndRepsositories/models_and_repositories.dart';
import '../../../utils/providers/providers.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Defer initialization to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChats();
    });
  }

  void _initializeChats() {
    if (!mounted || _isInitialized) return;

    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    if (appProvider.currentUser?.id != null) {
      chatProvider.loadChats(appProvider.currentUser!.id);
      setState(() {
        _isInitialized = true;
      });
    }
  }

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
  Future<String> _getImageUrl(String? profilePicture, String fullName) async {
    if (await _isValidUrl(profilePicture)) {
      return profilePicture!;
    }
    return 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(fullName)}&background=random';
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    // Show loading if user is not available or chats not initialized
    if (appProvider.currentUser?.id == null || !_isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chats')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: StreamBuilder(
        stream:
            FirebaseConfig.firestore
                .collection('users')
                .doc(appProvider.currentUser?.id)
                .collection('chats')
                .orderBy('last_message_time', descending: true)
                .snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isInitialized = false;
                      });
                      _initializeChats();
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 100,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No chats available',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Start a conversation by tapping the + button',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final chats =
              snapshot.data!.docs
                  .map((doc) => Chat.fromJson({...doc.data(), 'id': doc.id}))
                  .toList();

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              return _buildChatItem(context, chat);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewChatDialog(context),
        child: const Icon(Icons.add),
        tooltip: 'Start New Conversation',
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, Chat chat) {
    return FutureBuilder<String>(
      future: _getImageUrl(chat.imageUrl, chat.name),
      builder: (context, snapshot) {
        final imageUrl =
            snapshot.data ??
            'https://ui-avatars.com/api/?name=${Uri.encodeComponent(chat.name)}&background=random';
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ChatScreen(
                        chatId: chat.id,
                        name: chat.name,
                        imageUrl: imageUrl,
                      ),
                ),
              );
            },
            leading: CircleAvatar(
              backgroundImage: NetworkImage(imageUrl),
              onBackgroundImageError: (_, __) {},
            ),
            title: Text(
              chat.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              chat.lastMessage.isEmpty ? 'No messages yet' : chat.lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: chat.lastMessage.isEmpty ? Colors.grey : null,
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatTime(chat.lastMessageTime),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (chat.unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      chat.unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(time.year, time.month, time.day);

    if (messageDay == today) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (messageDay == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${time.month}/${time.day}';
    }
  }

  void _showNewChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final appProvider = Provider.of<AppProvider>(context, listen: false);
        final currentUser = appProvider.currentUser;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 500, minWidth: 300),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Start New Conversation',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search users...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      // Implement search functionality if needed
                    },
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream:
                          FirebaseConfig.firestore
                              .collection('users')
                              .where('email', isNotEqualTo: currentUser?.email)
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return const Center(
                            child: Text('Error loading users'),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text('No other users found'),
                          );
                        }

                        final users =
                            snapshot.data!.docs.map((doc) {
                              return User.fromJson({
                                ...doc.data() as Map<String, dynamic>,
                                'id': doc.id,
                              });
                            }).toList();

                        return ListView.separated(
                          itemCount: users.length,
                          separatorBuilder:
                              (context, index) =>
                                  const Divider(height: 1, thickness: 1),
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return FutureBuilder<String>(
                              future: _getImageUrl(
                                user.profilePicture,
                                user.fullName,
                              ),
                              builder: (context, snapshot) {
                                final imageUrl =
                                    snapshot.data ??
                                    'https://ui-avatars.com/api/?name=${Uri.encodeComponent(user.fullName)}&background=random';
                                return ListTile(
                                  leading: CircleAvatar(
                                    radius: 24,
                                    backgroundImage: NetworkImage(imageUrl),
                                    onBackgroundImageError: (_, __) {},
                                  ),
                                  title: Text(
                                    user.fullName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    user.email,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  onTap: () async {
                                    try {
                                      final chatProvider =
                                          Provider.of<ChatProvider>(
                                            context,
                                            listen: false,
                                          );
                                      final currentUserDoc =
                                          await FirebaseConfig.firestore
                                              .collection('users')
                                              .doc(currentUser?.id)
                                              .get();
                                      final currentUserData =
                                          currentUserDoc.data();
                                      final currentUserName =
                                          currentUserData?['first_name'] != null
                                              ? '${currentUserData?['first_name']} ${currentUserData?['last_name'] ?? ''}'
                                                  .trim()
                                              : currentUserData?['email']
                                                  .split('@')
                                                  .first;

                                      // Prevent duplicate conversations: search global 'chats' collection for both user IDs
                                      final globalChatsSnapshot =
                                          await FirebaseConfig.firestore
                                              .collection('chats')
                                              .where(
                                                'members',
                                                arrayContains: currentUser!.id,
                                              )
                                              .get();
                                      QueryDocumentSnapshot<
                                        Map<String, dynamic>
                                      >?
                                      existingChat;
                                      for (final doc
                                          in globalChatsSnapshot.docs) {
                                        final members =
                                            (doc.data()['members'] ?? [])
                                                as List<dynamic>;
                                        if (members.contains(user.id)) {
                                          existingChat = doc;
                                          break;
                                        }
                                      }
                                      if (existingChat != null) {
                                        // Redirect to existing chat
                                        if (context.mounted) {
                                          Navigator.pop(context);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => ChatScreen(
                                                    chatId: existingChat!.id,
                                                    name: user.fullName,
                                                    imageUrl: imageUrl,
                                                  ),
                                            ),
                                          );
                                        }
                                      } else {
                                        // Create new chat
                                        final newChatId = await chatProvider
                                            .createChat(
                                              currentUser!.id,
                                              currentUserName,
                                              user.id,
                                              user.fullName,
                                            );
                                        if (context.mounted) {
                                          Navigator.pop(context);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => ChatScreen(
                                                    chatId: newChatId,
                                                    name: user.fullName,
                                                    imageUrl: imageUrl,
                                                  ),
                                            ),
                                          );
                                        }
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Failed to start chat: e.toString()',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

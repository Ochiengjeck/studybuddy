import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:tencent_trtc_cloud/trtc_cloud.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_listener.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_video_view.dart';
import 'package:tencent_trtc_cloud/tx_audio_effect_manager.dart';
import 'package:tencent_trtc_cloud/tx_device_manager.dart';

import '../../../utils/modelsAndRepsositories/models_and_repositories.dart';
import '../../../utils/providers/providers.dart';

class VirtualMeetingScreen extends StatefulWidget {
  final Session session;

  const VirtualMeetingScreen({super.key, required this.session});

  @override
  State<VirtualMeetingScreen> createState() => _VirtualMeetingScreenState();
}

class _VirtualMeetingScreenState extends State<VirtualMeetingScreen> {
  bool _isMicOn = true;
  bool _isVideoOn = true;
  bool _isScreenSharing = false;
  bool _isChatVisible = false;
  late TRTCCloud _trtcCloud;
  late TXDeviceManager _deviceManager;
  late TXAudioEffectManager _audioEffectManager;
  bool _isInitialized = false;
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];

  // Replace with your Tencent Cloud credentials
  final int _appId = int.parse(dotenv.env['APP_ID']!);
  final String _userId = dotenv.env['USER_ID']!;
  final String _userSig = dotenv.env['USER_SIG']!;
  late final String _roomId;

  @override
  void initState() {
    super.initState();
    // Validate environment variables
    if (dotenv.env['APP_ID'] == null ||
        dotenv.env['USER_ID'] == null ||
        dotenv.env['USER_SIG'] == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Missing Tencent Cloud credentials')),
          );
        }
      });
      return;
    }
    // Set roomId from SessionProvider with fallback
    _roomId = context.read<SessionProvider>().selectedSession?.id ?? '111';
    // Request permissions before initializing TRTC
    _requestPermissions().then((granted) {
      if (granted) {
        _initializeTRTC();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Camera and microphone permissions are required',
              ),
              action: SnackBarAction(
                label: 'Settings',
                onPressed: () => openAppSettings(),
              ),
            ),
          );
        }
      }
    });
  }

  Future<bool> _requestPermissions() async {
    final Map<Permission, PermissionStatus> statuses =
        await [Permission.camera, Permission.microphone].request();

    if (statuses[Permission.camera]!.isPermanentlyDenied ||
        statuses[Permission.microphone]!.isPermanentlyDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Permissions permanently denied. Please enable them in settings.',
            ),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () => openAppSettings(),
            ),
          ),
        );
      }
      return false;
    }

    return statuses[Permission.camera]!.isGranted &&
        statuses[Permission.microphone]!.isGranted;
  }

  Future<void> _initializeTRTC() async {
    try {
      // Initialize Tencent RTC SDK
      _trtcCloud = (await TRTCCloud.sharedInstance())!;
      _deviceManager = _trtcCloud.getDeviceManager();
      _audioEffectManager = _trtcCloud.getAudioEffectManager();
      _trtcCloud.registerListener(onListener);

      // Enter the meeting room
      await _trtcCloud.enterRoom(
        TRTCParams(
          sdkAppId: _appId,
          userId: _userId,
          userSig: _userSig,
          roomId: int.tryParse(_roomId) ?? 111,
          role: TRTCCloudDef.TRTCRoleAnchor,
        ),
        TRTCCloudDef.TRTC_APP_SCENE_VIDEOCALL,
      );

      // Start local video and audio if permissions are granted
      if (await Permission.camera.isGranted) {
        await _trtcCloud.startLocalPreview(true, null);
      } else {
        throw Exception('Camera permission denied');
      }

      if (await Permission.microphone.isGranted) {
        await _trtcCloud.startLocalAudio(
          TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT,
        );
      } else {
        throw Exception('Microphone permission denied');
      }

      // Set up custom message listener
      _trtcCloud.registerListener((type, params) {
        if (type == TRTCCloudListener.onRecvCustomCmdMsg) {
          final String userId = params['userId'];
          final String message = params['message'];
          _addMessage(
            ChatMessage(
              sender: userId,
              content: message,
              isMe: false,
              timestamp: DateTime.now(),
            ),
          );
        }
        // Call the main listener as well
        onListener(type, params);
      });

      setState(() => _isInitialized = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize TRTC: $e')),
        );
      }
    }
  }

  void _addMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final message = _messageController.text;
    _messageController.clear();

    try {
      // Send message to all users in room
      await _trtcCloud.sendCustomCmdMsg(
        1, // Command ID for text message
        message,
        true, // reliable
        false, // ordered
      );

      // Add to local chat
      _addMessage(
        ChatMessage(
          sender: _userId,
          content: message,
          isMe: true,
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
      }
    }
  }

  void onListener(TRTCCloudListener type, dynamic params) {
    switch (type) {
      case TRTCCloudListener.onError:
        onError(params['errCode'], params['errMsg'], params['extraInfo']);
        break;
      case TRTCCloudListener.onUserVideoAvailable:
        onUserVideoAvailable(params['userId'], params['available']);
        break;
      case TRTCCloudListener.onScreenCaptureStarted:
        setState(() => _isScreenSharing = true);
        break;
      case TRTCCloudListener.onScreenCaptureStoped:
        setState(() => _isScreenSharing = false);
        break;
      default:
        break;
    }
  }

  void onError(int errCode, String errMsg, dynamic extraInfo) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('TRTC Error: $errMsg (Code: $errCode)')),
      );
    }
  }

  void onUserVideoAvailable(String userId, bool available) {
    if (mounted) {
      setState(() {}); // Refresh UI when remote user video changes
    }
  }

  Future<void> _toggleMic() async {
    if (!await Permission.microphone.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission is required')),
        );
      }
      return;
    }
    if (_isMicOn) {
      await _trtcCloud.muteLocalAudio(true);
    } else {
      await _trtcCloud.muteLocalAudio(false);
    }
    setState(() => _isMicOn = !_isMicOn);
  }

  Future<void> _toggleVideo() async {
    if (!await Permission.camera.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission is required')),
        );
      }
      return;
    }
    if (_isVideoOn) {
      await _trtcCloud.stopLocalPreview();
    } else {
      await _trtcCloud.startLocalPreview(true, null);
    }
    setState(() => _isVideoOn = !_isVideoOn);
  }

  Future<void> _toggleScreenShare() async {
    if (!_isScreenSharing) {
      // Request screen capture permission
      final status = await Permission.manageExternalStorage.request();
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Screen sharing permission required')),
          );
        }
        return;
      }

      await _trtcCloud.startScreenCapture(
        TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG,
        TRTCVideoEncParam(
          videoResolution: TRTCCloudDef.TRTC_VIDEO_RESOLUTION_1280_720,
          videoFps: 15,
          videoBitrate: 1600,
          enableAdjustRes: true,
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Screen sharing started')));
      }
    } else {
      await _trtcCloud.stopScreenCapture();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Screen sharing stopped')));
      }
    }
    setState(() => _isScreenSharing = !_isScreenSharing);
  }

  Future<void> _endSession() async {
    await _trtcCloud.exitRoom();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _trtcCloud.exitRoom();
    _trtcCloud.unRegisterListener(onListener);
    TRTCCloud.destroySharedInstance();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.session.title),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Session Info Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.session.tutorName,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${widget.session.formattedDateTime} • ${widget.session.formattedDuration}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Live',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.session.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              // Video Area
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child:
                      _isInitialized
                          ? Stack(
                            children: [
                              TRTCCloudVideoView(
                                onViewCreated: (controller) async {
                                  var cameraPermission =
                                      await Permission.camera.request();

                                  if (cameraPermission.isGranted) {
                                    _trtcCloud.startLocalPreview(
                                      true,
                                      controller,
                                    );
                                  }
                                },
                              ),
                              if (!_isVideoOn)
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.videocam_off,
                                        size: 48,
                                        color: Colors.white.withOpacity(0.6),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Camera is off',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          )
                          : const Center(child: CircularProgressIndicator()),
                ),
              ),

              // Control Panel
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Microphone toggle
                    _buildControlButton(
                      icon: _isMicOn ? Icons.mic : Icons.mic_off,
                      label: 'Mic',
                      isActive: _isMicOn,
                      onTap: _toggleMic,
                    ),

                    // Video toggle
                    _buildControlButton(
                      icon: _isVideoOn ? Icons.videocam : Icons.videocam_off,
                      label: 'Video',
                      isActive: _isVideoOn,
                      onTap: _toggleVideo,
                    ),

                    // Screen share
                    _buildControlButton(
                      icon:
                          _isScreenSharing
                              ? Icons.stop_screen_share
                              : Icons.screen_share,
                      label: 'Share',
                      isActive: _isScreenSharing,
                      onTap: _toggleScreenShare,
                    ),

                    // Chat
                    _buildControlButton(
                      icon: Icons.chat,
                      label: 'Chat',
                      isActive: _isChatVisible,
                      onTap: () {
                        setState(() => _isChatVisible = !_isChatVisible);
                      },
                    ),

                    // End call
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text('End Session'),
                                  content: const Text(
                                    'Are you sure you want to leave this session?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: _endSession,
                                      child: const Text('End'),
                                    ),
                                  ],
                                ),
                          );
                        },
                        icon: const Icon(Icons.call_end, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Chat Panel
          if (_isChatVisible)
            Positioned(
              right: 16,
              bottom: 80,
              child: Container(
                width: 300,
                height: 400,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Chat header
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.chat, color: Colors.white),
                          const SizedBox(width: 8),
                          const Text(
                            'Chat',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              setState(() => _isChatVisible = false);
                            },
                          ),
                        ],
                      ),
                    ),

                    // Messages
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        reverse: true,
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message =
                              _messages[_messages.length - 1 - index];
                          return ChatBubble(
                            message: message,
                            isMe: message.isMe,
                          );
                        },
                      ),
                    ),

                    // Message input
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey.withOpacity(0.2)),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              decoration: const InputDecoration(
                                hintText: 'Type a message...',
                                border: InputBorder.none,
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: _sendMessage,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color:
                isActive
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: onTap,
            icon: Icon(
              icon,
              color:
                  isActive
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[600],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const ChatBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe)
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: Text(
                message.sender.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: Colors.black),
              ),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe ? Theme.of(context).primaryColor : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Text(
                      message.sender,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isMe ? Colors.white : Colors.black,
                      ),
                    ),
                  Text(
                    message.content,
                    style: TextStyle(color: isMe ? Colors.white : Colors.black),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 10,
                      color:
                          isMe
                              ? Colors.white.withOpacity(0.7)
                              : Colors.black.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String sender;
  final String content;
  final bool isMe;
  final DateTime timestamp;

  ChatMessage({
    required this.sender,
    required this.content,
    required this.isMe,
    required this.timestamp,
  });
}

import 'dart:ui';

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
  late TRTCCloud _trtcCloud;
  late TXDeviceManager _deviceManager;
  late TXAudioEffectManager _audioEffectManager;
  bool _isInitialized = false;

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

      setState(() => _isInitialized = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize TRTC: $e')),
        );
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
      await _trtcCloud.startScreenCapture(
        0,
        TRTCVideoEncParam(
          videoResolution: TRTCCloudDef.TRTC_VIDEO_RESOLUTION_640_360,
          videoFps: 15,
          videoBitrate: 550,
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
      body: Column(
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
                    // CircleAvatar(
                    //   radius: 24,
                    //   backgroundImage: NetworkImage(widget.session.tutorImage),
                    // ),
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
                      ? TRTCCloudVideoView(
                        onViewCreated: (controller) async {
                          var cameraPermission =
                              await Permission.camera.request();

                          if (cameraPermission.isGranted) {
                            _trtcCloud.startLocalPreview(true, controller);
                          }
                        },
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
                  isActive: false,
                  onTap: () {
                    // TODO: Implement chat functionality
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

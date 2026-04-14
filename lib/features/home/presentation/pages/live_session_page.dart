import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:skillswap/init_dependencies.dart';
import 'package:skillswap/features/home/domain/repositories/chat_repository.dart';

class LiveSessionPage extends StatefulWidget {
  final List<String> agenda;
  final String? sessionId;
  final String peerName;
  final String peerImageUrl;
  final String currentUserId;
  final String peerId;
  final String? currentUserName;
  final String? currentUserImageUrl;
  final bool isCaller;

  const LiveSessionPage({
    super.key,
    required this.agenda,
    this.sessionId,
    required this.peerName,
    required this.peerImageUrl,
    required this.currentUserId,
    required this.peerId,
    this.currentUserName,
    this.currentUserImageUrl,
    this.isCaller = false,
  });

  @override
  State<LiveSessionPage> createState() => _LiveSessionPageState();
}

class _LiveSessionPageState extends State<LiveSessionPage>
    with SingleTickerProviderStateMixin {
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  StreamSubscription? _signalingSubscription;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final ValueNotifier<int> _secondsElapsed = ValueNotifier<int>(0);
  Timer? _timer;

  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _startTimer();
    _initWebRTC();
  }

  Future<void> _initWebRTC() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': {'facingMode': 'user'},
    });
    _localRenderer.srcObject = _localStream;

    final configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun1.l.google.com:19302'},
      ],
    };

    _peerConnection = await createPeerConnection(configuration);

    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      if (candidate.candidate != null) {
        _sendSignalingMessage('ice_candidate', {
          'candidate': candidate.candidate,
          'sdpMid': candidate.sdpMid,
          'sdpMLineIndex': candidate.sdpMLineIndex,
        });
      }
    };

    _peerConnection!.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        setState(() {
          _remoteRenderer.srcObject = event.streams[0];
        });
      }
    };

    _localStream!.getTracks().forEach((track) {
      _peerConnection!.addTrack(track, _localStream!);
    });

    _connectSignaling();

    setState(() {
      _isInitialized = true;
    });
  }

  Future<void> _connectSignaling() async {
    final chatRepo = serviceLocator<ChatRepository>();

    _signalingSubscription = chatRepo.getMessagesStream('').listen((event) {
      if (event is Map<String, dynamic> &&
          event['type'] == 'webrtc_signaling') {
        _handleSignalingMessage(event);
      }
    });

    if (widget.isCaller) {
      // Notify peer we are requesting a call
      _sendSignalingMessage('call_request', {
        'caller_name': widget.currentUserName ?? 'Peer',
        'caller_image': widget.currentUserImageUrl ?? '',
      });
    } else {
      // Notify caller we have joined with our camera ready
      _sendSignalingMessage('call_accepted', {});
    }
  }

  void _sendSignalingMessage(String action, Map<String, dynamic> data) {
    serviceLocator<ChatRepository>().sendSignalingMessage({
      'type': 'webrtc_signaling',
      'target_uid': widget.peerId,
      'action': action,
      'data': data,
    });
  }

  Future<void> _handleSignalingMessage(Map<String, dynamic> payload) async {
    final action = payload['action'];
    final data = payload['data'];
    final senderId = payload['sender_id'];

    // Ignore signaling from anyone else
    if (senderId != null && senderId != widget.peerId) return;

    if (_peerConnection == null) return;

    if (action == 'call_rejected') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Call declined by peer.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        Navigator.pop(context);
      }
      return;
    }

    if (action == 'call_accepted' && widget.isCaller) {
      // The caller creates the offer when the callee indicates they are ready
      final offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);
      _sendSignalingMessage('offer', {'sdp': offer.sdp, 'type': offer.type});
    } else if (action == 'offer' && !widget.isCaller) {
      // The callee receives the offer and creates an answer
      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(data['sdp'], data['type']),
      );
      final answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);
      _sendSignalingMessage('answer', {'sdp': answer.sdp, 'type': answer.type});
    } else if (action == 'answer' && widget.isCaller) {
      // The caller receives the answer
      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(data['sdp'], data['type']),
      );
    } else if (action == 'ice_candidate') {
      await _peerConnection!.addCandidate(
        RTCIceCandidate(
          data['candidate'],
          data['sdpMid'],
          data['sdpMLineIndex'],
        ),
      );
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) _secondsElapsed.value++;
    });
  }

  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _toggleMic() {
    if (_localStream != null) {
      final audioTracks = _localStream!.getAudioTracks();
      if (audioTracks.isNotEmpty) {
        final track = audioTracks.first;
        track.enabled = !track.enabled;
        setState(() => _isMuted = !track.enabled);
      }
    }
  }

  void _toggleVideo() {
    if (_localStream != null) {
      final videoTracks = _localStream!.getVideoTracks();
      if (videoTracks.isNotEmpty) {
        final track = videoTracks.first;
        track.enabled = !track.enabled;
        setState(() => _isVideoEnabled = track.enabled);
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _localStream?.dispose();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _peerConnection?.dispose();
    _signalingSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryBgColor = Color(0xFF0C0A09);
    const accentColor = Color(0xFFCA8A04);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background - Remote Video
          _buildRemoteVideo(primaryBgColor),

          // Cinematic Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                  ],
                  stops: const [0.0, 0.25, 0.75, 1.0],
                ),
              ),
            ),
          ),

          // Top Hud
          _buildTopHud(accentColor),

          // Active Call PiP
          _buildLocalPiP(),

          // Bottom Controls
          _buildControlBar(accentColor),
        ],
      ),
    );
  }

  Widget _buildRemoteVideo(Color bgColor) {
    if (_isInitialized && _remoteRenderer.srcObject != null) {
      return RTCVideoView(
        _remoteRenderer,
        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
      );
    }
    return Container(
      color: bgColor,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_tethering_rounded,
              color: Colors.white24,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'WAITING FOR PEER...',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Colors.white.withValues(alpha: 0.3),
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalPiP() {
    return Positioned(
      bottom: 140,
      right: 20,
      child: Container(
        width: 120,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 24,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22.5),
          child: _isInitialized && _isVideoEnabled
              ? RTCVideoView(
                  _localRenderer,
                  mirror: true,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                )
              : const Center(
                  child: Icon(
                    Icons.videocam_off_rounded,
                    color: Colors.white54,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildTopHud(Color accentColor) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LIVE SYNERGY',
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: accentColor,
                      letterSpacing: 2.0,
                    ),
                  ),
                  Text(
                    widget.peerName,
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              _buildRecordingIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          FadeTransition(
            opacity: _pulseAnimation,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFEF4444),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          ValueListenableBuilder<int>(
            valueListenable: _secondsElapsed,
            builder: (context, seconds, _) {
              return Text(
                _formatDuration(seconds),
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildControlBar(Color accentColor) {
    return Positioned(
      bottom: 40,
      left: 20,
      right: 20,
      child: Container(
        height: 88,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(44),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 40,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(44),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                  _isMuted ? Icons.mic_off_rounded : Icons.mic_none_rounded,
                  isActive: !_isMuted,
                  onTap: _toggleMic,
                  accentColor: accentColor,
                ),
                _buildControlButton(
                  _isVideoEnabled
                      ? Icons.videocam_outlined
                      : Icons.videocam_off_outlined,
                  isActive: _isVideoEnabled,
                  onTap: _toggleVideo,
                  accentColor: accentColor,
                ),
                _buildEndCallButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton(
    IconData icon, {
    bool isActive = false,
    VoidCallback? onTap,
    required Color accentColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: isActive
              ? accentColor.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.05),
          shape: BoxShape.circle,
          border: isActive
              ? Border.all(color: accentColor.withValues(alpha: 0.3))
              : null,
        ),
        child: Icon(
          icon,
          color: isActive ? accentColor : Colors.white,
          size: 26,
        ),
      ),
    );
  }

  Widget _buildEndCallButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        width: 52,
        height: 52,
        decoration: const BoxDecoration(
          color: Color(0xFFEF4444),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.call_end_rounded,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:skillswap/init_dependencies.dart';
import 'package:skillswap/features/home/domain/repositories/chat_repository.dart';
import 'package:skillswap/features/home/presentation/pages/review_session/review_session_page.dart';
import 'components/live_session_hud.dart';
import 'components/live_session_controls.dart';
import 'components/local_pip_view.dart';
import 'components/remote_video_renderer.dart';
import 'package:skillswap/core/theme/theme.dart';

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
      _sendSignalingMessage('call_request', {
        'caller_name': widget.currentUserName ?? 'Peer',
        'caller_image': widget.currentUserImageUrl ?? '',
      });
    } else {
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
      final offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);
      _sendSignalingMessage('offer', {'sdp': offer.sdp, 'type': offer.type});
    } else if (action == 'offer' && !widget.isCaller) {
      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(data['sdp'], data['type']),
      );
      final answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);
      _sendSignalingMessage('answer', {'sdp': answer.sdp, 'type': answer.type});
    } else if (action == 'answer' && widget.isCaller) {
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

  Future<bool?> _handleEndCallRequest() async {
    if (!mounted) return false;

    setState(() {
      _isInitialized = false;
    });

    if (widget.sessionId != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ReviewSessionPage(
            sessionId: widget.sessionId,
            peerId: widget.peerId,
            peerName: widget.peerName,
            peerImageUrl: widget.peerImageUrl,
          ),
        ),
      );
    } else {
      if (mounted) {
        Navigator.pop(context);
      }
    }
    return true;
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
    const primaryBgColor = AppColors.background;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background - Remote Video
          RemoteVideoRenderer(
            isInitialized: _isInitialized,
            remoteRenderer: _remoteRenderer,
            backgroundColor: primaryBgColor,
          ),

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
          LiveSessionHud(
            peerName: widget.peerName,
            secondsElapsed: _secondsElapsed,
            pulseAnimation: _pulseAnimation,
          ),

          // Active Call PiP
          LocalPiPView(
            isInitialized: _isInitialized,
            isVideoEnabled: _isVideoEnabled,
            localRenderer: _localRenderer,
          ),

          // Bottom Controls
          LiveSessionControls(
            isMuted: _isMuted,
            isVideoEnabled: _isVideoEnabled,
            onToggleMic: _toggleMic,
            onToggleVideo: _toggleVideo,
            onEndCallRequest: _handleEndCallRequest,
          ),
        ],
      ),
    );
  }
}

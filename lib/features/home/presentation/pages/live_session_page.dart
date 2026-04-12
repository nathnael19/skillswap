import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:floating/floating.dart';
import 'package:skillswap/features/home/presentation/pages/review_session_page.dart';

class LiveSessionPage extends StatefulWidget {
  final List<String> agenda;
  final String? sessionId;
  final String peerName;
  final String peerImageUrl;

  const LiveSessionPage({
    super.key,
    required this.agenda,
    this.sessionId,
    required this.peerName,
    required this.peerImageUrl,
  });

  @override
  State<LiveSessionPage> createState() => _LiveSessionPageState();
}

class _LiveSessionPageState extends State<LiveSessionPage>
    with SingleTickerProviderStateMixin {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final ValueNotifier<int> _secondsElapsed = ValueNotifier<int>(0);
  Timer? _timer;

  // Interaction State
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isFlashOn = false;

  // PiP State
  late Floating _floating;

  // Agenda State
  late Map<String, bool> _agendaManifestations;

  @override
  void initState() {
    super.initState();
    _floating = Floating();
    _initializeAgenda();
    _initializeCamera();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startTimer();
  }

  void _initializeAgenda() {
    _agendaManifestations = {for (var item in widget.agenda) item: false};
    // Default the first one as checked for visual baseline if it exists
    if (_agendaManifestations.isNotEmpty) {
      _agendaManifestations[widget.agenda.first] = true;
    }
  }

  Future<void> _initializeCamera() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        final frontCamera = _cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras!.first,
        );

        _controller = CameraController(
          frontCamera,
          ResolutionPreset.high,
          imageFormatGroup: ImageFormatGroup.jpeg,
        );

        try {
          await _controller!.initialize();
          if (!mounted) return;
          setState(() {
            _isInitialized = true;
          });
        } catch (e) {
          debugPrint('Camera initialization error: $e');
        }
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _secondsElapsed.value++;
      }
    });
  }

  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_isInitialized) return;
    try {
      if (_isFlashOn) {
        await _controller!.setFlashMode(FlashMode.off);
      } else {
        await _controller!.setFlashMode(FlashMode.torch);
      }
      setState(() => _isFlashOn = !_isFlashOn);
    } catch (e) {
      debugPrint('Flash toggle error: $e');
    }
  }

  void _toggleVideo() async {
    if (_isVideoEnabled) {
      await _controller?.pausePreview();
    } else {
      await _controller?.resumePreview();
    }
    setState(() => _isVideoEnabled = !_isVideoEnabled);
  }

  Future<void> _togglePip() async {
    try {
      final canUsePip = await _floating.isPipAvailable;
      if (canUsePip) {
        await _floating.enable(
          ImmediatePiP(aspectRatio: const Rational.landscape()),
        );
      }
    } catch (e) {
      debugPrint('PiP Error: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    _pulseController.dispose();
    _secondsElapsed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFFCA8A04);
    const primaryBgColor = Color(0xFF0C0A09);

    return PiPSwitcher(
      childWhenDisabled: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Background Layer (Camera)
            _buildPrimaryBackground(primaryBgColor),

            // 2. Cinematic Gradient Overlay
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

            // 3. Top Hud
            _buildTopHud(accentColor, primaryBgColor),

            // 4. Standard Overlays (Agenda & PiP)
            _buildStandardAgenda(accentColor),
            _buildStandardPiP(),

            // 5. Bottom Controls
            _buildControlBar(accentColor, primaryBgColor),
          ],
        ),
      ),
      childWhenEnabled: _buildPipModeUI(accentColor),
    );
  }

  Widget _buildPipModeUI(Color accentColor) {
    return GestureDetector(
      onTap: () {
        // Many PiP implementations automatically return to the app on tap,
        // but adding an explicit tap area just in case.
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Just the camera feed in PiP mode
            if (_isInitialized && _controller != null && _isVideoEnabled)
              Center(child: CameraPreview(_controller!))
            else
              const Center(
                child: Icon(
                  Icons.videocam_off_rounded,
                  color: Colors.white24,
                  size: 40,
                ),
              ),

            // Small overlay for status
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ValueListenableBuilder<int>(
                  valueListenable: _secondsElapsed,
                  builder: (context, seconds, _) {
                    return Text(
                      _formatDuration(seconds),
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryBackground(Color bgColor) {
    if (_isInitialized && _controller != null && _isVideoEnabled) {
      return Center(child: CameraPreview(_controller!));
    }

    return Container(
      color: bgColor,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isVideoEnabled
                  ? Icons.videocam_off_rounded
                  : Icons.visibility_off_rounded,
              color: Colors.white24,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _isVideoEnabled ? 'CONNECTING NEXUS FEED...' : 'FEED PAUSED',
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

  Widget _buildTopHud(Color accentColor, Color primaryBgColor) {
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
                    'Session in Progress',
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

  Widget _buildStandardAgenda(Color accentColor) {
    if (_agendaManifestations.isEmpty) return const SizedBox.shrink();

    return Positioned(
      top: 140,
      right: 20,
      child: _buildGlassCard(
        width: 240,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SYNERGY AGENDA',
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Colors.white.withValues(alpha: 0.6),
                    letterSpacing: 1.5,
                  ),
                ),
                Icon(
                  Icons.auto_awesome_mosaic_rounded,
                  color: accentColor,
                  size: 14,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.05)),
            const SizedBox(height: 16),
            ..._agendaManifestations.entries
                .map((e) => _buildAgendaItem(e.key, e.value)),
          ],
        ),
      ),
    );
  }

  Widget _buildAgendaItem(String label, bool isDone) {
    const accentColor = Color(0xFFCA8A04);
    return GestureDetector(
      onTap: () {
        setState(() {
          _agendaManifestations[label] = !isDone;
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          children: [
            Icon(
              isDone
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isDone ? accentColor : Colors.white.withValues(alpha: 0.2),
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: isDone ? FontWeight.w700 : FontWeight.w500,
                  color: isDone
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardPiP() {
    return Positioned(
      bottom: 140,
      right: 20,
      child: Container(
        width: 120,
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: DecorationImage(
            image: widget.peerImageUrl.startsWith('assets')
                ? AssetImage(widget.peerImageUrl) as ImageProvider
                : NetworkImage(widget.peerImageUrl),
            fit: BoxFit.cover,
          ),
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
        child: Stack(
          children: [
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.peerName.toUpperCase(),
                  style: GoogleFonts.dmSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlBar(Color accentColor, Color primaryBgColor) {
    return Positioned(
      bottom: 40,
      left: 20,
      right: 20,
      child: Container(
        height: 88,
        padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  onTap: () => setState(() => _isMuted = !_isMuted),
                ),
                _buildControlButton(
                  _isVideoEnabled
                      ? Icons.videocam_outlined
                      : Icons.videocam_off_outlined,
                  isActive: _isVideoEnabled,
                  onTap: _toggleVideo,
                ),
                _buildCenterButton(),
                StreamBuilder<PiPStatus>(
                  stream: _floating.pipStatusStream,
                  builder: (context, snapshot) {
                    final isPip = snapshot.data == PiPStatus.enabled || snapshot.data == PiPStatus.automatic;
                    return _buildControlButton(
                      Icons.screen_share_rounded,
                      isActive: isPip,
                      onTap: _togglePip,
                    );
                  },
                ),
                _buildEndCallButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard({required double width, required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: width,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildControlButton(
    IconData icon, {
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    const accentColor = Color(0xFFCA8A04);
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

  Widget _buildCenterButton() {
    return GestureDetector(
      onTap: _toggleFlash,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isFlashOn
                ? [const Color(0xFFFACC15), const Color(0xFFEAB308)]
                : [const Color(0xFFCA8A04), const Color(0xFFB47B03)],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color:
                  (_isFlashOn
                          ? const Color(0xFFFACC15)
                          : const Color(0xFFCA8A04))
                      .withValues(alpha: 0.4),
              blurRadius: _isFlashOn ? 30 : 20,
              spreadRadius: _isFlashOn ? 2 : -5,
            ),
          ],
        ),
        child: Icon(
          _isFlashOn ? Icons.bolt_rounded : Icons.bolt_outlined,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildEndCallButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ReviewSessionPage(sessionId: widget.sessionId),
          ),
        );
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

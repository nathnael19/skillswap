import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:skillswap/features/home/presentation/pages/review_session_page.dart';

class LiveSessionPage extends StatefulWidget {
  const LiveSessionPage({super.key});

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
  int _secondsElapsed = 0;
  Timer? _timer;

  // Interaction State
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isFlashOn = false;
  bool _isSharingScreen = false;

  // Agenda State
  final Map<String, bool> _agendaManifestations = {
    'Mastering Auto-layout': true,
    'Nexus Component Logic': false,
    'Manifestation Review': false,
  };

  @override
  void initState() {
    super.initState();
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
        setState(() {
          _secondsElapsed++;
        });
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

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFFCA8A04);
    const primaryBgColor = Color(0xFF0C0A09);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Layer (Camera or Shared Screen)
          _buildPrimaryBackground(primaryBgColor),

          // 2. Cinematic Gradient Overlay (Only if not sharing or if we want contrast)
          if (!_isSharingScreen)
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

          // 4. Agenda & PiP (Reacting to Mini-mode)
          if (_isSharingScreen)
            _buildMiniPlayerOverlay(accentColor)
          else ...[
            _buildStandardAgenda(accentColor),
            _buildStandardPiP(),
          ],

          // 5. Bottom Controls
          _buildControlBar(accentColor, primaryBgColor),
        ],
      ),
    );
  }

  Widget _buildPrimaryBackground(Color bgColor) {
    if (_isSharingScreen) {
      return Container(
        color: const Color(0xFF1A1A1A),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.monitor_rounded,
                color: const Color(0xFFCA8A04).withValues(alpha: 0.3),
                size: 120,
              ),
              const SizedBox(height: 24),
              Text(
                'BROADCASTING NEXUS SCREEN',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Colors.white.withValues(alpha: 0.2),
                  letterSpacing: 4.0,
                ),
              ),
            ],
          ),
        ),
      );
    }

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
                    _isSharingScreen
                        ? 'Screen Sharing Active'
                        : 'Session in Progress',
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
          Text(
            _formatDuration(_secondsElapsed),
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandardAgenda(Color accentColor) {
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
                .map((e) => _buildAgendaItem(e.key, e.value))
                .toList(),
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
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                isDone
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: isDone
                    ? accentColor
                    : Colors.white.withValues(alpha: 0.2),
                size: 22,
              ),
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
                  decoration: isDone
                      ? TextDecoration.none
                      : TextDecoration.none,
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
          image: const DecorationImage(
            image: NetworkImage(
              'https://images.unsplash.com/photo-1599566150163-29194dcaad36?auto=format&fit=crop&q=80&w=2574&ixlib=rb-4.0.3',
            ),
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
                  'MARCUS',
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

  Widget _buildMiniPlayerOverlay(Color accentColor) {
    return Positioned(
      bottom: 140,
      right: 20,
      child: _buildGlassCard(
        width: 160,
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Mini Camera Feed
            Container(
              height: 100,
              width: 136,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.black,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child:
                    (_isInitialized && _controller != null && _isVideoEnabled)
                    ? CameraPreview(_controller!)
                    : const Center(
                        child: Icon(
                          Icons.videocam_off_rounded,
                          color: Colors.white24,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            // Mini Agenda Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.checklist_rounded,
                  color: Color(0xFFCA8A04),
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  '${_agendaManifestations.values.where((v) => v).length}/${_agendaManifestations.length}',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
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
                _buildControlButton(
                  Icons.screen_share_rounded,
                  isActive: _isSharingScreen,
                  onTap: () =>
                      setState(() => _isSharingScreen = !_isSharingScreen),
                ),
                _buildEndCallButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard({
    required double width,
    required Widget child,
    Color? color,
    EdgeInsetsGeometry? padding,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: width,
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color ?? Colors.white.withValues(alpha: 0.05),
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
    final accentColor = const Color(0xFFCA8A04);
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
          MaterialPageRoute(builder: (context) => const ReviewSessionPage()),
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

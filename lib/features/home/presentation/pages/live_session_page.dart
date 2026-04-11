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

class _LiveSessionPageState extends State<LiveSessionPage> with SingleTickerProviderStateMixin {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  int _secondsElapsed = 0;
  Timer? _timer;

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
        // Use front camera if available
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
          // 1. Live Camera Feed (Background)
          if (_isInitialized && _controller != null)
            Center(
              child: CameraPreview(_controller!),
            )
          else
            Container(
              color: primaryBgColor,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.videocam_off_rounded, color: Colors.white24, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'CONNECTING NEXUS FEED...',
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
            ),

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

          // 3. Top Hud (Navigation, Status, Recording)
          Positioned(
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
                        child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24),
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
                    // Recording Indicator
                    Container(
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
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4. Agenda Floating Glass (Right)
          Positioned(
            top: 140,
            right: 20,
            child: _buildGlassCard(
              width: 220,
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
                      const Icon(Icons.auto_awesome_mosaic_rounded, color: accentColor, size: 14),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(height: 1, color: Colors.white.withValues(alpha: 0.05)),
                  const SizedBox(height: 16),
                  _buildAgendaItem('Mastering Auto-layout', true),
                  _buildAgendaItem('Nexus Component Logic', false),
                  _buildAgendaItem('Manifestation Review', false),
                ],
              ),
            ),
          ),

          // 5. Remote Master PiP (Bottom Right)
          Positioned(
            bottom: 140,
            right: 20,
            child: Container(
              width: 120,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                image: const DecorationImage(
                  image: AssetImage('assets/home.png'),
                  fit: BoxFit.cover,
                ),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 24),
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
          ),

          // 6. Bottom Controls (Premium Hub)
          Positioned(
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
                  BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 40),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(44),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildControlButton(Icons.mic_none_rounded),
                      _buildControlButton(Icons.videocam_outlined),
                      _buildCenterButton(),
                      _buildControlButton(Icons.screen_share_rounded),
                      _buildEndCallButton(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required double width, required Widget child, Color? color}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: width,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color ?? Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildAgendaItem(String label, bool isDone) {
    const accentColor = Color(0xFFCA8A04);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            color: isDone ? accentColor : Colors.white.withValues(alpha: 0.2),
            size: 20,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: isDone ? FontWeight.w700 : FontWeight.w500,
                color: isDone ? Colors.white : Colors.white.withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(IconData icon) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 26),
    );
  }

  Widget _buildCenterButton() {
    return Container(
      width: 64,
      height: 64,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFCA8A04), Color(0xFFB47B03)],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Color(0xFFCA8A04), blurRadius: 20, spreadRadius: -5),
        ],
      ),
      child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 32),
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
        child: const Icon(Icons.call_end_rounded, color: Colors.white, size: 26),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class LiveSessionPage extends StatelessWidget {
  const LiveSessionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Full Screen Video Simulation
            Image.asset(
              'assets/home.png', // Assuming user avatar/feed
              fit: BoxFit.cover,
            ),
            
            // Immersive Gradient Overlay (Top & Bottom)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.4),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.4),
                    ],
                    stops: const [0.0, 0.2, 0.8, 1.0],
                  ),
                ),
              ),
            ),

            // Top Navigation & Timer
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
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LIVE SESSION',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white.withOpacity(0.7),
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            'Skill Session',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0B6A7A),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD92D20),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '14:22',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.more_vert, color: Colors.white, size: 24),
                    ],
                  ),
                ),
              ),
            ),

            // Agenda Card Overlay
            Positioned(
              top: 140, // Adjusted for SafeArea and AppBar
              right: 20,
              child: _buildGlassCard(
                width: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'AGENDA',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                        const Icon(Icons.assignment_outlined, color: Colors.white, size: 14),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: Colors.white24, height: 1),
                    const SizedBox(height: 12),
                    _buildAgendaItem('Figma Auto-layout', true),
                    _buildAgendaItem('Component Props', false),
                    _buildAgendaItem('Documentation', false),
                  ],
                ),
              ),
            ),

            // Coming Up Overlay
            Positioned(
              top: 320, // Adjusted
              right: 20,
              child: _buildGlassCard(
                width: 200,
                color: const Color(0xFFB47E00).withOpacity(0.4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'COMING UP',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Q&A: Building Design Systems',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Picture-in-Picture (PiP)
            Positioned(
              bottom: 140,
              right: 20,
              child: Container(
                width: 110,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: const DecorationImage(
                    image: AssetImage('assets/home.png'), // Self image
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(color: Colors.white30, width: 1),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.mic_none, color: Colors.white, size: 8),
                            const SizedBox(width: 2),
                            Text(
                              'YOU',
                              style: GoogleFonts.inter(
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Status Pill (Screen Sharing)
            Positioned(
              bottom: 140,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.group, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Sarah is sharing screen',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Control Panel
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 30),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildControlButton(Icons.mic_none),
                    _buildControlButton(Icons.videocam_outlined),
                    _buildShareButton(),
                    _buildControlButton(Icons.assignment_outlined),
                    _buildEndCallButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard({required double width, required Widget child, Color? color}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: width,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color ?? Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white12, width: 1),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildAgendaItem(String label, bool isDone) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle_outlined : Icons.radio_button_unchecked,
            color: isDone ? Colors.white : Colors.white.withOpacity(0.4),
            size: 18,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDone ? Colors.white : Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(IconData icon) {
    return IconButton(
      icon: Icon(icon, color: const Color(0xFF475467), size: 28),
      onPressed: () {},
    );
  }

  Widget _buildShareButton() {
    return Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(
        color: Color(0xFF0B6A7A),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.screen_share, color: Colors.white, size: 24),
    );
  }

  Widget _buildEndCallButton() {
    return Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(
        color: Color(0xFFD92D20),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.call_end, color: Colors.white, size: 24),
    );
  }
}

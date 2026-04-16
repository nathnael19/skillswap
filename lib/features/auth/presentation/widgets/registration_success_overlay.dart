import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegistrationSuccessOverlay extends StatefulWidget {
  final VoidCallback onAnimationComplete;

  const RegistrationSuccessOverlay({
    super.key,
    required this.onAnimationComplete,
  });

  @override
  State<RegistrationSuccessOverlay> createState() => _RegistrationSuccessOverlayState();
}

class _RegistrationSuccessOverlayState extends State<RegistrationSuccessOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late List<Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
    ]).animate(_controller);

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
      ),
    );

    _particles = List.generate(30, (index) => Particle());

    _controller.forward().then((_) {
      widget.onAnimationComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Scaffold(
            backgroundColor: const Color(0xFF0B6A7A), // Teal theme color
            body: Stack(
              children: [
                // Celebration Particles
                CustomPaint(
                  painter: ParticlePainter(
                    particles: _particles,
                    progress: _controller.value,
                  ),
                  size: Size.infinite,
                ),
                // Main Content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Color(0xFF0B6A7A),
                            size: 80,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      FadeTransition(
                        opacity: CurvedAnimation(
                          parent: _controller,
                          curve: const Interval(0.2, 0.5, curve: Curves.easeIn),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Welcome to SkillSwap',
                              style: GoogleFonts.lora(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Your journey starts now.',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: Colors.white70,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class Particle {
  late double x;
  late double y;
  late double vx;
  late double vy;
  late Color color;
  late double size;

  Particle() {
    final random = Random();
    x = 0; // Relative to center
    y = 0;
    // Initial velocity
    double angle = random.nextDouble() * 2 * pi;
    double speed = random.nextDouble() * 5 + 2;
    vx = cos(angle) * speed;
    vy = sin(angle) * speed;
    
    // Random colors (whites and oranges)
    List<Color> colors = [
      Colors.white,
      Colors.white70,
      const Color(0xFFA67C52), // Orange theme color
      const Color(0xFFFFD700), // Gold
    ];
    color = colors[random.nextInt(colors.length)];
    size = random.nextDouble() * 6 + 2;
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;

  ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final center = Offset(size.width / 2, size.height / 2);

    for (var particle in particles) {
      // Simple physics: position = initial + velocity * time + gravity * time^2
      double t = progress * 20; // Scale time
      double dx = particle.vx * t;
      double dy = particle.vy * t + 0.5 * 0.1 * t * t; // Adding subtle gravity

      double opacity = (1.0 - progress).clamp(0.0, 1.0);
      paint.color = particle.color.withValues(alpha: opacity);
      
      canvas.drawCircle(
        Offset(center.dx + dx, center.dy + dy),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

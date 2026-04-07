import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/features/auth/presentation/pages/login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(LoginPage.route());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const tealColor = Color(0xFF0B6A7A);
    const brownColor = Color(0xFFA67C52);

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/splash-bg.png',
              fit: BoxFit.cover,
            ),
          ),
          // Dark Overlay for readability
          Positioned.fill(
            child: Container(
              color: Colors.black.withAlpha(51), // 0.2 opacity approx
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  // Decorative Lines
                  Column(
                    children: [
                      Container(
                        height: 3,
                        width: 100,
                        color: tealColor,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 3,
                        width: 50,
                        color: brownColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // App Name
                  Text(
                    'NEXUS EXCHANGE',
                    style: GoogleFonts.lora(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 4,
                      color: tealColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Main Title
                  Text(
                    'The Curator',
                    style: GoogleFonts.inter(
                      fontSize: 52,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF1A1A1A),
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Subtitle
                  Text(
                    'The Curated Exchange',
                    style: GoogleFonts.lora(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Slogan with Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.circle, size: 6, color: brownColor),
                      const SizedBox(width: 12),
                      Text(
                        'ELEVATING SKILL SHARING',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.circle, size: 6, color: brownColor),
                    ],
                  ),
                  const Spacer(flex: 5),
                  // Bottom Footer Text
                  Text(
                    'CRAFTING MASTERY THROUGH COMMUNITY',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      letterSpacing: 2,
                      color: Colors.black38,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

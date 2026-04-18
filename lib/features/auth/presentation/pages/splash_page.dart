import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/core/theme/theme.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_state.dart';
import 'package:skillswap/features/home/presentation/pages/home/home_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    // Start checking for user data immediately
    context.read<AuthCubit>().getUserData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryBgColor = AppColors.background;
    const accentColor = AppColors.primary;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        // Minimum display time for the splash screen
        Timer(const Duration(seconds: 2), () {
          if (!mounted) return;
          Navigator.of(
            context,
          ).pushAndRemoveUntil(HomePage.route(), (route) => false);
        });
      },
      child: Scaffold(
        backgroundColor: primaryBgColor,
        body: Stack(
          alignment: Alignment.center,
          children: [
            // Immersive Radial Glow
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.8,
                    colors: [AppColors.surface, primaryBgColor],
                  ),
                ),
              ),
            ),
            // Subtlest Bottom Glow
            Positioned(
              bottom: -150,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      accentColor.withValues(alpha: 0.08),
                      accentColor.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        const Spacer(flex: 3),
                        // Branding Halo
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    accentColor.withValues(alpha: 0.2),
                                    primaryBgColor.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.cardBackground,
                                border: Border.all(
                                  color: AppColors.borderDefault,
                                ),
                              ),

                              child: Image.asset(
                                'assets/logo.png',
                                width: 48,
                                height: 48,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 48),
                        // App Name
                        Text(
                          'SKILLSWAP',
                          style: AppTextStyles.h3.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 8.0,
                          ),
                        ),

                        const SizedBox(height: 16),
                        // Slogan
                        Text(
                          'LEARN • TEACH • GROW',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textPrimary.withValues(
                              alpha: 0.25,
                            ),
                            letterSpacing: 2.0,
                          ),
                        ),

                        const Spacer(flex: 3),
                        // Manifesto Footer
                        Text(
                          'YOUR JOURNEY STARTS HERE',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: accentColor.withValues(alpha: 0.4),
                            letterSpacing: 2.5,
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

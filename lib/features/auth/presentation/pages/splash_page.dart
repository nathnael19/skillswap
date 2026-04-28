import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/core/layout/responsive.dart';
import 'package:skillswap/core/theme/theme.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_state.dart';
import 'package:skillswap/features/home/presentation/pages/home/home_page.dart';
import 'package:skillswap/features/auth/presentation/pages/login_page.dart';
import 'package:skillswap/features/auth/presentation/pages/verify_email_page.dart';

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
        if (state is AuthSuccess) {
          Navigator.of(context).pushAndRemoveUntil(HomePage.route(), (route) => false);
        } else if (state is AuthInitial || state is AuthFailure) {
          Navigator.of(context).pushAndRemoveUntil(LoginPage.route(), (route) => false);
        } else if (state is AuthEmailUnverified) {
          Navigator.of(context).pushAndRemoveUntil(VerifyEmailPage.route(), (route) => false);
        }
      },
      child: Scaffold(
        backgroundColor: primaryBgColor,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final bottomGlowSize = (w * 0.9).clamp(260.0, 520.0);
            final haloSize = (w * 0.28).clamp(96.0, 140.0);
            final logoSize = (haloSize * 0.4).clamp(40.0, 56.0);

            return Stack(
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
                  bottom: -bottomGlowSize * 0.35,
                  child: Container(
                    width: bottomGlowSize,
                    height: bottomGlowSize,
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
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: Responsive.contentMaxWidthFor(context),
                          ),
                          child: SingleChildScrollView(
                            padding: Responsive.screenPadding(context),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight -
                                    MediaQuery.paddingOf(context).vertical,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(height: 40),
                                      // Branding Halo
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Container(
                                            width: haloSize,
                                            height: haloSize,
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
                                            padding: EdgeInsets.all(haloSize * 0.2),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppColors.cardBackground,
                                              border: Border.all(
                                                color: AppColors.borderDefault,
                                              ),
                                            ),
                                            child: Image.asset(
                                              'assets/logo.png',
                                              width: logoSize,
                                              height: logoSize,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 40),
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
                                    ],
                                  ),
                                  // Manifesto Footer
                                  Text(
                                    'YOUR JOURNEY STARTS HERE',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: accentColor.withValues(alpha: 0.4),
                                      letterSpacing: 2.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 40),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

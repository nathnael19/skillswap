import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/core/common/widgets/app_button.dart';
import 'package:skillswap/core/layout/responsive.dart';
import 'package:skillswap/core/theme/theme.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_state.dart';
import 'package:skillswap/features/home/presentation/pages/home/home_page.dart';

class VerifyEmailPage extends StatefulWidget {
  static MaterialPageRoute<dynamic> route() =>
      MaterialPageRoute(builder: (context) => const VerifyEmailPage());
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  Timer? _timer;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    // Periodically check verification status every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      context.read<AuthCubit>().checkEmailVerificationStatus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() {
      _resendCooldown = 60;
    });
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown == 0) {
        timer.cancel();
      } else {
        setState(() {
          _resendCooldown--;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = AppColors.primary;
    const primaryBgColor = AppColors.background;

    return Scaffold(
      backgroundColor: primaryBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: Responsive.valueFor<double>(
              context,
              compact: 18,
              mobile: 19,
              tablet: 20,
              tabletWide: 20,
              desktop: 22,
            ),
          ),
          onPressed: () {
            context.read<AuthCubit>().signOut();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is AuthSuccess) {
            _timer?.cancel();
            Navigator.of(context).pushAndRemoveUntil(
              HomePage.route(),
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          final screenW = MediaQuery.sizeOf(context).width;
          final glowSize = (screenW * 0.9).clamp(260.0, 460.0);

          return LayoutBuilder(
            builder: (context, constraints) {
              final iconOuter = Responsive.valueFor<double>(
                context,
                compact: 18,
                mobile: 20,
                tablet: 22,
                tabletWide: 24,
                desktop: 24,
              );
              final iconSize = Responsive.valueFor<double>(
                context,
                compact: 52,
                mobile: 58,
                tablet: 60,
                tabletWide: 64,
                desktop: 64,
              );
              final formMaxW = Responsive.valueFor<double>(
                context,
                compact: 400,
                mobile: 480,
                tablet: 520,
                tabletWide: 560,
                desktop: 600,
              );
              return Stack(
                children: [
                  // ambient glow
                  Positioned(
                    top: -glowSize * 0.35,
                    left: -glowSize * 0.15,
                    child: Container(
                      width: glowSize,
                      height: glowSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            accentColor.withValues(alpha: 0.08),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: formMaxW),
                        child: SingleChildScrollView(
                          padding: Responsive.screenPadding(context),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight -
                                  MediaQuery.paddingOf(context).vertical,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(iconOuter),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.overlay03,
                                    border: Border.all(color: AppColors.overlay08),
                                  ),
                                  child: Icon(
                                    Icons.mark_email_read_outlined,
                                    size: iconSize,
                                    color: accentColor,
                                  ),
                                ),
                                SizedBox(height: Responsive.valueFor<double>(context, compact: 24, mobile: 28, tablet: 30, tabletWide: 32, desktop: 32)),
                                Text(
                                  'Verify your email',
                                  style: AppTextStyles.h2,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'We\'ve sent a verification link to your email address. Please check your inbox and click the link to activate your account.',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: Responsive.valueFor<double>(context, compact: 24, mobile: 28, tablet: 30, tabletWide: 32, desktop: 32)),
                                AppButton(
                                  label: 'I have verified',
                                  isLoading: isLoading,
                                  onTap: () {
                                    context
                                        .read<AuthCubit>()
                                        .checkEmailVerificationStatus();
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextButton(
                                  onPressed: _resendCooldown > 0 || isLoading
                                      ? null
                                      : () {
                                          context
                                              .read<AuthCubit>()
                                              .sendEmailVerification();
                                          _startCooldown();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Verification email resent!'),
                                              backgroundColor: AppColors.success,
                                            ),
                                          );
                                        },
                                  child: Text(
                                    _resendCooldown > 0
                                        ? 'Resend email in ${_resendCooldown}s'
                                        : 'Resend verification email',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: _resendCooldown > 0
                                          ? AppColors.textMuted
                                          : accentColor,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                if (isLoading)
                                  const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      accentColor,
                                    ),
                                  ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

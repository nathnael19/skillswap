import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/core/common/widgets/app_button.dart';
import 'package:skillswap/core/layout/responsive.dart';
import 'package:skillswap/core/theme/theme.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_state.dart';
import 'package:skillswap/features/auth/presentation/widgets/auth_social_button.dart';
import 'package:skillswap/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:skillswap/features/home/presentation/pages/home/home_page.dart';
import 'package:skillswap/features/auth/presentation/pages/onboarding_page.dart';
import 'package:skillswap/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:skillswap/features/auth/presentation/pages/verify_email_page.dart';

class LoginPage extends StatefulWidget {
  static MaterialPageRoute<dynamic> route() =>
      MaterialPageRoute(builder: (context) => const LoginPage());
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryBgColor = AppColors.background;
    const accentColor = AppColors.primary;

    return Scaffold(
      backgroundColor: primaryBgColor,
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
            Navigator.of(
              context,
            ).pushAndRemoveUntil(HomePage.route(), (route) => false);
          } else if (state is AuthEmailUnverified) {
            Navigator.of(context).push(VerifyEmailPage.route());
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return LayoutBuilder(
            builder: (context, constraints) {
              final screenW = constraints.maxWidth;
              final screenH = constraints.maxHeight;
              final glowSize = (screenW * 0.95).clamp(260.0, 520.0);
              final isTabletLayout = Responsive.isTablet(context) ||
                  Responsive.isTabletWide(context) ||
                  Responsive.isDesktop(context);
              final logoHaloSize = isTabletLayout ? 120.0 : 100.0;
              final logoIconSize = isTabletLayout ? 48.0 : 40.0;
              final verticalGap = (screenH * 0.06).clamp(32.0, 80.0);
              final topPad = (verticalGap * 0.9).clamp(28.0, 72.0);
              final sectionGap = Responsive.valueFor<double>(
                context,
                compact: 36,
                mobile: 44,
                tablet: 48,
                tabletWide: 52,
                desktop: 56,
              );
              final formMaxW = Responsive.valueFor<double>(
                context,
                compact: 400,
                mobile: 480,
                tablet: 520,
                tabletWide: 560,
                desktop: 600,
              );

              return AbsorbPointer(
                absorbing: isLoading,
                child: Stack(
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
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: Responsive.screenPadding(context),
                        child: Form(
                          key: formKey,
                          child: Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: formMaxW),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(height: topPad),
                                  // Premium Logo Branding (Glass Halo)
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: logoHaloSize,
                                        height: logoHaloSize,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: RadialGradient(
                                            colors: [
                                              accentColor.withValues(
                                                alpha: 0.15,
                                              ),
                                              primaryBgColor.withValues(
                                                alpha: 0.0,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(
                                          (logoHaloSize * 0.2).clamp(14.0, 24.0),
                                        ),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.overlay03,
                                          border: Border.all(
                                            color: AppColors.overlay08,
                                          ),
                                        ),
                                        child: Image.asset(
                                          'assets/logo.png',
                                          width: logoIconSize,
                                          height: logoIconSize,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: verticalGap * 0.45),
                                  Text(
                                    'SKILLSWAP',
                                    style: AppTextStyles.captionEmphasis
                                        .copyWith(letterSpacing: 4),
                                  ),
                                  SizedBox(height: verticalGap * 0.75),
                                  // Welcome Title
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Welcome Back',
                                      style: AppTextStyles.h2,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Sign in to your account to continue.',
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: sectionGap),

                                  // Email Field
                                  AuthTextField(
                                    label: 'Email Address',
                                    controller: emailController,
                                    hint: 'master@skillswap.com',
                                    icon: Icons.mail_outline_rounded,
                                  ),
                                  const SizedBox(height: 24),

                                  // Password Field
                                  AuthTextField(
                                    label: 'Password',
                                    controller: passwordController,
                                    hint: 'Enter your password',
                                    icon: Icons.lock_outline_rounded,
                                    isPassword: true,
                                  ),

                                  const SizedBox(height: 16),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.of(
                                          context,
                                        ).push(ForgotPasswordPage.route());
                                      },
                                      child: Text(
                                        'Forgot Password?',
                                        style: AppTextStyles.labelSmall
                                            .copyWith(
                                              color: accentColor,
                                              letterSpacing: 1.0,
                                              fontWeight: FontWeight.w900,
                                            ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: sectionGap),

                                  // Sign In Button
                                  AppButton(
                                    label: 'Sign In',
                                    isLoading: isLoading,
                                    onTap: () {
                                      if (formKey.currentState!.validate()) {
                                        context.read<AuthCubit>().signIn(
                                          email: emailController.text.trim(),
                                          password: passwordController.text
                                              .trim(),
                                        );
                                      }
                                    },
                                  ),
                                  SizedBox(height: sectionGap),

                                  // Divider
                                  Row(
                                    children: [
                                      const Expanded(
                                        child: Divider(
                                          color: AppColors.borderSubtle,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0,
                                        ),
                                        child: Text(
                                          'Or sign in with',
                                          style: AppTextStyles.labelSmall
                                              .copyWith(
                                                color: AppColors.textMuted,
                                                letterSpacing: 2,
                                              ),
                                        ),
                                      ),
                                      const Expanded(
                                        child: Divider(
                                          color: AppColors.borderSubtle,
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: sectionGap * 0.85),

                                  // Social Login Buttons
                                  Row(
                                    children: [
                                      Expanded(
                                        child: AuthSocialButton(
                                          label: 'Google',
                                          icon: Icons.g_mobiledata_rounded,
                                          onTap: () {
                                            context
                                                .read<AuthCubit>()
                                                .signInWithGoogle();
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: AuthSocialButton(
                                          label: 'Apple',
                                          icon: Icons.apple_rounded,
                                          onTap: () {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Apple Sign-In coming soon!',
                                                ),
                                                backgroundColor:
                                                    AppColors.surface,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: verticalGap * 0.85),

                                  // Sign Up Link
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "New to SkillSwap? ",
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),

                                      GestureDetector(
                                        onTap: () {
                                          Navigator.of(
                                            context,
                                          ).push(OnboardingPage.route());
                                        },
                                        child: Text(
                                          "Sign Up",
                                          style: AppTextStyles.link.copyWith(
                                            color: accentColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: verticalGap * 0.55),
                                  Padding(
                                    padding: EdgeInsets.all(
                                      Responsive.valueFor<double>(
                                        context,
                                        compact: 20,
                                        mobile: 24,
                                        tablet: 28,
                                        tabletWide: 32,
                                        desktop: 32,
                                      ),
                                    ),
                                    child: Text(
                                      '© 2026 SkillSwap',
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.textMuted,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

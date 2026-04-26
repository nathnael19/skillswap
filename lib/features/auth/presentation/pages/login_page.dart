import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/core/common/widgets/app_button.dart';
import 'package:skillswap/core/theme/theme.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_state.dart';
import 'package:skillswap/features/auth/presentation/widgets/auth_social_button.dart';
import 'package:skillswap/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:skillswap/features/home/presentation/pages/home/home_page.dart';
import 'package:skillswap/features/auth/presentation/pages/onboarding_page.dart';

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
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return AbsorbPointer(
            absorbing: isLoading,
            child: Stack(
              children: [
                // ambient glow
                Positioned(
                  top: -150,
                  left: -50,
                  child: Container(
                    width: 400,
                    height: 400,
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
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 60),
                          // Premium Logo Branding (Glass Halo)
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      accentColor.withValues(alpha: 0.15),
                                      primaryBgColor.withValues(alpha: 0.0),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.overlay03,
                                  border: Border.all(
                                    color: AppColors.overlay08,
                                  ),
                                ),
                                child: Image.asset(
                                  'assets/logo.png',
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'SKILLSWAP',
                            style: AppTextStyles.captionEmphasis.copyWith(
                              letterSpacing: 4,
                            ),
                          ),
                          const SizedBox(height: 60),
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

                          const SizedBox(height: 48),

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
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Password reset link will be sent to your email.',
                                    ),
                                    backgroundColor: accentColor,
                                  ),
                                );
                              },
                              child: Text(
                                'Forgot Password?',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: accentColor,
                                  letterSpacing: 1.0,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 48),

                          // Sign In Button
                          AppButton(
                            label: 'Sign In',
                            isLoading: isLoading,
                            onTap: () {
                              if (formKey.currentState!.validate()) {
                                context.read<AuthCubit>().signIn(
                                  email: emailController.text.trim(),
                                  password: passwordController.text.trim(),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 48),

                          // Divider
                          Row(
                            children: [
                              const Expanded(
                                child: Divider(color: AppColors.borderSubtle),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                ),
                                child: Text(
                                  'Or sign in with',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.textMuted,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Divider(color: AppColors.borderSubtle),
                              ),
                            ],
                          ),

                          const SizedBox(height: 40),

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
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Apple Sign-In coming soon!',
                                        ),
                                        backgroundColor: AppColors.surface,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 60),

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
                          const SizedBox(height: 40),
                          Padding(
                            padding: const EdgeInsets.all(32.0),
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
              ],
            ),
          );
        },
      ),
    );
  }
}

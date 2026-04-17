import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/core/common/widgets/app_button.dart';
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
    const primaryBgColor = Color(0xFF0C0A09);
    const accentColor = Color(0xFFCA8A04);

    return Scaffold(
      backgroundColor: primaryBgColor,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message, style: GoogleFonts.dmSans()),
                backgroundColor: const Color(0xFFEF4444),
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
                                  color: Colors.white.withValues(alpha: 0.03),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.08),
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
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 4,
                            ),
                          ),
                          const SizedBox(height: 60),
                          // Welcome Title
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Welcome Back',
                              style: GoogleFonts.dmSans(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Sign in to your account to continue.',
                              style: GoogleFonts.dmSans(
                                fontSize: 16,
                                color: Colors.white.withValues(alpha: 0.4),
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
                            child: Text(
                              'Forgot Password?',
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: accentColor,
                                letterSpacing: 1.0,
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
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: Colors.white.withValues(alpha: 0.05),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                ),
                                child: Text(
                                  'Or sign in with',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2,
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: Colors.white.withValues(alpha: 0.05),
                                ),
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
                                  onTap: () {},
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: AuthSocialButton(
                                  label: 'Apple',
                                  icon: Icons.apple_rounded,
                                  onTap: () {},
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
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  color: Colors.white.withValues(alpha: 0.3),
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
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
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
                              style: GoogleFonts.dmSans(
                                fontSize: 8,
                                letterSpacing: 1.5,
                                color: Colors.white.withValues(alpha: 0.1),
                                fontWeight: FontWeight.w800,
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

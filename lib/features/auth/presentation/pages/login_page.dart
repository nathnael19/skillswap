import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/core/common/widgets/app_button.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_state.dart';
import 'package:skillswap/features/auth/presentation/widgets/auth_social_button.dart';
import 'package:skillswap/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:skillswap/features/home/presentation/pages/home_page.dart';
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
    const tealColor = Color(0xFF0B6A7A);
    const borderColor = Color(0xFFE0E5EF);

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
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
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),
                      // Logo Text
                      Text(
                        'THE CURATOR',
                        style: GoogleFonts.lora(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 3,
                          color: tealColor,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Welcome Title
                      Text(
                        'Welcome Back',
                        style: GoogleFonts.inter(
                          fontSize: 32,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1E1E1E),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Subtitle
                      Text(
                        'Please enter your credentials to continue.',
                        style: GoogleFonts.lora(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Email Field
                      AuthTextField(
                        label: 'EMAIL ADDRESS',
                        controller: emailController,
                        hint: 'curator@skillswap.com',
                        icon: Icons.mail_outline,
                      ),
                      const SizedBox(height: 24),

                      // Password Header (with Forgot Password)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'PASSWORD',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'FORGOT PASSWORD?',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: tealColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Using the field logic from AuthTextField but without the built-in label 
                      // because this row is custom. Alternatively, I could just use AuthTextField
                      // and add a trailing widget to it, but keeping it simple for now.
                      AuthTextField(
                        label: '', // Hidden label as we built it above
                        controller: passwordController,
                        hint: '........',
                        icon: Icons.lock_outline,
                        isPassword: true,
                      ),
                      const SizedBox(height: 40),

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
                          const Expanded(child: Divider(color: borderColor)),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Text(
                              'OR CONTINUE WITH',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                                color: Colors.black26,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider(color: borderColor)),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // Social Login Buttons
                      Row(
                        children: [
                          Expanded(
                            child: AuthSocialButton(
                              label: 'GOOGLE',
                              icon: Icons.g_mobiledata,
                              onTap: () {},
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AuthSocialButton(
                              label: 'APPLE',
                              icon: Icons.apple,
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),

                      // Sign Up Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(OnboardingPage.route());
                            },
                            child: Text(
                              "Sign Up",
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: tealColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          '© 2026 THE CURATOR • SKILLSWAP ECOSYSTEM',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 8,
            letterSpacing: 1,
            color: Colors.black26,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

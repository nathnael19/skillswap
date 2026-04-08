import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_state.dart';
import 'package:skillswap/features/auth/presentation/pages/login_page.dart';
import 'package:skillswap/features/auth/presentation/widgets/registration_success_overlay.dart';
import 'package:skillswap/features/home/presentation/pages/home_page.dart';

class RegisterPage extends StatefulWidget {
  static MaterialPageRoute<dynamic> route() =>
      MaterialPageRoute(builder: (context) => const RegisterPage());
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const tealColor = Color(0xFF0B6A7A);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: tealColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'THE CURATOR',
          style: GoogleFonts.lora(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
            color: tealColor,
          ),
        ),
        centerTitle: false,
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is AuthSuccess) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => RegistrationSuccessOverlay(
                onAnimationComplete: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    HomePage.route(),
                    (route) => false,
                  );
                },
              ),
            );
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
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          Text(
                            'Create Account',
                            style: GoogleFonts.inter(
                              fontSize: 32,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF1E1E1E),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Step into a space of curated expertise.',
                            style: GoogleFonts.lora(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 40),

                          _buildLabel('FULL NAME'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: nameController,
                            hint: 'Julian Vane',
                            icon: Icons.person_outline,
                          ),
                          const SizedBox(height: 24),

                          _buildLabel('EMAIL ADDRESS'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: emailController,
                            hint: 'julian@nexus.exchange',
                            icon: Icons.mail_outline,
                          ),
                          const SizedBox(height: 24),

                          _buildLabel('PASSWORD'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: passwordController,
                            hint: '........',
                            icon: Icons.lock_outline,
                            isPassword: true,
                          ),
                          const SizedBox(height: 24),

                          _buildLabel('CONFIRM PASSWORD'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: confirmPasswordController,
                            hint: '........',
                            icon: Icons.verified_user_outlined,
                            isPassword: true,
                          ),
                          const SizedBox(height: 48),

                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      if (formKey.currentState!.validate()) {
                                        if (passwordController.text !=
                                            confirmPasswordController.text) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content:
                                                  Text('Passwords do not match'),
                                            ),
                                          );
                                          return;
                                        }
                                        context.read<AuthCubit>().signUp(
                                              name: nameController.text.trim(),
                                              email: emailController.text.trim(),
                                              password:
                                                  passwordController.text.trim(),
                                            );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: tealColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                elevation: 2,
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Create Account',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 48),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already part of the community? ",
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(
                                    context,
                                  ).pushReplacement(LoginPage.route());
                                },
                                child: Text(
                                  "Log In",
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
          '© 2024 THE CURATOR NEXUS EXCHANGE • ALL RIGHTS RESERVED',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 8,
            letterSpacing: 0.5,
            color: Colors.black26,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    const lightGrey = Color(0xFFF1F3F9);
    return Container(
      decoration: BoxDecoration(
        color: lightGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        style: GoogleFonts.inter(fontSize: 14),
        textAlign: TextAlign.left,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: Colors.black26),
          suffixIcon: Icon(icon, color: Colors.black38, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter this field';
          }
          return null;
        },
      ),
    );
  }
}

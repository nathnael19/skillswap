import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/core/common/widgets/app_button.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_state.dart';
import 'package:skillswap/features/auth/presentation/pages/login_page.dart';
import 'package:skillswap/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:skillswap/features/auth/presentation/widgets/registration_success_overlay.dart';
import 'package:skillswap/features/home/presentation/pages/home_page.dart';

class OnboardingPage extends StatefulWidget {
  static MaterialPageRoute<dynamic> route() =>
      MaterialPageRoute(builder: (context) => const OnboardingPage());
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Form Fields
  final nameController = TextEditingController();
  final professionController = TextEditingController();
  final locationController = TextEditingController();
  final bioController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Skills State
  final List<Map<String, String>> _skills = [];
  final TextEditingController _skillInputController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    nameController.dispose();
    professionController.dispose();
    locationController.dispose();
    bioController.dispose();
    emailController.dispose();
    passwordController.dispose();
    _skillInputController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _register();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _addSkill(String type) {
    if (_skillInputController.text.isNotEmpty) {
      setState(() {
        _skills.add({
          'name': _skillInputController.text,
          'type': type,
          'category': 'General',
        });
        _skillInputController.clear();
      });
    }
  }

  void _removeSkill(int index) {
    setState(() {
      _skills.removeAt(index);
    });
  }

  void _register() {
    context.read<AuthCubit>().signUp(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      bio: bioController.text.trim(),
      profession: professionController.text.trim(),
      location: locationController.text.trim(),
      skills: _skills,
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryBgColor = Color(0xFF0C0A09);
    const accentColor = Color(0xFFCA8A04);

    return Scaffold(
      backgroundColor: primaryBgColor,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: AppBar(
              backgroundColor: primaryBgColor.withValues(alpha: 0.8),
              elevation: 0,
              leading: Center(
                child: GestureDetector(
                  onTap: _currentStep > 0 ? _previousStep : () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: Icon(
                      _currentStep > 0 ? Icons.arrow_back_rounded : Icons.close_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ENROLLMENT JOURNEY',
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: accentColor,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildProgressTrack(accentColor),
                ],
              ),
              centerTitle: true,
              shape: Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 1),
              ),
            ),
          ),
        ),
      ),
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
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => RegistrationSuccessOverlay(
                onAnimationComplete: () {
                  Navigator.of(context).pushAndRemoveUntil(HomePage.route(), (route) => false);
                },
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Stack(
            children: [
              // Ambient Background Glows
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        accentColor.withValues(alpha: 0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentStep = index),
                children: [
                  _buildStep(
                    title: 'Digital Identity',
                    subtitle: 'Manifest your profile within the SkillSwap ecosystem.',
                    content: [
                      AuthTextField(
                        label: 'FULL NAME',
                        controller: nameController,
                        hint: 'Julian Vane',
                        icon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 24),
                      AuthTextField(
                        label: 'PROFESSION',
                        controller: professionController,
                        hint: 'UX Designer / Full-stack Dev',
                        icon: Icons.work_outline_rounded,
                      ),
                      const SizedBox(height: 24),
                      AuthTextField(
                        label: 'LOCATION',
                        controller: locationController,
                        hint: 'San Francisco, CA',
                        icon: Icons.location_on_outlined,
                      ),
                    ],
                    onContinue: () {
                      if (nameController.text.isNotEmpty && professionController.text.isNotEmpty) {
                        _nextStep();
                      }
                    },
                    footer: _buildAuthSwitch('Already in the Nexus?', 'Log In', () {
                      Navigator.of(context).push(LoginPage.route());
                    }),
                  ),
                  _buildStep(
                    title: 'Your Mastery',
                    subtitle: 'What wisdom will you share with the community?',
                    content: [
                      AuthTextField(
                        label: 'PERSONAL MANIFESTO',
                        controller: bioController,
                        hint: 'Briefly describe your journey...',
                        icon: Icons.notes_rounded,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'SKILLS YOU TEACH',
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.white.withValues(alpha: 0.3),
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSkillInput('teach'),
                      const SizedBox(height: 24),
                      _buildSkillWrap('teach'),
                    ],
                    onContinue: _nextStep,
                  ),
                  _buildStep(
                    title: 'Growth Vectors',
                    subtitle: 'What would you like to manifest next?',
                    content: [
                      Text(
                        'SKILLS YOU WANT TO LEARN',
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.white.withValues(alpha: 0.3),
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSkillInput('learn'),
                      const SizedBox(height: 24),
                      _buildSkillWrap('learn'),
                    ],
                    onContinue: _nextStep,
                  ),
                  _buildStep(
                    title: 'Account Manifest',
                    subtitle: 'Finalize your enrollment in the SkillSwap Nexus.',
                    content: [
                      AuthTextField(
                        label: 'EMAIL ADDRESS',
                        controller: emailController,
                        hint: 'master@skillswap.com',
                        icon: Icons.mail_outline_rounded,
                      ),
                      const SizedBox(height: 24),
                      AuthTextField(
                        label: 'SECURE KEY',
                        controller: passwordController,
                        hint: '........',
                        icon: Icons.lock_outline_rounded,
                        isPassword: true,
                      ),
                    ],
                    onContinue: () {
                      if (emailController.text.isNotEmpty && passwordController.text.length >= 6) {
                        _register();
                      }
                    },
                    isLoading: isLoading,
                    ctaLabel: 'Complete Enrollment',
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStep({
    required String title,
    required String subtitle,
    required List<Widget> content,
    required VoidCallback onContinue,
    Widget? footer,
    bool isLoading = false,
    String ctaLabel = 'Continue',
  }) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 140, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: GoogleFonts.dmSans(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.4),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 48),
          ...content,
          const SizedBox(height: 56),
          AppButton(
            label: ctaLabel,
            isLoading: isLoading,
            onTap: onContinue,
          ),
          if (footer != null) ...[
            const SizedBox(height: 32),
            footer,
          ],
        ],
      ),
    );
  }

  Widget _buildProgressTrack(Color accent) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        bool isActive = index <= _currentStep;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 4,
          width: 32,
          decoration: BoxDecoration(
            color: isActive ? accent : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(2),
            boxShadow: isActive ? [
              BoxShadow(color: accent.withValues(alpha: 0.3), blurRadius: 8)
            ] : [],
          ),
        );
      }),
    );
  }

  Widget _buildSkillInput(String type) {
    const accentColor = Color(0xFFCA8A04);
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _skillInputController,
              style: GoogleFonts.dmSans(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'e.g. Flutter, Advanced Design...',
                hintStyle: GoogleFonts.dmSans(color: Colors.white.withValues(alpha: 0.15)),
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _addSkill(type),
            ),
          ),
          GestureDetector(
            onTap: () => _addSkill(type),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillWrap(String type) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _skills
          .asMap()
          .entries
          .where((e) => e.value['type'] == type)
          .map(
            (e) => Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    e.value['name']!.toUpperCase(),
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withValues(alpha: 0.6),
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _removeSkill(e.key),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded, color: Colors.white24, size: 12),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildAuthSwitch(String question, String action, VoidCallback onTap) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "$question ",
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Text(
              action,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFCA8A04),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

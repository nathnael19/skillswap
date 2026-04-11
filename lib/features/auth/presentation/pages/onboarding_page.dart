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
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _register();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
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
    const tealColor = Color(0xFF0B6A7A);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: tealColor),
                onPressed: _previousStep,
              )
            : IconButton(
                icon: const Icon(Icons.close, color: tealColor),
                onPressed: () => Navigator.pop(context),
              ),
        title: Column(
          children: [
            Text(
              'STEP ${_currentStep + 1} OF 4',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: tealColor.withOpacity(0.5),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(4, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  height: 3,
                  width: 20,
                  decoration: BoxDecoration(
                    color: index <= _currentStep
                        ? tealColor
                        : tealColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            ),
          ],
        ),
        centerTitle: true,
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
                  Navigator.of(
                    context,
                  ).pushAndRemoveUntil(HomePage.route(), (route) => false);
                },
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) => setState(() => _currentStep = index),
            children: [
              _buildStep1(),
              _buildStep2(),
              _buildStep3(),
              _buildStep4(isLoading),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStep1() {
    const tealColor = Color(0xFF0B6A7A);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tell us about yourself',
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Help us build your digital identity in the Nexus.',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: const Color(0xFF667085),
            ),
          ),
          const SizedBox(height: 40),
          AuthTextField(
            label: 'FULL NAME',
            controller: nameController,
            hint: 'Julian Vane',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 24),
          AuthTextField(
            label: 'PROFESSION',
            controller: professionController,
            hint: 'UX Designer / Full-stack Dev',
            icon: Icons.work_outline,
          ),
          const SizedBox(height: 24),
          AuthTextField(
            label: 'LOCATION',
            controller: locationController,
            hint: 'San Francisco, CA',
            icon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 48),
          AppButton(
            label: 'Continue',
            onTap: () {
              if (nameController.text.isNotEmpty &&
                  professionController.text.isNotEmpty) {
                _nextStep();
              }
            },
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Already have an account? ",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF667085),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(LoginPage.route());
                },
                child: Text(
                  "Log In",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: tealColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Expertise',
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'What wisdom can you share with the community?',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: const Color(0xFF667085),
            ),
          ),
          const SizedBox(height: 40),
          AuthTextField(
            label: 'PERSONAL BIO',
            controller: bioController,
            hint: 'Briefly describe your journey...',
            icon: Icons.notes,
            maxLines: 4,
          ),
          const SizedBox(height: 32),
          Text(
            'SKILLS YOU TEACH',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF101828),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AuthTextField(
                  label: '',
                  controller: _skillInputController,
                  hint: 'e.g. Flutter, Design Thinking...',
                  icon: Icons.add_task,
                ),
              ),
              const SizedBox(width: 12),
              IconButton.filled(
                onPressed: () => _addSkill('teach'),
                icon: const Icon(Icons.add),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF0B6A7A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _skills
                .asMap()
                .entries
                .where((e) => e.value['type'] == 'teach')
                .map(
                  (e) => Chip(
                    label: Text(e.value['name']!),
                    onDeleted: () => _removeSkill(e.key),
                    backgroundColor: const Color(0xFFF2F4F7),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 48),
          AppButton(label: 'Continue', onTap: _nextStep),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Growth Goals',
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'What would you like to master next?',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: const Color(0xFF667085),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'SKILLS YOU WANT TO LEARN',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF101828),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AuthTextField(
                  label: '',
                  controller: _skillInputController,
                  hint: 'e.g. Advanced AI, Public Speaking...',
                  icon: Icons.trending_up,
                ),
              ),
              const SizedBox(width: 12),
              IconButton.filled(
                onPressed: () => _addSkill('learn'),
                icon: const Icon(Icons.add),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF0B6A7A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _skills
                .asMap()
                .entries
                .where((e) => e.value['type'] == 'learn')
                .map(
                  (e) => Chip(
                    label: Text(e.value['name']!),
                    onDeleted: () => _removeSkill(e.key),
                    backgroundColor: const Color(0xFFF2F4F7),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 48),
          AppButton(label: 'Continue', onTap: _nextStep),
        ],
      ),
    );
  }

  Widget _buildStep4(bool isLoading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Finalize Account',
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Last step to join the SkillSwap community.',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: const Color(0xFF667085),
            ),
          ),
          const SizedBox(height: 40),
          AuthTextField(
            label: 'EMAIL ADDRESS',
            controller: emailController,
            hint: 'julian@example.com',
            icon: Icons.mail_outline,
          ),
          const SizedBox(height: 24),
          AuthTextField(
            label: 'PASSWORD',
            controller: passwordController,
            hint: '........',
            icon: Icons.lock_outline,
            isPassword: true,
          ),
          const SizedBox(height: 48),
          AppButton(
            label: 'Complete Registration',
            isLoading: isLoading,
            onTap: () {
              if (emailController.text.isNotEmpty &&
                  passwordController.text.length >= 6) {
                _register();
              }
            },
          ),
        ],
      ),
    );
  }
}

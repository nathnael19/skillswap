import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/core/theme/theme.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_state.dart';
import 'package:skillswap/features/auth/presentation/widgets/registration_success_overlay.dart';
import 'package:skillswap/features/home/presentation/pages/home/home_page.dart';
import 'package:skillswap/features/auth/presentation/pages/verify_email_page.dart';
import 'package:skillswap/core/constants/app_categories.dart';

import '../widgets/onboarding/about_you_step.dart';
import '../widgets/onboarding/expertise_step.dart';
import '../widgets/onboarding/learning_step.dart';
import '../widgets/onboarding/account_creation_step.dart';

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
  final List<Map<String, dynamic>> _skills = [];
  String? _selectedCategory;
  String? _selectedExpertise;

  @override
  void initState() {
    super.initState();
    _selectedCategory = AppCategories.categories.first;
    _selectedExpertise = AppCategories.expertiseLevels[1]; // Skip 'All'
  }

  @override
  void dispose() {
    _pageController.dispose();
    nameController.dispose();
    professionController.dispose();
    locationController.dispose();
    bioController.dispose();
    emailController.dispose();
    passwordController.dispose();
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

  void _addSkill(String type, String skillName) {
    setState(() {
      _skills.add({'name': skillName, 'type': type, 'category': 'General'});
    });
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
      primaryCategory: _selectedCategory,
      expertiseLevel: _selectedExpertise,
      skills: _skills,
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryBgColor = AppColors.background;
    const accentColor = AppColors.primary;

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
                  onTap: _currentStep > 0
                      ? _previousStep
                      : () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.borderSubtle,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.borderDefault),
                    ),
                    child: Icon(
                      _currentStep > 0
                          ? Icons.arrow_back_rounded
                          : Icons.close_rounded,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                  ),
                ),
              ),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Profile Setup',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: accentColor,
                      letterSpacing: 2.0,
                    ),
                  ),

                  const SizedBox(height: 12),
                  _buildProgressTrack(accentColor),
                ],
              ),
              centerTitle: true,
              shape: const Border(
                bottom: BorderSide(color: AppColors.borderSubtle, width: 1),
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
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is AuthEmailUnverified) {
            Navigator.of(context).pushAndRemoveUntil(
              VerifyEmailPage.route(),
              (route) => false,
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
                  AboutYouStep(
                    nameController: nameController,
                    professionController: professionController,
                    locationController: locationController,
                    selectedCategory: _selectedCategory,
                    selectedExpertise: _selectedExpertise,
                    onCategoryChanged: (val) => setState(() => _selectedCategory = val),
                    onExpertiseChanged: (val) => setState(() => _selectedExpertise = val),
                    onContinue: () {
                      if (nameController.text.isNotEmpty &&
                          professionController.text.isNotEmpty) {
                        _nextStep();
                      }
                    },
                  ),
                  ExpertiseStep(
                    bioController: bioController,
                    skills: _skills,
                    onAddSkill: (skill) => _addSkill('teach', skill),
                    onRemoveSkill: _removeSkill,
                    onContinue: _nextStep,
                  ),
                  LearningStep(
                    skills: _skills,
                    onAddSkill: (skill) => _addSkill('learn', skill),
                    onRemoveSkill: _removeSkill,
                    onContinue: _nextStep,
                  ),
                  AccountCreationStep(
                    emailController: emailController,
                    passwordController: passwordController,
                    isLoading: isLoading,
                    onContinue: () {
                      if (emailController.text.isNotEmpty &&
                          passwordController.text.length >= 6) {
                        _register();
                      }
                    },
                  ),
                ],
              ),
            ],
          );
        },
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
            color: isActive ? accent : AppColors.borderSubtle,
            borderRadius: BorderRadius.circular(2),

            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.3),
                      blurRadius: 8,
                    ),
                  ]
                : [],
          ),
        );
      }),
    );
  }
}

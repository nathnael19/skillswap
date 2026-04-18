import 'package:flutter/material.dart';
import 'package:skillswap/core/theme/theme.dart';
import 'package:skillswap/features/auth/presentation/pages/login_page.dart';
import 'package:skillswap/features/auth/presentation/widgets/auth_text_field.dart';
import 'onboarding_step_layout.dart';
import 'package:skillswap/core/constants/app_categories.dart';

class AboutYouStep extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController professionController;
  final TextEditingController locationController;
  final String? selectedCategory;
  final String? selectedExpertise;
  final Function(String?) onCategoryChanged;
  final Function(String?) onExpertiseChanged;
  final VoidCallback onContinue;

  const AboutYouStep({
    super.key,
    required this.nameController,
    required this.professionController,
    required this.locationController,
    required this.selectedCategory,
    required this.selectedExpertise,
    required this.onCategoryChanged,
    required this.onExpertiseChanged,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingStepLayout(
      title: 'About You',
      subtitle: "Let's set up your profile so others can find you.",
      content: [
        AuthTextField(
          label: 'Full Name',
          controller: nameController,
          hint: 'Julian Vane',
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 24),
        AuthTextField(
          label: 'Profession',
          controller: professionController,
          hint: 'UX Designer / Full-stack Dev',
          icon: Icons.work_outline_rounded,
        ),
        const SizedBox(height: 24),
        AuthTextField(
          label: 'Location',
          controller: locationController,
          hint: 'San Francisco, CA',
          icon: Icons.location_on_outlined,
        ),
        const SizedBox(height: 24),

        // Category Selection
        DropdownButtonFormField<String>(
          value: selectedCategory,
          dropdownColor: AppColors.surface,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            labelText: 'Primary Category',
            labelStyle: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
            prefixIcon: const Icon(Icons.category_outlined, color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.overlay05,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.borderSubtle),
            ),
          ),
          items: AppCategories.categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: onCategoryChanged,
        ),
        const SizedBox(height: 24),

        // Expertise Selection
        DropdownButtonFormField<String>(
          value: selectedExpertise,
          dropdownColor: AppColors.surface,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            labelText: 'Expertise Level',
            labelStyle: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
            prefixIcon: const Icon(Icons.show_chart_rounded, color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.overlay05,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.borderSubtle),
            ),
          ),
          items: AppCategories.expertiseLevels.where((e) => e != 'All').map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onExpertiseChanged,
        ),
      ],
      onContinue: onContinue,
      footer: _buildAuthSwitch(
        context,
        'Already have an account?',
        'Log in',
        () {
          Navigator.of(context).push(LoginPage.route());
        },
      ),
    );
  }

  Widget _buildAuthSwitch(
    BuildContext context,
    String question,
    String action,
    VoidCallback onTap,
  ) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "$question ",
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Text(action, style: AppTextStyles.link),
          ),
        ],
      ),
    );
  }
}

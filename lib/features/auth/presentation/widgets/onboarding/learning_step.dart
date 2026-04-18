import 'package:flutter/material.dart';
import 'package:skillswap/core/theme/theme.dart';
import 'onboarding_step_layout.dart';
import 'skill_selection_input.dart';

class LearningStep extends StatelessWidget {
  final List<Map<String, dynamic>> skills;
  final Function(String) onAddSkill;
  final Function(int) onRemoveSkill;
  final VoidCallback onContinue;

  const LearningStep({
    super.key,
    required this.skills,
    required this.onAddSkill,
    required this.onRemoveSkill,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingStepLayout(
      title: 'What you want to learn',
      subtitle: 'What new skills are you looking to pick up?',
      content: [
        Text(
          'SKILLS TO LEARN',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: 16),
        SkillSelectionInput(
          type: 'learn',
          skills: skills,
          onAddSkill: onAddSkill,
          onRemoveSkill: onRemoveSkill,
        ),
      ],
      onContinue: onContinue,
    );
  }
}

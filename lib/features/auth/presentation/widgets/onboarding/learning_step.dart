import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'onboarding_step_layout.dart';
import 'skill_selection_input.dart';

class LearningStep extends StatelessWidget {
  final List<Map<String, String>> skills;
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
          style: GoogleFonts.dmSans(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: Colors.white.withValues(alpha: 0.3),
            letterSpacing: 1.5,
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

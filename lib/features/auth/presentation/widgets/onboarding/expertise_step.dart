import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/features/auth/presentation/widgets/auth_text_field.dart';
import 'onboarding_step_layout.dart';
import 'skill_selection_input.dart';

class ExpertiseStep extends StatelessWidget {
  final TextEditingController bioController;
  final List<Map<String, String>> skills;
  final Function(String) onAddSkill;
  final Function(int) onRemoveSkill;
  final VoidCallback onContinue;

  const ExpertiseStep({
    super.key,
    required this.bioController,
    required this.skills,
    required this.onAddSkill,
    required this.onRemoveSkill,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingStepLayout(
      title: 'Your Expertise',
      subtitle: 'What skills are you excited to teach?',
      content: [
        AuthTextField(
          label: 'Bio',
          controller: bioController,
          hint: 'Tell us a bit about your journey...',
          icon: Icons.notes_rounded,
          maxLines: 4,
        ),
        const SizedBox(height: 40),
        Text(
          'SKILLS TO TEACH',
          style: GoogleFonts.dmSans(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: Colors.white.withValues(alpha: 0.3),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        SkillSelectionInput(
          type: 'teach',
          skills: skills,
          onAddSkill: onAddSkill,
          onRemoveSkill: onRemoveSkill,
        ),
      ],
      onContinue: onContinue,
    );
  }
}

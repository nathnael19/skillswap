import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/features/auth/presentation/pages/login_page.dart';
import 'package:skillswap/features/auth/presentation/widgets/auth_text_field.dart';
import 'onboarding_step_layout.dart';

class AboutYouStep extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController professionController;
  final TextEditingController locationController;
  final VoidCallback onContinue;

  const AboutYouStep({
    super.key,
    required this.nameController,
    required this.professionController,
    required this.locationController,
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
      ],
      onContinue: onContinue,
      footer: _buildAuthSwitch(context, 'Already have an account?', 'Log in', () {
        Navigator.of(context).push(LoginPage.route());
      }),
    );
  }

  Widget _buildAuthSwitch(BuildContext context, String question, String action, VoidCallback onTap) {
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

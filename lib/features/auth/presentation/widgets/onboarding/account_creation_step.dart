import 'package:flutter/material.dart';
import 'package:skillswap/features/auth/presentation/widgets/auth_text_field.dart';
import 'onboarding_step_layout.dart';

class AccountCreationStep extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onContinue;
  final bool isLoading;

  const AccountCreationStep({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.onContinue,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingStepLayout(
      title: 'Create Account',
      subtitle: 'Almost done! Set your email and password to finish.',
      content: [
        AuthTextField(
          label: 'Email Address',
          controller: emailController,
          hint: 'master@skillswap.com',
          icon: Icons.mail_outline_rounded,
        ),
        const SizedBox(height: 24),
        AuthTextField(
          label: 'Password',
          controller: passwordController,
          hint: 'Enter your password',
          icon: Icons.lock_outline_rounded,
          isPassword: true,
        ),
      ],
      onContinue: onContinue,
      isLoading: isLoading,
      ctaLabel: 'Finish Setup',
    );
  }
}

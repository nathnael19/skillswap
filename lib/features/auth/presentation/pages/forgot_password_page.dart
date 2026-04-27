import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/core/common/widgets/app_button.dart';
import 'package:skillswap/core/layout/responsive.dart';
import 'package:skillswap/core/theme/theme.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_state.dart';
import 'package:skillswap/features/auth/presentation/widgets/auth_text_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  static MaterialPageRoute<dynamic> route() =>
      MaterialPageRoute(builder: (context) => const ForgotPasswordPage());
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryBgColor = AppColors.background;
    const accentColor = AppColors.primary;

    return Scaffold(
      backgroundColor: primaryBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: Responsive.valueFor<double>(
              context,
              compact: 18,
              mobile: 19,
              tablet: 20,
              tabletWide: 20,
              desktop: 22,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
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
          } else if (state is AuthPasswordResetSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password reset link sent! Please check your email.'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          final screenW = MediaQuery.sizeOf(context).width;
          final glowSize = (screenW * 0.95).clamp(260.0, 520.0);
          final gap = Responsive.valueFor<double>(
            context,
            compact: 32,
            mobile: 40,
            tablet: 44,
            tabletWide: 48,
            desktop: 48,
          );
          final formMaxW = Responsive.valueFor<double>(
            context,
            compact: 400,
            mobile: 480,
            tablet: 520,
            tabletWide: 560,
            desktop: 600,
          );

          return AbsorbPointer(
            absorbing: isLoading,
            child: Stack(
              children: [
                // ambient glow
                Positioned(
                  top: -glowSize * 0.35,
                  right: -glowSize * 0.15,
                  child: Container(
                    width: glowSize,
                    height: glowSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          accentColor.withValues(alpha: 0.08),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: Responsive.screenPadding(context),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: formMaxW),
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: Responsive.valueFor<double>(context, compact: 12, mobile: 16, tablet: 18, tabletWide: 20, desktop: 20)),
                              Text(
                                'Forgot Password?',
                                style: AppTextStyles.h2,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Enter your email address and we\'ll send you a link to reset your password.',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: gap),
                              AuthTextField(
                                label: 'Email Address',
                                controller: emailController,
                                hint: 'master@skillswap.com',
                                icon: Icons.mail_outline_rounded,
                              ),
                              SizedBox(height: gap),
                              AppButton(
                                label: 'Send Reset Link',
                                isLoading: isLoading,
                                onTap: () {
                                  if (formKey.currentState!.validate()) {
                                    context
                                        .read<AuthCubit>()
                                        .sendPasswordResetEmail(
                                          emailController.text.trim(),
                                        );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

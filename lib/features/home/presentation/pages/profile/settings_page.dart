import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/core/common/widgets/connectivity_guard.dart';
import 'package:skillswap/core/theme/theme.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_state.dart';
import 'package:skillswap/features/auth/presentation/pages/login_page.dart';
import 'package:skillswap/features/home/presentation/pages/identity_verification_page.dart';
import '../edit_profile/components/account_settings_section.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const Color kBackground = AppColors.background;
  static const Color kAccent = AppColors.primary;
  static const Color kText = AppColors.textPrimary;
  static const Color kTextSecondary = AppColors.textSecondary;

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Sign Out',
          style: AppTextStyles.h4.copyWith(color: AppColors.error),
        ),
        content: Text(
          'Are you sure you want to sign out of your account?',
          style: AppTextStyles.bodyMedium.copyWith(color: kTextSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelLarge.copyWith(color: kTextSecondary),
            ),
          ),
          ConnectivityGuard(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<AuthCubit>().signOut();
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('Sign Out'),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Delete Account',
          style: AppTextStyles.h4.copyWith(color: AppColors.error),
        ),
        content: Text(
          'Are you absolutely sure you want to delete your account? This action cannot be undone. All your matches, messages, and profile data will be permanently erased.',
          style: AppTextStyles.bodyMedium.copyWith(color: kTextSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelLarge.copyWith(color: kTextSecondary),
            ),
          ),
          ConnectivityGuard(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<AuthCubit>().deleteAccount();
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('Delete'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          Navigator.of(
            context,
          ).pushAndRemoveUntil(LoginPage.route(), (route) => false);
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Auth Error: ${state.message}')),
          );
        }
      },
      child: Scaffold(
        backgroundColor: kBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: kText,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Settings',
            style: AppTextStyles.labelMedium.copyWith(
              color: kAccent,
              letterSpacing: 2.0,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              AccountSettingsSection(
                onIdentityVerificationTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const IdentityVerificationPage(),
                    ),
                  );
                },
                onLogoutTap: _showLogoutConfirmation,
                onDeleteAccountTap: _showDeleteAccountConfirmation,
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}

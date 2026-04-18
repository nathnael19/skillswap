import 'package:flutter/material.dart';
import 'package:skillswap/core/theme/theme.dart';

class AccountSettingsSection extends StatelessWidget {
  final VoidCallback onIdentityVerificationTap;
  final VoidCallback onLogoutTap;

  const AccountSettingsSection({
    super.key,
    required this.onIdentityVerificationTap,
    required this.onLogoutTap,
  });

  static const Color kAccent = AppColors.primary;
  static const Color kText = AppColors.textPrimary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Settings',
          style: AppTextStyles.labelSmall.copyWith(color: kAccent),
        ),

        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderSubtle),
          ),

          child: Column(
            children: [
              _buildSettingsTile(Icons.settings_outlined, 'Account Settings'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Divider(color: AppColors.borderSubtle, height: 1),
              ),

              _buildSettingsTile(
                Icons.verified_user_outlined,
                'Identity Verification',
                onTap: onIdentityVerificationTap,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Divider(color: AppColors.borderSubtle, height: 1),
              ),

              _buildLogoutTile(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    IconData icon,
    String title, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.borderSubtle,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: kAccent, size: 20),
            ),

            const SizedBox(width: 16),
            Expanded(child: Text(title, style: AppTextStyles.bodyMedium)),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutTile() {
    return InkWell(
      onTap: onLogoutTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: AppColors.error,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Sign Out',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

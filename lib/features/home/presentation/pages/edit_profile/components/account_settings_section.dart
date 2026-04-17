import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AccountSettingsSection extends StatelessWidget {
  final VoidCallback onIdentityVerificationTap;
  final VoidCallback onLogoutTap;

  const AccountSettingsSection({
    super.key,
    required this.onIdentityVerificationTap,
    required this.onLogoutTap,
  });

  static const Color kAccent = Color(0xFFCA8A04);
  static const Color kText = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Settings',
          style: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: kAccent,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            children: [
              _buildSettingsTile(Icons.settings_outlined, 'Account Settings'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Divider(
                  color: Colors.white.withValues(alpha: 0.05),
                  height: 1,
                ),
              ),
              _buildSettingsTile(
                Icons.verified_user_outlined,
                'Identity Verification',
                onTap: onIdentityVerificationTap,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Divider(
                  color: Colors.white.withValues(alpha: 0.05),
                  height: 1,
                ),
              ),
              _buildLogoutTile(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: kAccent, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: kText,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withValues(alpha: 0.2),
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
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFEF4444),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Sign Out',
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFEF4444),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:skillswap/core/common/widgets/connectivity_guard.dart';
import 'package:skillswap/core/theme/theme.dart';

class LikeCardActions extends StatelessWidget {
  final bool isReceived;
  final bool isSent;
  final bool isPassed;
  final VoidCallback onProfileTap;
  final VoidCallback onConnectTap;
  final VoidCallback onWithdrawTap;

  const LikeCardActions({
    super.key,
    required this.isReceived,
    required this.isSent,
    required this.isPassed,
    required this.onProfileTap,
    required this.onConnectTap,
    required this.onWithdrawTap,
  });

  @override
  Widget build(BuildContext context) {
    const accentColor = AppColors.primary;

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onProfileTap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.borderSubtle,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderDefault),
              ),
              child: Center(
                child: Text(
                  'Profile',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (isReceived || isSent || isPassed) const SizedBox(width: 14),
        if (isReceived || isPassed)
          Expanded(
            flex: 2,
            child: ConnectivityGuard(
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [accentColor, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.3),
                      blurRadius: 15,
                      spreadRadius: -2,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: onConnectTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: AppColors.textPrimary,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    isPassed ? 'Connect' : 'Connect',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (isSent)
          Expanded(
            flex: 2,
            child: ConnectivityGuard(
              child: GestureDetector(
                onTap: onWithdrawTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderDefault),
                  ),
                  child: Center(
                    child: Text(
                      'Withdraw',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

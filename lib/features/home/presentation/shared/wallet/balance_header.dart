import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:skillswap/core/layout/responsive.dart';
import 'package:skillswap/features/home/presentation/pages/withdraw_page.dart';
import 'package:skillswap/core/constants/app_constants.dart';
import 'package:skillswap/core/theme/theme.dart';

class BalanceHeader extends StatelessWidget {
  final double balance;
  final double escrowBalance;
  final VoidCallback? onBuyCredits;

  /// Progress bar target in display credits (purely visual).
  final double progressCapCredits;

  const BalanceHeader({
    super.key,
    required this.balance,
    required this.escrowBalance,
    this.onBuyCredits,
    this.progressCapCredits = AppConstants.walletProgressCap,
  });

  @override
  Widget build(BuildContext context) {
    const accentColor = AppColors.primary;
    final fmt = NumberFormat('#,##0.##');
    final balanceLabel = fmt.format(balance);
    final progress = (balance / progressCapCredits).clamp(0.0, 1.0).toDouble();
    final hPad = Responsive.contentHorizontalPadding(context);
    final innerPad = Responsive.valueFor<double>(
      context,
      compact: 20,
      mobile: 24,
      tablet: 28,
      tabletWide: 30,
      desktop: 32,
    );
    final balanceFont = Responsive.valueFor<double>(
      context,
      compact: 40,
      mobile: 48,
      tablet: 54,
      tabletWide: 58,
      desktop: 64,
    );
    final unitFont = Responsive.valueFor<double>(
      context,
      compact: 16,
      mobile: 18,
      tablet: 19,
      tabletWide: 20,
      desktop: 22,
    );
    final btnHeight = Responsive.valueFor<double>(
      context,
      compact: 48,
      mobile: 52,
      tablet: 54,
      tabletWide: 56,
      desktop: 56,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Container(
        padding: EdgeInsets.all(innerPad),
        decoration: BoxDecoration(
          color: AppColors.overlay03,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: AppColors.overlay08),
        ),
        child: Column(
          children: [
            Text(
              'Available Balance',
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: accentColor,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 16),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    balanceLabel,
                    style: GoogleFonts.dmSans(
                      fontSize: balanceFont,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -2.0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppConstants.currencyLabel,
                    style: GoogleFonts.dmSans(
                      fontSize: unitFont,
                      fontWeight: FontWeight.w800,
                      color: accentColor,
                    ),
                  ),
                ],
              ),
            ),
            if (escrowBalance > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.overlay05,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.overlay10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lock_clock_rounded,
                      size: 14,
                      color: AppColors.overlay40,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${fmt.format(escrowBalance)} Locked in Escrow',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.overlay40,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress toward ${fmt.format(progressCapCredits)} CR',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.overlay40,
                  ),
                ),
                Text(
                  '$balanceLabel / ${fmt.format(progressCapCredits)}',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.overlay05,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Stack(
                children: [
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [accentColor, AppColors.primaryDark],
                        ),
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    height: btnHeight,
                    icon: Icons.add_circle_outline_rounded,
                    label: 'Top Up',
                    isPrimary: true,
                    onTap: onBuyCredits,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    height: btnHeight,
                    icon: Icons.payments_rounded,
                    label: 'Withdraw',
                    isPrimary: false,
                    onTap: () {
                      if (balance < 50) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('You need at least 50 credits to withdraw.'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              WithdrawPage(currentBalance: balance),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required double height,
    required IconData icon,
    required String label,
    required bool isPrimary,
    VoidCallback? onTap,
  }) {
    const accentColor = AppColors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          height: height,
          decoration: BoxDecoration(
            gradient: isPrimary
                ? const LinearGradient(
                    colors: [accentColor, AppColors.primaryDark],
                  )
                : null,
            color: isPrimary ? null : AppColors.overlay05,
            borderRadius: BorderRadius.circular(22),
            border: isPrimary ? null : Border.all(color: AppColors.overlay10),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.3),
                      blurRadius: 15,
                      spreadRadius: -2,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isPrimary ? AppColors.textPrimary : AppColors.overlay40,
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: isPrimary
                      ? AppColors.textPrimary
                      : AppColors.overlay40,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

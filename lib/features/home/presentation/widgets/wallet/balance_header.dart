import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class BalanceHeader extends StatelessWidget {
  final double balance;
  final VoidCallback? onBuyCredits;
  /// Progress bar target in display credits (purely visual).
  final double progressCapCredits;

  const BalanceHeader({
    super.key,
    required this.balance,
    this.onBuyCredits,
    this.progressCapCredits = 50,
  });

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFFCA8A04);
    final fmt = NumberFormat('#,##0.##');
    final balanceLabel = fmt.format(balance);
    final progress =
        (balance / progressCapCredits).clamp(0.0, 1.0).toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          children: [
            Text(
              'AVAILABLE TREASURY',
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: accentColor,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  balanceLabel,
                  style: GoogleFonts.dmSans(
                    fontSize: 64,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -2.0,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'CR',
                  style: GoogleFonts.dmSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress toward ${fmt.format(progressCapCredits)} CR',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.4),
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
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Stack(
                children: [
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [accentColor, Color(0xFFB47B03)],
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
                    icon: Icons.add_circle_outline_rounded,
                    label: 'BUY',
                    isPrimary: true,
                    onTap: onBuyCredits,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.auto_awesome_rounded,
                    label: 'PERKS',
                    isPrimary: false,
                    onTap: null,
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
    required IconData icon,
    required String label,
    required bool isPrimary,
    VoidCallback? onTap,
  }) {
    const accentColor = Color(0xFFCA8A04);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          height: 56,
          decoration: BoxDecoration(
            gradient: isPrimary
                ? const LinearGradient(
                    colors: [accentColor, Color(0xFFB47B03)],
                  )
                : null,
            color: isPrimary ? null : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(22),
            border: isPrimary
                ? null
                : Border.all(color: Colors.white.withValues(alpha: 0.1)),
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
                color: isPrimary
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.4),
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: isPrimary
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.4),
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'transaction_item.dart';
import 'package:skillswap/core/theme/theme.dart';

class RecentTransactionsSection extends StatelessWidget {
  final List<dynamic> transactions;

  const RecentTransactionsSection({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    const accentColor = AppColors.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Transaction History',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: accentColor,
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (transactions.isEmpty)
            _buildEmptyLedger()
          else
            ...transactions.map(
              (t) => TransactionItem(data: t as Map<String, dynamic>),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyLedger() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.textPrimary.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.textPrimary.withValues(alpha: 0.04),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.history_toggle_off_rounded,
            color: AppColors.overlay10,
            size: 40,
          ),
          const SizedBox(height: 16),
          Text(
            'No history yet',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.overlay20,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your transactions will appear once you\ncomplete sessions or earn rewards.',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: AppColors.textPrimary.withValues(alpha: 0.15),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

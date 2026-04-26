import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/core/theme/theme.dart';

class TransactionItem extends StatelessWidget {
  final Map<String, dynamic> data;

  const TransactionItem({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    const accentColor = AppColors.primary;

    final String type = data['type'] ?? 'earn';
    final bool isPositive = const {'earn', 'grant', 'purchase', 'refund'}.contains(type);
    final String title =
        data['description'] ??
        (isPositive ? 'Revenue Inflow' : 'Credit Expenditure');
    final dynamic displayAmount = data['amount_display'] ?? data['amount'] ?? 0;
    final String amount = displayAmount is num
        ? (displayAmount == displayAmount.roundToDouble()
              ? displayAmount.toStringAsFixed(0)
              : displayAmount.toStringAsFixed(2))
        : displayAmount.toString();
    final String rawTimestamp = data['timestamp'] ?? '';
    final String subtitle = _formatSubtitle(rawTimestamp);

    IconData icon;
    if (type == 'earn' || type == 'grant' || type == 'refund') {
      icon = type == 'refund' ? Icons.history_rounded : Icons.add_chart_rounded;
    } else if (type == 'spend') {
      icon = Icons.shopping_basket_rounded;
    } else if (type == 'purchase') {
      icon = Icons.payments_outlined;
    } else if (type == 'escrow') {
      icon = Icons.lock_clock_rounded;
    } else {
      icon = Icons.auto_awesome_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.overlay03,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.textPrimary.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isPositive
                  ? accentColor.withValues(alpha: 0.1)
                  : AppColors.overlay05,
              shape: BoxShape.circle,
              border: Border.all(
                color: isPositive
                    ? accentColor.withValues(alpha: 0.2)
                    : AppColors.overlay10,
              ),
            ),
            child: Icon(
              icon,
              color: isPositive ? accentColor : AppColors.overlay50,
              size: 20,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppColors.overlay30,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isPositive ? '+$amount' : '-$amount',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isPositive ? accentColor : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatSubtitle(String rawTimestamp) {
    if (rawTimestamp.isEmpty) return 'Recent History';
    try {
      final dateTime = DateTime.parse(rawTimestamp).toLocal();
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
      if (difference.inHours < 24) return '${difference.inHours}h ago';
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return 'Completed Item';
    }
  }
}

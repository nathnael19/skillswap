import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BalanceHeader extends StatelessWidget {
  final int balance;
  final int nextRewardCredits;
  final int totalRewardCredits;

  const BalanceHeader({
    super.key,
    required this.balance,
    required this.nextRewardCredits,
    required this.totalRewardCredits,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          Text(
            'AVAILABLE BALANCE',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF667085),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$balance Credits',
            style: GoogleFonts.outfit(
              fontSize: 48,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${totalRewardCredits - balance} credits to next reward',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1D2939),
                ),
              ),
              Text(
                '$balance / $totalRewardCredits',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1D2939),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: const Color(0xFFEAECF5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: balance / totalRewardCredits,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B6A7A),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.add_circle_outline,
                  label: 'Earn More',
                  isPrimary: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.help_outline,
                  label: 'Get Help',
                  isPrimary: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isPrimary,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: isPrimary ? const Color(0xFF0B6A7A) : const Color(0xFFEAECF5),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isPrimary ? Colors.white : const Color(0xFF101828),
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isPrimary ? Colors.white : const Color(0xFF101828),
            ),
          ),
        ],
      ),
    );
  }
}

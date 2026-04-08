import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF101828)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Wallet & Rewards',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF101828),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
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
                    '12 Credits',
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
                        '8 credits to next reward',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1D2939),
                        ),
                      ),
                      Text(
                        '12 / 20',
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
                          widthFactor: 12 / 20,
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
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transaction History',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF101828),
                    ),
                  ),
                  const Icon(Icons.tune, color: Color(0xFF101828), size: 24),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildTransactionItem(
                    icon: Icons.stars_rounded,
                    title: 'Completed Session with Marcus',
                    subtitle: 'Oct 24, 2023 • UI Design Review',
                    amount: '+1',
                    isPositive: true,
                    iconColor: const Color(0xFF9E6400).withOpacity(0.1),
                    iconSymbolColor: const Color(0xFF9E6400),
                  ),
                  const SizedBox(height: 16),
                  _buildTransactionItem(
                    icon: Icons.calendar_today_outlined,
                    title: 'Scheduled Session with Elena',
                    subtitle: 'Oct 22, 2023 • Advanced Python',
                    amount: '-1',
                    isPositive: false,
                    iconColor: const Color(0xFFE0F2F1),
                    iconSymbolColor: const Color(0xFF0B6A7A),
                  ),
                  const SizedBox(height: 16),
                  _buildTransactionItem(
                    icon: Icons.military_tech_outlined,
                    title: 'Referral Bonus',
                    subtitle: 'Oct 19, 2023 • Invited Sarah J.',
                    amount: '+3',
                    isPositive: true,
                    iconColor: const Color(0xFFFDECDA),
                    iconSymbolColor: const Color(0xFF9E6400),
                  ),
                  const SizedBox(height: 16),
                  _buildTransactionItem(
                    icon: Icons.auto_stories_outlined,
                    title: 'Scheduled Session with David',
                    subtitle: 'Oct 15, 2023 • Creative Writing',
                    amount: '-1',
                    isPositive: false,
                    iconColor: const Color(0xFFE0F2F1),
                    iconSymbolColor: const Color(0xFF475467),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required bool isPrimary}) {
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

  Widget _buildTransactionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String amount,
    required bool isPositive,
    required Color iconColor,
    required Color iconSymbolColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconSymbolColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF101828),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF667085),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            amount,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isPositive ? const Color(0xFF9E6400) : const Color(0xFF101828),
            ),
          ),
        ],
      ),
    );
  }
}

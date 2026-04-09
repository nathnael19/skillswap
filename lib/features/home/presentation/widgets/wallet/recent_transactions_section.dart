import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/features/home/presentation/widgets/wallet/transaction_item.dart';

class RecentTransactionsSection extends StatelessWidget {
  const RecentTransactionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              TransactionItem(
                icon: Icons.stars_rounded,
                title: 'Completed Session with Marcus',
                subtitle: 'Oct 24, 2023 • UI Design Review',
                amount: '+1',
                isPositive: true,
                iconColor: const Color(0xFF9E6400).withOpacity(0.1),
                iconSymbolColor: const Color(0xFF9E6400),
              ),
              const SizedBox(height: 16),
              const TransactionItem(
                icon: Icons.calendar_today_outlined,
                title: 'Scheduled Session with Elena',
                subtitle: 'Oct 22, 2023 • Advanced Python',
                amount: '-1',
                isPositive: false,
                iconColor: Color(0xFFE0F2F1),
                iconSymbolColor: Color(0xFF0B6A7A),
              ),
              const SizedBox(height: 16),
              const TransactionItem(
                icon: Icons.military_tech_outlined,
                title: 'Referral Bonus',
                subtitle: 'Oct 19, 2023 • Invited Sarah J.',
                amount: '+3',
                isPositive: true,
                iconColor: Color(0xFFFDECDA),
                iconSymbolColor: Color(0xFF9E6400),
              ),
              const SizedBox(height: 16),
              const TransactionItem(
                icon: Icons.auto_stories_outlined,
                title: 'Scheduled Session with David',
                subtitle: 'Oct 15, 2023 • Creative Writing',
                amount: '-1',
                isPositive: false,
                iconColor: Color(0xFFE0F2F1),
                iconSymbolColor: Color(0xFF475467),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/features/home/presentation/widgets/wallet/balance_header.dart';
import 'package:skillswap/features/home/presentation/widgets/wallet/recent_transactions_section.dart';

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
            const BalanceHeader(
              balance: 12,
              nextRewardCredits: 8,
              totalRewardCredits: 20,
            ),
            const SizedBox(height: 40),
            const RecentTransactionsSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

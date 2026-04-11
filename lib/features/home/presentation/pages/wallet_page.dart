import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/features/home/presentation/cubits/credits_cubit.dart';
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
      body: BlocBuilder<CreditsCubit, CreditsState>(
        builder: (context, state) {
          if (state is CreditsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CreditsError) {
            return Center(child: Text(state.message));
          }

          if (state is CreditsLoaded) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  BalanceHeader(
                    balance: state.balance,
                    nextRewardCredits: 10, // Mocked milestone logic
                    totalRewardCredits: 50, // Mocked milestone logic
                  ),
                  const SizedBox(height: 40),
                  const RecentTransactionsSection(), // This widget might need internal update too if it has mock data
                  const SizedBox(height: 40),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

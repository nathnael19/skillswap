import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/core/common/widgets/app_error_widget.dart';
import 'package:skillswap/features/home/domain/repositories/home_repository.dart';
import 'package:skillswap/features/home/presentation/cubits/credits_cubit.dart';
import 'package:skillswap/features/home/presentation/widgets/wallet/balance_header.dart';
import 'package:skillswap/features/home/presentation/widgets/wallet/recent_transactions_section.dart';
import 'package:skillswap/init_dependencies.dart';
import 'package:skillswap/core/common/widgets/guest_wall.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_state.dart';
import 'package:url_launcher/url_launcher.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  Future<void> _openCheckout(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final repo = serviceLocator<HomeRepository>();
    final result = await repo.createBillingCheckout();
    await result.fold((failure) async {
      messenger.showSnackBar(SnackBar(content: Text(failure.message)));
    }, (data) => _launchStripeCheckout(context, messenger, data));
  }

  Future<void> _launchStripeCheckout(
    BuildContext context,
    ScaffoldMessengerState messenger,
    Map<String, dynamic> data,
  ) async {
    final url = data['url'] as String?;
    if (url == null || url.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No checkout URL returned.')),
      );
      return;
    }
    final uri = Uri.parse(url);
    if (!await canLaunchUrl(uri)) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Cannot open checkout in this environment.'),
        ),
      );
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (context.mounted) {
      await context.read<CreditsCubit>().fetchCredits();
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBgColor = Color(0xFF0C0A09);
    const accentColor = Color(0xFFCA8A04);

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthSuccess) {
          return const Scaffold(
            backgroundColor: primaryBgColor,
            body: GuestWall(),
          );
        }

        return Scaffold(
          backgroundColor: primaryBgColor,
          extendBodyBehindAppBar: true,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: AppBar(
                  backgroundColor: primaryBgColor.withValues(alpha: 0.8),
                  elevation: 0,
                  leading: Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    'Wallet',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2.0,
                    ),
                  ),
                  centerTitle: true,
                  shape: Border(
                    bottom: BorderSide(
                      color: Colors.white.withValues(alpha: 0.05),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
          body: BlocBuilder<CreditsCubit, CreditsState>(
            builder: (context, state) {
              if (state is CreditsLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: accentColor),
                );
              }

              if (state is CreditsError) {
                return AppErrorWidget(
                  message: state.message,
                  onRetry: () => context.read<CreditsCubit>().fetchCredits(),
                );
              }

              if (state is CreditsLoaded) {
                return RefreshIndicator(
                  onRefresh: () => context.read<CreditsCubit>().fetchCredits(),
                  color: accentColor,
                  backgroundColor: const Color(0xFF1C1917),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 120),
                        BalanceHeader(
                          balance: state.balance,
                          progressCapCredits: 50,
                          onBuyCredits: () => _openCheckout(context),
                        ),
                        const SizedBox(height: 24),
                        RecentTransactionsSection(
                          transactions: state.transactions,
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }
}

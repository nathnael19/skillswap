import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_state.dart';
import 'package:skillswap/features/home/presentation/cubits/profile_cubit.dart';
import 'package:skillswap/features/home/presentation/pages/profile/components/expertise_portfolio.dart';
import 'package:skillswap/features/home/presentation/pages/profile/components/profile_header.dart';
import 'package:skillswap/features/home/presentation/pages/profile/components/recent_activity_section.dart';
import 'package:skillswap/features/home/presentation/pages/wallet_page.dart';
import 'package:skillswap/core/common/widgets/app_error_widget.dart';
import 'package:skillswap/core/common/widgets/guest_wall.dart';
import 'package:skillswap/core/theme/theme.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthSuccess) {
          return const GuestWall();
        }

        return SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: _buildHeader(context, true),
              ),
              Expanded(
                child: BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (context, state) {
                    if (state is ProfileLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      );
                    }

                    if (state is ProfileError) {
                      return AppErrorWidget(
                        message: state.message,
                        onRetry: () =>
                            context.read<ProfileCubit>().fetchUserProfile(),
                      );
                    }

                    if (state is ProfileLoaded) {
                      final user = state.user;
                      return RefreshIndicator(
                        onRefresh: () =>
                            context.read<ProfileCubit>().fetchUserProfile(),
                        color: AppColors.primary,
                        backgroundColor: AppColors.surface,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              ProfileHeader(user: user),
                              const SizedBox(height: 40),
                              ExpertisePortfolio(user: user),
                              const SizedBox(height: 40),
                              const RecentActivitySection(),
                              const SizedBox(height: 120),
                            ],
                          ),
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isLoggedIn) {
    const accentColor = AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  'PORTFOLIO',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: accentColor,
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
            if (isLoggedIn)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const WalletPage()),
                  );
                },
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: AppColors.overlay05,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.overlay08, width: 1),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: AppColors.textPrimary,
                    size: 18,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'Your Profile',
          style: GoogleFonts.dmSans(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -1.0,
          ),
        ),
      ],
    );
  }
}

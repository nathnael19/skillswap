import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_state.dart';
import 'package:skillswap/features/auth/presentation/pages/login_page.dart';
import 'package:skillswap/features/auth/presentation/pages/onboarding_page.dart';
import 'package:skillswap/features/home/presentation/cubits/profile_cubit.dart';
import 'package:skillswap/features/home/presentation/widgets/profile/expertise_portfolio.dart';
import 'package:skillswap/features/home/presentation/widgets/profile/profile_header.dart';
import 'package:skillswap/features/home/presentation/widgets/profile/recent_activity_section.dart';
import 'package:skillswap/core/common/widgets/app_error_widget.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState is AuthSuccess) {
          return BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFCA8A04),
                    strokeWidth: 2,
                  ),
                );
              }

              if (state is ProfileError) {
                return AppErrorWidget(
                  message: state.message,
                  onRetry: () => context.read<ProfileCubit>().fetchUserProfile(),
                );
              }

              if (state is ProfileLoaded) {
                final user = state.user;
                return RefreshIndicator(
                  onRefresh: () =>
                      context.read<ProfileCubit>().fetchUserProfile(),
                  color: const Color(0xFFCA8A04),
                  backgroundColor: const Color(0xFF1C1917),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 32),
                        ProfileHeader(user: user),
                        const SizedBox(height: 40),
                        ExpertisePortfolio(user: user),
                        const SizedBox(height: 40),
                        const RecentActivitySection(),
                        const SizedBox(height: 120), // Extra space for bottom bar
                      ],
                    ),
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          );
        }

        // Guest Mode or Loading Auth
        return _buildGuestWall(context);
      },
    );
  }


  Widget _buildGuestWall(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: const Icon(
              Icons.fingerprint_rounded,
              color: Color(0xFFCA8A04),
              size: 72,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            'Master Your Path',
            style: GoogleFonts.dmSans(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Curate your expert persona, track your growth journey, and manifest your mastery.',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.4),
              height: 1.6,
            ),
          ),
          const Spacer(flex: 3),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFCA8A04), Color(0xFFB47B03)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFCA8A04).withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(OnboardingPage.route());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Build Your Profile',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(LoginPage.route());
            },
            child: Text(
              'RECLAIM YOUR IDENTITY',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFCA8A04),
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}

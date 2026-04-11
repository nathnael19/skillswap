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
                return const Center(child: CircularProgressIndicator());
              }

              if (state is ProfileError) {
                return _buildErrorView(context, state.message);
              }

              if (state is ProfileLoaded) {
                final user = state.user;
                return RefreshIndicator(
                  onRefresh: () =>
                      context.read<ProfileCubit>().fetchUserProfile(),
                  color: const Color(0xFF0B6A7A),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        ProfileHeader(user: user),
                        const SizedBox(height: 32),
                        ExpertisePortfolio(user: user),
                        const SizedBox(height: 32),
                        const RecentActivitySection(),
                        const SizedBox(height: 40),
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

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              "Profile Unavailable",
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "We're having trouble loading your expert profile. Please try again.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () => context.read<ProfileCubit>().fetchUserProfile(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("RETRY CONNECTION"),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF0B6A7A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestWall(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F7),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Color(0xFF0B6A7A),
              size: 64,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            'Join the Nexus',
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Curate your expertise, connect with masters, and elevate your craft through shared wisdom.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: const Color(0xFF667085),
              height: 1.5,
            ),
          ),
          const Spacer(flex: 3),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(OnboardingPage.route());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B6A7A),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Get Started',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(LoginPage.route());
            },
            child: Text(
              'LOG IN TO YOUR ACCOUNT',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0B6A7A),
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

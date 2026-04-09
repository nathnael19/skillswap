import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/features/home/presentation/cubits/profile_cubit.dart';
import 'package:skillswap/features/home/presentation/widgets/profile/expertise_portfolio.dart';
import 'package:skillswap/features/home/presentation/widgets/profile/profile_header.dart';
import 'package:skillswap/features/home/presentation/widgets/profile/recent_activity_section.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProfileError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(state.message),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      context.read<ProfileCubit>().fetchUserProfile(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is ProfileLoaded) {
          final user = state.user;
          return SingleChildScrollView(
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
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

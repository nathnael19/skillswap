import 'package:flutter/material.dart';
import 'package:skillswap/features/home/presentation/widgets/profile/expertise_portfolio.dart';
import 'package:skillswap/features/home/presentation/widgets/profile/profile_header.dart';
import 'package:skillswap/features/home/presentation/widgets/profile/recent_activity_section.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          SizedBox(height: 24),
          ProfileHeader(),
          SizedBox(height: 32),
          ExpertisePortfolio(),
          SizedBox(height: 32),
          RecentActivitySection(),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/core/common/cubits/connectivity/connectivity_cubit.dart';
import 'package:skillswap/core/common/widgets/offline_screen.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_state.dart';
import 'package:skillswap/features/home/presentation/cubits/profile_cubit.dart';
import 'package:skillswap/features/home/presentation/pages/home/components/home_app_bar_action.dart';
import 'package:skillswap/features/home/presentation/pages/notifications/notifications_page.dart';
import 'package:skillswap/features/home/presentation/pages/wallet_page.dart';
import 'package:skillswap/features/home/presentation/pages/profile/settings_page.dart';
import 'components/expertise_portfolio.dart';
import 'components/profile_header.dart';
import 'components/recent_activity_section.dart';
import 'package:skillswap/core/common/widgets/app_error_widget.dart';
import 'package:skillswap/core/common/widgets/guest_wall.dart';
import 'package:skillswap/core/theme/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthSuccess) {
          return const GuestWall();
        }

        return MultiBlocListener(
          listeners: [
            BlocListener<ConnectivityCubit, ConnectivityStatus>(
              listenWhen: (prev, curr) =>
                  prev == ConnectivityStatus.disconnected &&
                  curr == ConnectivityStatus.connected,
              listener: (context, _) {
                context.read<ProfileCubit>().fetchUserProfile();
              },
            ),
          ],
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: _buildHeader(context, true),
                ),
                Expanded(
                  child: BlocBuilder<ConnectivityCubit, ConnectivityStatus>(
                    builder: (context, connectivity) {
                      return BlocBuilder<ProfileCubit, ProfileState>(
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
                            if (connectivity ==
                                ConnectivityStatus.disconnected) {
                              return OfflineScreen(
                                onRetry: () => context
                                    .read<ProfileCubit>()
                                    .fetchUserProfile(),
                              );
                            }
                            return AppErrorWidget(
                              message: state.message,
                              onRetry: () => context
                                  .read<ProfileCubit>()
                                  .fetchUserProfile(),
                            );
                          }

                          if (state is ProfileLoaded) {
                            final user = state.user;
                            return RefreshIndicator(
                              onRefresh: () => context
                                  .read<ProfileCubit>()
                                  .fetchUserProfile(),
                              color: AppColors.primary,
                              backgroundColor: AppColors.surface,
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
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

                          if (connectivity == ConnectivityStatus.disconnected) {
                            return OfflineScreen(
                              onRetry: () => context
                                  .read<ProfileCubit>()
                                  .fetchUserProfile(),
                            );
                          }

                          return const SizedBox.shrink();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
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
                  'PROFILE',
                  style: AppTextStyles.labelSmall.copyWith(color: accentColor),
                ),
              ],
            ),

            if (isLoggedIn)
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseAuth.instance.currentUser != null
                          ? FirebaseFirestore.instance
                                .collection('users')
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .collection('notifications')
                                .where('is_read', isEqualTo: false)
                                .snapshots()
                          : const Stream.empty(),
                      builder: (context, snapshot) {
                        int unreadCount = 0;
                        if (snapshot.hasData) {
                          unreadCount = snapshot.data!.docs.length;
                        }
                        return HomeAppBarAction(
                          icon: Icons.notifications_rounded,
                          badgeCount: unreadCount,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NotificationsPage(),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: HomeAppBarAction(
                      icon: Icons.account_balance_wallet_outlined,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WalletPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: HomeAppBarAction(
                      icon: Icons.settings_outlined,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

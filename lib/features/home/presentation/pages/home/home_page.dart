import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/core/common/cubits/connectivity/connectivity_cubit.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_state.dart';
import 'package:skillswap/features/home/presentation/cubits/credits_cubit.dart';
import 'package:skillswap/features/home/presentation/cubits/discovery_cubit.dart';
import 'package:skillswap/features/home/presentation/cubits/matches_cubit.dart';
import 'package:skillswap/features/home/presentation/cubits/likes_cubit.dart';
import 'package:skillswap/features/home/presentation/cubits/profile_cubit.dart';
import 'package:skillswap/features/home/presentation/pages/search_page.dart';
import 'package:skillswap/features/home/presentation/pages/matches/matches_page.dart';
import 'package:skillswap/features/home/presentation/pages/likes/likes_page.dart';
import 'package:skillswap/features/home/presentation/pages/profile/profile_page.dart';
import 'package:skillswap/features/home/presentation/pages/wallet_page.dart';
import 'package:skillswap/features/home/presentation/pages/discovery/discovery_page.dart';
import 'package:skillswap/features/live_sessions/presentation/pages/session_list_page.dart';
import 'package:skillswap/features/live_sessions/data/services/live_session_firestore_service.dart';
import 'package:skillswap/init_dependencies.dart';
import 'package:skillswap/features/home/presentation/pages/notifications/notifications_page.dart';
import '../../shared/filter_bottom_sheet.dart';
import 'components/midnight_navigation_bar.dart';
import 'components/home_app_bar_action.dart';
import 'package:skillswap/core/theme/theme.dart';

class HomePage extends StatefulWidget {
  static MaterialPageRoute<dynamic> route() => MaterialPageRoute(
    builder: (context) => MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              serviceLocator<DiscoveryCubit>()..fetchDiscoveryUsers(),
        ),
        BlocProvider(
          create: (_) => serviceLocator<MatchesCubit>()..fetchMatches(),
        ),
        BlocProvider(
          create: (_) => serviceLocator<ProfileCubit>()..fetchUserProfile(),
        ),
        BlocProvider(
          create: (_) => serviceLocator<LikesCubit>()..fetchLikesReceived(),
        ),
      ],
      child: const HomePage(),
    ),
  );
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Filter State (Shared across tabs)
  List<String> _selectedCategories = [];
  String _selectedExpertise = 'All';
  double _minRating = 0.0;

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => FilterBottomSheet(
        selectedCategories: _selectedCategories,
        selectedExpertise: _selectedExpertise,
        minRating: _minRating,
        onApply: (categories, expertise, rating) {
          setState(() {
            _selectedCategories = categories;
            _selectedExpertise = expertise;
            _minRating = rating;
          });
          // Call actual filtering logic in the cubit
          context.read<DiscoveryCubit>().filterDiscoveryUsers(
            categories: categories,
            expertise: expertise,
            minRating: rating,
          );
        },
      ),
    );
  }

  void _refreshAllData(BuildContext context) {
    context.read<DiscoveryCubit>().fetchDiscoveryUsers();
    context.read<MatchesCubit>().fetchMatches();
    context.read<ProfileCubit>().fetchUserProfile();
    context.read<LikesCubit>().fetchLikesReceived();
    context.read<CreditsCubit>().fetchCredits();
  }

  @override
  Widget build(BuildContext context) {
    const primaryBgColor = AppColors.background;

    return Builder(
      builder: (context) {
        String title = "SkillSwap";
        Widget bodyContent = const DiscoveryPage();
        List<Widget>? actions;
        Widget? leading;

        switch (_selectedIndex) {
          case 0:
            title = "SkillSwap";
            bodyContent = const DiscoveryPage();
            leading = HomeAppBarAction(
              icon: Icons.search_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchPage()),
                );
              },
            );
            actions = [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: StreamBuilder(
                  stream: serviceLocator<LiveSessionFirestoreService>()
                      .watchSessions(),
                  builder: (context, snapshot) {
                    final sessions = snapshot.data ?? [];
                    final publicCount = sessions
                        .where((s) => s.type != 'one-on-one')
                        .length;
                    return HomeAppBarAction(
                      icon: Icons.video_camera_front_rounded,
                      badgeCount: publicCount > 0 ? publicCount : null,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SessionListPage(),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: HomeAppBarAction(
                  icon: Icons.tune_rounded,
                  onTap: () => _showFilterBottomSheet(context),
                ),
              ),
            ];
            break;
          case 1:
            title = "Matches";
            bodyContent = const MatchesPage();
            leading = HomeAppBarAction(
              icon: Icons.search_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchPage()),
                );
              },
            );
            actions = [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: HomeAppBarAction(
                  icon: Icons.tune_rounded,
                  onTap: () => _showFilterBottomSheet(context),
                ),
              ),
            ];
            break;
          case 2:
            title = "Likes";
            bodyContent = const LikesPage();
            break;
          case 3:
            title = "Profile";
            bodyContent = const ProfilePage();
            actions = [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
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
            ];
            break;
        }

        return MultiBlocListener(
          listeners: [
            BlocListener<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state is AuthSuccess) {
                  _refreshAllData(context);
                }
              },
            ),
            BlocListener<ConnectivityCubit, ConnectivityStatus>(
              listenWhen: (prev, curr) =>
                  prev == ConnectivityStatus.disconnected &&
                  curr == ConnectivityStatus.connected,
              listener: (context, _) => _refreshAllData(context),
            ),
          ],
          child: Scaffold(
            extendBody: true,
            backgroundColor: primaryBgColor,
            appBar:
                (_selectedIndex == 1 ||
                    _selectedIndex == 2 ||
                    _selectedIndex == 3)
                ? null
                : PreferredSize(
                    preferredSize: const Size.fromHeight(70),
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: AppBar(
                          backgroundColor: primaryBgColor.withValues(
                            alpha: 0.8,
                          ),
                          elevation: 0,
                          leadingWidth: 70,
                          leading: leading,
                          title: Text(
                            title,
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: AppColors.textPrimary,
                              letterSpacing: 2.0,
                            ),
                          ),
                          centerTitle: true,
                          actions: actions,
                          shape: Border(
                            bottom: BorderSide(
                              color: AppColors.overlay05,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
            body: bodyContent,
            bottomNavigationBar: MidnightNavigationBar(
              selectedIndex: _selectedIndex,
              onItemSelected: (index) => setState(() => _selectedIndex = index),
            ),
          ),
        );
      },
    );
  }
}

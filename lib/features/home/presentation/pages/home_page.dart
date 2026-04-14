import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_state.dart';
import 'package:skillswap/features/home/presentation/cubits/credits_cubit.dart';
import 'package:skillswap/features/home/presentation/cubits/discovery_cubit.dart';
import 'package:skillswap/features/home/presentation/cubits/matches_cubit.dart';
import 'package:skillswap/features/home/presentation/cubits/likes_cubit.dart';
import 'package:skillswap/features/home/presentation/cubits/profile_cubit.dart';
import 'package:skillswap/features/home/presentation/pages/search_page.dart';
import 'package:skillswap/features/home/presentation/widgets/matches_view.dart';
import 'package:skillswap/features/home/presentation/widgets/likes_view.dart';
import 'package:skillswap/features/home/presentation/widgets/profile_view.dart';
import 'package:skillswap/features/home/presentation/pages/wallet_page.dart';
import 'package:skillswap/features/home/presentation/widgets/discovery/discovery_tab.dart';
import 'package:skillswap/init_dependencies.dart';
import '../widgets/filter_bottom_sheet.dart';

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
  List<String> _selectedCategories = ['Design'];
  String _selectedExpertise = 'Intermediate';
  double _minRating = 4.0;

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

  @override
  Widget build(BuildContext context) {
    const primaryBgColor = Color(0xFF0C0A09);

    return Builder(
      builder: (context) {
        String title = "SkillSwap";
        Widget bodyContent = const DiscoveryTab();
        List<Widget>? actions;
        Widget? leading;

        switch (_selectedIndex) {
          case 0:
            title = "SkillSwap";
            bodyContent = const DiscoveryTab();
            leading = _buildActionButton(
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
                child: _buildActionButton(
                  icon: Icons.tune_rounded,
                  onTap: () => _showFilterBottomSheet(context),
                ),
              ),
            ];
            break;
          case 1:
            title = "Matches";
            bodyContent = const MatchesView();
            leading = _buildActionButton(
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
                child: _buildActionButton(
                  icon: Icons.tune_rounded,
                  onTap: () => _showFilterBottomSheet(context),
                ),
              ),
            ];
            break;
          case 2:
            title = "Curation";
            bodyContent = const LikesView();
            break;
          case 3:
            title = "Account";
            bodyContent = const ProfileView();
            actions = [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: _buildActionButton(
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

        return BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              context.read<DiscoveryCubit>().fetchDiscoveryUsers();
              context.read<MatchesCubit>().fetchMatches();
              context.read<ProfileCubit>().fetchUserProfile();
              context.read<LikesCubit>().fetchLikesReceived();
              context.read<CreditsCubit>().fetchCredits();
            }
          },
          child: Scaffold(
            extendBody: true,
            backgroundColor: primaryBgColor,
            appBar: _selectedIndex == 2
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
                            title.toUpperCase(),
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: Colors.white,
                              letterSpacing: 2.0,
                            ),
                          ),
                          centerTitle: true,
                          actions: actions,
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
            body: bodyContent,
            bottomNavigationBar: _buildMidnightNavigationBar(),
          ),
        );
      },
    );
  }

  Widget _buildMidnightNavigationBar() {
    return Container(
      height: 80,
      margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0C0A09).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.auto_awesome_rounded,
                label: 'DISCOVER',
                isSelected: _selectedIndex == 0,
                onTap: () => setState(() => _selectedIndex = 0),
              ),
              _NavItem(
                icon: Icons.handshake_rounded,
                label: 'MATCHES',
                isSelected: _selectedIndex == 1,
                onTap: () => setState(() => _selectedIndex = 1),
              ),
              _NavItem(
                icon: Icons.favorite_rounded,
                label: 'LIKES',
                isSelected: _selectedIndex == 2,
                onTap: () => setState(() => _selectedIndex = 2),
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: 'PROFILE',
                isSelected: _selectedIndex == 3,
                onTap: () => setState(() => _selectedIndex = 3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFFCA8A04);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSelected
                  ? accentColor.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: isSelected
                  ? accentColor
                  : Colors.white.withValues(alpha: 0.3),
              size: 26,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: isSelected
                  ? accentColor
                  : Colors.white.withValues(alpha: 0.3),
              letterSpacing: 1.0,
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.6),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

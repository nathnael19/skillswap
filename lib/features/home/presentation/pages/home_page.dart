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
  static MaterialPageRoute<dynamic> route() =>
      MaterialPageRoute(builder: (context) => const HomePage());
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

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        selectedCategories: _selectedCategories,
        selectedExpertise: _selectedExpertise,
        minRating: _minRating,
        onApply: (categories, expertise, rating) {
          setState(() {
            _selectedCategories = categories;
            _selectedExpertise = expertise;
            _minRating = rating;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String title = "SkillSwap";
    Widget bodyContent = const DiscoveryTab();
    List<Widget>? actions;
    Widget? leading;

    switch (_selectedIndex) {
      case 0:
        title = "SkillSwap";
        bodyContent = const DiscoveryTab();
        leading = _buildActionButton(
          icon: Icons.search,
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
              icon: Icons.tune,
              onTap: _showFilterBottomSheet,
            ),
          ),
        ];
        break;
      case 1:
        title = "Matches";
        bodyContent = const MatchesView();
        leading = IconButton(
          icon: const Icon(Icons.search, color: Color(0xFF1D2939)),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchPage()),
            );
          },
        );
        actions = [
          IconButton(
            icon: const Icon(Icons.tune, color: Color(0xFF1D2939)),
            onPressed: _showFilterBottomSheet,
          ),
        ];
        break;
      case 2:
        title = "Likes";
        bodyContent = const LikesView();
        break;
      case 3:
        title = "SkillSwap";
        bodyContent = const ProfileView();
        leading = null;
        actions = [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(
                Icons.account_balance_wallet_outlined,
                color: Color(0xFF1D2939),
                size: 28,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WalletPage()),
                );
              },
            ),
          ),
        ];
        break;
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              serviceLocator<DiscoveryCubit>()..fetchDiscoveryUsers(),
        ),
        BlocProvider(
          create: (_) => serviceLocator<MatchesCubit>()..fetchMatches(),
        ),
        BlocProvider(
          create: (_) => serviceLocator<CreditsCubit>()..fetchCredits(),
        ),
        BlocProvider(
          create: (_) => serviceLocator<ProfileCubit>()..fetchUserProfile(),
        ),
        BlocProvider(
          create: (_) => serviceLocator<LikesCubit>()..fetchLikesReceived(),
        ),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            // Refresh all data when user logs in successfully
            context.read<DiscoveryCubit>().fetchDiscoveryUsers();
            context.read<MatchesCubit>().fetchMatches();
            context.read<ProfileCubit>().fetchUserProfile();
            context.read<LikesCubit>().fetchLikesReceived();
            context.read<CreditsCubit>().fetchCredits();
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leadingWidth: _selectedIndex == 0 ? 70 : null,
            leading: leading,
            title: Text(
              title,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w700,
                fontSize: 24,
                color: const Color(0xFF101828),
              ),
            ),
            centerTitle: true,
            actions: actions,
          ),
          body: bodyContent,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF0B6A7A),
            unselectedItemColor: const Color(0xFF98A2B3),
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedLabelStyle: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
            unselectedLabelStyle: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.auto_awesome_rounded),
                ),
                label: 'DISCOVER',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.handshake_rounded),
                ),
                label: 'MATCHES',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.favorite_rounded),
                ),
                label: 'LIKES',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.person_rounded),
                ),
                label: 'PROFILE',
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
          decoration: const BoxDecoration(
            color: Color(0xFFF2F4F7),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF1D2939), size: 20),
        ),
      ),
    );
  }
}

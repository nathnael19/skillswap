import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/features/home/presentation/cubits/likes_cubit.dart';
import 'package:skillswap/features/home/presentation/cubits/matches_cubit.dart';
import '../../domain/models/user_model.dart';
import '../pages/master_profile_page.dart';
import 'package:skillswap/core/common/widgets/app_error_widget.dart';

class LikesView extends StatelessWidget {
  const LikesView({super.key});

  @override
  Widget build(BuildContext context) {

    const accentColor = Color(0xFFCA8A04);

    return DefaultTabController(
      length: 3,
      child: BlocBuilder<LikesCubit, LikesState>(
        builder: (context, state) {
          if (state is LikesLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: accentColor,
                strokeWidth: 2,
              ),
            );
          }

          if (state is LikesError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () => context.read<LikesCubit>().fetchLikes(),
            );
          }

          if (state is LikesLoaded) {
            return SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                    child: _buildHeader(),
                  ),
                  // Premium Glassy TabBar
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: TabBar(
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      dividerColor: Colors.transparent,
                      labelColor: accentColor,
                      unselectedLabelColor: Colors.white.withValues(alpha: 0.3),
                      labelStyle: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                      labelPadding: EdgeInsets.zero,
                      tabs: const [
                        Tab(text: 'INTERESTS'),
                        Tab(text: 'MY LIKES'),
                        Tab(text: 'HISTORY'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildLikesList(
                          context,
                          state.receivedLikes,
                          'The Stage is Set',
                          'Wait for masters to express interest in your craft and manifest your synergy.',
                          isReceived: true,
                        ),
                        _buildLikesList(
                          context,
                          state.sentLikes,
                          'Path of Discovery',
                          'Reach out to experts to manifest your journey and build your circle.',
                          isSent: true,
                        ),
                        _buildLikesList(
                          context,
                          state.passedUsers,
                          'Inner Circle Only',
                          'Your filtration history remains encrypted and private.',
                          isPassed: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildHeader() {
    const accentColor = Color(0xFFCA8A04);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
              'CURATED FEED',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: accentColor,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'Manifest Curation',
          style: GoogleFonts.dmSans(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildLikesList(
    BuildContext context,
    List<User> users,
    String emptyTitle,
    String emptySubtitle, {
    bool isReceived = false,
    bool isSent = false,
    bool isPassed = false,
  }) {
    const accentColor = Color(0xFFCA8A04);
    
    if (users.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          await context.read<LikesCubit>().fetchLikes();
          if (context.mounted) {
            await context.read<MatchesCubit>().fetchMatches();
          }
        },
        color: accentColor,
        backgroundColor: const Color(0xFF1C1917),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
          children: [
            const SizedBox(height: 80),
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.02),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    ),
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      size: 56,
                      color: accentColor.withValues(alpha: 0.3),
                    ),
                  ),
                  const SizedBox(height: 48),
                  Text(
                    emptyTitle,
                    style: GoogleFonts.dmSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    emptySubtitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      color: Colors.white.withValues(alpha: 0.3),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<LikesCubit>().fetchLikes();
        if (context.mounted) {
          await context.read<MatchesCubit>().fetchMatches();
        }
      },
      color: accentColor,
      backgroundColor: const Color(0xFF1C1917),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
        physics: const BouncingScrollPhysics(),
        itemCount: users.length,
        itemBuilder: (context, index) {
          return _buildLikeCard(
            context,
            users[index],
            isReceived: isReceived,
            isSent: isSent,
            isPassed: isPassed,
          );
        },
      ),
    );
  }

  Widget _buildLikeCard(
    BuildContext context,
    User user, {
    bool isReceived = false,
    bool isSent = false,
    bool isPassed = false,
  }) {
    const accentColor = Color(0xFFCA8A04);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(36),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Premium Image Section
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MasterProfilePage(userId: user.id),
                ),
              );
            },
            child: Stack(
              children: [
                ShaderMask(
                  shaderCallback: (rect) {
                    return LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.0),
                        Colors.black.withValues(alpha: 0.7),
                        Colors.black.withValues(alpha: 0.9),
                      ],
                      stops: const [0.0, 0.7, 1.0],
                    ).createShader(rect);
                  },
                  blendMode: BlendMode.darken,
                  child: user.imageUrl.startsWith('http')
                      ? Image.network(
                          user.imageUrl,
                          height: 280,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          user.imageUrl.isEmpty
                              ? 'assets/home.png'
                              : user.imageUrl,
                          height: 280,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),
                // Premium Overlay Metadata
                Positioned(
                  left: 24,
                  bottom: 24,
                  right: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: accentColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          user.teaching?.name.toUpperCase() ?? 'EXPERT',
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: accentColor,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        '${user.name}, ${user.age}',
                        style: GoogleFonts.dmSans(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Editorial Content Section
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.bio.isEmpty
                      ? "Passionate about crafting digital experiences that feel human."
                      : user.bio,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.4),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MasterProfilePage(userId: user.id),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                          ),
                          child: Center(
                            child: Text(
                              'Profile',
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (isReceived || isSent || isPassed)
                      const SizedBox(width: 14),
                    if (isReceived || isPassed)
                      Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [accentColor, Color(0xFFB47B03)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withValues(alpha: 0.3),
                                blurRadius: 15,
                                spreadRadius: -2,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              context.read<LikesCubit>().likeBackUser(user.id);
                              context.read<MatchesCubit>().fetchMatches();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              isPassed ? 'Express Interest' : 'Interconnect',
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (isSent)
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () => _showRetractConfirmation(context, user),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                            ),
                            child: Center(
                              child: Text(
                                'Withdraw',
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRetractConfirmation(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (dialogContext) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: AlertDialog(
          backgroundColor: const Color(0xFF0C0A09).withValues(alpha: 0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          title: Text(
            'Withdraw interest for ${user.name}?',
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          content: Text(
            'This action is final and will remove ${user.name} from your curated feed.',
            style: GoogleFonts.dmSans(
              color: Colors.white.withValues(alpha: 0.4),
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'CANCEL',
                style: GoogleFonts.dmSans(
                  color: Colors.white.withValues(alpha: 0.2),
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(dialogContext);
                context.read<LikesCubit>().undoLike(user.id);
                context.read<MatchesCubit>().fetchMatches();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.2)),
                ),
                child: Text(
                  'CONFIRM',
                  style: GoogleFonts.dmSans(
                    color: const Color(0xFFEF4444),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

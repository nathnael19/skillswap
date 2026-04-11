import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/features/home/presentation/cubits/likes_cubit.dart';
import 'package:skillswap/features/home/presentation/cubits/matches_cubit.dart';
import '../../domain/models/user_model.dart';
import '../pages/master_profile_page.dart';

class LikesView extends StatelessWidget {
  const LikesView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: BlocBuilder<LikesCubit, LikesState>(
        builder: (context, state) {
          if (state is LikesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is LikesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<LikesCubit>().fetchLikes(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is LikesLoaded) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: _buildHeader(),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TabBar(
                    isScrollable: true,
                    indicatorColor: const Color(0xFF0B6A7A),
                    labelColor: const Color(0xFF0B6A7A),
                    unselectedLabelColor: const Color(0xFF667085),
                    labelStyle: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                    indicatorWeight: 3,
                    indicatorSize: TabBarIndicatorSize.label,
                    tabs: const [
                      Tab(text: 'FOR YOU'),
                      Tab(text: 'LIKED'),
                      Tab(text: 'PASSED'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildLikesList(
                        context,
                        state.receivedLikes,
                        'No interest yet',
                        'Keep swiping to get noticed!',
                        isReceived: true,
                      ),
                      _buildLikesList(
                        context,
                        state.sentLikes,
                        'No likes sent',
                        'Find talented people in Discovery!',
                      ),
                      _buildLikesList(
                        context,
                        state.passedUsers,
                        'No passed profiles',
                        'Your skip history will appear here.',
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CURATION',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0B6A7A),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Interaction History',
          style: GoogleFonts.outfit(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF101828),
            height: 1.1,
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
  }) {
    if (users.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => context.read<LikesCubit>().fetchLikes(),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          children: [
            const SizedBox(height: 60),
            Center(
              child: Column(
                children: [
                  const Icon(Icons.history, size: 48, color: Colors.grey),
                  const SizedBox(height: 24),
                  Text(
                    emptyTitle,
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF101828),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    emptySubtitle,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF667085),
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
      onRefresh: () => context.read<LikesCubit>().fetchLikes(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        itemCount: users.length,
        itemBuilder: (context, index) {
          return _buildLikeCard(context, users[index], isReceived: isReceived);
        },
      ),
    );
  }

  Widget _buildLikeCard(BuildContext context, User user,
      {bool isReceived = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
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
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                  child: user.imageUrl.startsWith('http')
                      ? Image.network(
                          user.imageUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          user.imageUrl.isEmpty
                              ? 'assets/images/placeholder.png'
                              : user.imageUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),
                // Skill Tag overlay
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDECDA), // Light peach
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          user.teaching?.name.toUpperCase() ?? 'EXPERT',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF9E6400),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${user.name}, ${user.age}',
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Content Section
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
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF475467),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MasterProfilePage(userId: user.id),
                            ),
                          );
                        },
                        child: Text(
                          'See Profile',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0B6A7A),
                          ),
                        ),
                      ),
                    ),
                    if (isReceived) const SizedBox(width: 16),
                    if (isReceived)
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            context.read<LikesCubit>().likeBackUser(user.id);
                            context.read<MatchesCubit>().fetchMatches();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0B6A7A),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Like Back',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
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
}

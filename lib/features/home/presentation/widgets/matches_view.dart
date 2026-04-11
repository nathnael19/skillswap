import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/features/home/presentation/cubits/matches_cubit.dart';
import 'package:skillswap/features/home/presentation/pages/chat_page.dart';
import 'package:skillswap/features/auth/presentation/pages/onboarding_page.dart';
import 'package:skillswap/features/home/presentation/widgets/matches/conversation_item.dart';
import 'package:skillswap/features/home/presentation/widgets/matches/new_match_bubble.dart';

class MatchesView extends StatelessWidget {
  const MatchesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MatchesCubit, MatchesState>(
      builder: (context, state) {
        if (state is MatchesLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is MatchesError) {
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
                  ),
                  child: const Icon(
                    Icons.handshake_rounded,
                    color: Color(0xFF0B6A7A),
                    size: 64,
                  ),
                ),
                const SizedBox(height: 48),
                Text(
                  'Your Connections',
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF101828),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Once you connect with an expert, your shared journey and messages will appear here.',
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
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        }

        if (state is MatchesLoaded) {
          final matches = state.matches;

          if (matches.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.handshake_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    "No matches yet!",
                    style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text("Start swiping to find skill-swap partners."),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              _buildSectionHeader('NEW MATCHES • SUCCESS'),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: matches.map((user) {
                    return NewMatchBubble(
                      name: user.name,
                      imageUrl: user.imageUrl,
                      teachingSkill: user.teaching?.name ?? 'Expert',
                      isTopMatch: false,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              userName: user.name,
                              userImageUrl: user.imageUrl,
                              userTitle: user.teaching?.name ?? 'Expert',
                              matchId: user.matchId ?? '',
                              isOnline: true,
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionHeader('CONVERSATIONS • ACTIVE'),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    final user = matches[index];
                    return ConversationItem(
                      userName: user.name,
                      userImageUrl: user.imageUrl,
                      lastMessage: "Start a conversation!",
                      timestamp: "Just now",
                      skillTag: user.teaching?.name ?? 'Expert',
                      isOnline: true,
                      hasUnread: false,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              userName: user.name,
                              userImageUrl: user.imageUrl,
                              userTitle: user.teaching?.name ?? 'Expert',
                              matchId: user.matchId ?? '',
                              isOnline: true,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF0B6A7A),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/features/home/domain/models/user_model.dart';
import 'package:skillswap/features/home/presentation/cubits/likes_cubit.dart';
import 'package:skillswap/features/home/presentation/cubits/matches_cubit.dart';
import 'package:skillswap/features/home/presentation/pages/master_profile/master_profile_page.dart';
import 'like_card_header.dart';
import 'like_card_actions.dart';
import 'retract_confirmation_dialog.dart';

class LikeCard extends StatelessWidget {
  final User user;
  final bool isReceived;
  final bool isSent;
  final bool isPassed;

  const LikeCard({
    super.key,
    required this.user,
    this.isReceived = false,
    this.isSent = false,
    this.isPassed = false,
  });

  @override
  Widget build(BuildContext context) {


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
          LikeCardHeader(user: user),
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
                LikeCardActions(
                  isReceived: isReceived,
                  isSent: isSent,
                  isPassed: isPassed,
                  onProfileTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MasterProfilePage(userId: user.id),
                      ),
                    );
                  },
                  onConnectTap: () {
                    context.read<LikesCubit>().likeBackUser(user.id);
                    context.read<MatchesCubit>().fetchMatches();
                  },
                  onWithdrawTap: () => _showRetractConfirmation(context, user),
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
      builder: (dialogContext) => RetractConfirmationDialog(
        user: user,
        onConfirm: () {
          context.read<LikesCubit>().undoLike(user.id);
          context.read<MatchesCubit>().fetchMatches();
        },
      ),
    );
  }
}

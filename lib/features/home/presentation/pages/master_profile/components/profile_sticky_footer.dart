import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_state.dart';
import 'package:skillswap/features/auth/presentation/pages/onboarding_page.dart';
import 'package:skillswap/features/home/domain/models/user_model.dart';
import 'package:skillswap/features/home/domain/repositories/home_repository.dart';
import 'package:skillswap/features/home/presentation/cubits/credits_cubit.dart';
import 'package:skillswap/features/home/presentation/pages/chat/chat_page.dart';
import 'package:skillswap/features/home/presentation/shared/premium_dialogs.dart';
import 'package:skillswap/init_dependencies.dart';
import 'package:skillswap/core/constants/app_constants.dart';
import 'package:skillswap/core/theme/theme.dart';

class ProfileStickyFooter extends StatelessWidget {
  final User user;
  const ProfileStickyFooter({super.key, required this.user});

  void _navigateToChat(
    BuildContext context,
    String currentUserId,
    String matchId, {
    String status = 'mutual',
    String? payerId,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          userName: user.name,
          userImageUrl: user.imageUrl,
          userTitle: user.profession,
          matchId: matchId,
          userId: user.id,
          currentUserId: currentUserId,
          status: status,
          payerId: payerId,
        ),
      ),
    );
  }

  void _showPaidMessageDialog(BuildContext context, String currentUserId) {
    showDialog(
      context: context,
      builder: (dialogContext) => PremiumActionDialog(
        title: "Instant Connection",
        description:
            "Connect with ${user.name} immediately for ${AppConstants.paidChatCostLabel}. This will open a permanent chat channel.",
        actionLabel: "Message Now",
        costLabel: AppConstants.paidChatCostLabel,
        onConfirm: () async {
          final result = await serviceLocator<HomeRepository>().initPaidChat(
            user.id,
          );

          if (!context.mounted) return;

          result.fold(
            (failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(failure.message),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
            (matchId) {
              // Refresh credits after spending
              context.read<CreditsCubit>().fetchCredits();

              _navigateToChat(
                context,
                currentUserId,
                matchId,
                status: 'pending',
                payerId: currentUserId,
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const kPrimary = AppColors.primary;
    const kBackground = AppColors.surface;

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final bool isGuest = authState is! AuthSuccess;
        final String? currentUserId = authState is AuthSuccess
            ? authState.uid
            : null;

        void handleAction(VoidCallback onAuth) {
          if (isGuest) {
            Navigator.of(context).push(OnboardingPage.route());
          } else {
            onAuth();
          }
        }

        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 34),
            decoration: BoxDecoration(
              color: kBackground,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 30,
                  offset: const Offset(0, -10),
                ),
              ],
              border: Border(top: BorderSide(color: AppColors.overlay05)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => handleAction(() {
                      // Request Swap logic would go here
                    }),
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: kPrimary.withValues(alpha: 0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          isGuest ? 'Sign in to Swap' : 'Request Swap',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () => handleAction(() {
                    if (user.matchId != null) {
                      _navigateToChat(
                        context,
                        currentUserId!,
                        user.matchId!,
                        status: user.matchStatus ?? 'mutual',
                        payerId: user.matchPayerId,
                      );
                    } else {
                      _showPaidMessageDialog(context, currentUserId!);
                    }
                  }),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.overlay05,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.overlay05),
                    ),
                    child: const Icon(
                      Icons.chat_bubble_rounded,
                      color: kPrimary,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

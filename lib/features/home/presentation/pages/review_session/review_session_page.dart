import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/features/home/domain/repositories/home_repository.dart';
import 'package:skillswap/features/home/presentation/cubits/credits_cubit.dart';
import 'package:skillswap/features/home/presentation/pages/home/home_page.dart';
import 'package:skillswap/features/home/presentation/pages/wallet_page.dart';
import 'package:skillswap/init_dependencies.dart';
import 'components/avatar_header.dart';
import 'components/rating_stars_card.dart';
import 'components/endorsements_section.dart';
import 'components/review_input.dart';
import 'package:skillswap/core/theme/theme.dart';

class ReviewSessionPage extends StatefulWidget {
  final String? sessionId;
  final String peerId;
  final String peerName;
  final String peerImageUrl;

  const ReviewSessionPage({
    super.key,
    this.sessionId,
    required this.peerId,
    required this.peerName,
    required this.peerImageUrl,
  });

  @override
  State<ReviewSessionPage> createState() => _ReviewSessionPageState();
}

class _ReviewSessionPageState extends State<ReviewSessionPage> {
  int _rating = 4;
  final Set<String> _selectedEndorsements = {'Patient Learner'};
  final TextEditingController _reviewController = TextEditingController();
  bool _finishingSession = false;

  final List<String> _endorsementOptions = [
    'Great Teacher',
    'Patient Learner',
    'Clear Communication',
    'Practical Examples',
    'Resourceful',
  ];

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _exitAfterComplete(BuildContext context) {
    if (mounted) {
      Navigator.pushAndRemoveUntil(context, HomePage.route(), (route) => false);
    }
  }

  void _showInsufficientCreditsDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Not enough credits'),
        content: const Text(
          'You need at least 3 credits to complete this session as the learner. Buy credits to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Later'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push<void>(
                context,
                MaterialPageRoute<void>(builder: (_) => const WalletPage()),
              ).then((_) {
                if (context.mounted) {
                  context.read<CreditsCubit>().fetchCredits();
                }
              });
            },
            child: const Text('Buy credits'),
          ),
        ],
      ),
    );
  }

  Future<void> _tryCompleteThenExit() async {
    if (_finishingSession) return;
    if (widget.sessionId == null) {
      if (mounted) Navigator.pop(context);
      return;
    }
    setState(() => _finishingSession = true);
    final repo = serviceLocator<HomeRepository>();
    final result = await repo.updateSessionStatus(
      sessionId: widget.sessionId!,
      status: 'completed',
    );
    if (!mounted) return;
    setState(() => _finishingSession = false);
    result.fold(
      (failure) {
        if (failure.message == 'INSUFFICIENT_CREDITS') {
          _showInsufficientCreditsDialog(context);
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(failure.message)));
        }
      },
      (_) async {
        final reviewComment = _reviewController.text.trim();
        final endorsementsText = _selectedEndorsements.isNotEmpty
            ? '\n[Endorsements: ${_selectedEndorsements.join(', ')}]'
            : '';

        await repo.submitReview(
          sessionId: widget.sessionId!,
          targetId: widget.peerId,
          rating: _rating.toDouble(),
          comment: reviewComment + endorsementsText,
        );

        if (mounted) _exitAfterComplete(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.textPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF101828), size: 24),
          onPressed: _finishingSession
              ? null
              : () => _exitAfterComplete(context),
        ),
        title: Text(
          'Review Session',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF101828),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 32),
            AvatarHeader(
              peerName: widget.peerName,
              peerImageUrl: widget.peerImageUrl,
            ),
            const SizedBox(height: 48),
            RatingStarsCard(
              rating: _rating,
              onRatingChanged: (val) => setState(() => _rating = val),
            ),
            const SizedBox(height: 40),
            EndorsementsSection(
              endorsementOptions: _endorsementOptions,
              selectedEndorsements: _selectedEndorsements,
              onToggle: (trait) {
                setState(() {
                  if (_selectedEndorsements.contains(trait)) {
                    _selectedEndorsements.remove(trait);
                  } else {
                    _selectedEndorsements.add(trait);
                  }
                });
              },
            ),
            const SizedBox(height: 40),
            ReviewInput(controller: _reviewController),
            const SizedBox(height: 40),
            _buildSubmitButton(),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _finishingSession
                  ? null
                  : () => _tryCompleteThenExit(),
              child: Text(
                'Skip for now',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF667085),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _finishingSession ? null : () => _tryCompleteThenExit(),
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF0B6A7A),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0B6A7A).withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: _finishingSession
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.textPrimary,
                    ),
                  )
                : Text(
                    'Submit Review',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

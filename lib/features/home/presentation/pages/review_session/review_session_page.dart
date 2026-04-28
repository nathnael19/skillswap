import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/features/home/domain/repositories/home_repository.dart';
import 'package:skillswap/features/home/presentation/cubits/credits_cubit.dart';
import 'package:skillswap/features/home/presentation/pages/home/home_page.dart';
import 'package:skillswap/features/home/presentation/pages/wallet_page.dart';
import 'package:skillswap/init_dependencies.dart';
import 'components/avatar_header.dart';
import 'components/rating_stars_card.dart';
import 'components/endorsements_section.dart';
import 'components/review_input.dart';
import 'package:skillswap/core/layout/responsive.dart';
import 'package:skillswap/core/theme/theme.dart';
import 'package:skillswap/core/common/widgets/app_button.dart';

class ReviewSessionPage extends StatefulWidget {
  final String? sessionId;
  final String peerId;
  final String peerName;
  final String peerImageUrl;
  final bool fromLiveSession;

  const ReviewSessionPage({
    super.key,
    this.sessionId,
    required this.peerId,
    required this.peerName,
    required this.peerImageUrl,
    this.fromLiveSession = false,
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

  Future<bool> _submitReview(HomeRepository repo) async {
    final reviewComment = _reviewController.text.trim();
    final endorsementsText = _selectedEndorsements.isNotEmpty
        ? '\n[Endorsements: ${_selectedEndorsements.join(', ')}]'
        : '';
    final reviewResult = await repo.submitReview(
      sessionId: widget.sessionId!,
      targetId: widget.peerId,
      rating: _rating.toDouble(),
      comment: reviewComment + endorsementsText,
    );

    if (!mounted) return false;

    return reviewResult.fold((failure) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message)));
      return false;
    }, (_) => true);
  }

  Future<void> _tryCompleteThenExit() async {
    if (_finishingSession) return;
    if (widget.sessionId == null) {
      if (mounted) Navigator.pop(context);
      return;
    }
    setState(() => _finishingSession = true);
    final repo = serviceLocator<HomeRepository>();
    final result = widget.fromLiveSession
        ? null
        : await repo.updateSessionStatus(
            sessionId: widget.sessionId!,
            status: 'completed',
          );
    if (!mounted) return;
    if (result == null) {
      setState(() => _finishingSession = false);
      final submitted = await _submitReview(repo);
      if (submitted && mounted) {
        _exitAfterComplete(context);
      }
      return;
    }
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
        final submitted = await _submitReview(repo);
        if (!mounted) return;
        setState(() => _finishingSession = false);
        if (submitted) {
          _exitAfterComplete(context);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = AppColors.primary;
    const primaryBgColor = AppColors.background;

    return Scaffold(
      backgroundColor: primaryBgColor,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: AppBar(
              backgroundColor: primaryBgColor.withValues(alpha: 0.8),
              elevation: 0,
              leading: Center(
                child: GestureDetector(
                  onTap: _finishingSession
                      ? null
                      : () => _exitAfterComplete(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.borderSubtle,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.borderDefault),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                  ),
                ),
              ),
              title: Text(
                'Review Session',
                style: AppTextStyles.labelMedium.copyWith(
                  color: accentColor,
                  letterSpacing: 2.0,
                ),
              ),
              centerTitle: true,
              shape: const Border(
                bottom: BorderSide(color: AppColors.borderSubtle, width: 1),
              ),
            ),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final glowSize = (constraints.maxWidth * 0.95).clamp(260.0, 520.0);
          return Stack(
            children: [
              // ambient glow
              Positioned(
                top: -glowSize * 0.35,
                left: -glowSize * 0.15,
                child: Container(
                  width: glowSize,
                  height: glowSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        accentColor.withValues(alpha: 0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: Responsive.contentMaxWidthFor(context).isFinite
                          ? Responsive.contentMaxWidthFor(context)
                          : 560,
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        Responsive.contentHorizontalPadding(context),
                        Responsive.valueFor<double>(
                          context,
                          compact: 20,
                          mobile: 28,
                          tablet: 32,
                          tabletWide: 32,
                          desktop: 36,
                        ),
                        Responsive.contentHorizontalPadding(context),
                        Responsive.valueFor<double>(
                              context,
                              compact: 24,
                              mobile: 32,
                              tablet: 36,
                              tabletWide: 40,
                              desktop: 40,
                            ) +
                            MediaQuery.viewInsetsOf(context).bottom,
                      ),
                      child: Responsive.isTwoPane(context)
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      AvatarHeader(
                                        peerName: widget.peerName,
                                        peerImageUrl: widget.peerImageUrl,
                                      ),
                                      SizedBox(
                                        height: Responsive.valueFor<double>(
                                          context,
                                          compact: 24,
                                          mobile: 32,
                                          tablet: 40,
                                          tabletWide: 48,
                                          desktop: 48,
                                        ),
                                      ),
                                      RatingStarsCard(
                                        rating: _rating,
                                        onRatingChanged: (val) =>
                                            setState(() => _rating = val),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: Responsive.valueFor<double>(
                                    context,
                                    compact: 16,
                                    mobile: 20,
                                    tablet: 24,
                                    tabletWide: 28,
                                    desktop: 32,
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      EndorsementsSection(
                                        endorsementOptions: _endorsementOptions,
                                        selectedEndorsements:
                                            _selectedEndorsements,
                                        onToggle: (trait) {
                                          setState(() {
                                            if (_selectedEndorsements.contains(
                                              trait,
                                            )) {
                                              _selectedEndorsements.remove(
                                                trait,
                                              );
                                            } else {
                                              _selectedEndorsements.add(trait);
                                            }
                                          });
                                        },
                                      ),
                                      SizedBox(
                                        height: Responsive.valueFor<double>(
                                          context,
                                          compact: 24,
                                          mobile: 32,
                                          tablet: 36,
                                          tabletWide: 40,
                                          desktop: 40,
                                        ),
                                      ),
                                      ReviewInput(
                                        controller: _reviewController,
                                      ),
                                      SizedBox(
                                        height: Responsive.valueFor<double>(
                                          context,
                                          compact: 24,
                                          mobile: 32,
                                          tablet: 36,
                                          tabletWide: 40,
                                          desktop: 40,
                                        ),
                                      ),
                                      AppButton(
                                        label: 'Submit Review',
                                        isLoading: _finishingSession,
                                        onTap: () => _tryCompleteThenExit(),
                                      ),
                                      SizedBox(
                                        height: Responsive.valueFor<double>(
                                          context,
                                          compact: 12,
                                          mobile: 16,
                                          tablet: 18,
                                          tabletWide: 20,
                                          desktop: 20,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: _finishingSession
                                            ? null
                                            : () => _tryCompleteThenExit(),
                                        child: Text(
                                          'Skip for now',
                                          style: AppTextStyles.labelSmall
                                              .copyWith(
                                                color: AppColors.textSecondary,
                                                letterSpacing: 1.0,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                AvatarHeader(
                                  peerName: widget.peerName,
                                  peerImageUrl: widget.peerImageUrl,
                                ),
                                SizedBox(
                                  height: Responsive.valueFor<double>(
                                    context,
                                    compact: 28,
                                    mobile: 36,
                                    tablet: 42,
                                    tabletWide: 48,
                                    desktop: 48,
                                  ),
                                ),
                                RatingStarsCard(
                                  rating: _rating,
                                  onRatingChanged: (val) =>
                                      setState(() => _rating = val),
                                ),
                                SizedBox(
                                  height: Responsive.valueFor<double>(
                                    context,
                                    compact: 28,
                                    mobile: 32,
                                    tablet: 36,
                                    tabletWide: 40,
                                    desktop: 40,
                                  ),
                                ),
                                EndorsementsSection(
                                  endorsementOptions: _endorsementOptions,
                                  selectedEndorsements: _selectedEndorsements,
                                  onToggle: (trait) {
                                    setState(() {
                                      if (_selectedEndorsements.contains(
                                        trait,
                                      )) {
                                        _selectedEndorsements.remove(trait);
                                      } else {
                                        _selectedEndorsements.add(trait);
                                      }
                                    });
                                  },
                                ),
                                SizedBox(
                                  height: Responsive.valueFor<double>(
                                    context,
                                    compact: 28,
                                    mobile: 32,
                                    tablet: 36,
                                    tabletWide: 40,
                                    desktop: 40,
                                  ),
                                ),
                                ReviewInput(controller: _reviewController),
                                SizedBox(
                                  height: Responsive.valueFor<double>(
                                    context,
                                    compact: 28,
                                    mobile: 32,
                                    tablet: 36,
                                    tabletWide: 40,
                                    desktop: 40,
                                  ),
                                ),
                                AppButton(
                                  label: 'Submit Review',
                                  isLoading: _finishingSession,
                                  onTap: () => _tryCompleteThenExit(),
                                ),
                                SizedBox(
                                  height: Responsive.valueFor<double>(
                                    context,
                                    compact: 12,
                                    mobile: 16,
                                    tablet: 18,
                                    tabletWide: 20,
                                    desktop: 20,
                                  ),
                                ),
                                TextButton(
                                  onPressed: _finishingSession
                                      ? null
                                      : () => _tryCompleteThenExit(),
                                  child: Text(
                                    'Skip for now',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.textSecondary,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

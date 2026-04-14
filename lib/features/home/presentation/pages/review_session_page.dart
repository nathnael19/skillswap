import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/features/home/domain/repositories/home_repository.dart';
import 'package:skillswap/features/home/presentation/cubits/credits_cubit.dart';
import 'package:skillswap/features/home/presentation/pages/wallet_page.dart';
import 'package:skillswap/init_dependencies.dart';

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
    final nav = Navigator.of(context);
    nav.pop();
    if (widget.sessionId != null) {
      if (nav.canPop()) nav.pop();
      if (nav.canPop()) nav.pop();
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

  Future<void> _tryCompleteThenExit(BuildContext context) async {
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message)),
          );
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF101828), size: 24),
          onPressed: _finishingSession ? null : () => _tryCompleteThenExit(context),
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
            _buildAvatarHeader(),
            const SizedBox(height: 48),
            _buildRatingCard(),
            const SizedBox(height: 40),
            _buildEndorsementsSection(),
            const SizedBox(height: 40),
            _buildReviewInput(),
            const SizedBox(height: 40),
            _buildSubmitButton(),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _finishingSession ? null : () => _tryCompleteThenExit(context),
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

  Widget _buildAvatarHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                image: DecorationImage(
                  image: NetworkImage(widget.peerImageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFF9E6400),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.stars, color: Colors.white, size: 18),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'SKILL EXCHANGE COMPLETE',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0B6A7A),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Review your session\nwith ${widget.peerName}',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 28, // Scaled down to prevent overflow
            fontWeight: FontWeight.w800,
            color: const Color(0xFF101828),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            'How was the experience?',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF475467),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => setState(() => _rating = index + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    index < _rating ? Icons.star_rounded : Icons.star_border_rounded,
                    color: index < _rating ? const Color(0xFF0B6A7A) : const Color(0xFFD0D5DD),
                    size: 40,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildEndorsementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ENDORSE SKILLS',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF475467),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 12,
          children: _endorsementOptions.map((trait) {
            bool isSelected = _selectedEndorsements.contains(trait);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedEndorsements.remove(trait);
                  } else {
                    _selectedEndorsements.add(trait);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF0B6A7A) : const Color(0xFFE4E7EC).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  trait,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF475467),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildReviewInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WHAT DID YOU LEARN?',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF475467),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE4E7EC).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _reviewController,
            maxLines: 4,
            style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF101828)),
            decoration: InputDecoration(
              hintText: 'Sarah was incredibly patient while explaining the fundamentals of Figma auto-layout...',
              hintStyle: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF98A2B3),
                height: 1.4,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _finishingSession ? null : () => _tryCompleteThenExit(context),
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
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Submit Review',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

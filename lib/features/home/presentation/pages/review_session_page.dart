import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReviewSessionPage extends StatefulWidget {
  const ReviewSessionPage({super.key});

  @override
  State<ReviewSessionPage> createState() => _ReviewSessionPageState();
}

class _ReviewSessionPageState extends State<ReviewSessionPage> {
  int _rating = 4;
  final Set<String> _selectedEndorsements = {'Patient Learner'};
  final TextEditingController _reviewController = TextEditingController();

  final List<String> _endorsementOptions = [
    'Great Teacher',
    'Patient Learner',
    'Clear Communication',
    'Practical Examples',
    'Resourceful',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF101828), size: 24),
          onPressed: () => Navigator.pop(context),
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
              onPressed: () => Navigator.pop(context),
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
                image: const DecorationImage(
                  image: AssetImage('assets/home.png'),
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
          'Review your session\nwith Sarah',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 28,
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
    return Container(
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
        child: Text(
          'Submit Review',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

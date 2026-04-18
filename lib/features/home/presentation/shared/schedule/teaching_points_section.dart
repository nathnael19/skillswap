import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/core/theme/theme.dart';

class TeachingPointsSection extends StatelessWidget {
  final List<String> topics;
  final TextEditingController controller;
  final VoidCallback onAdd;
  final Function(int) onRemove;

  const TeachingPointsSection({
    super.key,
    required this.topics,
    required this.controller,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    const accentColor = AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accentColor.withValues(alpha: 0.2)),
              ),
              child: const Icon(
                Icons.auto_awesome_mosaic_rounded,
                color: accentColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 20),
            Text(
              '2. Add Topics',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        // Dynamic Topic List
        if (topics.isEmpty)
          _buildEmptyTopics()
        else
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: topics.asMap().entries.map((entry) {
              return _buildTopicChip(entry.key, entry.value);
            }).toList(),
          ),
        const SizedBox(height: 32),
        // Premium Input Field
        Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.overlay03,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.overlay08),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  style: GoogleFonts.dmSans(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'What do you want to learn or teach?',
                    hintStyle: GoogleFonts.dmSans(
                      color: AppColors.overlay20,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => onAdd(),
                ),
              ),
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopicChip(int index, String label) {
    const accentColor = AppColors.primary;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      decoration: BoxDecoration(
        color: AppColors.overlay05,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.overlay10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: AppColors.overlay60,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => onRemove(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.overlay10,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                color: accentColor,
                size: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTopics() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.textPrimary.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.overlay05,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            color: AppColors.overlay10,
            size: 32,
          ),
          const SizedBox(height: 16),
          Text(
            'No topics yet',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: AppColors.overlay20,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some topics to help focus your session.',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: AppColors.textPrimary.withValues(alpha: 0.15),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

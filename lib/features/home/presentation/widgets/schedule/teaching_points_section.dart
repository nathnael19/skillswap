import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    const accentColor = Color(0xFFCA8A04);
    
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
              child: const Icon(Icons.auto_awesome_mosaic_rounded,
                  color: accentColor, size: 22),
            ),
            const SizedBox(width: 20),
            Text(
              '2. MANIFEST TOPICS',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.white,
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
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Manifest a new teaching point...',
                    hintStyle: GoogleFonts.dmSans(
                      color: Colors.white.withValues(alpha: 0.2),
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
                      )
                    ],
                  ),
                  child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopicChip(int index, String label) {
    const accentColor = Color(0xFFCA8A04);
    
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Colors.white.withValues(alpha: 0.6),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => onRemove(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded,
                  color: accentColor, size: 12),
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
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.auto_awesome_rounded,
              color: Colors.white.withValues(alpha: 0.1), size: 32),
          const SizedBox(height: 16),
          Text(
            'EMPTY NEXUS',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: Colors.white.withValues(alpha: 0.2),
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Suggest topics to sharpen the synergy between both masters.',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.15),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

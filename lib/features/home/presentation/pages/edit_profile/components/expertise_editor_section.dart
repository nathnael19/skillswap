import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/features/home/domain/models/user_model.dart';

class ExpertiseEditorSection extends StatelessWidget {
  final String title;
  final List<Skill> tags;
  final VoidCallback onAdd;
  final Function(Skill) onRemove;

  const ExpertiseEditorSection({
    super.key,
    required this.title,
    required this.tags,
    required this.onAdd,
    required this.onRemove,
  });

  static const Color kAccent = Color(0xFFCA8A04);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: kAccent,
                letterSpacing: 1.5,
              ),
            ),
            InkWell(
              onTap: onAdd,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: kAccent.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.add_rounded, color: kAccent, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      'Add',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: kAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: tags
              .map(
                (skill) => _buildEditableTag(skill),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildEditableTag(Skill skill) {
    return Container(
      padding: const EdgeInsets.only(left: 14, right: 8, top: 8, bottom: 8),
      decoration: BoxDecoration(
        color: kAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kAccent.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            skill.name,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: kAccent,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => onRemove(skill),
            child: Icon(
              Icons.close_rounded,
              color: kAccent.withValues(alpha: 0.5),
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SkillSelectionInput extends StatefulWidget {
  final String type;
  final List<Map<String, String>> skills;
  final Function(String) onAddSkill;
  final Function(int) onRemoveSkill;

  const SkillSelectionInput({
    super.key,
    required this.type,
    required this.skills,
    required this.onAddSkill,
    required this.onRemoveSkill,
  });

  @override
  State<SkillSelectionInput> createState() => _SkillSelectionInputState();
}

class _SkillSelectionInputState extends State<SkillSelectionInput> {
  final TextEditingController _skillInputController = TextEditingController();

  void _handleAdd() {
    if (_skillInputController.text.isNotEmpty) {
      widget.onAddSkill(_skillInputController.text);
      _skillInputController.clear();
    }
  }

  @override
  void dispose() {
    _skillInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFFCA8A04);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _skillInputController,
                  style: GoogleFonts.dmSans(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'e.g. Flutter, Advanced Design...',
                    hintStyle: GoogleFonts.dmSans(
                        color: Colors.white.withValues(alpha: 0.15)),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _handleAdd(),
                ),
              ),
              GestureDetector(
                onTap: _handleAdd,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: widget.skills
              .asMap()
              .entries
              .where((e) => e.value['type'] == widget.type)
              .map(
                (e) => Container(
                  padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        e.value['name']!,
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.white.withValues(alpha: 0.6),
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => widget.onRemoveSkill(e.key),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded,
                              color: Colors.white24, size: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

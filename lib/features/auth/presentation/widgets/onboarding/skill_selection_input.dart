import 'package:flutter/material.dart';
import 'package:skillswap/core/theme/theme.dart';

class SkillSelectionInput extends StatefulWidget {
  final String type;
  final List<Map<String, dynamic>> skills;
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
    const accentColor = AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderSubtle),
          ),

          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _skillInputController,
                  style: AppTextStyles.bodySmall,
                  decoration: InputDecoration(
                    hintText: 'e.g. Flutter, Advanced Design...',
                    hintStyle: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary.withValues(alpha: 0.15),
                    ),
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
                    color: AppColors.borderSubtle,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: AppColors.borderDefault),
                  ),

                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        e.value['name']?.toString() ?? '',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => widget.onRemoveSkill(e.key),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.borderDefault,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: AppColors.textMuted,
                            size: 12,
                          ),
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

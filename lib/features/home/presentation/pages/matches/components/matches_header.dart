import 'package:flutter/material.dart';
import 'package:skillswap/features/home/presentation/pages/search_page.dart';
import 'package:skillswap/core/theme/theme.dart';

class MatchesHeader extends StatelessWidget {
  const MatchesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    const accentColor = AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'CONNECTIONS',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: accentColor,
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                _buildHeaderAction(
                  icon: Icons.search_rounded,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                _buildHeaderAction(
                  icon: Icons.tune_rounded,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Filter from home tab')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderAction({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: AppColors.borderSubtle,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderDefault, width: 1),
        ),

        child: Icon(icon, color: AppColors.textPrimary, size: 18),
      ),
    );
  }
}

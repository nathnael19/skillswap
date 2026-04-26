import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/core/theme/theme.dart';
import 'package:skillswap/features/home/domain/models/user_model.dart';

class GamificationStats extends StatelessWidget {
  final User user;

  const GamificationStats({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final levelInfo = user.levelInfo ?? {};
    final String level = levelInfo['level'] ?? 'Novice';
    final double progress = (levelInfo['progress'] ?? 0.0).toDouble();
    final double teachingHours = (levelInfo['teaching_hours'] ?? 0.0).toDouble();
    final int streak = user.learningStreak;
    final int highestStreak = user.highestLearningStreak;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.overlay03,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.overlay08),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                icon: Icons.auto_awesome_rounded,
                title: 'Level',
                value: level,
                color: AppColors.primary,
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.overlay10,
              ),
              _buildStatItem(
                icon: Icons.local_fire_department_rounded,
                title: 'Weekly Streak',
                value: '$streak',
                subtitle: 'Best: $highestStreak',
                color: Colors.orangeAccent,
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.overlay10,
              ),
              _buildStatItem(
                icon: Icons.timer_rounded,
                title: 'Taught',
                value: '${teachingHours}h',
                color: Colors.lightBlueAccent,
              ),
            ],
          ),
          if (levelInfo['next_level'] != null) ...[
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress to ${levelInfo['next_level']}',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.overlay40,
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.overlay05,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Stack(
                children: [
                  FractionallySizedBox(
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                        ),
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    String? subtitle,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.overlay40,
            letterSpacing: 0.5,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.overlay30,
            ),
          ),
        ]
      ],
    );
  }
}

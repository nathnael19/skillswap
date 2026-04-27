import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/core/layout/responsive.dart';
import 'package:skillswap/core/theme/theme.dart';

class MidnightNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const MidnightNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isCompact = Responsive.isCompact(context);
    final barHeight = isCompact ? 72.0 : 80.0;
    final iconSize = isCompact ? 22.0 : 26.0;
    final labelSize = isCompact ? 8.0 : 9.0;
    final iconPadding = isCompact ? 8.0 : 10.0;
    final horizontalMargin = isCompact ? 10.0 : 16.0;
    return Container(
      height: barHeight,
      margin: EdgeInsets.only(bottom: 24, left: horizontalMargin, right: horizontalMargin),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.overlay10, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Material(
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.auto_awesome_rounded,
                  label: 'Discover',
                  isSelected: selectedIndex == 0,
                  onTap: () => onItemSelected(0),
                  iconSize: iconSize,
                  labelSize: labelSize,
                  iconPadding: iconPadding,
                ),
                _NavItem(
                  icon: Icons.handshake_rounded,
                  label: 'Matches',
                  isSelected: selectedIndex == 1,
                  onTap: () => onItemSelected(1),
                  iconSize: iconSize,
                  labelSize: labelSize,
                  iconPadding: iconPadding,
                ),
                _NavItem(
                  icon: Icons.favorite_rounded,
                  label: 'Likes',
                  isSelected: selectedIndex == 2,
                  onTap: () => onItemSelected(2),
                  iconSize: iconSize,
                  labelSize: labelSize,
                  iconPadding: iconPadding,
                ),
                _NavItem(
                  icon: Icons.groups_2_rounded,
                  label: 'Hubs',
                  isSelected: selectedIndex == 3,
                  onTap: () => onItemSelected(3),
                  iconSize: iconSize,
                  labelSize: labelSize,
                  iconPadding: iconPadding,
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  isSelected: selectedIndex == 4,
                  onTap: () => onItemSelected(4),
                  iconSize: iconSize,
                  labelSize: labelSize,
                  iconPadding: iconPadding,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final double iconSize;
  final double labelSize;
  final double iconPadding;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.iconSize,
    required this.labelSize,
    required this.iconPadding,
  });

  @override
  Widget build(BuildContext context) {
    const accentColor = AppColors.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.all(iconPadding),
              decoration: BoxDecoration(
                color: isSelected
                    ? accentColor.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: isSelected ? accentColor : AppColors.overlay60,
                size: iconSize,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: labelSize,
                fontWeight: FontWeight.w800,
                color: isSelected ? accentColor : AppColors.overlay60,
                letterSpacing: 1.0,
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.6),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

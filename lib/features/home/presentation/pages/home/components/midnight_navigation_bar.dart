import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    return Container(
      height: 80,
      margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0C0A09).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.auto_awesome_rounded,
                label: 'Discover',
                isSelected: selectedIndex == 0,
                onTap: () => onItemSelected(0),
              ),
              _NavItem(
                icon: Icons.handshake_rounded,
                label: 'Matches',
                isSelected: selectedIndex == 1,
                onTap: () => onItemSelected(1),
              ),
              _NavItem(
                icon: Icons.favorite_rounded,
                label: 'Likes',
                isSelected: selectedIndex == 2,
                onTap: () => onItemSelected(2),
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                isSelected: selectedIndex == 3,
                onTap: () => onItemSelected(3),
              ),
            ],
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

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFFCA8A04);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSelected
                  ? accentColor.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: isSelected
                  ? accentColor
                  : Colors.white.withValues(alpha: 0.3),
              size: 26,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: isSelected
                  ? accentColor
                  : Colors.white.withValues(alpha: 0.3),
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
    );
  }
}

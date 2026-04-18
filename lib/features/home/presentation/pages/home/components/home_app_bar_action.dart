import 'package:flutter/material.dart';
import 'package:skillswap/core/theme/theme.dart';

class HomeAppBarAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const HomeAppBarAction({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: AppColors.overlay05,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.overlay10, width: 1),
          ),
          child: Icon(icon, color: AppColors.textPrimary, size: 20),
        ),
      ),
    );
  }
}

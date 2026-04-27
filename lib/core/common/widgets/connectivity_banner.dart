import 'package:flutter/material.dart';
import 'package:skillswap/core/layout/responsive.dart';

class ConnectivityBanner extends StatelessWidget {
  final bool isVisible;

  const ConnectivityBanner({
    super.key,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    final h = Responsive.valueFor<double>(
      context,
      compact: 28,
      mobile: 30,
      tablet: 32,
      tabletWide: 34,
      desktop: 36,
    );
    final fontSize = Responsive.valueFor<double>(
      context,
      compact: 11,
      mobile: 12,
      tablet: 13,
      tabletWide: 13,
      desktop: 14,
    );
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: isVisible ? h : 0,
      width: double.infinity,
      color: Colors.redAccent,
      child: isVisible
          ? Center(
              child: Text(
                'No Internet Connection',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

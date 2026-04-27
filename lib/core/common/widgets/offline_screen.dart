import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/core/layout/responsive.dart';
import 'package:skillswap/core/theme/theme.dart';

class OfflineScreen extends StatelessWidget {
  final VoidCallback onRetry;
  final String? message;
  final bool showCachedBadge;

  const OfflineScreen({
    super.key,
    required this.onRetry,
    this.message,
    this.showCachedBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final hPad = Responsive.contentHorizontalPadding(context);
    final vPad = Responsive.valueFor<double>(
      context,
      compact: 16,
      mobile: 20,
      tablet: 22,
      tabletWide: 24,
      desktop: 24,
    );
    final iconSize = Responsive.valueFor<double>(
      context,
      compact: 52,
      mobile: 58,
      tablet: 62,
      tabletWide: 64,
      desktop: 64,
    );
    final titleSize = Responsive.valueFor<double>(
      context,
      compact: 20,
      mobile: 22,
      tablet: 24,
      tabletWide: 24,
      desktop: 26,
    );
    final bodySize = Responsive.valueFor<double>(
      context,
      compact: 14,
      mobile: 15,
      tablet: 16,
      tabletWide: 16,
      desktop: 17,
    );

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showCachedBadge)
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.info.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off_rounded,
                      size: 14,
                      color: AppColors.info,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Showing cached data",
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ),
              ),
            Container(
              padding: EdgeInsets.all(Responsive.valueFor<double>(
                context,
                compact: 24,
                mobile: 28,
                tablet: 30,
                tabletWide: 32,
                desktop: 32,
              )),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                color: AppColors.overlay40,
                size: iconSize,
              ),
            ),
            SizedBox(height: Responsive.valueFor<double>(context, compact: 24, mobile: 28, tablet: 30, tabletWide: 32, desktop: 32)),
            Text(
              "You're offline",
              style: GoogleFonts.dmSans(
                fontSize: titleSize,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                letterSpacing: 1.0,
              ),
            ),
            SizedBox(height: Responsive.valueFor<double>(context, compact: 12, mobile: 14, tablet: 16, tabletWide: 16, desktop: 16)),
            Text(
              message ??
                  "This page needs internet to load latest updates. Check your connection and try again.",
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: bodySize,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            SizedBox(height: Responsive.valueFor<double>(context, compact: 28, mobile: 32, tablet: 36, tabletWide: 40, desktop: 40)),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.overlay10,
                foregroundColor: AppColors.textPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppColors.overlay10),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.valueFor<double>(
                    context,
                    compact: 32,
                    mobile: 40,
                    tablet: 44,
                    tabletWide: 48,
                    desktop: 48,
                  ),
                  vertical: Responsive.valueFor<double>(
                    context,
                    compact: 14,
                    mobile: 16,
                    tablet: 17,
                    tabletWide: 18,
                    desktop: 18,
                  ),
                ),
                elevation: 0,
              ),
              child: Text(
                'Try Again',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w700,
                  fontSize: bodySize,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/core/common/cubits/connectivity/connectivity_cubit.dart';
import 'package:skillswap/core/layout/responsive.dart';
import 'package:skillswap/core/theme/theme.dart';
import 'dart:ui';

class OfflineToast extends StatefulWidget {
  const OfflineToast({super.key});

  @override
  State<OfflineToast> createState() => _OfflineToastState();
}

class _OfflineToastState extends State<OfflineToast> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;
  ConnectivityStatus? _lastStatus;
  bool _showSuccess = false;
  Timer? _successTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _successTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectivityCubit, ConnectivityStatus>(
      listener: (context, state) {
        if (state == ConnectivityStatus.disconnected) {
          _successTimer?.cancel();
          setState(() {
            _showSuccess = false;
          });
          _controller.forward();
        } else if (state == ConnectivityStatus.connected && _lastStatus == ConnectivityStatus.disconnected) {
          setState(() {
            _showSuccess = true;
          });
          _successTimer = Timer(const Duration(seconds: 3), () {
            if (mounted) {
              _controller.reverse().then((_) {
                if (mounted) {
                  setState(() {
                    _showSuccess = false;
                  });
                }
              });
            }
          });
        }
        _lastStatus = state;
      },
      child: SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.paddingOf(context).bottom +
                  Responsive.valueFor<double>(
                    context,
                    compact: 72,
                    mobile: 88,
                    tablet: 96,
                    tabletWide: 24,
                    desktop: 28,
                  ),
            ),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _offsetAnimation,
                child: _buildToast(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToast() {
    final color = _showSuccess ? AppColors.success : AppColors.primary;
    final icon = _showSuccess ? Icons.wifi_rounded : Icons.wifi_off_rounded;
    final title = _showSuccess ? "Back Online" : "No Internet Connection";
    final subtitle = _showSuccess ? "You're connected again." : "Check your connection and try again.";

    final hMargin = Responsive.contentHorizontalPadding(context);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: hMargin),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.valueFor<double>(
                context,
                compact: 12,
                mobile: 14,
                tablet: 16,
                tabletWide: 16,
                desktop: 18,
              ),
              vertical: Responsive.valueFor<double>(
                context,
                compact: 10,
                mobile: 11,
                tablet: 12,
                tabletWide: 12,
                desktop: 12,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(Responsive.valueFor<double>(
                    context,
                    compact: 6,
                    mobile: 7,
                    tablet: 8,
                    tabletWide: 8,
                    desktop: 8,
                  )),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: Responsive.valueFor<double>(
                      context,
                      compact: 18,
                      mobile: 19,
                      tablet: 20,
                      tabletWide: 20,
                      desktop: 22,
                    ),
                  ),
                ),
                SizedBox(width: Responsive.valueFor<double>(context, compact: 10, mobile: 11, tablet: 12, tabletWide: 12, desktop: 12)),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: Responsive.valueFor<double>(
                            context,
                            compact: 12,
                            mobile: 13,
                            tablet: 14,
                            tabletWide: 14,
                            desktop: 15,
                          ),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: Responsive.valueFor<double>(
                            context,
                            compact: 11,
                            mobile: 11,
                            tablet: 12,
                            tabletWide: 12,
                            desktop: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

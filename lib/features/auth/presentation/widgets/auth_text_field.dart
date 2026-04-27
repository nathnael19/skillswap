import 'package:flutter/material.dart';
import 'package:skillswap/core/layout/responsive.dart';
import 'package:skillswap/core/theme/theme.dart';

class AuthTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final bool iconIsPrefix;
  final int maxLines;

  const AuthTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.iconIsPrefix = true,
    this.maxLines = 1,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = AppColors.primary;
    final iconSize = Responsive.valueFor<double>(
      context,
      compact: 18,
      mobile: 19,
      tablet: 20,
      tabletWide: 20,
      desktop: 22,
    );
    final hPad = Responsive.valueFor<double>(
      context,
      compact: 16,
      mobile: 18,
      tablet: 19,
      tabletWide: 20,
      desktop: 20,
    );
    final vPad = Responsive.valueFor<double>(
      context,
      compact: 16,
      mobile: 18,
      tablet: 19,
      tabletWide: 20,
      desktop: 20,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty) ...[
          Text(
            widget.label,
            style: AppTextStyles.labelSmall.copyWith(
              color: _isFocused ? accentColor : AppColors.textSecondary,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isFocused
                  ? accentColor.withValues(alpha: 0.5)
                  : AppColors.borderSubtle,
              width: 1.5,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.1),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.isPassword,
            maxLines: widget.maxLines,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary.withValues(alpha: 0.15),
              ),
              prefixIcon: widget.iconIsPrefix
                  ? Icon(
                      widget.icon,
                      color: _isFocused ? accentColor : AppColors.textMuted,
                      size: iconSize,
                    )
                  : null,
              suffixIcon: widget.iconIsPrefix
                  ? null
                  : Icon(
                      widget.icon,
                      color: _isFocused ? accentColor : AppColors.textMuted,
                      size: iconSize,
                    ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: hPad,
                vertical: vPad,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}

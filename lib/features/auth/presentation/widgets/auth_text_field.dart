import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    const accentColor = Color(0xFFCA8A04);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty) ...[
          Text(
            widget.label,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: _isFocused ? accentColor : Colors.white.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 12),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isFocused 
                  ? accentColor.withValues(alpha: 0.5) 
                  : Colors.white.withValues(alpha: 0.08),
              width: 1.5,
            ),
            boxShadow: _isFocused ? [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.1),
                blurRadius: 15,
                spreadRadius: 2,
              )
            ] : [],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.isPassword,
            maxLines: widget.maxLines,
            style: GoogleFonts.dmSans(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: GoogleFonts.dmSans(color: Colors.white.withValues(alpha: 0.15)),
              prefixIcon: widget.iconIsPrefix
                  ? Icon(widget.icon, 
                      color: _isFocused ? accentColor : Colors.white.withValues(alpha: 0.2), 
                      size: 20)
                  : null,
              suffixIcon: widget.iconIsPrefix
                  ? null
                  : Icon(widget.icon, 
                      color: _isFocused ? accentColor : Colors.white.withValues(alpha: 0.2), 
                      size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
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

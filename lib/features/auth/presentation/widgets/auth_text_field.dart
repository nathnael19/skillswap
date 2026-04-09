import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shared labelled text field for the auth screens (login & register).
/// Includes a label above the field and an icon inside it.
class AuthTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final bool iconIsPrefix;

  const AuthTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.iconIsPrefix = true,
  });

  @override
  Widget build(BuildContext context) {
    const lightGrey = Color(0xFFF1F3F9);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: lightGrey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: isPassword,
            style: GoogleFonts.inter(fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(color: Colors.black26),
              prefixIcon: iconIsPrefix
                  ? Icon(icon, color: Colors.black38, size: 20)
                  : null,
              suffixIcon: iconIsPrefix
                  ? null
                  : Icon(icon, color: Colors.black38, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter this field';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}

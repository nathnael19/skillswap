import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onAddTap;
  final VoidCallback? onSendTap;

  const ChatInputBar({
    super.key,
    required this.controller,
    this.onAddTap,
    this.onSendTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 32, top: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF2F4F7))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline,
              color: Color(0xFF667085),
              size: 30,
            ),
            onPressed: onAddTap,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F7),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Center(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: GoogleFonts.inter(
                      color: const Color(0xFF98A2B3),
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onSendTap,
            child: Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF0B6A7A),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0B6A7A).withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

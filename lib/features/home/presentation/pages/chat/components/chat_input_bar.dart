import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:skillswap/core/theme/theme.dart';

class ChatInputBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback? onAddTap;
  final VoidCallback? onSendTap;
  final void Function(bool isTyping)? onTypingChanged;

  const ChatInputBar({
    super.key,
    required this.controller,
    this.onAddTap,
    this.onSendTap,
    this.onTypingChanged,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  Timer? _typingTimer;
  bool _isTyping = false;

  void _onTextChanged(String text) {
    if (text.isNotEmpty && !_isTyping) {
      _isTyping = true;
      widget.onTypingChanged?.call(true);
    }

    _typingTimer?.cancel();

    if (text.isEmpty) {
      if (_isTyping) {
        _isTyping = false;
        widget.onTypingChanged?.call(false);
      }
      return;
    }

    _typingTimer = Timer(const Duration(seconds: 2), () {
      if (_isTyping) {
        _isTyping = false;
        widget.onTypingChanged?.call(false);
      }
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = AppColors.primary;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 32,
            top: 16,
          ),
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.8),
            border: Border(top: BorderSide(color: AppColors.overlay08)),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.add_circle_outline_rounded,
                  color: AppColors.overlay30,
                  size: 28,
                ),
                onPressed: widget.onAddTap,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(27),
                    border: Border.all(color: AppColors.overlay08),
                  ),
                  child: Center(
                    child: TextField(
                      controller: widget.controller,
                      onChanged: _onTextChanged,
                      style: GoogleFonts.dmSans(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                      ),
                      cursorColor: accentColor,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: GoogleFonts.dmSans(
                          color: AppColors.textPrimary.withValues(alpha: 0.25),
                          fontWeight: FontWeight.w500,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  if (_isTyping) {
                    _isTyping = false;
                    _typingTimer?.cancel();
                    widget.onTypingChanged?.call(false);
                  }
                  widget.onSendTap?.call();
                },
                child: Container(
                  height: 54,
                  width: 54,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    color: AppColors.textPrimary,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

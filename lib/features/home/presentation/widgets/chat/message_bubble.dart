import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final String time;
  final bool isRead;

  const MessageBubble({
    super.key,
    required this.text,
    required this.isMe,
    required this.time,
    this.isRead = false,
  });

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFFCA8A04);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    gradient: isMe ? const LinearGradient(
                      colors: [Color(0xFFCA8A04), Color(0xFFB47B03)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ) : null,
                    color: isMe ? null : Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(24),
                      topRight: const Radius.circular(24),
                      bottomLeft: Radius.circular(isMe ? 24 : 6),
                      bottomRight: Radius.circular(isMe ? 6 : 24),
                    ),
                    border: isMe ? null : Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                    boxShadow: [
                      if (isMe)
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.25),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                    ],
                  ),
                  child: Text(
                    text,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                      color: isMe ? Colors.white : Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isMe) ...[
                  Text(
                    time,
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: accentColor.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    isRead ? Icons.done_all_rounded : Icons.done_rounded,
                    size: 14,
                    color: isRead
                        ? Colors.white // Two rights -> white on gold bubble
                        : Colors.white.withValues(alpha: 0.4), // One right -> dimmed
                  ),
                ] else
                  Text(
                    time,
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final String time;
  final bool isSeen;

  const MessageBubble({
    super.key,
    required this.text,
    required this.isMe,
    required this.time,
    this.isSeen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
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
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isMe ? const Color(0xFF0B6A7A) : const Color(0xFFE4E7EC),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isMe ? 20 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 20),
                    ),
                    boxShadow: [
                      if (isMe)
                        BoxShadow(
                          color: const Color(0xFF0B6A7A).withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Text(
                    text,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      height: 1.5,
                      color: isMe ? Colors.white : const Color(0xFF344054),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isMe) ...[
                Text(
                  time,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF98A2B3),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.done_all,
                  size: 16,
                  color: isSeen
                      ? const Color(0xFF2E90FA)
                      : const Color(0xFF98A2B3),
                ),
              ] else
                Text(
                  time,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF98A2B3),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

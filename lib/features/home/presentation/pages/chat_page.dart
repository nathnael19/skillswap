import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/features/home/presentation/pages/schedule_session_page.dart';
import 'package:skillswap/features/home/presentation/pages/master_profile_page.dart';
import 'package:skillswap/features/home/presentation/widgets/chat/chat_input_bar.dart';
import 'package:skillswap/features/home/presentation/widgets/chat/chat_quick_actions.dart';
import 'package:skillswap/features/home/presentation/widgets/chat/date_separator.dart';
import 'package:skillswap/features/home/presentation/widgets/chat/message_bubble.dart';

class ChatPage extends StatefulWidget {
  final String userName;
  final String userImageUrl;
  final String userTitle;
  final bool isOnline;

  const ChatPage({
    super.key,
    required this.userName,
    required this.userImageUrl,
    required this.userTitle,
    this.isOnline = true,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [
    {
      'text':
          'Hi there! I saw your profile and noticed you\'re looking to learn more about advanced React patterns. I\'d love to help out!',
      'isMe': false,
      'time': '10:24 AM',
    },
    {
      'text': 'Maybe we could swap for some of your UI/UX auditing skills? 🎨',
      'isMe': false,
      'time': '10:24 AM',
    },
    {
      'text':
          'Hey Elena! That sounds like a perfect match. I\'m definitely interested in those React patterns. I\'ve been struggling with compound components lately.',
      'isMe': true,
      'time': '10:28 AM',
      'isSeen': true,
    },
    {
      'text':
          'Compound components are my favorite! I can show you how I built the new design system modules. When are you free for a session?',
      'isMe': false,
      'time': '10:30 AM',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF101828)),
          onPressed: () => Navigator.pop(context),
        ),
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const MasterProfilePage()),
            );
          },
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage(widget.userImageUrl),
                  ),
                  if (widget.isOnline)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        height: 12,
                        width: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFF12B76A), // Success Green
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.userName,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF101828),
                      ),
                    ),
                    Text(
                      '${widget.userTitle.toUpperCase()} • ${widget.isOnline ? 'ONLINE' : 'OFFLINE'}',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF667085),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFF2F4F7),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.calendar_today_outlined,
                size: 20,
                color: Color(0xFF1D2939),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ScheduleSessionPage(),
                  ),
                );
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF1D2939)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const DateSeparator(date: 'TODAY'),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return MessageBubble(
                  text: msg['text'],
                  isMe: msg['isMe'] ?? false,
                  time: msg['time'],
                  isSeen: msg['isSeen'] ?? false,
                );
              },
            ),
          ),
          const ChatQuickActions(),
          ChatInputBar(
            controller: _messageController,
            onSendTap: () {
              // Implementation of sending logic would go here
              _messageController.clear();
            },
          ),
        ],
      ),
    );
  }
}

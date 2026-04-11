import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/features/home/presentation/cubits/chat_cubit.dart';
import 'package:skillswap/features/home/presentation/cubits/chat_state.dart';
import 'package:skillswap/features/home/presentation/pages/schedule_session_page.dart';
import 'package:skillswap/features/home/presentation/pages/master_profile_page.dart';
import 'package:skillswap/features/home/presentation/widgets/chat/chat_input_bar.dart';
import 'package:skillswap/features/home/presentation/widgets/chat/chat_quick_actions.dart';
import 'package:skillswap/features/home/presentation/widgets/chat/date_separator.dart';
import 'package:skillswap/features/home/presentation/widgets/chat/message_bubble.dart';
import 'package:skillswap/init_dependencies.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  final String userName;
  final String userImageUrl;
  final String userTitle;
  final String matchId;
  final bool isOnline;

  const ChatPage({
    super.key,
    required this.userName,
    required this.userImageUrl,
    required this.userTitle,
    required this.matchId,
    this.isOnline = true,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          serviceLocator<ChatCubit>()..loadMessages(widget.matchId),
      child: Scaffold(
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
                  builder: (context) => const MasterProfilePage(),
                ),
              );
            },
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: widget.userImageUrl.startsWith('assets')
                          ? AssetImage(widget.userImageUrl)
                          : NetworkImage(widget.userImageUrl) as ImageProvider,
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
        body: BlocConsumer<ChatCubit, ChatState>(
          listener: (context, state) {
            if (state is ChatMessagesLoaded) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => _scrollToBottom(),
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                Expanded(child: _buildMessageList(state)),
                const ChatQuickActions(),
                ChatInputBar(
                  controller: _messageController,
                  onSendTap: () {
                    final content = _messageController.text;
                    if (content.isNotEmpty) {
                      context.read<ChatCubit>().sendMessage(
                        widget.matchId,
                        content,
                      );
                      _messageController.clear();
                    }
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMessageList(ChatState state) {
    if (state is ChatLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ChatError) {
      return Center(
        child: Text(state.message, style: const TextStyle(color: Colors.red)),
      );
    }

    if (state is ChatMessagesLoaded) {
      if (state.messages.isEmpty) {
        return Center(
          child: Text(
            'No messages yet. Say hi to ${widget.userName}!',
            style: GoogleFonts.inter(color: Colors.grey),
          ),
        );
      }

      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemCount: state.messages.length,
        itemBuilder: (context, index) {
          final msg = state.messages[index];
          final isMe = msg.senderId == _currentUserId;

          return MessageBubble(
            text: msg.content,
            isMe: isMe,
            time: DateFormat('hh:mm a').format(msg.timestamp),
            isSeen: true,
          );
        },
      );
    }

    return const SizedBox.shrink();
  }
}

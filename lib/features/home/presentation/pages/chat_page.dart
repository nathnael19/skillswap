import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/features/home/presentation/cubits/chat_cubit.dart';
import 'package:skillswap/features/home/presentation/cubits/chat_state.dart';
import 'package:skillswap/features/home/presentation/pages/schedule_session_page.dart';
import 'package:skillswap/features/home/presentation/pages/master_profile_page.dart';
import 'package:skillswap/features/home/presentation/widgets/chat/chat_input_bar.dart';
import 'package:skillswap/features/home/presentation/widgets/chat/chat_quick_actions.dart';
import 'package:skillswap/features/home/presentation/widgets/chat/message_bubble.dart';
import 'package:skillswap/init_dependencies.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  final String userName;
  final String userImageUrl;
  final String userTitle;
  final String matchId;
  final String userId;
  final bool isOnline;

  const ChatPage({
    super.key,
    required this.userName,
    required this.userImageUrl,
    required this.userTitle,
    required this.matchId,
    required this.userId,
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
    const primaryBgColor = Color(0xFF0C0A09);
    const accentColor = Color(0xFFCA8A04);
    
    return BlocProvider(
      create: (context) =>
          serviceLocator<ChatCubit>()..loadMessages(widget.matchId),
      child: Scaffold(
        backgroundColor: primaryBgColor,
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: AppBar(
                backgroundColor: primaryBgColor.withValues(alpha: 0.8),
                elevation: 0,
                toolbarHeight: 80,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                title: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MasterProfilePage(userId: widget.userId),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: widget.isOnline ? accentColor : Colors.white.withValues(alpha: 0.1),
                                width: 1.5,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundImage: widget.userImageUrl.startsWith('assets')
                                  ? AssetImage(widget.userImageUrl)
                                  : NetworkImage(widget.userImageUrl) as ImageProvider,
                            ),
                          ),
                          if (widget.isOnline)
                            Positioned(
                              right: 2,
                              bottom: 2,
                              child: Container(
                                height: 10,
                                width: 10,
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: primaryBgColor, width: 2),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.userName,
                              style: GoogleFonts.dmSans(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${widget.userTitle.toUpperCase()} • ${widget.isOnline ? 'ACTIVE NOW' : 'OFFLINE'}',
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: widget.isOnline ? accentColor : Colors.white.withValues(alpha: 0.3),
                                letterSpacing: 0.8,
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
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.calendar_today_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ScheduleSessionPage(matchId: widget.matchId),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
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
                ChatQuickActions(matchId: widget.matchId),
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
      return const Center(child: CircularProgressIndicator(color: Color(0xFFCA8A04)));
    }

    if (state is ChatError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, color: Colors.white24, size: 48),
              const SizedBox(height: 16),
              Text(
                "MESSAGING OFFLINE",
                style: GoogleFonts.dmSans(
                  color: Colors.white30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(color: Colors.white24, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    if (state is ChatMessagesLoaded) {
      if (state.messages.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFFCA8A04), size: 40),
                ),
                const SizedBox(height: 24),
                Text(
                  'Start the Flow',
                  style: GoogleFonts.dmSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'No messages yet. Say hi to ${widget.userName} and manifest your collaboration.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    color: Colors.white.withValues(alpha: 0.3),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () =>
            context.read<ChatCubit>().loadMessages(widget.matchId),
        color: const Color(0xFFCA8A04),
        backgroundColor: const Color(0xFF1C1917),
        child: ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 120, 16, 20),
          itemCount: state.messages.length,
          itemBuilder: (context, index) {
            final msg = state.messages[index];
            final isMe = msg.senderId == _currentUserId;

            return MessageBubble(
              text: msg.content,
              isMe: isMe,
              time: DateFormat('h:mm a').format(msg.timestamp),
              isSeen: true,
            );
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

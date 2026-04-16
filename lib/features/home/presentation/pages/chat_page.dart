import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/features/home/domain/repositories/home_repository.dart';
import 'package:skillswap/features/home/presentation/cubits/chat_cubit.dart';
import 'package:skillswap/features/home/presentation/cubits/chat_state.dart';
import 'package:skillswap/features/home/presentation/cubits/presence_cubit.dart';
import 'package:skillswap/features/home/presentation/pages/live_session_page.dart';
import 'package:skillswap/features/home/presentation/pages/schedule_session_page.dart';
import 'package:skillswap/features/home/presentation/pages/master_profile_page.dart';
import 'package:skillswap/features/home/presentation/widgets/chat/chat_input_bar.dart';
import 'package:skillswap/features/home/presentation/widgets/chat/chat_quick_actions.dart';
import 'package:skillswap/features/home/presentation/widgets/chat/message_bubble.dart';
import 'package:skillswap/init_dependencies.dart';
import 'package:intl/intl.dart';

import 'package:skillswap/features/home/presentation/cubits/profile_cubit.dart';

class ChatPage extends StatefulWidget {
  final String userName;
  final String userImageUrl;
  final String userTitle;
  final String matchId;
  final String userId;
  final String currentUserId;
  final String status;
  final String? payerId;
  final bool isOnline;

  const ChatPage({
    super.key,
    required this.userName,
    required this.userImageUrl,
    required this.userTitle,
    required this.matchId,
    required this.userId,
    required this.currentUserId,
    this.status = 'mutual',
    this.payerId,
    this.isOnline = true,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.status;
  }

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

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              serviceLocator<ChatCubit>()
                ..loadMessages(widget.matchId, widget.userId),
        ),
        BlocProvider(
          create: (context) =>
              serviceLocator<ProfileCubit>()..fetchUserProfile(),
        ),
        BlocProvider(
          create: (context) =>
              PresenceCubit()..watchPeer(widget.userId, widget.matchId),
        ),
      ],
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, profileState) {
          final currentUser = profileState is ProfileLoaded
              ? profileState.user
              : null;

          return Scaffold(
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
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    title: BlocBuilder<PresenceCubit, PresenceState>(
                      builder: (context, presenceState) {
                        final isOnline = presenceState.isOnline;
                        final isTyping = presenceState.isTyping;
                        
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MasterProfilePage(userId: widget.userId),
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
                                        color: isOnline
                                            ? accentColor
                                            : Colors.white.withValues(alpha: 0.1),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: 20,
                                      backgroundImage:
                                          widget.userImageUrl.startsWith('assets')
                                          ? AssetImage(widget.userImageUrl)
                                          : NetworkImage(widget.userImageUrl)
                                                as ImageProvider,
                                    ),
                                  ),
                                  if (isOnline)
                                    Positioned(
                                      right: 2,
                                      bottom: 2,
                                      child: Container(
                                        height: 10,
                                        width: 10,
                                        decoration: BoxDecoration(
                                          color: accentColor,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: primaryBgColor,
                                            width: 2,
                                          ),
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
                                      isTyping 
                                        ? 'typing...' 
                                        : '${widget.userTitle} • ${isOnline ? 'Active now' : 'Offline'}',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: isTyping || isOnline
                                            ? accentColor
                                            : Colors.white.withValues(alpha: 0.3),
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    actions: [
                      Container(
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
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
                                builder: (context) => ScheduleSessionPage(
                                  matchId: widget.matchId,
                                  peerName: widget.userName,
                                  peerImageUrl: widget.userImageUrl,
                                  currentUserId: widget.currentUserId,
                                  peerId: widget.userId,
                                  currentUserName: currentUser?.name,
                                  currentUserImageUrl: currentUser?.imageUrl,
                                ),
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
                if (state is ChatSendError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              builder: (context, state) {
                return Stack(
                  children: [
                    Column(
                      children: [
                        if (_currentStatus == 'pending' &&
                            widget.payerId != null &&
                            widget.currentUserId != widget.payerId)
                          _buildAcceptanceBanner(context),
                        Expanded(child: _buildMessageList(state)),
                        ChatQuickActions(
                          matchId: widget.matchId,
                          peerName: widget.userName,
                          peerImageUrl: widget.userImageUrl,
                          currentUserId: widget.currentUserId,
                          peerId: widget.userId,
                          currentUserName: currentUser?.name,
                          currentUserImageUrl: currentUser?.imageUrl,
                        ),
                        ChatInputBar(
                          controller: _messageController,
                          onTypingChanged: (isTyping) {
                            if (context.mounted) {
                              context.read<PresenceCubit>().setTyping(widget.matchId, isTyping);
                            }
                          },
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
                    ),
                    if (state is ChatIncomingCall)
                      _buildIncomingCallOverlay(
                        context,
                        state,
                        currentUser?.name,
                        currentUser?.imageUrl,
                      ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildIncomingCallOverlay(
    BuildContext context,
    ChatIncomingCall state,
    String? currentUserName,
    String? currentUserImageUrl,
  ) {
    const accentColor = Color(0xFFCA8A04);

    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.8),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1917),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: accentColor.withValues(alpha: 0.3),
                            width: 4,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 46,
                          backgroundImage:
                              state.peerImageUrl.startsWith('assets')
                              ? AssetImage(state.peerImageUrl)
                              : NetworkImage(state.peerImageUrl)
                                    as ImageProvider,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Session Request',
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: accentColor,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.peerName,
                    style: GoogleFonts.dmSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            context.read<ChatCubit>().rejectCall(
                              targetId: state.peerId,
                            );
                          },
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                'Decline',
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white54,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // Navigate immediately. The LiveSessionPage will send 
                            // 'call_accepted' once the camera and WebRTC are initialized.
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LiveSessionPage(
                                  agenda: const ['Spontaneous Synergy'],
                                  peerName: widget.userName,
                                  peerImageUrl: widget.userImageUrl,
                                  currentUserId: widget.currentUserId,
                                  peerId: widget.userId,
                                  currentUserName: currentUserName,
                                  currentUserImageUrl: currentUserImageUrl,
                                  isCaller: false,
                                ),
                              ),
                            );
                            // Reset cubit state
                            context.read<ChatCubit>().loadMessages(
                              widget.matchId,
                              widget.userId,
                            );
                          },
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [accentColor, Color(0xFFB47B03)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                'Accept',
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageList(ChatState state) {
    if (state is ChatLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFCA8A04)),
      );
    }

    if (state is ChatError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                color: Colors.white24,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                "Chat Offline",
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
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Color(0xFFCA8A04),
                    size: 40,
                  ),
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
                  'No messages yet. Send a message to start the conversation!',
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
        onRefresh: () => context.read<ChatCubit>().loadMessages(
          widget.matchId,
          widget.userId,
        ),
        color: const Color(0xFFCA8A04),
        backgroundColor: const Color(0xFF1C1917),
        child: ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 120, 16, 20),
          itemCount: state.messages.length,
          itemBuilder: (context, index) {
            final msg = state.messages[index];
            final isMe = msg.senderId == widget.currentUserId;

            return MessageBubble(
              text: msg.content,
              isMe: isMe,
              time: DateFormat('h:mm a').format(msg.timestamp),
              isRead: msg.isRead,
            );
          },
        ),
      );
    }

    // When there's an incoming call or a send error, the cubit emits a new state
    // but we still want the messages to show behind the overlay. Since these states
    // don't carry message data, we fall through to an empty list here — the overlay
    // is rendered on top by the Stack in the builder above.
    return const SizedBox.shrink();
  }

  Widget _buildAcceptanceBanner(BuildContext context) {
    const accentColor = Color(0xFFCA8A04);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 100, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1917).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Direct Connection",
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${widget.userName} reached out via paid message.",
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () async {
              final result = await serviceLocator<HomeRepository>().acceptMatch(
                widget.matchId,
              );
              result.fold(
                (failure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(failure.message),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                },
                (_) {
                  setState(() {
                    _currentStatus = 'mutual';
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Connection accepted!",
                      ),
                      backgroundColor: accentColor,
                    ),
                  );
                },
              );
            },
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [accentColor, Color(0xFFB47B03)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  "Accept Connection",
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

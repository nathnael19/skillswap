import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/features/home/domain/repositories/home_repository.dart';
import 'package:skillswap/features/home/presentation/cubits/chat_cubit.dart';
import 'package:skillswap/features/home/presentation/cubits/chat_state.dart';
import 'package:skillswap/features/home/presentation/cubits/presence_cubit.dart';
import 'package:skillswap/features/home/presentation/cubits/profile_cubit.dart';
import 'package:skillswap/init_dependencies.dart';
import 'components/chat_app_bar.dart';
import 'components/chat_input_bar.dart';
import 'components/chat_quick_actions.dart';
import 'components/connection_banner.dart';
import 'components/incoming_call_overlay.dart';
import 'components/chat_message_list.dart';
import 'package:skillswap/core/theme/theme.dart';

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
    const primaryBgColor = AppColors.background;
    const accentColor = AppColors.primary;

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
            appBar: ChatAppBar(
              userName: widget.userName,
              userImageUrl: widget.userImageUrl,
              userTitle: widget.userTitle,
              matchId: widget.matchId,
              userId: widget.userId,
              currentUserId: widget.currentUserId,
              currentUser: currentUser,
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
                          ConnectionBanner(
                            userName: widget.userName,
                            onAccept: () async {
                              final result =
                                  await serviceLocator<HomeRepository>()
                                      .acceptMatch(widget.matchId);
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
                                      content: Text("Connection accepted!"),
                                      backgroundColor: accentColor,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        Expanded(
                          child: ChatMessageList(
                            state: state,
                            scrollController: _scrollController,
                            currentUserId: widget.currentUserId,
                            matchId: widget.matchId,
                            userId: widget.userId,
                            onRefresh: () async {
                              context.read<ChatCubit>().loadMessages(
                                widget.matchId,
                                widget.userId,
                              );
                            },
                          ),
                        ),
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
                              context.read<PresenceCubit>().setTyping(
                                widget.matchId,
                                isTyping,
                              );
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
                      IncomingCallOverlay(
                        state: state,
                        currentUserName: currentUser?.name,
                        currentUserImageUrl: currentUser?.imageUrl,
                        matchId: widget.matchId,
                        userId: widget.userId,
                        currentUserId: widget.currentUserId,
                        userName: widget.userName,
                        userImageUrl: widget.userImageUrl,
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
}

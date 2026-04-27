import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:skillswap/core/layout/responsive.dart';
import 'package:skillswap/core/theme/theme.dart';
import 'package:skillswap/features/live_sessions/presentation/cubit/live_session_cubit.dart';
import 'package:skillswap/features/live_sessions/presentation/cubit/live_session_state.dart';
import 'package:skillswap/init_dependencies.dart';

class LiveSessionPage extends StatefulWidget {
  final List<String> agenda;
  final String? sessionId;
  final String peerName; // kept for backward compatibility
  final String peerImageUrl; // kept for backward compatibility
  final String currentUserId; // kept for backward compatibility
  final String peerId; // kept for backward compatibility
  final String? currentUserName;
  final String? currentUserImageUrl;
  final bool isCaller; // kept for backward compatibility
  final String? sessionTitle;

  const LiveSessionPage({
    super.key,
    required this.agenda,
    this.sessionId,
    required this.peerName,
    required this.peerImageUrl,
    required this.currentUserId,
    required this.peerId,
    this.currentUserName,
    this.currentUserImageUrl,
    this.isCaller = false,
    this.sessionTitle,
  });

  @override
  State<LiveSessionPage> createState() => _LiveSessionPageState();
}

class _LiveSessionPageState extends State<LiveSessionPage> with WidgetsBindingObserver {
  final TextEditingController _chatController = TextEditingController();
  late final LiveSessionCubit _cubit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cubit = serviceLocator<LiveSessionCubit>();
    if (widget.sessionId != null) {
      unawaited(_cubit.watchSession(widget.sessionId!));
      unawaited(_cubit.watchChat(widget.sessionId!));
      unawaited(_cubit.watchParticipantSignals(widget.sessionId!));
      unawaited(
        _cubit.joinSession(
          sessionId: widget.sessionId!,
          userName: widget.currentUserName ?? 'SkillSwap User',
        ),
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (widget.sessionId == null) return;
    if (state == AppLifecycleState.resumed) {
      unawaited(_cubit.onAppResumed(widget.sessionId!));
    } else if (state == AppLifecycleState.paused) {
      unawaited(_cubit.onAppBackgrounded());
    }
  }

  Future<bool?> _handleEndCallRequest() async {
    if (widget.sessionId != null) {
      await _cubit.leaveSession(widget.sessionId!);
    }
    if (!mounted) return false;
    Navigator.pop(context);
    return true;
  }

  @override
  void dispose() {
    _chatController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryBgColor = AppColors.background;

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: primaryBgColor,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: BlocBuilder<LiveSessionCubit, LiveSessionState>(
            builder: (context, state) {
              final title = widget.sessionTitle ?? state.session?.title ?? 'Live Session';
              return Text(title);
            },
          ),
          actions: [
            BlocBuilder<LiveSessionCubit, LiveSessionState>(
              builder: (context, state) {
                if (!state.isHost || widget.sessionId == null) {
                  return const SizedBox.shrink();
                }
                return IconButton(
                  icon: const Icon(Icons.stop_circle_outlined),
                  onPressed: () => _cubit.endSession(widget.sessionId!),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<LiveSessionCubit, LiveSessionState>(
          builder: (context, state) {
            if (widget.sessionId == null) {
              return const Center(child: Text('Missing session id.'));
            }
            final twoPane = Responsive.isTwoPane(context);
            return Column(
              children: [
                if (state.loading) const LinearProgressIndicator(minHeight: 2),
                if (state.error != null)
                  Container(
                    width: double.infinity,
                    color: AppColors.error.withValues(alpha: 0.2),
                    padding: EdgeInsets.all(
                      Responsive.valueFor<double>(
                        context,
                        compact: 6,
                        mobile: 8,
                        tablet: 10,
                        tabletWide: 10,
                        desktop: 10,
                      ),
                    ),
                    child: Text(state.error!, textAlign: TextAlign.center),
                  ),
                if (state.reconnecting)
                  Container(
                    width: double.infinity,
                    color: AppColors.warning,
                    padding: EdgeInsets.all(
                      Responsive.valueFor<double>(
                        context,
                        compact: 6,
                        mobile: 8,
                        tablet: 10,
                        tabletWide: 10,
                        desktop: 10,
                      ),
                    ),
                    child: const Text('Reconnecting...', textAlign: TextAlign.center),
                  ),
                Expanded(
                  child: twoPane
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: _buildMainStage(context, state),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: _buildParticipants(context, state),
                                  ),
                                  if (state.isHost && widget.sessionId != null)
                                    _buildHostRequestPanel(context, state),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: Responsive.valueFor<double>(
                                context,
                                compact: 8,
                                mobile: 10,
                                tablet: 12,
                                tabletWide: 14,
                                desktop: 16,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: _buildChat(context, state),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            Expanded(
                              flex: 3,
                              child: _buildMainStage(context, state),
                            ),
                            Expanded(
                              child: _buildParticipants(context, state),
                            ),
                            if (state.isHost && widget.sessionId != null)
                              _buildHostRequestPanel(context, state),
                            Expanded(
                              flex: 2,
                              child: _buildChat(context, state),
                            ),
                          ],
                        ),
                ),
                _buildControls(context, state),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMainStage(BuildContext context, LiveSessionState state) {
    final edge = Responsive.valueFor<double>(
      context,
      compact: 8,
      mobile: 10,
      tablet: 12,
      tabletWide: 12,
      desktop: 14,
    );
    if (state.peers.isEmpty) {
      return Container(
        margin: EdgeInsets.all(edge),
        decoration: BoxDecoration(
          color: AppColors.overlay10,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'Waiting for participants...',
            style: TextStyle(color: AppColors.textPrimary),
          ),
        ),
      );
    }

    final hostPeer = state.peers.firstWhere(
      (peer) => state.session?.hostId == peer.customerUserId || state.session?.hostId == peer.peerId,
      orElse: () => state.peers.first,
    );
    final hostTrack = state.videoTracksByPeerId[hostPeer.peerId];
    return Container(
      margin: EdgeInsets.all(edge),
      decoration: BoxDecoration(
        color: AppColors.overlay10,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: hostTrack == null
            ? Text(
                hostPeer.name.isEmpty ? 'Waiting for host video...' : hostPeer.name,
                style: const TextStyle(color: AppColors.textPrimary),
              )
            : HMSVideoView(
                track: hostTrack as HMSVideoTrack,
              ),
      ),
    );
  }

  Widget _buildParticipants(BuildContext context, LiveSessionState state) {
    final activeSpeakerIds = state.speakers.map((s) => s.peer.peerId).toSet();
    final sortedPeers = [...state.peers]
      ..sort((a, b) {
        final aActive = activeSpeakerIds.contains(a.peerId);
        final bActive = activeSpeakerIds.contains(b.peerId);
        if (aActive == bActive) return 0;
        return aActive ? -1 : 1;
      });
    final visiblePeers = sortedPeers.take(8).toList();

    final tileW = Responsive.valueFor<double>(
      context,
      compact: 108,
      mobile: 120,
      tablet: 132,
      tabletWide: 140,
      desktop: 148,
    );
    final hGap = Responsive.valueFor<double>(
      context,
      compact: 4,
      mobile: 6,
      tablet: 6,
      tabletWide: 8,
      desktop: 8,
    );
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: visiblePeers.length,
      itemBuilder: (context, index) {
        final peer = visiblePeers[index];
        return Container(
          width: tileW,
          margin: EdgeInsets.symmetric(horizontal: hGap, vertical: 8),
          padding: EdgeInsets.all(
            Responsive.valueFor<double>(
              context,
              compact: 8,
              mobile: 9,
              tablet: 10,
              tabletWide: 10,
              desktop: 10,
            ),
          ),
          decoration: BoxDecoration(
            color: AppColors.overlay05,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(child: Icon(Icons.person)),
              const SizedBox(height: 8),
              Text(
                peer.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (state.isHost && !peer.isLocal)
                IconButton(
                  onPressed: () => _cubit.setPeerMuted(peer, mute: true),
                  icon: const Icon(Icons.volume_off, size: 18),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHostRequestPanel(BuildContext context, LiveSessionState state) {
    final pending = state.participantSignals
        .where((signal) => signal.requestToSpeak)
        .toList();
    if (pending.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: AppColors.overlay05,
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.contentHorizontalPadding(context)
            .clamp(8.0, 20.0)
            .toDouble(),
        vertical: Responsive.valueFor<double>(
          context,
          compact: 6,
          mobile: 8,
          tablet: 8,
          tabletWide: 8,
          desktop: 8,
        ),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: pending.map((request) {
          return ActionChip(
            label: Text('Approve ${request.uid.substring(0, 6)}'),
            onPressed: () => _cubit.approveSpeakerRequest(
              sessionId: widget.sessionId!,
              participantId: request.uid,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChat(BuildContext context, LiveSessionState state) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: state.chatMessages.length,
            itemBuilder: (context, index) {
              final item = state.chatMessages[index];
              return ListTile(
                dense: true,
                title: Text(item.text),
                subtitle: Text(item.senderId),
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            Responsive.contentHorizontalPadding(context)
                .clamp(8.0, 16.0)
                .toDouble(),
            8,
            Responsive.contentHorizontalPadding(context)
                .clamp(8.0, 16.0)
                .toDouble(),
            8 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: widget.sessionId == null
                    ? null
                    : () {
                        _cubit.sendChat(widget.sessionId!, _chatController.text);
                        _chatController.clear();
                      },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControls(BuildContext context, LiveSessionState state) {
    final h = Responsive.contentHorizontalPadding(context)
        .clamp(10.0, 20.0)
        .toDouble();
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(h, 6, h, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton.filled(
              onPressed: _cubit.toggleMic,
              icon: Icon(state.isMicMuted ? Icons.mic_off : Icons.mic),
            ),
            IconButton.filled(
              onPressed: _cubit.toggleVideo,
              icon: Icon(state.isCameraMuted ? Icons.videocam_off : Icons.videocam),
            ),
            if (!state.isHost)
              IconButton.filled(
                onPressed: widget.sessionId == null
                    ? null
                    : () => _cubit.requestToSpeak(widget.sessionId!),
                icon: const Icon(Icons.pan_tool_alt),
              ),
            IconButton.filled(
              style: IconButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: _handleEndCallRequest,
              icon: const Icon(Icons.call_end),
            ),
          ],
        ),
      ),
    );
  }
}

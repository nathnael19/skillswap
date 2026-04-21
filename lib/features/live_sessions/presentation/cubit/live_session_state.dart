import 'package:equatable/equatable.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:skillswap/features/live_sessions/data/models/live_session_model.dart';
import 'package:skillswap/features/live_sessions/data/services/live_session_firestore_service.dart';
import 'package:skillswap/features/live_sessions/data/services/live_session_service.dart';

class LiveSessionState extends Equatable {
  final bool loading;
  final bool joined;
  final bool reconnecting;
  final String? error;
  final LiveSession? session;
  final SessionRole role;
  final List<HMSPeer> peers;
  final List<HMSSpeaker> speakers;
  final Map<String, HMSTrack> videoTracksByPeerId;
  final List<SessionChatMessage> chatMessages;
  final List<ParticipantSignal> participantSignals;
  final bool isMicMuted;
  final bool isCameraMuted;

  const LiveSessionState({
    this.loading = false,
    this.joined = false,
    this.reconnecting = false,
    this.error,
    this.session,
    this.role = SessionRole.audience,
    this.peers = const [],
    this.speakers = const [],
    this.videoTracksByPeerId = const {},
    this.chatMessages = const [],
    this.participantSignals = const [],
    this.isMicMuted = true,
    this.isCameraMuted = true,
  });

  bool get isHost => role == SessionRole.host;

  LiveSessionState copyWith({
    bool? loading,
    bool? joined,
    bool? reconnecting,
    String? error,
    LiveSession? session,
    SessionRole? role,
    List<HMSPeer>? peers,
    List<HMSSpeaker>? speakers,
    Map<String, HMSTrack>? videoTracksByPeerId,
    List<SessionChatMessage>? chatMessages,
    List<ParticipantSignal>? participantSignals,
    bool? isMicMuted,
    bool? isCameraMuted,
  }) {
    return LiveSessionState(
      loading: loading ?? this.loading,
      joined: joined ?? this.joined,
      reconnecting: reconnecting ?? this.reconnecting,
      error: error,
      session: session ?? this.session,
      role: role ?? this.role,
      peers: peers ?? this.peers,
      speakers: speakers ?? this.speakers,
      videoTracksByPeerId: videoTracksByPeerId ?? this.videoTracksByPeerId,
      chatMessages: chatMessages ?? this.chatMessages,
      participantSignals: participantSignals ?? this.participantSignals,
      isMicMuted: isMicMuted ?? this.isMicMuted,
      isCameraMuted: isCameraMuted ?? this.isCameraMuted,
    );
  }

  @override
  List<Object?> get props => [
        loading,
        joined,
        reconnecting,
        error,
        session,
        role,
        peers,
        speakers,
        videoTracksByPeerId,
        chatMessages,
        participantSignals,
        isMicMuted,
        isCameraMuted,
      ];
}

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/live_sessions/data/services/live_session_backend_service.dart';
import 'package:skillswap/features/live_sessions/data/services/live_session_firestore_service.dart';
import 'package:skillswap/features/live_sessions/data/services/live_session_service.dart';
import 'package:skillswap/features/live_sessions/presentation/cubit/live_session_state.dart';

class LiveSessionCubit extends Cubit<LiveSessionState> {
  final LiveSessionService _liveService;
  final LiveSessionBackendService _backendService;
  final LiveSessionFirestoreService _firestoreService;

  StreamSubscription? _sessionSub;
  StreamSubscription? _chatSub;
  StreamSubscription? _participantSignalSub;

  LiveSessionCubit({
    required LiveSessionService liveService,
    required LiveSessionBackendService backendService,
    required LiveSessionFirestoreService firestoreService,
  })  : _liveService = liveService,
        _backendService = backendService,
        _firestoreService = firestoreService,
        super(const LiveSessionState()) {
    _bindHmsCallbacks();
  }

  void _bindHmsCallbacks() {
    _liveService.onJoinRoom = (_) {
      emit(state.copyWith(joined: true, reconnecting: false, error: null));
    };
    _liveService.onPeerChanged = (peer, update) {
      emit(state.copyWith(peers: _liveService.peers));
    };
    _liveService.onTrackAdded = (peer, track) {
      if (track is HMSVideoTrack) {
        final next = Map<String, HMSTrack>.from(state.videoTracksByPeerId)
          ..[peer.peerId] = track;
        emit(state.copyWith(videoTracksByPeerId: next));
      }
    };
    _liveService.onTrackRemoved = (peer, _) {
      final next = Map<String, HMSTrack>.from(state.videoTracksByPeerId)
        ..remove(peer.peerId);
      emit(state.copyWith(videoTracksByPeerId: next));
    };
    _liveService.onSpeakerChanged = (speakers) {
      emit(state.copyWith(speakers: speakers));
    };
    _liveService.onReconnectingState = () {
      emit(state.copyWith(reconnecting: true));
    };
    _liveService.onReconnectedState = () {
      emit(state.copyWith(reconnecting: false));
    };
    _liveService.onError = (e) {
      emit(state.copyWith(loading: false, error: e.message));
    };
  }

  Future<void> watchSession(String sessionId) async {
    await _sessionSub?.cancel();
    _sessionSub = _firestoreService.watchSessionById(sessionId).listen((session) {
      emit(state.copyWith(session: session));
    });
  }

  Future<void> watchChat(String sessionId) async {
    await _chatSub?.cancel();
    _chatSub = _firestoreService.watchChat(sessionId).listen((messages) {
      emit(state.copyWith(chatMessages: messages));
    });
  }

  Future<void> watchParticipantSignals(String sessionId) async {
    await _participantSignalSub?.cancel();
    _participantSignalSub =
        _firestoreService.watchParticipantSignals(sessionId).listen((signals) {
      emit(state.copyWith(participantSignals: signals));
    });
  }

  Future<void> joinSession({
    required String sessionId,
    required String userName,
  }) async {
    try {
      emit(state.copyWith(loading: true, error: null));
      final token = await _backendService.getJoinToken(sessionId);
      await _liveService.init();
      await _liveService.join(
        token: token.token,
        userName: userName,
        role: token.role,
      );
      await _firestoreService.setParticipantJoined(sessionId);
      emit(
        state.copyWith(
          loading: false,
          role: token.role,
          isMicMuted: token.role == SessionRole.audience,
          isCameraMuted: token.role == SessionRole.audience,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: _readableError(e)));
    }
  }

  Future<void> leaveSession(String sessionId) async {
    await _liveService.leave();
    await _backendService.leaveSession(sessionId);
    await _firestoreService.setParticipantLeft(sessionId);
    emit(state.copyWith(joined: false));
  }

  Future<String?> createSession({
    required String title,
    required DateTime scheduledAt,
    int maxParticipants = 20,
    String type = 'group',
    String? participantId,
    List<String>? topics,
  }) async {
    try {
      emit(state.copyWith(loading: true, error: null));
      final sessionId = await _backendService.createSession(
        title: title,
        scheduledAt: scheduledAt,
        maxParticipants: maxParticipants,
        type: type,
        participantId: participantId,
        topics: topics,
      );
      emit(state.copyWith(loading: false));
      return sessionId;
    } catch (e) {
      emit(state.copyWith(loading: false, error: _readableError(e)));
      return null;
    }
  }

  Future<void> startSession(String sessionId) async {
    await _backendService.startSession(sessionId);
  }

  Future<void> endSession(String sessionId) async {
    await _backendService.endSession(sessionId);
  }

  Future<void> toggleMic() async {
    await _liveService.toggleMic();
    emit(state.copyWith(isMicMuted: !state.isMicMuted));
  }

  Future<void> toggleVideo() async {
    await _liveService.toggleVideo();
    emit(state.copyWith(isCameraMuted: !state.isCameraMuted));
  }

  Future<void> raiseHand(String sessionId) async {
    await _firestoreService.setRaiseHand(sessionId, raised: true);
  }

  Future<void> requestToSpeak(String sessionId) => raiseHand(sessionId);

  Future<void> setPeerMuted(HMSPeer peer, {required bool mute}) =>
      _liveService.mutePeerAudio(peer, mute: mute);

  Future<void> approveSpeakerRequest({
    required String sessionId,
    required String participantId,
  }) async {
    await _firestoreService.approveSpeakerRequest(sessionId, participantId);
  }

  Future<void> sendChat(String sessionId, String text) =>
      _firestoreService.sendChat(sessionId, text);

  Future<void> onAppBackgrounded() async {
    if (!state.isCameraMuted) {
      await toggleVideo();
    }
  }

  Future<void> onAppResumed(String sessionId) async {
    await watchSession(sessionId);
  }

  String _readableError(Object error) {
    final raw = error is Failure ? error.message : error.toString();
    final normalized = raw.toLowerCase();
    if (normalized.contains('already stated')) {
      return 'This session is already started.';
    }
    if (normalized.contains('already started')) {
      return 'This session is already started.';
    }
    return raw;
  }

  @override
  Future<void> close() async {
    await _sessionSub?.cancel();
    await _chatSub?.cancel();
    await _participantSignalSub?.cancel();
    return super.close();
  }
}

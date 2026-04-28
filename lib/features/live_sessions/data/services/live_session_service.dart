import 'package:hmssdk_flutter/hmssdk_flutter.dart';

enum SessionRole { host, audience }

class LiveSessionSnapshot {
  final HMSRoom? room;
  final HMSPeer? localPeer;
  final List<HMSPeer> peers;
  final bool isReconnecting;
  final String? error;

  const LiveSessionSnapshot({
    this.room,
    this.localPeer,
    this.peers = const [],
    this.isReconnecting = false,
    this.error,
  });

  LiveSessionSnapshot copyWith({
    HMSRoom? room,
    HMSPeer? localPeer,
    List<HMSPeer>? peers,
    bool? isReconnecting,
    String? error,
  }) {
    return LiveSessionSnapshot(
      room: room ?? this.room,
      localPeer: localPeer ?? this.localPeer,
      peers: peers ?? this.peers,
      isReconnecting: isReconnecting ?? this.isReconnecting,
      error: error,
    );
  }
}

class LiveSessionService implements HMSUpdateListener {
  HMSSDK? _hmsSDK;
  SessionRole _role = SessionRole.audience;
  HMSRoom? _room;
  HMSPeer? _localPeer;
  final List<HMSPeer> _peers = [];
  bool _isMicMuted = true;
  bool _isCameraMuted = true;

  void Function(HMSRoom room)? onJoinRoom;
  void Function(HMSRoom room, HMSRoomUpdate update)? onRoomChanged;
  void Function(HMSPeer peer, HMSTrack track)? onTrackAdded;
  void Function(HMSPeer peer, HMSTrack track)? onTrackRemoved;
  void Function(HMSPeer peer, HMSPeerUpdate update)? onPeerChanged;
  void Function(List<HMSSpeaker> speakers)? onSpeakerChanged;
  void Function(HMSException exception)? onError;
  void Function()? onReconnectingState;
  void Function()? onReconnectedState;

  SessionRole get currentRole => _role;
  HMSPeer? get localPeer => _localPeer;
  HMSRoom? get room => _room;
  List<HMSPeer> get peers => List.unmodifiable(_peers);
  bool get isHost => _role == SessionRole.host;
  bool get isMicMuted => _isMicMuted;
  bool get isCameraMuted => _isCameraMuted;

  Future<void> init() async {
    if (_hmsSDK != null) return;
    _hmsSDK = HMSSDK();
    await _hmsSDK?.build();
    _hmsSDK?.addUpdateListener(listener: this);
  }

  Future<void> join({
    required String token,
    required String userName,
    required SessionRole role,
    bool muteOnJoinForAudience = true,
  }) async {
    _role = role;
    _isMicMuted = role == SessionRole.audience;
    _isCameraMuted = role == SessionRole.audience;
    HMSConfig config = HMSConfig(
      authToken: token,
      userName: userName,
    );
    await _hmsSDK?.join(config: config);
    if (_role == SessionRole.audience && muteOnJoinForAudience) {
      // Audience always joins muted by default for classes/workshops.
      await _hmsSDK?.toggleMicMuteState();
      await _hmsSDK?.toggleCameraMuteState();
    }
  }

  Future<void> leave() async {
    await _hmsSDK?.leave();
  }

  Future<bool> toggleMic() async {
    await _hmsSDK?.toggleMicMuteState();
    _isMicMuted = !_isMicMuted;
    return _isMicMuted;
  }

  Future<bool> toggleVideo() async {
    await _hmsSDK?.toggleCameraMuteState();
    _isCameraMuted = !_isCameraMuted;
    return _isCameraMuted;
  }

  Future<void> switchCamera() async {
    await _hmsSDK?.switchCamera();
  }

  Future<void> raiseHand() async {
    await _hmsSDK?.changeMetadata(metadata: '{"isHandRaised": true}');
  }

  Future<void> lowerHand() async {
    await _hmsSDK?.changeMetadata(metadata: '{"isHandRaised": false}');
  }

  Future<void> requestToSpeak() async {
    await _hmsSDK?.changeMetadata(metadata: '{"requestToSpeak": true}');
  }

  Future<void> mutePeerAudio(HMSPeer peer, {required bool mute}) async {
    final track = peer.audioTrack;
    if (track == null) return;
    await _hmsSDK?.changeTrackState(forRemoteTrack: track, mute: mute);
  }

  bool canModerate() => isHost;

  @override
  void onJoin({required HMSRoom room}) {
    _room = room;
    _hmsSDK?.getLocalPeer().then((peer) {
      _localPeer = peer;
    });
    _peers
      ..clear()
      ..addAll(room.peers ?? const []);
    onJoinRoom?.call(room);
  }

  @override
  void onPeerUpdate({required HMSPeer peer, required HMSPeerUpdate update}) {
    if (update == HMSPeerUpdate.peerJoined && !_peers.any((p) => p.peerId == peer.peerId)) {
      _peers.add(peer);
    }
    if (update == HMSPeerUpdate.peerLeft) {
      _peers.removeWhere((p) => p.peerId == peer.peerId);
    }
    onPeerChanged?.call(peer, update);
  }

  @override
  void onTrackUpdate({
    required HMSTrack track,
    required HMSTrackUpdate trackUpdate,
    required HMSPeer peer,
  }) {
    if (trackUpdate == HMSTrackUpdate.trackAdded) {
      onTrackAdded?.call(peer, track);
    } else if (trackUpdate == HMSTrackUpdate.trackRemoved) {
      onTrackRemoved?.call(peer, track);
    }
  }

  @override
  void onHMSError({required HMSException error}) {
    onError?.call(error);
  }

  @override
  void onRoomUpdate({required HMSRoom room, required HMSRoomUpdate update}) {
    _room = room;
    onRoomChanged?.call(room, update);
  }

  @override
  void onMessage({required HMSMessage message}) {}

  @override
  void onUpdateSpeakers({required List<HMSSpeaker> updateSpeakers}) {
    onSpeakerChanged?.call(updateSpeakers);
  }

  @override
  void onReconnecting() {
    onReconnectingState?.call();
  }

  @override
  void onReconnected() {
    onReconnectedState?.call();
  }

  @override
  void onChangeTrackStateRequest(
      {required HMSTrackChangeRequest hmsTrackChangeRequest}) {}

  @override
  void onRemovedFromRoom(
      {required HMSPeerRemovedFromPeer hmsPeerRemovedFromPeer}) {}

  @override
  void onRoleChangeRequest({required HMSRoleChangeRequest roleChangeRequest}) {}

  @override
  void onAudioDeviceChanged(
      {HMSAudioDevice? currentAudioDevice,
      List<HMSAudioDevice>? availableAudioDevice}) {}

  @override
  void onSessionStoreAvailable({HMSSessionStore? hmsSessionStore}) {}

  @override
  void onPeerListUpdate(
      {required List<HMSPeer> addedPeers, required List<HMSPeer> removedPeers}) {
    for (final peer in addedPeers) {
      if (!_peers.any((p) => p.peerId == peer.peerId)) {
        _peers.add(peer);
      }
    }
    for (final peer in removedPeers) {
      _peers.removeWhere((p) => p.peerId == peer.peerId);
    }
  }
}

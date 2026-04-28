import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skillswap/features/live_sessions/data/models/live_session_model.dart';

class SessionChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime createdAt;

  const SessionChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.createdAt,
  });
}

class ParticipantSignal {
  final String uid;
  final bool handRaised;
  final bool requestToSpeak;

  const ParticipantSignal({
    required this.uid,
    this.handRaised = false,
    this.requestToSpeak = false,
  });
}

class LiveSessionFirestoreService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  LiveSessionFirestoreService(this._firestore, this._auth);

  CollectionReference<Map<String, dynamic>> get _sessions =>
      _firestore.collection('sessions');

  String get _uid => _auth.currentUser!.uid;
  String? get currentUserId => _auth.currentUser?.uid;

  Stream<List<LiveSession>> watchSessions() {
    final uid = currentUserId;
    return _sessions
        .snapshots()
        .map((event) {
          final sessions = event.docs.map(LiveSession.fromFirestore).where((session) {
            final isStatusOk = session.status == 'scheduled' || session.status == 'live';
            if (!isStatusOk) return false;

            if (session.type == 'one-on-one') {
              if (uid == null) return false;
              return session.allowedParticipants.contains(uid);
            }
            return true;
          }).toList();
          sessions.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
          return sessions;
        });
  }

  Stream<List<LiveSession>> watchOneOnOneSessions(String userId1, String userId2) {
    return _sessions
        .where('type', isEqualTo: 'one-on-one')
        .where('allowed_participants', arrayContains: userId1)
        .snapshots()
        .map((event) {
      return event.docs
          .map(LiveSession.fromFirestore)
          .where((session) =>
              session.allowedParticipants.contains(userId2))
          .where((session) =>
              session.status == 'scheduled' || session.status == 'live')
          .toList();
    });
  }

  Stream<LiveSession> watchSessionById(String sessionId) {
    return _sessions
        .doc(sessionId)
        .snapshots()
        .where((doc) => doc.exists)
        .map(LiveSession.fromFirestore);
  }

  Future<void> setParticipantJoined(String sessionId) async {
    await _firestore.runTransaction((txn) async {
      final sessionRef = _sessions.doc(sessionId);
      final snap = await txn.get(sessionRef);
      if (!snap.exists) {
        throw StateError('Session not found');
      }
      final data = snap.data()!;
      final participants = List<String>.from(data['participants'] ?? const []);
      final maxParticipants = (data['maxParticipants'] as num?)?.toInt() ?? 20;
      if (!participants.contains(_uid) && participants.length >= maxParticipants) {
        throw StateError('Session is full');
      }
      txn.update(sessionRef, {
        'participants': FieldValue.arrayUnion([_uid]),
      });
    });
  }

  Future<void> setParticipantLeft(String sessionId) async {
    await _sessions.doc(sessionId).update({
      'participants': FieldValue.arrayRemove([_uid]),
    });
  }

  Stream<List<SessionChatMessage>> watchChat(String sessionId) {
    return _sessions
        .doc(sessionId)
        .collection('chat')
        .orderBy('createdAt')
        .limitToLast(150)
        .snapshots()
        .map((event) {
          return event.docs.map((doc) {
            final data = doc.data();
            return SessionChatMessage(
              id: doc.id,
              senderId: data['senderId'] as String? ?? '',
              senderName: data['senderName'] as String? ?? '',
              text: data['text'] as String? ?? '',
              createdAt:
                  (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            );
          }).toList();
        });
  }

  Future<void> sendChat(String sessionId, String text) async {
    final clean = text.trim();
    if (clean.isEmpty) return;
    await _sessions.doc(sessionId).collection('chat').add({
      'senderId': _uid,
      'senderName': _auth.currentUser?.displayName ?? '',
      'text': clean,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<ParticipantSignal>> watchParticipantSignals(String sessionId) {
    return _sessions.doc(sessionId).collection('participantSignals').snapshots().map((snap) {
      return snap.docs.map((doc) {
        final data = doc.data();
        return ParticipantSignal(
          uid: doc.id,
          handRaised: data['handRaised'] as bool? ?? false,
          requestToSpeak: data['requestToSpeak'] as bool? ?? false,
        );
      }).toList();
    });
  }

  Future<void> setRaiseHand(String sessionId, {required bool raised}) async {
    await _sessions.doc(sessionId).collection('participantSignals').doc(_uid).set({
      'handRaised': raised,
      'requestToSpeak': raised,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> approveSpeakerRequest(String sessionId, String participantId) async {
    await _sessions.doc(sessionId).collection('participantSignals').doc(participantId).set({
      'requestToSpeak': false,
      'approvedBy': _uid,
      'approvedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}

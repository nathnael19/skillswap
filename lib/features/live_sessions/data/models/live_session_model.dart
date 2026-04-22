import 'package:cloud_firestore/cloud_firestore.dart';

class LiveSession {
  final String sessionId;
  final String id;
  final String title;
  final String hostId;
  final String hmsRoomId;
  final String status; // "scheduled", "live", "ended"
  final String type; // "group", "one-on-one"
  final int maxParticipants;
  final List<String> participants;
  final List<String> allowedParticipants;
  final List<String> topics;
  final DateTime createdAt;
  final DateTime scheduledAt;
  final DateTime? startedAt;
  final DateTime? endedAt;

  LiveSession({
    required this.sessionId,
    required this.id,
    required this.title,
    required this.hostId,
    required this.hmsRoomId,
    required this.status,
    required this.type,
    required this.maxParticipants,
    required this.participants,
    required this.allowedParticipants,
    this.topics = const [],
    required this.createdAt,
    required this.scheduledAt,
    this.startedAt,
    this.endedAt,
  });

  factory LiveSession.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>? ?? <String, dynamic>{});
    final resolvedId = (data['sessionId'] as String?) ?? doc.id;
    final createdAtTs = data['createdAt'] as Timestamp?;
    final scheduledAtTs = data['scheduledAt'] as Timestamp?;
    final fallbackTime = createdAtTs?.toDate() ?? DateTime.now();
    return LiveSession(
      sessionId: resolvedId,
      id: doc.id,
      title: data['title'] ?? '',
      hostId: data['hostId'] ?? '',
      hmsRoomId: data['hmsRoomId'] ?? '',
      status: data['status'] ?? 'scheduled',
      type: data['type'] ?? 'group',
      maxParticipants: (data['maxParticipants'] as num?)?.toInt() ?? 20,
      participants: List<String>.from(data['participants'] ?? []),
      allowedParticipants: List<String>.from(data['allowed_participants'] ?? []),
      topics: List<String>.from(data['topics'] ?? []),
      createdAt: fallbackTime,
      scheduledAt: scheduledAtTs?.toDate() ?? fallbackTime,
      startedAt: (data['startedAt'] as Timestamp?)?.toDate(),
      endedAt: (data['endedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'sessionId': sessionId,
      'hostId': hostId,
      'hmsRoomId': hmsRoomId,
      'status': status,
      'type': type,
      'maxParticipants': maxParticipants,
      'participants': participants,
      'allowed_participants': allowedParticipants,
      'topics': topics,
      'createdAt': Timestamp.fromDate(createdAt),
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
      'endedAt': endedAt != null ? Timestamp.fromDate(endedAt!) : null,
    };
  }
}

import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String id;
  final String matchId;
  final String senderId;
  final String content;
  final DateTime timestamp;

  const Message({
    required this.id,
    required this.matchId,
    required this.senderId,
    required this.content,
    required this.timestamp,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] ?? '',
      matchId: map['match_id'] ?? '',
      senderId: map['sender_id'] ?? '',
      content: map['content'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'match_id': matchId,
      'sender_id': senderId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, matchId, senderId, content, timestamp];
}

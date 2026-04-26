class HubMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime createdAt;

  const HubMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.createdAt,
  });

  factory HubMessage.fromMap(Map<String, dynamic> map) {
    return HubMessage(
      id: map['id']?.toString() ?? '',
      senderId: map['sender_id']?.toString() ?? '',
      text: map['text']?.toString() ?? '',
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

/// Model representing a chat message in the conversation
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? id;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.id,
  });

  /// Creates a ChatMessage from a Map
  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      text: map['text'] as String,
      isUser: map['isUser'] as bool,
      timestamp: DateTime.parse(map['timestamp'] as String),
      id: map['id'] as String?,
    );
  }

  /// Converts a ChatMessage to a Map
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'id': id,
    };
  }

  /// Creates a copy of this ChatMessage with updated fields
  ChatMessage copyWith({
    String? text,
    bool? isUser,
    DateTime? timestamp,
    String? id,
  }) {
    return ChatMessage(
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      id: id ?? this.id,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessage &&
        other.text == text &&
        other.isUser == isUser &&
        other.timestamp == timestamp &&
        other.id == id;
  }

  @override
  int get hashCode {
    return text.hashCode ^
        isUser.hashCode ^
        timestamp.hashCode ^
        id.hashCode;
  }

  @override
  String toString() {
    return 'ChatMessage(text: $text, isUser: $isUser, timestamp: $timestamp, id: $id)';
  }
}

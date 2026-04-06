class Chat {
  final String id;
  final String contactName;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  Chat({
    required this.id,
    required this.contactName,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
  });

  Chat copyWith({
    String? id,
    String? contactName,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
  }) {
    return Chat(
      id: id ?? this.id,
      contactName: contactName ?? this.contactName,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

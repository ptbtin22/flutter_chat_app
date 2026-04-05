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
}

import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String id;
  final String contactName;      // displayName của đối phương
  final String contactUid;       // UID của đối phương
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final List<String> participants; // [myUid, otherUid]

  Chat({
    required this.id,
    required this.contactName,
    this.contactUid = '',
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.participants = const [],
  });

  factory Chat.fromFirestore(DocumentSnapshot doc, String currentUid, String contactDisplayName) {
    final data = doc.data() as Map<String, dynamic>;
    final participants = List<String>.from(data['participants'] ?? []);
    final contactUid = participants.firstWhere(
      (uid) => uid != currentUid,
      orElse: () => '',
    );
    return Chat(
      id: doc.id,
      contactName: contactDisplayName,
      contactUid: contactUid,
      lastMessage: data['lastMessage'] as String? ?? '',
      lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      unreadCount: (data['unreadCount'] as int?) ?? 0,
      participants: participants,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadCount': unreadCount,
    };
  }
}


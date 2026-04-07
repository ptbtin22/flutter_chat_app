import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String text;
  final String senderId;   // Firebase UID của người gửi
  final bool isMe;         // Tính toán từ currentUser.uid == senderId
  final DateTime timestamp;
  final bool isRead;

  Message({
    this.id = '',
    required this.text,
    required this.senderId,
    required this.isMe,
    required this.timestamp,
    this.isRead = false,
  });

  factory Message.fromFirestore(DocumentSnapshot doc, String currentUid) {
    final data = doc.data() as Map<String, dynamic>;
    final senderId = data['senderId'] as String? ?? '';
    return Message(
      id: doc.id,
      text: data['text'] as String? ?? '',
      senderId: senderId,
      isMe: senderId == currentUid,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'senderId': senderId,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': isRead,
    };
  }
}


import 'package:hive/hive.dart';
import '../../features/chat/domain/entities/chat.dart';
import '../../features/chat/domain/entities/message.dart';

class ChatAdapter extends TypeAdapter<Chat> {
  @override
  final int typeId = 0;

  @override
  Chat read(BinaryReader reader) {
    try {
      final map = reader.readMap().cast<String, dynamic>();
      return Chat(
        id: map['id'] as String? ?? '',
        contactName: map['contactName'] as String? ?? 'Unknown',
        contactUid: map['contactUid'] as String? ?? '',
        lastMessage: map['lastMessage'] as String? ?? '',
        lastMessageTime: DateTime.fromMillisecondsSinceEpoch(map['lastMessageTime'] as int? ?? 0),
        unreadCount: map['unreadCount'] as int? ?? 0,
        participants: List<String>.from(map['participants'] ?? []),
      );
    } catch (e) {
      return Chat(id: 'err', contactName: 'err', lastMessage: 'err', lastMessageTime: DateTime.now());
    }
  }

  @override
  void write(BinaryWriter writer, Chat obj) {
    writer.writeMap({
      'id': obj.id,
      'contactName': obj.contactName,
      'contactUid': obj.contactUid,
      'lastMessage': obj.lastMessage,
      'lastMessageTime': obj.lastMessageTime.millisecondsSinceEpoch,
      'unreadCount': obj.unreadCount,
      'participants': obj.participants,
    });
  }
}

class MessageAdapter extends TypeAdapter<Message> {
  @override
  final int typeId = 1;

  @override
  Message read(BinaryReader reader) {
    try {
      final map = reader.readMap().cast<String, dynamic>();
      return Message(
        id: map['id'] as String? ?? '',
        text: map['text'] as String? ?? '',
        senderId: map['senderId'] as String? ?? '',
        isMe: map['isMe'] as bool? ?? false,
        timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int? ?? 0),
        isRead: map['isRead'] as bool? ?? false,
      );
    } catch (e) {
      return Message(id: 'err', text: 'err', senderId: 'err', isMe: false, timestamp: DateTime.now(), isRead: false);
    }
  }

  @override
  void write(BinaryWriter writer, Message obj) {
    writer.writeMap({
      'id': obj.id,
      'text': obj.text,
      'senderId': obj.senderId,
      'isMe': obj.isMe,
      'timestamp': obj.timestamp.millisecondsSinceEpoch,
      'isRead': obj.isRead,
    });
  }
}

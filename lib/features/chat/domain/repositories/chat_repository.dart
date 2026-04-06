import '../entities/chat.dart';
import '../entities/message.dart';

abstract class ChatRepository {
  /// Real-time stream danh sách chats của user
  Stream<List<Chat>> chatsStream(String currentUid);

  /// Real-time stream messages của một chat
  Stream<List<Message>> messagesStream(String chatId, String currentUid);

  /// Gửi tin nhắn vào chat đã tồn tại
  Future<void> sendMessage(String chatId, Message message);

  /// Tìm hoặc tạo conversation với người dùng theo email.
  /// Trả về chatId (mới hoặc đã tồn tại).
  Future<String> findOrCreateChat({
    required String currentUid,
    required String currentDisplayName,
    required String otherEmail,
  });
}

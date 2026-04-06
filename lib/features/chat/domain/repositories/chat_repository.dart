import '../entities/chat.dart';
import '../entities/message.dart';

abstract class ChatRepository {
  Future<List<Chat>> getChats();
  Future<void> createChat(String contactName);
  Future<List<Message>> getMessages(String chatId);
  Future<void> sendMessage(String chatId, Message message);
  Future<void> deleteChat(String chatId);
}

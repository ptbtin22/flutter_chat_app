import '../../domain/entities/chat.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';

/// Mock repository chỉ dùng cho testing/DEV offline.
/// Production dùng FirestoreChatRepositoryImpl.
class MockChatRepositoryImpl implements ChatRepository {
  final List<Chat> _mockChats = [
    Chat(
      id: '1',
      contactName: 'Alice',
      lastMessage: 'Are we still on for tomorrow?',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
      unreadCount: 2,
    ),
    Chat(
      id: '2',
      contactName: 'Bob',
      lastMessage: 'Thanks man!',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  final Map<String, List<Message>> _mockMessages = {
    '1': [
      Message(
        text: 'Hey! Long time no see.',
        senderId: 'other',
        isMe: false,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      Message(
        text: 'I know! How have you been?',
        senderId: 'me',
        isMe: true,
        timestamp: DateTime.now().subtract(const Duration(minutes: 55)),
      ),
      Message(
        text: 'Are we still on for tomorrow?',
        senderId: 'other',
        isMe: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ],
  };

  @override
  Stream<List<Chat>> chatsStream(String currentUid) async* {
    await Future.delayed(const Duration(milliseconds: 500));
    yield _mockChats;
  }

  @override
  Stream<List<Message>> messagesStream(String chatId, String currentUid, {int limit = 20}) async* {
    await Future.delayed(const Duration(milliseconds: 300));
    yield _mockMessages[chatId] ?? [
      Message(
        text: 'Hello from newly created chat!',
        senderId: 'other',
        isMe: false,
        timestamp: DateTime.now(),
      ),
    ];
  }

  @override
  Future<void> sendMessage(String chatId, Message message) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!_mockMessages.containsKey(chatId)) {
      _mockMessages[chatId] = [];
    }
    _mockMessages[chatId]!.add(message);
  }

  @override
  Future<void> updateTypingStatus(String chatId, String currentUid, bool isTyping) async {}

  @override
  Stream<bool> typingStatusStream(String chatId, String otherUid) async* {
    yield false;
  }

  @override
  Future<void> markMessagesAsRead(String chatId, String currentUid) async {}

  @override
  Future<String> findOrCreateChat({
    required String currentUid,
    required String currentDisplayName,
    required String otherEmail,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return 'mock_chat_${otherEmail.hashCode}';
  }
}

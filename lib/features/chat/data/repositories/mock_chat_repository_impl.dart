import '../../domain/entities/chat.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';

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
    Chat(
      id: '3',
      contactName: 'Charlie',
      lastMessage: 'Send me the files ASAP.',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  final Map<String, List<Message>> _mockMessages = {
    '1': [
      Message(
        text: 'Hey! Long time no see.',
        isMe: false,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      Message(
        text: 'I know! How have you been?',
        isMe: true,
        timestamp: DateTime.now().subtract(const Duration(minutes: 55)),
      ),
      Message(
        text: 'Are we still on for tomorrow?',
        isMe: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ],
  };

  @override
  Future<List<Chat>> getChats() async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    ); // Simulate network latency
    return _mockChats;
  }

  @override
  Future<void> createChat(String contactName) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final newChat = Chat(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      contactName: contactName,
      lastMessage: 'Tap to start a conversation',
      lastMessageTime: DateTime.now(),
    );
    _mockChats.insert(0, newChat); // Insert at top
  }

  @override
  Future<List<Message>> getMessages(String chatId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_mockMessages.containsKey(chatId)) {
      return _mockMessages[chatId]!;
    }
    
    // Look up the actual Chat so the mocked fallback message logically matches the chat list UI!
    final chat = _mockChats.firstWhere(
      (c) => c.id == chatId,
      orElse: () => Chat(
        id: chatId,
        contactName: 'Unknown',
        lastMessage: 'Tap to start a conversation',
        lastMessageTime: DateTime.now(),
      ),
    );
    
    return [
      Message(
        text: chat.lastMessage,
        isMe: false,
        timestamp: chat.lastMessageTime,
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
  Future<void> deleteChat(String chatId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _mockChats.removeWhere((c) => c.id == chatId);
    _mockMessages.remove(chatId);
  }
}

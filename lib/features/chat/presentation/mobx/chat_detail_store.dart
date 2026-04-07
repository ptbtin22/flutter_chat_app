import 'dart:async';
import 'package:mobx/mobx.dart';
import '../../../../core/service_locator.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/message.dart';

part 'chat_detail_store.g.dart';

class ChatDetailStore = _ChatDetailStoreBase with _$ChatDetailStore;

abstract class _ChatDetailStoreBase with Store {
  final String chatId;
  late final ChatRepository _chatRepository = sl<ChatRepository>();
  late final AuthRepository _authRepository = sl<AuthRepository>();

  StreamSubscription<List<Message>>? _subscription;
  StreamSubscription<bool>? _typingSubscription;
  Timer? _typingThrottle;

  _ChatDetailStoreBase({required this.chatId});

  @observable
  ObservableList<Message> messages = ObservableList<Message>();

  @observable
  bool isLoading = true;

  @observable
  bool isSending = false;

  @observable
  bool isOtherTyping = false;
  
  @observable
  int messageLimit = 20;

  @observable
  bool hasMore = true;

  @action
  void initStream(String contactUid) {
    _listenToMessages();

    if (contactUid.isNotEmpty) {
      _typingSubscription = _chatRepository.typingStatusStream(chatId, contactUid).listen((isTyping) {
        setOtherTyping(isTyping);
      });
    }

    final currentUid = _authRepository.currentUser?.uid ?? '';
    _chatRepository.markMessagesAsRead(chatId, currentUid);
  }

  void _listenToMessages() {
    _subscription?.cancel();
    final currentUid = _authRepository.currentUser?.uid ?? '';
    _subscription = _chatRepository
        .messagesStream(chatId, currentUid, limit: messageLimit)
        .listen((incomingMessages) {
      if (incomingMessages.length < messageLimit) {
        hasMore = false;
      } else {
        hasMore = true;
      }
      
      updateMessages(incomingMessages);
      
      // Auto-read trigger
      if (incomingMessages.any((m) => !m.isMe && !m.isRead)) {
         _chatRepository.markMessagesAsRead(chatId, currentUid);
      }
    }, onError: (e) {
      setLoading(false);
    });
  }

  @action
  void loadMore() {
    if (!hasMore || isLoading) return;
    messageLimit += 20;
    _listenToMessages();
  }

  @action
  void updateMessages(List<Message> newMessages) {
    messages.clear();
    messages.addAll(newMessages);
    isLoading = false;
  }

  @action
  void setLoading(bool val) => isLoading = val;

  @action
  void setSending(bool val) => isSending = val;

  @action
  void setOtherTyping(bool val) => isOtherTyping = val;

  void reportTyping() {
    final currentUid = _authRepository.currentUser?.uid;
    if (currentUid == null) return;

    _chatRepository.updateTypingStatus(chatId, currentUid, true);
    
    _typingThrottle?.cancel();
    _typingThrottle = Timer(const Duration(seconds: 2), () {
      _chatRepository.updateTypingStatus(chatId, currentUid, false);
    });
  }

  @action
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || isSending) return;

    final currentUser = _authRepository.currentUser;
    if (currentUser == null) return;

    setSending(true);

    final newMessage = Message(
      text: text.trim(),
      senderId: currentUser.uid,
      isMe: true,
      timestamp: DateTime.now(),
    );

    try {
      await _chatRepository.sendMessage(chatId, newMessage);
    } finally {
      setSending(false);
    }
  }

  void dispose() {
    _subscription?.cancel();
    _typingSubscription?.cancel();
    _typingThrottle?.cancel();
  }
}

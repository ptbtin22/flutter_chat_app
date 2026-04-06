import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_chat_app/features/auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/message.dart';
import '../../../../core/service_locator.dart';
import '../../domain/repositories/chat_repository.dart';
import '../widgets/message_bubble.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  final String contactName;

  const ChatDetailScreen({
    super.key,
    required this.chatId,
    required this.contactName,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  late final ChatRepository _chatRepository = sl<ChatRepository>();
  late final AuthRepository _authRepository = sl<AuthRepository>();

  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  StreamSubscription<List<Message>>? _subscription;
  List<Message> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _subscribeToMessages();
  }

  void _subscribeToMessages() {
    final currentUid = _authRepository.currentUser?.uid ?? '';
    _subscription = _chatRepository
        .messagesStream(widget.chatId, currentUid)
        .listen((messages) {
      if (mounted) {
        final wasEmpty = _messages.isEmpty;
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
        if (wasEmpty || messages.isNotEmpty) {
          _scrollToBottom();
        }
      }
    }, onError: (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_textController.text.trim().isEmpty || _isSending) return;

    final currentUser = _authRepository.currentUser;
    if (currentUser == null) return;

    final text = _textController.text.trim();
    _textController.clear();

    setState(() => _isSending = true);

    final newMessage = Message(
      text: text,
      senderId: currentUser.uid,
      isMe: true,
      timestamp: DateTime.now(),
    );

    try {
      await _chatRepository.sendMessage(widget.chatId, newMessage);
      _scrollToBottom();
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Column(
          children: [
            Text(
              widget.contactName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        border: const Border(
          bottom: BorderSide(color: CupertinoColors.systemGrey4, width: 0.5),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CupertinoActivityIndicator())
                  : _messages.isEmpty
                      ? const Center(
                          child: Text(
                            'Hãy bắt đầu cuộc trò chuyện! 👋',
                            style: TextStyle(
                              color: CupertinoColors.systemGrey,
                              fontSize: 15,
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            return MessageBubble(message: _messages[index]);
                          },
                        ),
            ),
            _buildMessageInput(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 10.0,
        right: 10.0,
        top: 8.0,
        bottom: 8.0 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: CupertinoColors.systemGroupedBackground,
        border: Border(
          top: BorderSide(color: CupertinoColors.systemGrey4, width: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              child: CupertinoTextField(
                controller: _textController,
                placeholder: 'iMessage',
                textCapitalization: TextCapitalization.sentences,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                minLines: 1,
                maxLines: 5,
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  border: Border.all(
                    color: CupertinoColors.systemGrey4,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                onSubmitted: (_) => _sendMessage(),
                suffix: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _isSending ? null : _sendMessage,
                  child: Container(
                    margin: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: _isSending
                          ? CupertinoColors.systemGrey3
                          : CupertinoColors.activeBlue,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4.0),
                    child: _isSending
                        ? const CupertinoActivityIndicator(
                            color: CupertinoColors.white,
                            radius: 9,
                          )
                        : const Icon(
                            CupertinoIcons.arrow_up,
                            color: CupertinoColors.white,
                            size: 18,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

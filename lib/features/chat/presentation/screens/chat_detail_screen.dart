import 'package:flutter/cupertino.dart';
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

  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Message> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    final msgs = await _chatRepository.getMessages(widget.chatId);
    if (mounted) {
      setState(() {
        _messages = List.from(msgs); // Create mutable list based on mocked data
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _sendMessage() async {
    if (_textController.text.trim().isEmpty) return;

    final newMessage = Message(
      text: _textController.text,
      isMe: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(newMessage);
    });

    final textSent = _textController.text;
    _textController.clear();
    _scrollToBottom();

    // Persist to Mock Repository
    await _chatRepository.sendMessage(widget.chatId, newMessage);

    // Fake an automated reply
    Future.delayed(const Duration(seconds: 1), () async {
      if (!mounted) return;

      final reply = Message(
        text: "Automated mock reply to: '$textSent' \u{1F916}",
        isMe: false,
        timestamp: DateTime.now(),
      );

      await _chatRepository.sendMessage(widget.chatId, reply);

      if (mounted) {
        setState(() {
          _messages.add(reply);
        });
        _scrollToBottom();
      }
    });
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

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final isToday = now.year == timestamp.year && now.month == timestamp.month && now.day == timestamp.day;
    
    int hour = timestamp.hour;
    final ampm = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    if (hour == 0) hour = 12;
    final timeString = '$hour:${timestamp.minute.toString().padLeft(2, '0')} $ampm';
    
    if (isToday) {
      return 'Today $timeString';
    } else {
      final dateString = '${timestamp.month}/${timestamp.day}/${timestamp.year}';
      return '$dateString $timeString';
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemBackground,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildCustomHeader(context),
            Expanded(
              child: _isLoading
                  ? const Center(child: CupertinoActivityIndicator())
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        final previousMessage = index > 0 ? _messages[index - 1] : null;

                        bool showTimestamp = false;
                        if (previousMessage == null) {
                          showTimestamp = true;
                        } else {
                          final difference = message.timestamp.difference(previousMessage.timestamp);
                          if (difference.inMinutes >= 15) {
                            showTimestamp = true;
                          }
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (showTimestamp)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                child: Text(
                                  _formatTimestamp(message.timestamp),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: CupertinoColors.systemGrey,
                                  ),
                                ),
                              ),
                            MessageBubble(message: message),
                          ],
                        );
                      },
                    ),
            ),
            _buildMessageInput(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: CupertinoColors.systemBackground,
        border: Border(
          bottom: BorderSide(color: CupertinoColors.systemGrey4, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Back button physically anchored to the extreme left
          Align(
            alignment: Alignment.centerLeft,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.of(context).pop(),
              child: const Icon(CupertinoIcons.back, size: 28),
            ),
          ),
          // Center avatar + name strictly mathematically centered in the Stack bounds!
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: CupertinoColors.activeBlue,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    widget.contactName.isNotEmpty
                        ? widget.contactName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.contactName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: CupertinoColors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
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
      // Adding top border to simulate iMessage input area
      decoration: const BoxDecoration(
        color: CupertinoColors.systemGroupedBackground,
        border: Border(
          top: BorderSide(color: CupertinoColors.systemGrey4, width: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CupertinoButton(
            padding: const EdgeInsets.only(bottom: 5.0, right: 8.0, left: 4.0),
            onPressed: () {},
            child: const Icon(CupertinoIcons.add, size: 28),
          ),
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
                suffix: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _sendMessage,
                  child: Container(
                    margin: const EdgeInsets.all(4.0),
                    decoration: const BoxDecoration(
                      color: CupertinoColors.activeBlue,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4.0),
                    child: const Icon(
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

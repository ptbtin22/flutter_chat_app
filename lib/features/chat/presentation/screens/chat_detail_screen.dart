import 'package:flutter/cupertino.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../../core/service_locator.dart';
import '../mobx/chat_detail_store.dart';
import '../widgets/message_bubble.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  final String contactName;
  final String contactUid;

  const ChatDetailScreen({
    super.key,
    required this.chatId,
    required this.contactName,
    required this.contactUid,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  late final ChatDetailStore _store = sl<ChatDetailStore>(param1: widget.chatId);

  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _store.initStream(widget.contactUid);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 50) {
        _store.loadMore();
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _store.isSending) return;

    _textController.clear(); // Optimistic clear
    await _store.sendMessage(text);
    if (_scrollController.hasClients && _scrollController.position.pixels > 0) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _store.dispose();
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
              child: Observer(
                builder: (_) {
                  if (_store.isLoading) {
                    return const Center(child: CupertinoActivityIndicator());
                  }

                  if (_store.messages.isEmpty) {
                    return const Center(
                      child: Text(
                        'Hãy bắt đầu cuộc trò chuyện! 👋',
                        style: TextStyle(
                          color: CupertinoColors.systemGrey,
                          fontSize: 15,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    itemCount: _store.messages.length + (_store.isOtherTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_store.isOtherTyping && index == 0) {
                         return Padding(
                           padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                           child: Row(
                             crossAxisAlignment: CrossAxisAlignment.end,
                             children: [
                               Container(
                                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                 decoration: BoxDecoration(
                                   color: CupertinoColors.systemGrey5,
                                   borderRadius: BorderRadius.circular(16),
                                 ),
                                 child: const Text(
                                   'Đang soạn tin...',
                                   style: TextStyle(
                                     fontSize: 14,
                                     fontStyle: FontStyle.italic,
                                     color: CupertinoColors.systemGrey,
                                   ),
                                 ),
                               ),
                             ],
                           ),
                         );
                      }
                      
                      final messageIndex = _store.isOtherTyping ? index - 1 : index;
                      if (messageIndex >= _store.messages.length) return const SizedBox.shrink();
                      
                      return MessageBubble(message: _store.messages[messageIndex]);
                    },
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
                onChanged: (_) => _store.reportTyping(),
                onSubmitted: (_) => _sendMessage(),
                suffix: Observer(
                  builder: (_) => CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _store.isSending ? null : _sendMessage,
                    child: Container(
                      margin: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: _store.isSending
                            ? CupertinoColors.systemGrey3
                            : CupertinoColors.activeBlue,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4.0),
                      child: _store.isSending
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
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/message.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Message> _messages = [
    Message(
      text: "Hello! Welcome to the iOS Chat Demo \u{1F44B}",
      isMe: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];

  void _sendMessage() {
    if (_textController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        Message(
          text: _textController.text,
          isMe: true,
          timestamp: DateTime.now(),
        ),
      );
    });

    _textController.clear();
    _scrollToBottom();

    // Fake an automated reply
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _messages.add(
          Message(
            text: "This is an automated reply. \u{1F916}",
            isMe: false,
            timestamp: DateTime.now(),
          ),
        );
      });
      _scrollToBottom();
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

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We use CupertinoPageScaffold which is the iOS equivalent to Scaffold
    return CupertinoPageScaffold(
      // CupertinoNavigationBar provides the translucent iOS blur effect
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Seminar Chat Demo'),
        border: Border(bottom: BorderSide(color: CupertinoColors.systemGrey4, width: 0.5)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return MessageBubble(message: message);
                },
              ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      // Adding top border to simulate iMessage input area
      decoration: const BoxDecoration(
        color: CupertinoColors.systemGroupedBackground,
        border: Border(top: BorderSide(color: CupertinoColors.systemGrey4, width: 0.5)),
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                minLines: 1,
                maxLines: 5,
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  border: Border.all(color: CupertinoColors.systemGrey4, width: 1.0),
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
                    child: const Icon(CupertinoIcons.arrow_up, color: CupertinoColors.white, size: 18),
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

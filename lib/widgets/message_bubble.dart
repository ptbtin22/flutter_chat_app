import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            // Fake avatar for "them"
            const CircleAvatar(
              radius: 16,
              backgroundColor: CupertinoColors.systemGrey4,
              child: Icon(CupertinoIcons.person_fill, color: CupertinoColors.white, size: 20),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              decoration: BoxDecoration(
                // iMessage style blue for me, gray for them
                color: isMe ? CupertinoColors.activeBlue : CupertinoColors.systemGrey5,
                borderRadius: BorderRadius.circular(20.0).copyWith(
                  bottomRight: isMe ? const Radius.circular(0) : null,
                  bottomLeft: !isMe ? const Radius.circular(0) : null,
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isMe ? CupertinoColors.white : CupertinoColors.black,
                  fontSize: 16.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

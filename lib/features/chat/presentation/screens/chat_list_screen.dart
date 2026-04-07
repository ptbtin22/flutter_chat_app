import 'package:flutter/cupertino.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'chat_detail_screen.dart';
import 'new_chat_screen.dart';
import '../widgets/search_bar.dart';
import '../../../../core/service_locator.dart';
import '../mobx/chat_list_store.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late final ChatListStore _store = sl<ChatListStore>();

  @override
  void initState() {
    super.initState();
    _store.listenToChats();
  }

  @override
  void dispose() {
    _store.stopListening();
    super.dispose();
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inDays == 0) {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Hôm qua';
    } else {
      return '${time.day}/${time.month}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text(
          'Messages',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        border: const Border(
          bottom: BorderSide(color: CupertinoColors.systemGrey4, width: 0.5),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.of(context, rootNavigator: true).push(
              CupertinoPageRoute(
                builder: (_) => const NewChatScreen(),
              ),
            );
          },
          child: const Icon(CupertinoIcons.square_pencil, size: 22),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const ChatSearchBar(),
            Expanded(
              child: Observer(
                builder: (_) {
                  if (_store.isLoading) {
                    return const Center(child: CupertinoActivityIndicator());
                  }

                  if (_store.errorMessage != null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          _store.errorMessage!,
                          style: const TextStyle(
                            color: CupertinoColors.secondaryLabel,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  final chats = _store.filteredChats;

                  if (chats.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            CupertinoIcons.chat_bubble_2,
                            size: 64,
                            color: CupertinoColors.systemGrey3,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Chưa có cuộc trò chuyện nào.',
                            style: TextStyle(
                              color: CupertinoColors.systemGrey,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          CupertinoButton(
                            onPressed: () {
                              Navigator.of(context, rootNavigator: true).push(
                                CupertinoPageRoute(
                                  builder: (_) => const NewChatScreen(),
                                ),
                              );
                            },
                            child: const Text('Bắt đầu chat mới'),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: chats.length,
                    itemBuilder: (context, index) {
                      final chat = chats[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).push(
                            CupertinoPageRoute(
                              builder: (context) => ChatDetailScreen(
                                chatId: chat.id,
                                contactName: chat.contactName,
                                contactUid: chat.contactUid,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          color: CupertinoColors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                          child: Row(
                            children: [
                              // Avatar
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: CupertinoColors.activeBlue
                                      .withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    chat.contactName.isNotEmpty
                                        ? chat.contactName[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: CupertinoColors.activeBlue,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          chat.contactName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: CupertinoColors.black,
                                          ),
                                        ),
                                        Text(
                                          _formatTime(chat.lastMessageTime),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: CupertinoColors.systemGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            chat.lastMessage.isEmpty
                                                ? 'Bắt đầu cuộc trò chuyện'
                                                : chat.lastMessage,
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: chat.lastMessage.isEmpty
                                                  ? CupertinoColors.systemGrey3
                                                  : CupertinoColors.systemGrey,
                                              fontStyle: chat.lastMessage.isEmpty
                                                  ? FontStyle.italic
                                                  : FontStyle.normal,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (chat.unreadCount > 0)
                                          Container(
                                            margin: const EdgeInsets.only(
                                                left: 8),
                                            padding: const EdgeInsets.all(6),
                                            decoration: const BoxDecoration(
                                              color: CupertinoColors.activeBlue,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Text(
                                              '${chat.unreadCount}',
                                              style: const TextStyle(
                                                color: CupertinoColors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'chat_detail_screen.dart';
import '../widgets/search_bar.dart';
import '../../../../core/service_locator.dart';
import '../mobx/chat_list_store.dart';
import 'create_chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  // Grab the reference ONCE. Clean and decoupled.
  late final ChatListStore _store = sl<ChatListStore>();
  @override
  void initState() {
    super.initState();
    // Dispatch the fetch action when the screen mounts
    _store.fetchChats();
  }

  void _showNewChatDialog(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => const CreateChatScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Messages', style: TextStyle(fontWeight: FontWeight.bold)),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _showNewChatDialog(context),
          child: const Icon(CupertinoIcons.square_pencil),
        ),
        border: const Border(
          bottom: BorderSide(color: CupertinoColors.systemGrey4, width: 0.5),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const ChatSearchBar(),
            Expanded(
              // Observer handles all reactivity based on read observables transparently
              child: Observer(
                builder: (_) {
                  if (_store.isLoading) {
                    return const Center(child: CupertinoActivityIndicator());
                  }

                  final chats = _store.filteredChats;

                  if (chats.isEmpty) {
                    return const Center(
                      child: Text(
                        'No messages found.',
                        style: TextStyle(color: CupertinoColors.systemGrey),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: chats.length,
                    itemBuilder: (context, index) {
                      final chat = chats[index];
                      return Dismissible(
                        key: ValueKey(chat.id),
                        direction: DismissDirection
                            .endToStart, // iOS Swipe Right-to-Left
                        onDismissed: (_) {
                          _store.deleteChat(chat.id);
                        },
                        background: Container(
                          color: CupertinoColors.destructiveRed,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20.0),
                          child: const Icon(
                            CupertinoIcons.trash,
                            color: CupertinoColors.white,
                          ),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            _store.markAsRead(chat.id);
                            Navigator.of(context, rootNavigator: true).push(
                              CupertinoPageRoute(
                                builder: (context) => ChatDetailScreen(
                                  chatId: chat.id,
                                  contactName: chat.contactName,
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
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: const BoxDecoration(
                                    color: CupertinoColors.activeBlue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      chat.contactName.isNotEmpty ? chat.contactName[0].toUpperCase() : '?',
                                      style: const TextStyle(
                                        color: CupertinoColors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                            '${chat.lastMessageTime.hour}:${chat.lastMessageTime.minute.toString().padLeft(2, '0')}',
                                            style: const TextStyle(
                                              fontSize: 14,
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
                                              chat.lastMessage,
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: CupertinoColors.systemGrey,
                                                fontWeight: chat.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (chat.unreadCount > 0)
                                            Container(
                                              margin: const EdgeInsets.only(left: 8.0),
                                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                                              decoration: BoxDecoration(
                                                color: CupertinoColors.activeBlue,
                                                borderRadius: BorderRadius.circular(12.0),
                                              ),
                                              child: Text(
                                                chat.unreadCount.toString(),
                                                style: const TextStyle(
                                                  color: CupertinoColors.white,
                                                  fontSize: 12,
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

import 'package:flutter/cupertino.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'chat_detail_screen.dart';
import '../widgets/search_bar.dart';
import '../../../../core/service_locator.dart';
import '../mobx/chat_list_store.dart';

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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Messages', style: TextStyle(fontWeight: FontWeight.bold)),
        border: Border(bottom: BorderSide(color: CupertinoColors.systemGrey4, width: 0.5)),
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
                      return GestureDetector(
                        onTap: () {
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
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: const BoxDecoration(
                                  color: CupertinoColors.systemGrey4,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(CupertinoIcons.person_fill, color: CupertinoColors.white, size: 30),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    Text(
                                      chat.lastMessage,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: CupertinoColors.systemGrey,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
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

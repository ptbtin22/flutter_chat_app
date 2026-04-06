import 'package:mobx/mobx.dart';
import 'package:flutter_chat_app/features/chat/domain/entities/chat.dart';
import 'package:flutter_chat_app/core/service_locator.dart';
import 'package:flutter_chat_app/features/chat/domain/repositories/chat_repository.dart';

// Run 'dart run build_runner build' to generate this file
part 'chat_list_store.g.dart';

// ignore: library_private_types_in_public_api
class ChatListStore = _ChatListStoreBase with _$ChatListStore;

abstract class _ChatListStoreBase with Store {
  @observable
  ObservableList<Chat> allChats = ObservableList<Chat>();

  @observable
  String searchQuery = "";

  @observable
  bool isLoading = false;

  // This is the "Advanced" part: MobX caches this
  // and only re-runs it if allChats or searchQuery changes.
  @computed
  List<Chat> get filteredChats {
    if (searchQuery.isEmpty) return allChats;
    return allChats
        .where(
          (chat) => chat.contactName.toLowerCase().contains(
            searchQuery.toLowerCase(),
          ),
        )
        .toList();
  }

  @action
  Future<void> fetchChats() async {
    isLoading = true;
    final chats = await sl<ChatRepository>().getChats();
    allChats.clear();
    allChats.addAll(chats);
    isLoading = false;
  }

  @action
  void setSearchQuery(String value) {
    searchQuery = value;
  }

  @action
  Future<void> deleteChat(String chatId) async {
    // Optimistic UI Update instantly deletes it for true native feel
    allChats.removeWhere((c) => c.id == chatId);
    // Background execution to the backend/repo
    await sl<ChatRepository>().deleteChat(chatId);
  }

  @action
  void markAsRead(String chatId) {
    final index = allChats.indexWhere((c) => c.id == chatId);
    if (index != -1 && allChats[index].unreadCount > 0) {
      allChats[index] = allChats[index].copyWith(unreadCount: 0);
    }
  }

  @action
  Future<void> createChat(String contactName) async {
    final newChat = Chat(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      contactName: contactName,
      lastMessage: 'Tap to start a conversation',
      lastMessageTime: DateTime.now(),
    );
    // Optimistic UI insert at top
    allChats.insert(0, newChat);
    await sl<ChatRepository>().createChat(contactName);
  }
}

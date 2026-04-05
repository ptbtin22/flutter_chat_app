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
}

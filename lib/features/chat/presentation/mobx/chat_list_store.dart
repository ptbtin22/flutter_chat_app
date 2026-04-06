import 'dart:async';
import 'package:mobx/mobx.dart';
import 'package:flutter_chat_app/features/chat/domain/entities/chat.dart';
import 'package:flutter_chat_app/core/service_locator.dart';
import 'package:flutter_chat_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:flutter_chat_app/features/auth/domain/repositories/auth_repository.dart';

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

  @observable
  String? errorMessage;

  StreamSubscription<List<Chat>>? _subscription;

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
  void listenToChats() {
    final currentUid = sl<AuthRepository>().currentUser?.uid;
    if (currentUid == null) return;

    _subscription?.cancel();
    isLoading = true; // Bắt đầu loading trước khi stream emit lần đầu
    errorMessage = null;
    _subscription = sl<ChatRepository>().chatsStream(currentUid).listen(
      (chats) {
        allChats.clear();
        allChats.addAll(chats);
        isLoading = false;
      },
      onError: (e) {
        errorMessage = 'Không thể tải danh sách chat: $e';
        isLoading = false;
      },
    );
  }


  @action
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  @action
  void setSearchQuery(String value) {
    searchQuery = value;
  }
}


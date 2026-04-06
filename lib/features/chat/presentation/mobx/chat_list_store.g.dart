// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_list_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ChatListStore on _ChatListStoreBase, Store {
  Computed<List<Chat>>? _$filteredChatsComputed;

  @override
  List<Chat> get filteredChats =>
      (_$filteredChatsComputed ??= Computed<List<Chat>>(
        () => super.filteredChats,
        name: '_ChatListStoreBase.filteredChats',
      )).value;

  late final _$allChatsAtom = Atom(
    name: '_ChatListStoreBase.allChats',
    context: context,
  );

  @override
  ObservableList<Chat> get allChats {
    _$allChatsAtom.reportRead();
    return super.allChats;
  }

  @override
  set allChats(ObservableList<Chat> value) {
    _$allChatsAtom.reportWrite(value, super.allChats, () {
      super.allChats = value;
    });
  }

  late final _$searchQueryAtom = Atom(
    name: '_ChatListStoreBase.searchQuery',
    context: context,
  );

  @override
  String get searchQuery {
    _$searchQueryAtom.reportRead();
    return super.searchQuery;
  }

  @override
  set searchQuery(String value) {
    _$searchQueryAtom.reportWrite(value, super.searchQuery, () {
      super.searchQuery = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: '_ChatListStoreBase.isLoading',
    context: context,
  );

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$fetchChatsAsyncAction = AsyncAction(
    '_ChatListStoreBase.fetchChats',
    context: context,
  );

  @override
  Future<void> fetchChats() {
    return _$fetchChatsAsyncAction.run(() => super.fetchChats());
  }

  late final _$deleteChatAsyncAction = AsyncAction(
    '_ChatListStoreBase.deleteChat',
    context: context,
  );

  @override
  Future<void> deleteChat(String chatId) {
    return _$deleteChatAsyncAction.run(() => super.deleteChat(chatId));
  }

  late final _$createChatAsyncAction = AsyncAction(
    '_ChatListStoreBase.createChat',
    context: context,
  );

  @override
  Future<void> createChat(String contactName) {
    return _$createChatAsyncAction.run(() => super.createChat(contactName));
  }

  late final _$_ChatListStoreBaseActionController = ActionController(
    name: '_ChatListStoreBase',
    context: context,
  );

  @override
  void setSearchQuery(String value) {
    final _$actionInfo = _$_ChatListStoreBaseActionController.startAction(
      name: '_ChatListStoreBase.setSearchQuery',
    );
    try {
      return super.setSearchQuery(value);
    } finally {
      _$_ChatListStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void markAsRead(String chatId) {
    final _$actionInfo = _$_ChatListStoreBaseActionController.startAction(
      name: '_ChatListStoreBase.markAsRead',
    );
    try {
      return super.markAsRead(chatId);
    } finally {
      _$_ChatListStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
allChats: ${allChats},
searchQuery: ${searchQuery},
isLoading: ${isLoading},
filteredChats: ${filteredChats}
    ''';
  }
}

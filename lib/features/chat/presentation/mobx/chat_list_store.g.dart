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

  late final _$errorMessageAtom = Atom(
    name: '_ChatListStoreBase.errorMessage',
    context: context,
  );

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$_ChatListStoreBaseActionController = ActionController(
    name: '_ChatListStoreBase',
    context: context,
  );

  @override
  void listenToChats() {
    final _$actionInfo = _$_ChatListStoreBaseActionController.startAction(
      name: '_ChatListStoreBase.listenToChats',
    );
    try {
      return super.listenToChats();
    } finally {
      _$_ChatListStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void stopListening() {
    final _$actionInfo = _$_ChatListStoreBaseActionController.startAction(
      name: '_ChatListStoreBase.stopListening',
    );
    try {
      return super.stopListening();
    } finally {
      _$_ChatListStoreBaseActionController.endAction(_$actionInfo);
    }
  }

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
  String toString() {
    return '''
allChats: ${allChats},
searchQuery: ${searchQuery},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
filteredChats: ${filteredChats}
    ''';
  }
}

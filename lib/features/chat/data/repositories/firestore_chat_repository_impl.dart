import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat.dart';
import '../../domain/entities/message.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/repositories/chat_repository.dart';

class FirestoreChatRepositoryImpl implements ChatRepository {
  final FirebaseFirestore _firestore;

  // Cache tên user để không phải fetch lại mỗi lần stream update
  final Map<String, String> _userNameCache = {};

  FirestoreChatRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ── Chats Stream ────────────────────────────────────────────────────────────

  @override
  Stream<List<Chat>> chatsStream(String currentUid) {
    // Dùng StreamController + generation counter để implement "switchMap" semantics:
    // Khi snapshot mới đến, generation tăng lên → fetch cũ đang chạy sẽ biết bỏ kết quả.
    // Điều này đảm bảo snapshot mới nhất luôn thắng, tránh list bị trống tạm thời.
    late StreamController<List<Chat>> controller;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? upstream;
    int generation = 0;

    controller = StreamController<List<Chat>>(
      onListen: () async {
        try {
          final box = await Hive.openBox<List>('chats_box');
          final cachedList = box.get('my_chats_$currentUid')?.cast<Chat>();
          if (cachedList != null && cachedList.isNotEmpty && !controller.isClosed) {
            controller.add(cachedList);
          }
        } catch (_) {}

        upstream = _firestore
            .collection('chats')
            .where('participants', arrayContains: currentUid)
            // Bỏ qua metadata-only changes (pending writes) để tránh snapshot thừa
            .snapshots(includeMetadataChanges: false)
            .listen(
          (snapshot) {
            final currentGen = ++generation;

            if (snapshot.docs.isEmpty) {
              controller.add(<Chat>[]);
              return;
            }

            // Fetch user profiles còn thiếu trong cache
            final uidsToFetch = <String>{};
            for (final doc in snapshot.docs) {
              final parts = List<String>.from(doc.data()['participants'] ?? []);
              final otherUid = parts.firstWhere(
                (uid) => uid != currentUid,
                orElse: () => '',
              );
              if (otherUid.isNotEmpty && !_userNameCache.containsKey(otherUid)) {
                uidsToFetch.add(otherUid);
              }
            }

            Future(() async {
              // Batch fetch song song
              if (uidsToFetch.isNotEmpty) {
                final futures = uidsToFetch.map(
                  (uid) => _firestore.collection('users').doc(uid).get(),
                );
                final userDocs = await Future.wait(futures, eagerError: false);
                for (final userDoc in userDocs) {
                  if (userDoc.exists) {
                    final name = userDoc.data()?['displayName'] as String?;
                    if (name != null && name.isNotEmpty) {
                      _userNameCache[userDoc.id] = name;
                    }
                  }
                }
              }

              // Nếu generation đã tăng → có snapshot mới hơn đang được xử lý, bỏ qua.
              if (currentGen != generation) return;
              if (controller.isClosed) return;

              // Build chat list
              final chats = <Chat>[];
              for (final doc in snapshot.docs) {
                final data = doc.data();
                final parts = List<String>.from(data['participants'] ?? []);
                final otherUid = parts.firstWhere(
                  (uid) => uid != currentUid,
                  orElse: () => '',
                );
                final contactName = _userNameCache[otherUid]
                    ?? data['contactName_$currentUid'] as String?
                    ?? (otherUid.isNotEmpty ? otherUid : '?');
                chats.add(Chat.fromFirestore(doc, currentUid, contactName));
              }

              chats.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
              
              try {
                final box = Hive.box<List>('chats_box');
                box.put('my_chats_$currentUid', chats);
              } catch (_) {}
              
              if (!controller.isClosed) controller.add(chats);
            }).catchError((e) {
              if (!controller.isClosed) controller.addError(e);
            });
          },
          onError: (e) {
            if (!controller.isClosed) controller.addError(e);
          },
        );
      },
      onCancel: () {
        upstream?.cancel();
        upstream = null;
      },
    );

    return controller.stream;
  }


  // ── Messages Stream ──────────────────────────────────────────────────────────

  @override
  Stream<List<Message>> messagesStream(String chatId, String currentUid, {int limit = 20}) {
    late StreamController<List<Message>> controller;
    StreamSubscription? upstream;

    controller = StreamController<List<Message>>(
      onListen: () async {
        try {
          final box = await Hive.openBox<List>('messages_box');
          final cached = box.get('msgs_$chatId')?.cast<Message>();
          if (cached != null && cached.isNotEmpty && !controller.isClosed) {
            controller.add(cached);
          }
        } catch (_) {}

        upstream = _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .limit(limit)
            .snapshots()
            .listen((snapshot) {
              final msgs = snapshot.docs.map((doc) => Message.fromFirestore(doc, currentUid)).toList();
              
              try {
                 final box = Hive.box<List>('messages_box');
                 box.put('msgs_$chatId', msgs);
              } catch (_) {}

              if (!controller.isClosed) controller.add(msgs);
            }, onError: (e) {
              if (!controller.isClosed) controller.addError(e);
            });
      },
      onCancel: () {
        upstream?.cancel();
      },
    );

    return controller.stream;
  }

  // ── Send Message ─────────────────────────────────────────────────────────────

  @override
  Future<void> sendMessage(String chatId, Message message) async {
    final batch = _firestore.batch();

    final msgRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();
    batch.set(msgRef, message.toFirestore());

    final chatRef = _firestore.collection('chats').doc(chatId);
    batch.update(chatRef, {
      'lastMessage': message.text,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  // ── Advanced Features ────────────────────────────────────────────────────────

  @override
  Future<void> updateTypingStatus(String chatId, String currentUid, bool isTyping) async {
    await _firestore.collection('chats').doc(chatId).update({
      'typing_$currentUid': isTyping,
    }).catchError((_) {}); // Ignore if document missing
  }

  @override
  Stream<bool> typingStatusStream(String chatId, String otherUid) {
    return _firestore.collection('chats').doc(chatId).snapshots().map((doc) {
      final data = doc.data();
      return (data?['typing_$otherUid'] as bool?) ?? false;
    });
  }

  @override
  Future<void> markMessagesAsRead(String chatId, String currentUid) async {
    // Drop the strict .where('isRead', isEqualTo: false) query!
    // If old text messages didn't have the 'isRead' field natively yet, Firestore drops them completely from that strict query.
    // Fetching natively and filtering via Dart fixes the schema migration bug instantly.
    final snapshot = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('senderId', isNotEqualTo: currentUid)
        .get();

    if (snapshot.docs.isEmpty) return;

    final batch = _firestore.batch();
    bool hasUpdates = false;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data['isRead'] != true) {
        batch.update(doc.reference, {'isRead': true});
        hasUpdates = true;
      }
    }
    
    if (hasUpdates) {
      final chatRef = _firestore.collection('chats').doc(chatId);
      batch.update(chatRef, {'unreadCount': 0});
      await batch.commit();
    }
  }

  // ── Find or Create Chat ──────────────────────────────────────────────────────

  @override
  Future<String> findOrCreateChat({
    required String currentUid,
    required String currentDisplayName,
    required String otherEmail,
  }) async {
    final emailLower = otherEmail.trim().toLowerCase();

    print('[Firestore] findOrCreateChat: searching email="$emailLower"');

    // Tìm user theo email (lowercase để match đúng)
    final usersQuery = await _firestore
        .collection('users')
        .where('email', isEqualTo: emailLower)
        .limit(1)
        .get();

    print('[Firestore] Query result: ${usersQuery.docs.length} docs found');

    // Debug: in ra tất cả users để kiểm tra
    if (usersQuery.docs.isEmpty) {
      // Lấy tối đa 10 users để xem dữ liệu thực sự trong Firestore
      final allUsers = await _firestore.collection('users').limit(10).get();
      print('[Firestore] Total users in collection: ${allUsers.docs.length}');
      for (final doc in allUsers.docs) {
        print('[Firestore]   uid=${doc.id}, data=${doc.data()}');
      }
      throw Exception(
        'Không tìm thấy tài khoản với email "$otherEmail".\n'
        'Lưu ý: người dùng cần đăng nhập ít nhất một lần để tìm kiếm được.',
      );
    }

    final otherUser = usersQuery.docs.first;
    final otherUid = otherUser.id;
    final otherDisplayName =
        otherUser.data()['displayName'] as String? ?? emailLower.split('@').first;

    print('[Firestore] Found user: uid=$otherUid, displayName=$otherDisplayName');

    if (otherUid == currentUid) {
      throw Exception('Không thể tạo chat với chính mình.');
    }

    // Kiểm tra xem đã có conversation chưa
    final existingChats = await _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUid)
        .get();

    for (final doc in existingChats.docs) {
      final participants = List<String>.from(doc.data()['participants'] ?? []);
      if (participants.contains(otherUid)) {
        print('[Firestore] Found existing chat: ${doc.id}');
        return doc.id;
      }
    }

    // Tạo conversation mới
    print('[Firestore] Creating new chat between $currentUid and $otherUid');
    final newChatRef = _firestore.collection('chats').doc();
    await newChatRef.set({
      'participants': [currentUid, otherUid],
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadCount': 0,
      'contactName_$currentUid': otherDisplayName,
      'contactName_$otherUid': currentDisplayName,
    });

    // Cập nhật cache
    _userNameCache[otherUid] = otherDisplayName;

    print('[Firestore] New chat created: ${newChatRef.id}');
    return newChatRef.id;
  }
}


import 'package:get_it/get_it.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/data/repositories/firebase_auth_repository_impl.dart';
import '../features/auth/presentation/mobx/auth_store.dart';
import '../features/chat/domain/repositories/chat_repository.dart';
import '../features/chat/data/repositories/firestore_chat_repository_impl.dart';
import '../features/chat/presentation/mobx/chat_list_store.dart';
import '../features/chat/presentation/mobx/chat_detail_store.dart';

final sl = GetIt.instance;

void initServiceLocator() {
  // ── Auth ──────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
    () => FirebaseAuthRepositoryImpl(),
  );

  sl.registerLazySingleton<AuthStore>(
    () => AuthStore(sl<AuthRepository>()),
  );

  // ── Chat ──────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<ChatRepository>(
    () => FirestoreChatRepositoryImpl(),
  );

  // Store dùng lazy singleton để giữ state khi chuyển tab
  sl.registerLazySingleton<ChatListStore>(() => ChatListStore());

  sl.registerFactoryParam<ChatDetailStore, String, void>(
    (chatId, _) => ChatDetailStore(chatId: chatId),
  );
}

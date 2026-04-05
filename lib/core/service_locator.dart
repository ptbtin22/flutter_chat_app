import 'package:get_it/get_it.dart';
import '../features/chat/domain/repositories/chat_repository.dart';
import '../features/chat/data/repositories/mock_chat_repository_impl.dart';
import '../features/chat/presentation/mobx/chat_list_store.dart';

final sl = GetIt.instance;

void initServiceLocator() {
  // Repositories
  // registerLazySingleton creates it once! Like Swinject's standard container registration.
  sl.registerLazySingleton<ChatRepository>(() => MockChatRepositoryImpl());

  // Stores
  // We want the ChatListStore to persist the loaded chat list across tab switches.
  sl.registerLazySingleton<ChatListStore>(() => ChatListStore());
  
  // TODO: We will use sl.registerFactory<ChatDetailStore>(() => ChatDetailStore());
  // Later when we make the ChatDetailScreen use MobX! 
}

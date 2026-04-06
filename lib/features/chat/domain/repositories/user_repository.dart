import '../entities/user.dart';

abstract class UserRepository {
  Future<List<User>> searchUsers(String query);
}

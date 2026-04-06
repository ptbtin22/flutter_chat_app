import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';

class MockUserRepositoryImpl implements UserRepository {
  final List<User> _mockUsers = [
    User(id: 'u1', username: 'john_doe', name: 'John Doe'),
    User(id: 'u2', username: 'jane_smith', name: 'Jane Smith'),
    User(id: 'u3', username: 'alex99', name: 'Alex Johnson'),
    User(id: 'u4', username: 'cr7goat', name: 'Cristiano Ronaldo'),
    User(id: 'u5', username: 'steve_jobs', name: 'Steve Jobs'),
    User(id: 'u6', username: 'tim_cook', name: 'Tim Cook'),
  ];

  @override
  Future<List<User>> searchUsers(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (query.isEmpty) return _mockUsers;

    final lowerQuery = query.toLowerCase();
    return _mockUsers
        .where(
          (u) =>
              u.username.toLowerCase().contains(lowerQuery) ||
              u.name.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }
}

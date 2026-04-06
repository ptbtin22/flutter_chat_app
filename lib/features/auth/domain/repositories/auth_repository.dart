import '../entities/app_user.dart';

abstract class AuthRepository {
  /// Stream trạng thái đăng nhập (null = chưa đăng nhập)
  Stream<AppUser?> get authStateChanges;

  /// User hiện tại (null nếu chưa đăng nhập)
  AppUser? get currentUser;

  /// Đăng nhập bằng email/password
  Future<AppUser> signIn({required String email, required String password});

  /// Đăng ký tài khoản mới
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  /// Đăng xuất
  Future<void> signOut();
}

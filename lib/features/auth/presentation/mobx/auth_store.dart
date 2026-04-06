import 'package:mobx/mobx.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_app/features/auth/domain/entities/app_user.dart';
import 'package:flutter_chat_app/features/auth/domain/repositories/auth_repository.dart';

part 'auth_store.g.dart';

// ignore: library_private_types_in_public_api
class AuthStore = _AuthStoreBase with _$AuthStore;

abstract class _AuthStoreBase with Store {
  final AuthRepository _authRepository;

  _AuthStoreBase(this._authRepository);

  @observable
  AppUser? currentUser;

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @computed
  bool get isLoggedIn => currentUser != null;

  @action
  Future<bool> login({required String email, required String password}) async {
    isLoading = true;
    errorMessage = null;
    try {
      currentUser = await _authRepository.signIn(
        email: email,
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage = _mapFirebaseError(e.code);
      return false;
    } catch (e) {
      errorMessage = 'Đã xảy ra lỗi. Vui lòng thử lại.';
      return false;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    isLoading = true;
    errorMessage = null;
    try {
      currentUser = await _authRepository.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage = _mapFirebaseError(e.code);
      return false;
    } catch (e) {
      errorMessage = 'Đã xảy ra lỗi. Vui lòng thử lại.';
      return false;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> logout() async {
    await _authRepository.signOut();
    currentUser = null;
  }

  @action
  void setCurrentUser(AppUser? user) {
    currentUser = user;
  }

  @action
  void clearError() {
    errorMessage = null;
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này.';
      case 'wrong-password':
        return 'Mật khẩu không đúng.';
      case 'invalid-credential':
        return 'Email hoặc mật khẩu không đúng.';
      case 'email-already-in-use':
        return 'Email này đã được sử dụng.';
      case 'invalid-email':
        return 'Địa chỉ email không hợp lệ.';
      case 'weak-password':
        return 'Mật khẩu quá yếu. Vui lòng dùng ít nhất 6 ký tự.';
      case 'too-many-requests':
        return 'Quá nhiều lần thử. Vui lòng thử lại sau.';
      case 'network-request-failed':
        return 'Lỗi kết nối mạng. Kiểm tra internet của bạn.';
      default:
        return 'Lỗi xác thực: $code';
    }
  }
}

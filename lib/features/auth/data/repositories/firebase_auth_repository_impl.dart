import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseAuthRepositoryImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<AppUser?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((user) {
      if (user == null) return null;
      return AppUser(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? user.email?.split('@').first ?? '',
      );
    });
  }

  @override
  AppUser? get currentUser {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? user.email?.split('@').first ?? '',
    );
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user!;
    final displayName = user.displayName ?? user.email?.split('@').first ?? '';

    // Tạo Firestore profile nếu chưa tồn tại
    // (cho user đăng ký trước khi Firestore được setup)
    _firestore.collection('users').doc(user.uid).get().then((doc) {
      if (!doc.exists) {
        _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': (user.email ?? '').toLowerCase(),
          'displayName': displayName,
          'createdAt': FieldValue.serverTimestamp(),
        }).catchError((_) {});
      }
    }).catchError((_) {});

    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: displayName,
    );
  }


  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user!;
    final trimmedName = displayName.trim();

    // Cập nhật displayName — không block nếu lỗi
    user.updateDisplayName(trimmedName).catchError((_) {});

    // Lưu user profile vào Firestore — KHÔNG await (fire-and-forget)
    // Tránh trường hợp Firestore chưa được setup làm treo app
    _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': (user.email ?? '').toLowerCase(),
      'displayName': trimmedName,
      'createdAt': FieldValue.serverTimestamp(),
    }).catchError((_) {
      // Retry trong background nếu lần đầu thất bại
      Future.delayed(const Duration(seconds: 3), () {
        _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': (user.email ?? '').toLowerCase(),
          'displayName': trimmedName,
          'createdAt': FieldValue.serverTimestamp(),
        }).catchError((_) {});
      });
    });

    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: trimmedName,
    );
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}

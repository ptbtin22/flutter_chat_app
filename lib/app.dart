import 'package:flutter/cupertino.dart';
import 'package:flutter_chat_app/core/service_locator.dart';
import 'package:flutter_chat_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_chat_app/features/auth/domain/entities/app_user.dart';
import 'package:flutter_chat_app/features/auth/presentation/mobx/auth_store.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/home/presentation/screens/main_tab_screen.dart';

class ChatDemoApp extends StatelessWidget {
  const ChatDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Chat App',
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(
        primaryColor: CupertinoColors.activeBlue,
        brightness: Brightness.light,
      ),
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUser?>(
      stream: sl<AuthRepository>().authStateChanges,
      builder: (context, snapshot) {
        // Đang chờ kết quả xác thực
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CupertinoPageScaffold(
            child: Center(child: CupertinoActivityIndicator()),
          );
        }

        final user = snapshot.data;

        if (user != null) {
          // Cập nhật AuthStore với user hiện tại
          sl<AuthStore>().setCurrentUser(user);
          return const MainTabScreen();
        }

        return const LoginScreen();
      },
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'features/home/presentation/screens/main_tab_screen.dart';

class ChatDemoApp extends StatelessWidget {
  const ChatDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'Chat App Seminar',
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        primaryColor: CupertinoColors.activeBlue, // standard iOS blue
        brightness: Brightness.light,
      ),
      home: MainTabScreen(),
    );
  }
}

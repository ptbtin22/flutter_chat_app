import 'package:flutter/cupertino.dart';
import 'screens/chat_screen.dart';

class ChatDemoApp extends StatelessWidget {
  const ChatDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    // We use CupertinoApp instead of MaterialApp to get the native iOS look,
    // including navigation transitions, tap effects, and default iOS fonts.
    return const CupertinoApp(
      title: 'Chat App Seminar',
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        primaryColor: CupertinoColors.activeBlue, // standard iOS blue
        brightness: Brightness.light, 
      ),
      home: ChatScreen(),
    );
  }
}

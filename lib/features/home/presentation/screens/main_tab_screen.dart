import 'package:flutter/cupertino.dart';
import '../../../chat/presentation/screens/chat_list_screen.dart';

class MainTabScreen extends StatelessWidget {
  const MainTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chat_bubble_2_fill),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            label: 'Settings',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (context) {
            if (index == 0) {
              return const ChatListScreen();
            } else {
              return const CupertinoPageScaffold(
                navigationBar: CupertinoNavigationBar(
                  middle: Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                child: Center(child: Text('Settings')),
              );
            }
          },
        );
      },
    );
  }
}

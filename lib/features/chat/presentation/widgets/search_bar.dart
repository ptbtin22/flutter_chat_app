import 'package:flutter/cupertino.dart';
import '../../../../core/service_locator.dart';
import '../mobx/chat_list_store.dart';

class ChatSearchBar extends StatelessWidget {
  const ChatSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      child: Row(
        children: [
          Expanded(
            child: CupertinoSearchTextField(
              placeholder: 'Search',
              onChanged: (val) => sl<ChatListStore>().setSearchQuery(val),
            ),
          ),
          const SizedBox(width: 8),
          CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: const Size(32, 32),
            onPressed: () {
              // TODO: Implement new chat action
            },
            child: const Icon(CupertinoIcons.create),
          ),
        ],
      ),
    );
  }
}

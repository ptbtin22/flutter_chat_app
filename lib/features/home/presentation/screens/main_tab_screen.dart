import 'package:flutter/cupertino.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_chat_app/core/service_locator.dart';
import 'package:flutter_chat_app/features/auth/presentation/mobx/auth_store.dart';
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
            icon: Icon(CupertinoIcons.person_crop_circle_fill),
            label: 'Profile',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (context) {
            if (index == 0) {
              return const ChatListScreen();
            } else {
              return const _ProfileTab();
            }
          },
        );
      },
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final authStore = sl<AuthStore>();

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        border: Border(
          bottom: BorderSide(color: CupertinoColors.systemGrey4, width: 0.5),
        ),
      ),
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: SafeArea(
        child: Observer(
          builder: (_) {
            final user = authStore.currentUser;
            return ListView(
              children: [
                const SizedBox(height: 32),

                // Avatar + Name
                Column(
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: CupertinoColors.activeBlue.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          user?.displayName.isNotEmpty == true
                              ? user!.displayName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.activeBlue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.displayName ?? '',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.label,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.secondaryLabel,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Info card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: CupertinoIcons.person,
                        label: 'Tên',
                        value: user?.displayName ?? '',
                      ),
                      Container(height: 0.5, color: CupertinoColors.separator, margin: const EdgeInsets.only(left: 52)),
                      _InfoRow(
                        icon: CupertinoIcons.mail,
                        label: 'Email',
                        value: user?.email ?? '',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Logout button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CupertinoButton(
                    color: CupertinoColors.destructiveRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    onPressed: authStore.isLoading
                        ? null
                        : () async {
                            final confirm = await showCupertinoDialog<bool>(
                              context: context,
                              barrierDismissible: true,
                              builder: (dialogCtx) => CupertinoAlertDialog(
                                title: const Text('Đăng xuất'),
                                content: const Text(
                                    'Bạn có chắc muốn đăng xuất không?'),
                                actions: [
                                  CupertinoDialogAction(
                                    isDestructiveAction: true,
                                    onPressed: () =>
                                        Navigator.of(dialogCtx).pop(true),
                                    child: const Text('Đăng xuất'),
                                  ),
                                  CupertinoDialogAction(
                                    onPressed: () =>
                                        Navigator.of(dialogCtx).pop(false),
                                    child: const Text('Hủy'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await authStore.logout();
                            }
                          },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          CupertinoIcons.square_arrow_left,
                          color: CupertinoColors.destructiveRed,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Đăng xuất',
                          style: TextStyle(
                            color: CupertinoColors.destructiveRed,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: CupertinoColors.activeBlue, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: CupertinoColors.secondaryLabel,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                color: CupertinoColors.label,
                fontSize: 15,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

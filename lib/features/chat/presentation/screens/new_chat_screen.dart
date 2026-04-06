import 'package:flutter/cupertino.dart';
import 'package:flutter_chat_app/core/service_locator.dart';
import 'package:flutter_chat_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_chat_app/features/chat/domain/repositories/chat_repository.dart';
import 'chat_detail_screen.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _startChat() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _errorMessage = 'Vui lòng nhập email.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authRepo = sl<AuthRepository>();
      final currentUser = authRepo.currentUser;
      if (currentUser == null) {
        if (mounted) setState(() { _isLoading = false; _errorMessage = 'Chưa đăng nhập.'; });
        return;
      }

      // Debug log
      print('[NewChat] Searching for email: "$email" (currentUid: ${currentUser.uid})');

      final chatId = await sl<ChatRepository>().findOrCreateChat(
        currentUid: currentUser.uid,
        currentDisplayName: currentUser.displayName,
        otherEmail: email,
      );

      print('[NewChat] Found/created chatId: $chatId');

      if (mounted) {
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(
            builder: (_) => ChatDetailScreen(
              chatId: chatId,
              contactName: email.split('@').first,
            ),
          ),
        );
      }
    } catch (e) {
      print('[NewChat] Error: $e');
      // Phải check mounted TRƯỚC khi setState — tránh crash khi widget đã dispose
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Chat mới'),
        border: Border(
          bottom: BorderSide(color: CupertinoColors.systemGrey4, width: 0.5),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const Text(
                'Nhập email người muốn chat:',
                style: TextStyle(
                  fontSize: 15,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: CupertinoTextField(
                  controller: _emailController,
                  placeholder: 'email@example.com',
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _startChat(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: const BoxDecoration(),
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Icon(
                      CupertinoIcons.at,
                      color: CupertinoColors.secondaryLabel,
                      size: 18,
                    ),
                  ),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.destructiveRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.exclamationmark_circle,
                        color: CupertinoColors.destructiveRed,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: CupertinoColors.destructiveRed,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              CupertinoButton.filled(
                onPressed: _isLoading ? null : _startChat,
                borderRadius: BorderRadius.circular(12),
                child: _isLoading
                    ? const CupertinoActivityIndicator(
                        color: CupertinoColors.white)
                    : const Text(
                        'Bắt đầu chat',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

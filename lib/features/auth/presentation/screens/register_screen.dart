import 'package:flutter/cupertino.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_chat_app/core/service_locator.dart';
import '../mobx/auth_store.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _authStore = sl<AuthStore>();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final name = _displayNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _authStore.errorMessage = 'Vui lòng điền đầy đủ thông tin.';
      return;
    }
    if (password != confirm) {
      _authStore.errorMessage = 'Mật khẩu xác nhận không khớp.';
      return;
    }
    if (password.length < 6) {
      _authStore.errorMessage = 'Mật khẩu phải có ít nhất 6 ký tự.';
      return;
    }

    // Lưu navigator ref TRƯỚC khi await — tránh "use after dispose"
    final navigator = Navigator.of(context);

    final success = await _authStore.register(
      email: email,
      password: password,
      displayName: name,
    );

    if (success) {
      // Pop tất cả routes về root (_AuthGate) để auth gate tự điều hướng
      navigator.popUntil((route) => route.isFirst);
    }
  }


  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Tạo tài khoản'),
        border: Border(
          bottom: BorderSide(color: CupertinoColors.systemGrey4, width: 0.5),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
          child: Observer(
            builder: (_) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),

                // Icon
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: CupertinoColors.activeBlue,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      CupertinoIcons.person_add_solid,
                      color: CupertinoColors.white,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Form
                Container(
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBackground,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      _buildField(
                        controller: _displayNameController,
                        placeholder: 'Tên hiển thị',
                        icon: CupertinoIcons.person,
                        textInputAction: TextInputAction.next,
                        hasBorder: true,
                      ),
                      _buildField(
                        controller: _emailController,
                        placeholder: 'Email',
                        icon: CupertinoIcons.mail,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        hasBorder: true,
                      ),
                      _buildField(
                        controller: _passwordController,
                        placeholder: 'Mật khẩu',
                        icon: CupertinoIcons.lock,
                        obscure: _obscurePassword,
                        textInputAction: TextInputAction.next,
                        hasBorder: true,
                        suffixIcon: GestureDetector(
                          onTap: () => setState(() {
                            _obscurePassword = !_obscurePassword;
                          }),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Icon(
                              _obscurePassword
                                  ? CupertinoIcons.eye
                                  : CupertinoIcons.eye_slash,
                              color: CupertinoColors.secondaryLabel,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      _buildField(
                        controller: _confirmPasswordController,
                        placeholder: 'Xác nhận mật khẩu',
                        icon: CupertinoIcons.lock_shield,
                        obscure: _obscureConfirm,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _handleRegister(),
                        hasBorder: false,
                        suffixIcon: GestureDetector(
                          onTap: () => setState(() {
                            _obscureConfirm = !_obscureConfirm;
                          }),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Icon(
                              _obscureConfirm
                                  ? CupertinoIcons.eye
                                  : CupertinoIcons.eye_slash,
                              color: CupertinoColors.secondaryLabel,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Error message
                if (_authStore.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
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
                            _authStore.errorMessage!,
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
                  onPressed: _authStore.isLoading ? null : _handleRegister,
                  borderRadius: BorderRadius.circular(12),
                  child: _authStore.isLoading
                      ? const CupertinoActivityIndicator(
                          color: CupertinoColors.white)
                      : const Text(
                          'Tạo tài khoản',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),

                const SizedBox(height: 16),

                CupertinoButton(
                  onPressed:
                      _authStore.isLoading ? null : () => Navigator.pop(context),
                  child: const Text(
                    'Đã có tài khoản? Đăng nhập',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String placeholder,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
    TextInputAction? textInputAction,
    ValueChanged<String>? onSubmitted,
    bool hasBorder = false,
    Widget? suffixIcon,
  }) {
    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      keyboardType: keyboardType,
      obscureText: obscure,
      autocorrect: false,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: hasBorder
            ? const Border(
                bottom: BorderSide(
                  color: CupertinoColors.separator,
                  width: 0.5,
                ),
              )
            : null,
      ),
      prefix: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Icon(
          icon,
          color: CupertinoColors.secondaryLabel,
          size: 20,
        ),
      ),
      suffix: suffixIcon,
    );
  }
}

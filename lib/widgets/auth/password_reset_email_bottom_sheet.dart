import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';
import '../../gradients.dart';
import '../../utils/error_handler.dart';
import '../../utils/text_selection_menu_builder.dart';

class PasswordResetEmailBottomSheet extends StatefulWidget {
  final VoidCallback? onEmailSent;

  const PasswordResetEmailBottomSheet({super.key, this.onEmailSent});

  @override
  State<PasswordResetEmailBottomSheet> createState() =>
      _PasswordResetEmailBottomSheetState();
}

class _PasswordResetEmailBottomSheetState
    extends State<PasswordResetEmailBottomSheet> {
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _supabaseService = SupabaseService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.removeListener(_onFocusChange);
    _emailFocusNode.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      AppErrorHandler.handleError(
        context,
        'メールアドレスを入力してください',
        operation: 'パスワードリセット',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _supabaseService.resetPassword(email: email);

      if (mounted) {
        AppErrorHandler.showSuccess(
          context,
          'パスワードリセット用のメールを送信しました。メールをご確認ください。',
          duration: const Duration(seconds: 5),
        );
        widget.onEmailSent?.call();
      }
    } catch (error) {
      if (mounted) {
        AppErrorHandler.handleError(
          context,
          error,
          operation: 'パスワードリセットメール送信',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    final hasFocus = _emailFocusNode.hasFocus;

    double modalHeight;
    if (viewInsets > 0 || hasFocus) {
      modalHeight = screenHeight * 0.9;
    } else {
      modalHeight = screenHeight * 0.45;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      height: modalHeight,
      decoration: const BoxDecoration(
        color: Color(0xFF2B2B2B),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // ハンドル
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 60,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // コンテンツ
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: _buildResetForm(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        // 説明テキスト
        Text(
          'パスワードをリセットするには、登録したメールアドレスを入力してください。',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),

        // メールアドレス入力
        const Text(
          'メールアドレス',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF3A3A3A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[600]!),
          ),
          child: TextField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'example@email.com',
              hintStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
              prefixIcon: Icon(Icons.email_outlined, color: Colors.grey),
            ),
            contextMenuBuilder: nativeTextSelectionMenuBuilder,
          ),
        ),
        const SizedBox(height: 32),

        // 送信ボタン
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: createHorizontalOrangeYellowGradient(),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _sendResetEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child:
                _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                      'リセットメールを送信',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

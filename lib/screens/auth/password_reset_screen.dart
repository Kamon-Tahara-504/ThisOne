import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';
import '../../gradients.dart';
import '../../utils/error_handler.dart';
import '../../utils/text_selection_menu_builder.dart';

/// パスワードリセット画面
///
/// パスワードリセットのディープリンクからアプリが起動された後に表示される画面。
/// 新しいパスワードを入力してパスワードを更新する。
class PasswordResetScreen extends StatefulWidget {
  final VoidCallback? onPasswordResetComplete;

  const PasswordResetScreen({super.key, this.onPasswordResetComplete});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _supabaseService = SupabaseService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password.isEmpty) {
      AppErrorHandler.handleError(
        context,
        '新しいパスワードを入力してください',
        operation: 'パスワード更新',
      );
      return;
    }

    if (password.length < 6) {
      AppErrorHandler.handleError(
        context,
        'パスワードは6文字以上で入力してください',
        operation: 'パスワード更新',
      );
      return;
    }

    if (password != confirmPassword) {
      AppErrorHandler.handleError(
        context,
        'パスワードが一致しません',
        operation: 'パスワード確認',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _supabaseService.updatePassword(newPassword: password);

      if (mounted) {
        AppErrorHandler.showSuccess(
          context,
          'パスワードを更新しました。',
          duration: const Duration(seconds: 3),
        );
        // コールバックを呼び出し
        widget.onPasswordResetComplete?.call();
        // 前の画面に戻る（またはホーム画面に遷移）
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (mounted) {
        AppErrorHandler.handleError(
          context,
          error,
          operation: 'パスワード更新',
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
    return Scaffold(
      backgroundColor: const Color(0xFF2B2B2B),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56.0),
        child: Container(
          color: const Color(0xFF2B2B2B),
          child: SafeArea(
            bottom: false,
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  // 戻るボタン
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // タイトル
                  const Text(
                    'パスワード再設定',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // グラデーションガイドライン
          Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: createHorizontalOrangeYellowGradient(),
            ),
          ),

          // メインコンテンツ
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // 説明テキスト
                  Text(
                    '新しいパスワードを入力してください。',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 新しいパスワード入力
                  const Text(
                    '新しいパスワード',
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
                      controller: _passwordController,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 16),
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: '6文字以上で入力',
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                        prefixIcon: const Icon(
                          Icons.lock_outlined,
                          color: Colors.grey,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      contextMenuBuilder: nativeTextSelectionMenuBuilder,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // パスワード確認入力
                  const Text(
                    'パスワード確認',
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
                      controller: _confirmPasswordController,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 16),
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        hintText: 'パスワードを再入力',
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                        prefixIcon: const Icon(
                          Icons.lock_outlined,
                          color: Colors.grey,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      contextMenuBuilder: nativeTextSelectionMenuBuilder,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 更新ボタン
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: createHorizontalOrangeYellowGradient(),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updatePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                          _isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text(
                                'パスワードを更新',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

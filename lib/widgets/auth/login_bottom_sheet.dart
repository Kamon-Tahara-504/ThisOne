import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';
import '../../gradients.dart';
import '../../utils/error_handler.dart';
import '../../utils/text_selection_menu_builder.dart';
import 'google_signin_button.dart';
import 'x_signin_button.dart';
import 'disabled_auth_button.dart';

class LoginBottomSheet extends StatefulWidget {
  final VoidCallback? onLoginSuccess;

  const LoginBottomSheet({super.key, this.onLoginSuccess});

  @override
  State<LoginBottomSheet> createState() => _LoginBottomSheetState();
}

class _LoginBottomSheetState extends State<LoginBottomSheet> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _supabaseService = SupabaseService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _showEmailLogin = false;

  @override
  void initState() {
    super.initState();
    // フォーカスリスナーを追加（UI更新のため）
    _emailFocusNode.addListener(_onFocusChange);
    _passwordFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    // フォーカス変更時にUIを更新
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.removeListener(_onFocusChange);
    _passwordFocusNode.removeListener(_onFocusChange);
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loginWithEmail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _supabaseService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        AppErrorHandler.showSuccess(context, 'ログインしました！');
        widget.onLoginSuccess?.call();
      }
    } catch (error) {
      if (mounted) {
        AppErrorHandler.handleError(context, error, operation: 'ログイン');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // TODO: 開発中の機能 - 今後実装予定
  // ignore: unused_element
  Future<void> _loginWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _supabaseService.signInWithGoogle();
      if (mounted) {
        if (success) {
          AppErrorHandler.showSuccess(context, 'Googleでログインしました！');
          widget.onLoginSuccess?.call();
        } else {
          AppErrorHandler.showInfo(context, 'Google認証がキャンセルされました');
        }
      }
    } catch (error) {
      if (mounted) {
        AppErrorHandler.handleError(context, error, operation: 'Google認証');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // TODO: 開発中の機能 - 今後実装予定
  // ignore: unused_element
  Future<void> _loginWithX() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _supabaseService.signInWithTwitter();
      if (mounted) {
        if (success) {
          AppErrorHandler.showSuccess(context, 'Xでログインしました！');
          widget.onLoginSuccess?.call();
        } else {
          AppErrorHandler.showInfo(context, 'X認証がキャンセルされました');
        }
      }
    } catch (error) {
      if (mounted) {
        AppErrorHandler.handleError(context, error, operation: 'X認証');
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
    // キーボードの高さを検知
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    // フォーカス状態を取得（キーボード表示を予測するため）
    final hasFocus = _emailFocusNode.hasFocus || _passwordFocusNode.hasFocus;

    // モーダルの高さを計算
    double modalHeight;
    if (_showEmailLogin) {
      // メールログイン画面: フォーカスがあるか、キーボードが表示されている場合は大きくする
      // フォーカスがある場合はキーボードが表示されることが予測できるので、即座に高さを大きくする
      if (viewInsets > 0 || hasFocus) {
        modalHeight = screenHeight * 0.9;
      } else {
        modalHeight = screenHeight * 0.55;
      }
    } else {
      // ログイン選択画面: キーボードが表示されている場合は利用可能な高さを考慮
      // キーボードが表示されていない場合は固定で35%
      final availableHeight = screenHeight - viewInsets;
      final desiredHeight = screenHeight * 0.35;
      // 利用可能な高さを超えないようにする
      modalHeight =
          desiredHeight <= availableHeight ? desiredHeight : availableHeight;
    }

    return AnimatedContainer(
      duration: const Duration(
        milliseconds: 150,
      ), // アニメーション時間を短縮（300ms → 150ms）
      curve: Curves.easeOut, // easeInOut → easeOutに変更（より早く反応）
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
          // ハンドル（視覚的な要素として残すが、ドラッグ機能はなし）
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
              child:
                  _showEmailLogin
                      ? _buildEmailLoginForm()
                      : _buildLoginOptions(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginOptions() {
    return Column(
      children: [
        const SizedBox(height: 20),

        // メールログインボタン
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: createHorizontalOrangeYellowGradient(),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ElevatedButton(
            onPressed:
                _isLoading
                    ? null
                    : () {
                      setState(() {
                        _showEmailLogin = true;
                      });
                    },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.email_outlined, color: Colors.white, size: 22),
                SizedBox(width: 12),
                Text(
                  'メールアドレスでログイン',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Googleログインボタン - ブランディングガイドライン準拠（開発中）
        DisabledAuthButton(
          button: GoogleSignInButton(
            onPressed: null, // 無効化
            text: "Googleでログイン",
            borderRadius: 12.0,
          ),
        ),
        const SizedBox(height: 16),

        // Xログインボタン - ブランディングガイドライン準拠（開発中）
        DisabledAuthButton(
          button: XSignInButton(
            onPressed: null, // 無効化
            text: "Xでログイン",
            borderRadius: 12.0,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEmailLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 戻るボタン
        TextButton.icon(
          onPressed: () {
            setState(() {
              _showEmailLogin = false;
            });
          },
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 16),
          label: const Text(
            '戻る',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
        const SizedBox(height: 20),

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
        const SizedBox(height: 20),

        // パスワード入力
        const Text(
          'パスワード',
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
            focusNode: _passwordFocusNode,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText: 'パスワードを入力',
              hintStyle: const TextStyle(color: Colors.grey),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              prefixIcon: const Icon(Icons.lock_outlined, color: Colors.grey),
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
        const SizedBox(height: 32),

        // ログインボタン
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: createHorizontalOrangeYellowGradient(),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _loginWithEmail,
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
                      'ログイン',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
          ),
        ),
        const SizedBox(height: 20),

        // パスワードを忘れた方
        Center(
          child: TextButton(
            onPressed: () {
              // パスワードリセット機能の実装
              AppErrorHandler.showInfo(context, 'パスワードリセット機能は準備中です');
            },
            child: Text(
              'パスワードを忘れた方',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

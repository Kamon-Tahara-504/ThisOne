import 'package:flutter/material.dart';
import '../../gradients.dart';
import '../../services/supabase_service.dart';
import '../../services/local_user_service.dart';
import '../../utils/error_handler.dart';
import '../../utils/phone_validator.dart';
import '../../widgets/account/not_logged_in_view.dart';
import '../../widgets/account/logged_in_view.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final LocalUserService _localUserService = LocalUserService();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = true;
  bool _isEditing = false;
  Map<String, dynamic>? _userProfile;
  String? _phoneErrorText;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = _supabaseService.getCurrentUser();
      if (user == null) {
        setState(() {
          _userProfile = null;
          _displayNameController.clear();
          _phoneController.clear();
          _isLoading = false;
        });
        return;
      }

      var profile = await _localUserService.getUser(user.id);

      // プロフィールが存在しない場合は初期レコードを作成
      if (profile == null) {
        await _localUserService.upsertUser(authId: user.id);
        profile = await _localUserService.getUser(user.id);
      }

      setState(() {
        _userProfile = profile;
        _displayNameController.text = profile?['display_name'] ?? '';
        _phoneController.text = profile?['phone_number'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_isEditing) return;

    try {
      final user = _supabaseService.getCurrentUser();
      if (user == null) {
        return;
      }

      final displayName = _displayNameController.text.trim();
      final phoneInput = _phoneController.text.trim();

      // 電話番号のバリデーション
      final phoneValidation = PhoneValidator.validate(phoneInput);
      if (!phoneValidation.isValid) {
        setState(() {
          _phoneErrorText = phoneValidation.errorMessage;
        });
        return;
      }

      // 正規化された電話番号を使用（空の場合はnull）
      final phoneNumber = phoneValidation.normalizedValue;

      await _localUserService.upsertUser(
        authId: user.id,
        displayName: displayName,
        phoneNumber: phoneNumber,
      );

      setState(() {
        _isEditing = false;
        _phoneErrorText = null;
        _userProfile = {
          'auth_id': user.id,
          'display_name': displayName,
          'phone_number': phoneNumber,
        };
      });

      if (mounted) {
        AppErrorHandler.showSuccess(context, 'プロフィールを更新しました');
      }

      await _loadUserProfile();
    } catch (e) {
      if (mounted) {
        AppErrorHandler.handleError(context, e, operation: 'プロフィールの更新');
      }
    }
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _phoneErrorText = null;
      _displayNameController.text = _userProfile?['display_name'] ?? '';
      _phoneController.text = _userProfile?['phone_number'] ?? '';
    });
  }

  void _handleLogout() {
    if (mounted) {
      Navigator.pop(context); // アカウント画面を閉じる
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _supabaseService.getCurrentUser();

    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFF2B2B2B),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          statusBarHeight + 56.0,
        ), // StatusBar + 4 + 52
        child: Container(
          color: const Color(0xFF2B2B2B),
          child: SafeArea(
            bottom: false,
            child: Container(
              height: 52,
              margin: const EdgeInsets.only(top: 4.0), // baseOffsetと同じ
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 1.0,
              ),
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
                    'アカウント',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  // アクションボタン
                  if (user != null && !_isEditing)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = true;
                          _phoneErrorText = null;
                        });
                      },
                      child: const Text(
                        '編集',
                        style: TextStyle(
                          color: Color(0xFFE85A3B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (_isEditing) ...[
                    TextButton(
                      onPressed: _cancelEdit,
                      child: Text(
                        'キャンセル',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _updateProfile,
                      child: const Text(
                        '保存',
                        style: TextStyle(
                          color: Color(0xFFE85A3B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
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
            child:
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFE85A3B),
                      ),
                    )
                    : user == null
                    ? NotLoggedInView(onLoginSuccess: _loadUserProfile)
                    : LoggedInView(
                      user: user,
                      userProfile: _userProfile,
                      isEditing: _isEditing,
                      displayNameController: _displayNameController,
                      phoneController: _phoneController,
                      onLogout: _handleLogout,
                      phoneErrorText: _phoneErrorText,
                    ),
          ),
        ],
      ),
    );
  }
}

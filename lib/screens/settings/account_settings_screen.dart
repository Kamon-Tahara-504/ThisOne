import 'package:flutter/material.dart';
import '../../gradients.dart';
import '../../services/supabase_service.dart';
import '../../widgets/account/not_logged_in_view.dart';
import '../../widgets/account/logged_in_view.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = true;
  bool _isEditing = false;
  Map<String, dynamic>? _userProfile;

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
      final profile = await _supabaseService.getUserProfile();
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
      await _supabaseService.updateUserProfile(
        displayName: _displayNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );

      setState(() {
        _isEditing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('プロフィールを更新しました')));
      }

      await _loadUserProfile();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('プロフィールの更新に失敗しました: $e')));
      }
    }
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
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
                    ),
          ),
        ],
      ),
    );
  }
}

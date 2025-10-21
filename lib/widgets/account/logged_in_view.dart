import 'package:flutter/material.dart';
import '../../gradients.dart';
import 'account_info_item.dart';
import 'logout_dialog.dart';
import '../../services/supabase_service.dart';

class LoggedInView extends StatelessWidget {
  final dynamic user;
  final Map<String, dynamic>? userProfile;
  final bool isEditing;
  final TextEditingController displayNameController;
  final TextEditingController phoneController;
  final VoidCallback onLogout;

  const LoggedInView({
    super.key,
    required this.user,
    required this.userProfile,
    required this.isEditing,
    required this.displayNameController,
    required this.phoneController,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // プロフィールカード
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF3A3A3A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[700]!),
            ),
            child: Column(
              children: [
                // アバター
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: createOrangeYellowGradient(),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                // 表示名
                if (isEditing)
                  TextField(
                    controller: displayNameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'ユーザーネーム',
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[600]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE85A3B)),
                      ),
                    ),
                  )
                else
                  Text(
                    userProfile?['display_name']?.isEmpty == false
                        ? userProfile!['display_name']
                        : 'ユーザーネーム未設定',
                    style: TextStyle(
                      color:
                          userProfile?['display_name']?.isEmpty == false
                              ? Colors.white
                              : Colors.grey[500],
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // アカウント情報セクション
          const Text(
            'アカウント情報',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // メールアドレス
          AccountInfoItem(
            icon: Icons.email,
            title: 'メールアドレス',
            value: user.email ?? '未設定',
            isEditable: false,
            isEditing: false,
          ),

          // 電話番号
          AccountInfoItem(
            icon: Icons.phone,
            title: '電話番号',
            value:
                isEditing
                    ? null
                    : (userProfile?['phone_number']?.isEmpty == false
                        ? userProfile!['phone_number']
                        : '未設定'),
            isEditable: true,
            isEditing: isEditing,
            controller: isEditing ? phoneController : null,
          ),

          // ログイン済み表示
          AccountInfoItem(
            icon: Icons.verified_user,
            title: '認証状態',
            value: 'ログイン済み',
            valueColor: const Color(0xFFE85A3B),
            isEditable: false,
            isEditing: false,
          ),

          const SizedBox(height: 32),

          // ログアウトボタン
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(Icons.logout, color: Colors.red[400]),
              title: Text(
                'ログアウト',
                style: TextStyle(
                  color: Colors.red[400],
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                showLogoutDialog(
                  context: context,
                  supabaseService: SupabaseService(),
                  onLogoutSuccess: onLogout,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

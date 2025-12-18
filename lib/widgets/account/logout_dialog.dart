import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';
import '../../utils/error_handler.dart';

Future<void> showLogoutDialog({
  required BuildContext context,
  required SupabaseService supabaseService,
  required VoidCallback onLogoutSuccess,
}) {
  return showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          backgroundColor: const Color(0xFF3A3A3A),
          title: const Text('ログアウト', style: TextStyle(color: Colors.white)),
          content: const Text(
            'ログアウトしますか？\nローカルのデータは保持されます。',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('キャンセル', style: TextStyle(color: Colors.grey[400])),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.red[400],
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  navigator.pop();
                  try {
                    await supabaseService.signOut();
                    if (!context.mounted) return;
                    AppErrorHandler.showSuccess(context, 'ログアウトしました');
                    onLogoutSuccess();
                  } catch (e) {
                    if (!context.mounted) return;
                    AppErrorHandler.handleError(context, e, operation: 'ログアウト');
                  }
                },
                child: const Text(
                  'ログアウト',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
  );
}

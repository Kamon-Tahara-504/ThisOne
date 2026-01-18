import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';
import '../../services/local_task_service.dart';
import '../../services/local_memo_service.dart';
import '../../services/local_schedule_service.dart';
import '../../utils/error_handler.dart';
import '../../utils/text_selection_menu_builder.dart';

/// アカウント削除ダイアログと削除処理を提供
class AccountDeletionDialog {
  /// アカウント削除のフロー全体を実行
  ///
  /// [context] BuildContext
  /// [userEmail] 現在ログインしているユーザーのメールアドレス
  /// [onDeletionStart] 削除処理開始時のコールバック（オプション）
  /// [onDeletionComplete] 削除完了時のコールバック（オプション）
  static Future<void> showAccountDeletionDialog({
    required BuildContext context,
    required String userEmail,
    VoidCallback? onDeletionStart,
    VoidCallback? onDeletionComplete,
  }) async {
    // 1. メールアドレス確認ダイアログを表示
    final emailConfirmed = await _showEmailConfirmationDialog(
      context,
      userEmail,
    );
    if (!emailConfirmed) return;

    // 2. 確認ダイアログを表示
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF3A3A3A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'アカウントを削除',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'アカウントとすべてのデータが完全に削除されます。\n\nこの操作は取り消せません。本当に削除しますか？',
          style: TextStyle(color: Colors.grey[300], fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'キャンセル',
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'アカウントを削除',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (!context.mounted || confirmed != true) return;

    // 3. 削除処理開始のコールバックを実行
    if (context.mounted && onDeletionStart != null) {
      onDeletionStart();
    }

    // 4. 削除処理を実行
    await _executeAccountDeletion(context);

    // 5. 削除完了のコールバックを実行
    if (context.mounted && onDeletionComplete != null) {
      onDeletionComplete();
    }
  }

  /// メールアドレス確認ダイアログを表示
  static Future<bool> _showEmailConfirmationDialog(
    BuildContext context,
    String userEmail,
  ) async {
    final emailController = TextEditingController();
    String? errorMessage;

    try {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            backgroundColor: const Color(0xFF3A3A3A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'メールアドレスを確認',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'アカウントを削除するには、現在ログインしているアカウントのメールアドレスを入力してください。',
                  style: TextStyle(color: Colors.grey[300], fontSize: 14),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'メールアドレス',
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    hintText: 'メールアドレスを入力',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    errorText: errorMessage,
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
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                  ),
                  contextMenuBuilder: nativeTextSelectionMenuBuilder,
                  onSubmitted: (value) {
                    if (value.trim().toLowerCase() ==
                        userEmail.toLowerCase()) {
                      Navigator.pop(context, true);
                    } else {
                      setState(() {
                        errorMessage = 'メールアドレスが一致しません';
                      });
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'キャンセル',
                  style: TextStyle(color: Colors.grey[400], fontSize: 16),
                ),
              ),
              TextButton(
                onPressed: () {
                  final inputEmail = emailController.text.trim().toLowerCase();
                  final currentEmail = userEmail.toLowerCase();

                  if (inputEmail.isEmpty) {
                    setState(() {
                      errorMessage = 'メールアドレスを入力してください';
                    });
                    return;
                  }

                  if (inputEmail != currentEmail) {
                    setState(() {
                      errorMessage = 'メールアドレスが一致しません';
                    });
                    return;
                  }

                  Navigator.pop(context, true);
                },
                child: const Text(
                  '確認',
                  style: TextStyle(
                    color: Color(0xFFE85A3B),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      return result ?? false;
    } finally {
      // ダイアログが完全に閉じられた後にdispose()を呼ぶ
      // 次のフレームで実行することで、TextFieldが完全に破棄されるのを待つ
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          emailController.dispose();
        } catch (e) {
          // 既にdispose()されている場合は無視
        }
      });
    }
  }

  /// アカウント削除処理を実行
  static Future<void> _executeAccountDeletion(BuildContext context) async {
    try {
      final supabaseService = SupabaseService();
      final taskService = LocalTaskService();
      final memoService = LocalMemoService();
      final scheduleService = LocalScheduleService();

      // ユーザーIDを取得
      final currentUser = supabaseService.getCurrentUser();
      if (currentUser == null) {
        if (context.mounted) {
          AppErrorHandler.handleError(
            context,
            Exception('ユーザー情報を取得できませんでした'),
            operation: 'アカウントの削除',
          );
        }
        return;
      }
      final userId = currentUser.id;

      // Supabaseのアカウントを削除（サーバー側のデータも削除される）
      await supabaseService.deleteAccount();

      // ローカルデータベースのデータも削除
      await taskService.permanentlyDeleteAllTasks(userId);
      await memoService.permanentlyDeleteAllMemos(userId);
      await scheduleService.permanentlyDeleteAllSchedules(userId);

      if (!context.mounted) return;

      // サインアウト
      await supabaseService.signOut();

      if (!context.mounted) return;

      AppErrorHandler.showSuccess(context, 'アカウントを削除しました');

      // アカウント削除後はログイン画面に遷移
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (context.mounted) {
        AppErrorHandler.handleError(context, e, operation: 'アカウントの削除');
      }
    }
  }
}

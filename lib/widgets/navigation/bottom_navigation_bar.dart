import 'package:flutter/material.dart';
import '../../gradients.dart';
import '../../services/supabase_service.dart';
import '../task/task_dialog.dart';
import '../memo/memo_dialog.dart';

class BottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabChanged;
  final PageController pageController;
  final SupabaseService supabaseService;
  final Function(Map<String, dynamic>) onTaskCreate;
  final Function(String, String, String) onMemoCreated;
  final VoidCallback? onScheduleCreate; // スケジュール作成コールバックを追加

  const BottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
    required this.pageController,
    required this.supabaseService,
    required this.onTaskCreate,
    required this.onMemoCreated,
    this.onScheduleCreate, // スケジュール作成コールバックを追加
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2B2B2B), // 黒背景
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // グラデーションガイドライン（上部）
          Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: createHorizontalOrangeYellowGradient(),
            ),
          ),
          // ナビゲーションバー本体
          Container(
            color: const Color(0xFF2B2B2B),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20), // 下部に余白を追加して上に上げる効果
                child: SizedBox(
                  height: 60,
                  child: Row(
                    children: [
                      _buildNavItem(context, 0, Icons.task_alt, 'タスク'),
                      _buildNavItem(context, 1, Icons.calendar_today, 'カレンダー'),
                      _buildCreateButton(context),
                      _buildNavItem(context, 3, Icons.note_alt, 'メモ'),
                      _buildNavItem(context, 4, Icons.settings, '設定'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData icon,
    String label,
  ) {
    final isSelected = currentIndex == index;
    return Expanded(
      child: Transform.translate(
        offset: const Offset(0, 8), // ページボタンを8px下に移動
        child: GestureDetector(
          onTap: () {
            // 作成ボタン（index 2）の場合はページ遷移しない
            if (index == 2) {
              return;
            }

            // onTabChangedを呼び出すだけでOK
            // AppPageController.navigateToTabが適切に処理する
            onTabChanged(index);
          },
          child: Container(
            color: Colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShaderMask(
                  shaderCallback:
                      (bounds) =>
                          isSelected
                              ? createHorizontalOrangeYellowGradient()
                                  .createShader(bounds)
                              : LinearGradient(
                                colors: [Colors.grey[500]!, Colors.grey[500]!],
                              ).createShader(bounds),
                  child: Icon(icon, size: 24, color: Colors.white),
                ),
                const SizedBox(height: 4),
                ShaderMask(
                  shaderCallback:
                      (bounds) =>
                          isSelected
                              ? createHorizontalOrangeYellowGradient()
                                  .createShader(bounds)
                              : LinearGradient(
                                colors: [Colors.grey[500]!, Colors.grey[500]!],
                              ).createShader(bounds),
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreateButton(BuildContext context) {
    return Expanded(
      child: Transform.translate(
        offset: const Offset(0, 8), // 作成ボタンの位置を調整
        child: GestureDetector(
          onTap: () {
            // 作成ボタンのアクション（現在アクティブなタブに応じて）
            if (currentIndex == 0) {
              // タスク作成（TaskScreenに委譲）
              _showCreateTaskDialog(context);
            } else if (currentIndex == 1) {
              // スケジュール作成（ScheduleScreenに委譲）
              _showCreateScheduleDialog(context);
            } else if (currentIndex == 3) {
              // メモ作成（MemoScreenに委譲）
              _showCreateMemoDialog(context);
            }
          },
          child: Container(
            width: 60, // さらに少し大きくしてはみ出し効果を強調
            height: 60,
            decoration: BoxDecoration(
              gradient: createOrangeYellowGradient(),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(
                    0xFFE85A3B,
                  ).withValues(alpha: 0.4), // 影を少し濃く
                  blurRadius: 12, // 影を大きく
                  offset: const Offset(0, 4), // 影の位置も調整
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2), // 追加の影で立体感
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.add,
              color: Color(0xFF2B2B2B), // UIデザインで使われている黒色に変更
              size: 34, // アイコンサイズも少し大きく
            ),
          ),
        ),
      ),
    );
  }

  void _showCreateTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder:
          (context) => TaskDialog(
            onAdd: (taskData) {
              Navigator.pop(context); // ダイアログを閉じる
              onTaskCreate(taskData);
            },
          ),
    );
  }

  void _showCreateScheduleDialog(BuildContext context) {
    // スケジュール作成ボトムシートを呼び出し
    if (onScheduleCreate != null) {
      onScheduleCreate!();
    }
  }

  void _showCreateMemoDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder:
          (context) => MemoDialog(
            onMemoCreated: (title, mode, colorHex) {
              Navigator.pop(context); // ダイアログを閉じる
              onMemoCreated(title, mode, colorHex);
            },
          ),
    );
  }
}

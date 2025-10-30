import 'package:flutter/material.dart';
import '../../gradients.dart';
import '../../services/settings_service.dart';
import '../../widgets/settings/settings_toggle_item.dart';
import '../../widgets/settings/settings_selection_item.dart';

/// 通知設定画面
///
/// 機能:
/// - プッシュ通知の有効/無効設定
/// - 通知音の有効/無効設定
/// - タスクリマインダーの有効/無効設定
/// - 期限切れタスクの通知設定
/// - スケジュール通知の有効/無効設定
/// - おやすみモード（通知時間帯制限）の設定
/// - 時刻選択ダイアログ
/// - 設定のリセット機能
///
/// 画面構成:
/// - 基本設定セクション（プッシュ通知、通知音）
/// - タスク通知セクション（リマインダー、期限切れ通知）
/// - スケジュール通知セクション
/// - 通知時間帯制限セクション（おやすみモード）
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final SettingsService _settingsService = SettingsService();

  bool _notificationsEnabled = true;
  bool _notificationSoundEnabled = true;
  bool _taskRemindersEnabled = true;
  bool _overdueTaskNotifications = true;
  bool _scheduleNotificationsEnabled = true;
  bool _quietHoursEnabled = false;
  String _quietHoursStart = '22:00';
  String _quietHoursEnd = '08:00';

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// 設定画面の初期化時に設定値を読み込む
  Future<void> _loadSettings() async {
    await _settingsService.initialize();

    final notificationsEnabled =
        await _settingsService.getNotificationsEnabled();
    final notificationSoundEnabled =
        await _settingsService.getNotificationSoundEnabled();
    final taskRemindersEnabled =
        await _settingsService.getTaskRemindersEnabled();
    final overdueTaskNotifications =
        await _settingsService.getOverdueTaskNotifications();
    final scheduleNotificationsEnabled =
        await _settingsService.getScheduleNotificationsEnabled();
    final quietHoursEnabled = await _settingsService.getQuietHoursEnabled();
    final quietHoursStart = await _settingsService.getQuietHoursStart();
    final quietHoursEnd = await _settingsService.getQuietHoursEnd();

    setState(() {
      _notificationsEnabled = notificationsEnabled;
      _notificationSoundEnabled = notificationSoundEnabled;
      _taskRemindersEnabled = taskRemindersEnabled;
      _overdueTaskNotifications = overdueTaskNotifications;
      _scheduleNotificationsEnabled = scheduleNotificationsEnabled;
      _quietHoursEnabled = quietHoursEnabled;
      _quietHoursStart = quietHoursStart;
      _quietHoursEnd = quietHoursEnd;
      _isLoading = false;
    });
  }

  /// 設定値を更新し、SharedPreferencesに保存する
  ///
  /// [key] 設定のキー
  /// [value] 新しい値
  /// [updateState] UIの状態を更新するコールバック
  Future<void> _updateSetting<T>(
    String key,
    T value,
    VoidCallback updateState,
  ) async {
    updateState();

    try {
      switch (key) {
        case 'notifications':
          await _settingsService.setNotificationsEnabled(value as bool);
          break;
        case 'sound':
          await _settingsService.setNotificationSoundEnabled(value as bool);
          break;
        case 'taskReminders':
          await _settingsService.setTaskRemindersEnabled(value as bool);
          break;
        case 'overdue':
          await _settingsService.setOverdueTaskNotifications(value as bool);
          break;
        case 'schedule':
          await _settingsService.setScheduleNotificationsEnabled(value as bool);
          break;
        case 'quietHours':
          await _settingsService.setQuietHoursEnabled(value as bool);
          break;
        case 'quietStart':
          await _settingsService.setQuietHoursStart(value as String);
          break;
        case 'quietEnd':
          await _settingsService.setQuietHoursEnd(value as String);
          break;
      }
    } catch (e) {
      // エラーが発生した場合は元に戻す
      setState(() {
        _loadSettings();
      });
    }
  }

  /// 時刻選択ダイアログを表示し、おやすみモードの時刻を設定する
  ///
  /// [type] 'start' または 'end' を指定
  Future<void> _selectTime(String type) async {
    final currentTime = type == 'start' ? _quietHoursStart : _quietHoursEnd;
    final parts = currentTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFE85A3B),
              onPrimary: Colors.white,
              surface: Color(0xFF3A3A3A),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      final timeString =
          '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';

      if (type == 'start') {
        await _updateSetting('quietStart', timeString, () {
          setState(() {
            _quietHoursStart = timeString;
          });
        });
      } else {
        await _updateSetting('quietEnd', timeString, () {
          setState(() {
            _quietHoursEnd = timeString;
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFF2B2B2B),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(statusBarHeight + 56.0),
        child: Container(
          color: const Color(0xFF2B2B2B),
          child: SafeArea(
            bottom: false,
            child: Container(
              height: 52,
              margin: const EdgeInsets.only(top: 4.0),
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 1.0,
              ),
              child: Row(
                children: [
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
                  const Text(
                    '通知設定',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      await _settingsService.resetNotificationSettings();
                      await _loadSettings();
                    },
                    child: const Text(
                      'リセット',
                      style: TextStyle(
                        color: Color(0xFFE85A3B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
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
                    : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 基本設定セクション
                          _buildSectionHeader('基本設定'),
                          const SizedBox(height: 12),

                          SettingsToggleItem(
                            icon: Icons.notifications,
                            title: 'プッシュ通知',
                            subtitle: 'アプリからの通知を受け取る',
                            value: _notificationsEnabled,
                            onChanged:
                                (value) =>
                                    _updateSetting('notifications', value, () {
                                      setState(() {
                                        _notificationsEnabled = value;
                                      });
                                    }),
                          ),

                          SettingsToggleItem(
                            icon: Icons.volume_up,
                            title: '通知音',
                            subtitle: '通知時に音を鳴らす',
                            value: _notificationSoundEnabled,
                            enabled: _notificationsEnabled,
                            onChanged:
                                (value) => _updateSetting('sound', value, () {
                                  setState(() {
                                    _notificationSoundEnabled = value;
                                  });
                                }),
                          ),

                          const SizedBox(height: 24),

                          // ツール通知セクション（タスク通知 + スケジュール通知を統合）
                          _buildSectionHeader('ツール通知'),
                          const SizedBox(height: 12),

                          SettingsToggleItem(
                            icon: Icons.task_alt,
                            title: 'タスクリマインダー',
                            subtitle: 'タスクの期限前に通知',
                            value: _taskRemindersEnabled,
                            enabled: _notificationsEnabled,
                            onChanged:
                                (value) =>
                                    _updateSetting('taskReminders', value, () {
                                      setState(() {
                                        _taskRemindersEnabled = value;
                                      });
                                    }),
                          ),

                          SettingsToggleItem(
                            icon: Icons.warning_amber_rounded,
                            title: '期限切れタスクの通知',
                            subtitle: '期限を過ぎたタスクを通知',
                            value: _overdueTaskNotifications,
                            enabled: _notificationsEnabled,
                            onChanged:
                                (value) => _updateSetting('overdue', value, () {
                                  setState(() {
                                    _overdueTaskNotifications = value;
                                  });
                                }),
                          ),

                          const SizedBox(height: 12),
                          // スケジュール通知（同一セクション内に配置）
                          SettingsToggleItem(
                            icon: Icons.event,
                            title: 'スケジュール通知',
                            subtitle: 'スケジュールの開始前に通知',
                            value: _scheduleNotificationsEnabled,
                            enabled: _notificationsEnabled,
                            onChanged:
                                (value) =>
                                    _updateSetting('schedule', value, () {
                                      setState(() {
                                        _scheduleNotificationsEnabled = value;
                                      });
                                    }),
                          ),

                          const SizedBox(height: 24),

                          // 通知時間帯制限セクション
                          _buildSectionHeader('通知時間帯制限'),
                          const SizedBox(height: 12),

                          SettingsToggleItem(
                            icon: Icons.bedtime,
                            title: 'おやすみモード',
                            subtitle: '指定した時間帯は通知を送らない',
                            value: _quietHoursEnabled,
                            enabled: _notificationsEnabled,
                            onChanged:
                                (value) =>
                                    _updateSetting('quietHours', value, () {
                                      setState(() {
                                        _quietHoursEnabled = value;
                                      });
                                    }),
                          ),

                          if (_quietHoursEnabled) ...[
                            const SizedBox(height: 12),

                            SettingsSelectionItem(
                              icon: Icons.bedtime,
                              title: '開始時刻',
                              currentValue: _quietHoursStart,
                              onTap: () => _selectTime('start'),
                            ),

                            SettingsSelectionItem(
                              icon: Icons.wb_sunny,
                              title: '終了時刻',
                              currentValue: _quietHoursEnd,
                              onTap: () => _selectTime('end'),
                            ),
                          ],
                        ],
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  /// セクションヘッダーを構築する
  ///
  /// [title] セクションのタイトル
  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        ShaderMask(
          shaderCallback:
              (bounds) => createOrangeYellowGradient().createShader(bounds),
          child: const Icon(Icons.settings, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

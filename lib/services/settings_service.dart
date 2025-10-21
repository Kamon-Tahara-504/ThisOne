import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 設定の永続化に使用するキー定数クラス
///
/// 各設定項目のSharedPreferencesキーを定義
class SettingsKeys {
  // 通知設定
  static const String notificationsEnabled = 'notifications_enabled';
  static const String notificationSoundEnabled = 'notification_sound_enabled';
  static const String taskRemindersEnabled = 'task_reminders_enabled';
  static const String overdueTaskNotifications = 'overdue_task_notifications';
  static const String scheduleNotificationsEnabled =
      'schedule_notifications_enabled';
  static const String quietHoursEnabled = 'quiet_hours_enabled';
  static const String quietHoursStart = 'quiet_hours_start'; // HH:mm形式
  static const String quietHoursEnd = 'quiet_hours_end'; // HH:mm形式

  // テーマ設定
  static const String themeMode = 'theme_mode'; // 'dark', 'light', 'system'
  static const String accentColor = 'accent_color'; // HEX値

  // データ管理
  static const String autoSync = 'auto_sync';
  static const String syncOnWifiOnly = 'sync_on_wifi_only';
  static const String lastSyncTime = 'last_sync_time'; // ISO8601形式

  // プライバシー
  static const String autoDeleteCompletedTasks =
      'auto_delete_completed_tasks'; // 'none', '30days', '90days'
  static const String autoArchiveOldMemos = 'auto_archive_old_memos';
}

/// アプリの設定を管理するサービスクラス
///
/// 機能:
/// - SharedPreferencesを使用した設定の永続化
/// - 通知、テーマ、データ、プライバシー設定の管理
/// - デフォルト値の管理
/// - 設定変更の通知（ChangeNotifier）
/// - 設定のリセット機能
///
/// 使用例:
/// ```dart
/// final settingsService = SettingsService();
/// await settingsService.initialize();
/// final notificationsEnabled = await settingsService.getNotificationsEnabled();
/// await settingsService.setNotificationsEnabled(true);
/// ```
class SettingsService extends ChangeNotifier {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  SharedPreferences? _prefs;
  bool _isInitialized = false;

  // デフォルト値
  static const Map<String, dynamic> _defaultValues = {
    SettingsKeys.notificationsEnabled: true,
    SettingsKeys.notificationSoundEnabled: true,
    SettingsKeys.taskRemindersEnabled: true,
    SettingsKeys.overdueTaskNotifications: true,
    SettingsKeys.scheduleNotificationsEnabled: true,
    SettingsKeys.quietHoursEnabled: false,
    SettingsKeys.quietHoursStart: '22:00',
    SettingsKeys.quietHoursEnd: '08:00',
    SettingsKeys.themeMode: 'dark',
    SettingsKeys.accentColor: '#E85A3B',
    SettingsKeys.autoSync: true,
    SettingsKeys.syncOnWifiOnly: false,
    SettingsKeys.lastSyncTime: '',
    SettingsKeys.autoDeleteCompletedTasks: 'none',
    SettingsKeys.autoArchiveOldMemos: false,
  };

  Future<void> initialize() async {
    if (_isInitialized) return;

    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
    notifyListeners();
  }

  Future<T> _getValue<T>(String key, T defaultValue) async {
    await _ensureInitialized();

    if (T == bool) {
      return (_prefs!.getBool(key) ?? defaultValue) as T;
    } else if (T == String) {
      return (_prefs!.getString(key) ?? defaultValue) as T;
    } else if (T == int) {
      return (_prefs!.getInt(key) ?? defaultValue) as T;
    } else if (T == double) {
      return (_prefs!.getDouble(key) ?? defaultValue) as T;
    } else {
      throw UnsupportedError('Type $T is not supported');
    }
  }

  Future<void> _setValue<T>(String key, T value) async {
    await _ensureInitialized();

    if (T == bool) {
      await _prefs!.setBool(key, value as bool);
    } else if (T == String) {
      await _prefs!.setString(key, value as String);
    } else if (T == int) {
      await _prefs!.setInt(key, value as int);
    } else if (T == double) {
      await _prefs!.setDouble(key, value as double);
    } else {
      throw UnsupportedError('Type $T is not supported');
    }

    notifyListeners();
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  // ==================== 通知設定 ====================

  /// プッシュ通知の有効/無効を取得
  Future<bool> getNotificationsEnabled() async {
    return await _getValue(
      SettingsKeys.notificationsEnabled,
      _defaultValues[SettingsKeys.notificationsEnabled] as bool,
    );
  }

  Future<void> setNotificationsEnabled(bool value) async {
    await _setValue(SettingsKeys.notificationsEnabled, value);
  }

  Future<bool> getNotificationSoundEnabled() async {
    return await _getValue(
      SettingsKeys.notificationSoundEnabled,
      _defaultValues[SettingsKeys.notificationSoundEnabled] as bool,
    );
  }

  Future<void> setNotificationSoundEnabled(bool value) async {
    await _setValue(SettingsKeys.notificationSoundEnabled, value);
  }

  Future<bool> getTaskRemindersEnabled() async {
    return await _getValue(
      SettingsKeys.taskRemindersEnabled,
      _defaultValues[SettingsKeys.taskRemindersEnabled] as bool,
    );
  }

  Future<void> setTaskRemindersEnabled(bool value) async {
    await _setValue(SettingsKeys.taskRemindersEnabled, value);
  }

  Future<bool> getOverdueTaskNotifications() async {
    return await _getValue(
      SettingsKeys.overdueTaskNotifications,
      _defaultValues[SettingsKeys.overdueTaskNotifications] as bool,
    );
  }

  Future<void> setOverdueTaskNotifications(bool value) async {
    await _setValue(SettingsKeys.overdueTaskNotifications, value);
  }

  Future<bool> getScheduleNotificationsEnabled() async {
    return await _getValue(
      SettingsKeys.scheduleNotificationsEnabled,
      _defaultValues[SettingsKeys.scheduleNotificationsEnabled] as bool,
    );
  }

  Future<void> setScheduleNotificationsEnabled(bool value) async {
    await _setValue(SettingsKeys.scheduleNotificationsEnabled, value);
  }

  Future<bool> getQuietHoursEnabled() async {
    return await _getValue(
      SettingsKeys.quietHoursEnabled,
      _defaultValues[SettingsKeys.quietHoursEnabled] as bool,
    );
  }

  Future<void> setQuietHoursEnabled(bool value) async {
    await _setValue(SettingsKeys.quietHoursEnabled, value);
  }

  Future<String> getQuietHoursStart() async {
    return await _getValue(
      SettingsKeys.quietHoursStart,
      _defaultValues[SettingsKeys.quietHoursStart] as String,
    );
  }

  Future<void> setQuietHoursStart(String value) async {
    await _setValue(SettingsKeys.quietHoursStart, value);
  }

  Future<String> getQuietHoursEnd() async {
    return await _getValue(
      SettingsKeys.quietHoursEnd,
      _defaultValues[SettingsKeys.quietHoursEnd] as String,
    );
  }

  Future<void> setQuietHoursEnd(String value) async {
    await _setValue(SettingsKeys.quietHoursEnd, value);
  }

  // ==================== テーマ設定 ====================

  /// テーマモード（ダーク/ライト/システム）を取得
  Future<String> getThemeMode() async {
    return await _getValue(
      SettingsKeys.themeMode,
      _defaultValues[SettingsKeys.themeMode] as String,
    );
  }

  Future<void> setThemeMode(String value) async {
    await _setValue(SettingsKeys.themeMode, value);
  }

  Future<String> getAccentColor() async {
    return await _getValue(
      SettingsKeys.accentColor,
      _defaultValues[SettingsKeys.accentColor] as String,
    );
  }

  Future<void> setAccentColor(String value) async {
    await _setValue(SettingsKeys.accentColor, value);
  }

  // ==================== データ管理 ====================

  /// 自動同期の有効/無効を取得
  Future<bool> getAutoSync() async {
    return await _getValue(
      SettingsKeys.autoSync,
      _defaultValues[SettingsKeys.autoSync] as bool,
    );
  }

  Future<void> setAutoSync(bool value) async {
    await _setValue(SettingsKeys.autoSync, value);
  }

  Future<bool> getSyncOnWifiOnly() async {
    return await _getValue(
      SettingsKeys.syncOnWifiOnly,
      _defaultValues[SettingsKeys.syncOnWifiOnly] as bool,
    );
  }

  Future<void> setSyncOnWifiOnly(bool value) async {
    await _setValue(SettingsKeys.syncOnWifiOnly, value);
  }

  Future<String> getLastSyncTime() async {
    return await _getValue(
      SettingsKeys.lastSyncTime,
      _defaultValues[SettingsKeys.lastSyncTime] as String,
    );
  }

  Future<void> setLastSyncTime(String value) async {
    await _setValue(SettingsKeys.lastSyncTime, value);
  }

  // ==================== プライバシー設定 ====================

  /// 完了済みタスクの自動削除設定を取得
  Future<String> getAutoDeleteCompletedTasks() async {
    return await _getValue(
      SettingsKeys.autoDeleteCompletedTasks,
      _defaultValues[SettingsKeys.autoDeleteCompletedTasks] as String,
    );
  }

  Future<void> setAutoDeleteCompletedTasks(String value) async {
    await _setValue(SettingsKeys.autoDeleteCompletedTasks, value);
  }

  Future<bool> getAutoArchiveOldMemos() async {
    return await _getValue(
      SettingsKeys.autoArchiveOldMemos,
      _defaultValues[SettingsKeys.autoArchiveOldMemos] as bool,
    );
  }

  Future<void> setAutoArchiveOldMemos(bool value) async {
    await _setValue(SettingsKeys.autoArchiveOldMemos, value);
  }

  // ==================== 設定のリセット ====================

  /// すべての設定をデフォルト値にリセット
  Future<void> resetToDefaults() async {
    await _ensureInitialized();

    for (final key in _defaultValues.keys) {
      final value = _defaultValues[key];
      if (value is bool) {
        await _prefs!.setBool(key, value);
      } else if (value is String) {
        await _prefs!.setString(key, value);
      } else if (value is int) {
        await _prefs!.setInt(key, value);
      } else if (value is double) {
        await _prefs!.setDouble(key, value);
      }
    }

    notifyListeners();
  }

  /// 通知設定のみをデフォルト値にリセット
  Future<void> resetNotificationSettings() async {
    await _setValue(
      SettingsKeys.notificationsEnabled,
      _defaultValues[SettingsKeys.notificationsEnabled],
    );
    await _setValue(
      SettingsKeys.notificationSoundEnabled,
      _defaultValues[SettingsKeys.notificationSoundEnabled],
    );
    await _setValue(
      SettingsKeys.taskRemindersEnabled,
      _defaultValues[SettingsKeys.taskRemindersEnabled],
    );
    await _setValue(
      SettingsKeys.overdueTaskNotifications,
      _defaultValues[SettingsKeys.overdueTaskNotifications],
    );
    await _setValue(
      SettingsKeys.scheduleNotificationsEnabled,
      _defaultValues[SettingsKeys.scheduleNotificationsEnabled],
    );
    await _setValue(
      SettingsKeys.quietHoursEnabled,
      _defaultValues[SettingsKeys.quietHoursEnabled],
    );
    await _setValue(
      SettingsKeys.quietHoursStart,
      _defaultValues[SettingsKeys.quietHoursStart],
    );
    await _setValue(
      SettingsKeys.quietHoursEnd,
      _defaultValues[SettingsKeys.quietHoursEnd],
    );
  }

  /// テーマ設定のみをデフォルト値にリセット
  Future<void> resetThemeSettings() async {
    await _setValue(
      SettingsKeys.themeMode,
      _defaultValues[SettingsKeys.themeMode],
    );
    await _setValue(
      SettingsKeys.accentColor,
      _defaultValues[SettingsKeys.accentColor],
    );
  }

  /// データ管理設定のみをデフォルト値にリセット
  Future<void> resetDataSettings() async {
    await _setValue(
      SettingsKeys.autoSync,
      _defaultValues[SettingsKeys.autoSync],
    );
    await _setValue(
      SettingsKeys.syncOnWifiOnly,
      _defaultValues[SettingsKeys.syncOnWifiOnly],
    );
  }

  /// プライバシー設定のみをデフォルト値にリセット
  Future<void> resetPrivacySettings() async {
    await _setValue(
      SettingsKeys.autoDeleteCompletedTasks,
      _defaultValues[SettingsKeys.autoDeleteCompletedTasks],
    );
    await _setValue(
      SettingsKeys.autoArchiveOldMemos,
      _defaultValues[SettingsKeys.autoArchiveOldMemos],
    );
  }
}

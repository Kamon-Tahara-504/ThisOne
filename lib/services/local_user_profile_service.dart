import 'package:sqflite/sqflite.dart';

import 'local_database_service.dart';

/// ローカルユーザープロファイルサービス
///
/// SQLite を利用してユーザープロフィール情報を管理します。
class LocalUserProfileService {
  final LocalDatabaseService _dbService = LocalDatabaseService();

  /// プロフィールを取得
  ///
  /// [userId] 取得対象のユーザーID
  /// 戻り値: プロフィール情報（存在しない場合は null）
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final Database db = await _dbService.database;
    final profiles = await db.query(
      'user_profiles',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (profiles.isEmpty) {
      return null;
    }

    return profiles.first;
  }

  /// プロフィールを作成または更新
  ///
  /// [userId] 対象ユーザーID
  /// [displayName] 表示名
  /// [phoneNumber] 電話番号
  /// [avatarUrl] アバターURL
  Future<void> upsertUserProfile({
    required String userId,
    String? displayName,
    String? phoneNumber,
    String? avatarUrl,
  }) async {
    final Database db = await _dbService.database;
    final now = DateTime.now().toIso8601String();

    final existingProfile = await getUserProfile(userId);
    final payload = <String, Object?>{
      'display_name': displayName?.isEmpty ?? true ? null : displayName,
      'phone_number': phoneNumber?.isEmpty ?? true ? null : phoneNumber,
      'avatar_url': avatarUrl?.isEmpty ?? true ? null : avatarUrl,
      'updated_at': now,
    };

    if (existingProfile == null) {
      await db.insert(
        'user_profiles',
        {
          'user_id': userId,
          ...payload,
          'created_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      await db.update(
        'user_profiles',
        payload,
        where: 'user_id = ?',
        whereArgs: [userId],
      );
    }
  }

  /// プロフィールを削除
  ///
  /// [userId] 削除対象のユーザーID
  Future<void> deleteUserProfile(String userId) async {
    final Database db = await _dbService.database;
    await db.delete(
      'user_profiles',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
}



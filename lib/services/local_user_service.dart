import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import 'local_database_service.dart';

/// ローカルユーザーサービス
///
/// SQLite を利用してユーザー情報を管理します。
/// Supabase Auth と連携し、auth_id でユーザーを識別します。
class LocalUserService {
  final LocalDatabaseService _dbService = LocalDatabaseService();
  static const _uuid = Uuid();

  /// ユーザー情報を取得（auth_idで検索）
  ///
  /// [authId] Supabase Auth のユーザーID
  /// 戻り値: ユーザー情報（存在しない場合は null）
  Future<Map<String, dynamic>?> getUser(String authId) async {
    final Database db = await _dbService.database;
    final users = await db.query(
      'users',
      where: 'auth_id = ?',
      whereArgs: [authId],
      limit: 1,
    );

    if (users.isEmpty) {
      return null;
    }

    return users.first;
  }

  /// ユーザー情報をIDで取得
  ///
  /// [id] ユーザーテーブルのプライマリキー
  /// 戻り値: ユーザー情報（存在しない場合は null）
  Future<Map<String, dynamic>?> getUserById(String id) async {
    final Database db = await _dbService.database;
    final users = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (users.isEmpty) {
      return null;
    }

    return users.first;
  }

  /// ユーザー情報を作成または更新
  ///
  /// [authId] Supabase Auth のユーザーID
  /// [displayName] 表示名
  /// [phoneNumber] 電話番号
  /// [avatarUrl] アバターURL
  Future<String> upsertUser({
    required String authId,
    String? displayName,
    String? phoneNumber,
    String? avatarUrl,
  }) async {
    final Database db = await _dbService.database;
    final now = DateTime.now().toIso8601String();

    final existingUser = await getUser(authId);
    final payload = <String, Object?>{
      'display_name': displayName?.isEmpty ?? true ? null : displayName,
      'phone_number': phoneNumber?.isEmpty ?? true ? null : phoneNumber,
      'avatar_url': avatarUrl?.isEmpty ?? true ? null : avatarUrl,
      'updated_at': now,
    };

    if (existingUser == null) {
      final id = _uuid.v4();
      await db.insert(
        'users',
        {
          'id': id,
          'auth_id': authId,
          ...payload,
          'created_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return id;
    } else {
      await db.update(
        'users',
        payload,
        where: 'auth_id = ?',
        whereArgs: [authId],
      );
      return existingUser['id'] as String;
    }
  }

  /// ユーザー情報を削除（auth_idで削除）
  ///
  /// [authId] Supabase Auth のユーザーID
  Future<void> deleteUser(String authId) async {
    final Database db = await _dbService.database;
    await db.delete(
      'users',
      where: 'auth_id = ?',
      whereArgs: [authId],
    );
  }

  /// ユーザー情報を削除（idで削除）
  ///
  /// [id] ユーザーテーブルのプライマリキー
  Future<void> deleteUserById(String id) async {
    final Database db = await _dbService.database;
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

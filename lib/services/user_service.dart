import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// ユーザーサービス
///
/// Supabase の public.users テーブルを管理します。
/// ユーザープロフィール情報（表示名、電話番号など）を保存・取得します。
class UserService {
  /// Supabaseクライアントへのアクセス
  SupabaseClient get _supabase {
    try {
      return Supabase.instance.client;
    } catch (e) {
      throw StateError(
        'Supabaseが初期化されていません。SupabaseConfig.initialize()を先に呼び出してください。',
      );
    }
  }

  /// 現在のユーザーのauth_idを取得
  String? get _currentAuthId => _supabase.auth.currentUser?.id;

  /// ユーザー情報を取得（auth_idで検索）
  ///
  /// [authId] Supabase Auth のユーザーID（省略時は現在のユーザー）
  /// 戻り値: ユーザー情報（存在しない場合は null）
  Future<Map<String, dynamic>?> getUser([String? authId]) async {
    final targetAuthId = authId ?? _currentAuthId;
    if (targetAuthId == null) {
      debugPrint('UserService.getUser: ユーザーがログインしていません');
      return null;
    }

    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('auth_id', targetAuthId)
          .maybeSingle();

      return response;
    } catch (e) {
      debugPrint('UserService.getUser error: $e');
      rethrow;
    }
  }

  /// ユーザー情報を作成または更新
  ///
  /// [authId] Supabase Auth のユーザーID（省略時は現在のユーザー）
  /// [displayName] 表示名
  /// [phoneNumber] 電話番号
  /// [avatarUrl] アバターURL
  Future<Map<String, dynamic>?> upsertUser({
    String? authId,
    String? displayName,
    String? phoneNumber,
    String? avatarUrl,
  }) async {
    final targetAuthId = authId ?? _currentAuthId;
    if (targetAuthId == null) {
      throw StateError('ユーザーがログインしていません');
    }

    try {
      final existingUser = await getUser(targetAuthId);

      final payload = <String, dynamic>{
        'auth_id': targetAuthId,
        'display_name': displayName?.isEmpty ?? true ? null : displayName,
        'phone_number': phoneNumber?.isEmpty ?? true ? null : phoneNumber,
        'avatar_url': avatarUrl?.isEmpty ?? true ? null : avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (existingUser == null) {
        // 新規作成
        final response = await _supabase
            .from('users')
            .insert(payload)
            .select()
            .single();
        return response;
      } else {
        // 更新（auth_idは更新しない）
        payload.remove('auth_id');
        final response = await _supabase
            .from('users')
            .update(payload)
            .eq('auth_id', targetAuthId)
            .select()
            .single();
        return response;
      }
    } catch (e) {
      debugPrint('UserService.upsertUser error: $e');
      rethrow;
    }
  }

  /// ユーザー情報を削除
  ///
  /// [authId] Supabase Auth のユーザーID（省略時は現在のユーザー）
  Future<void> deleteUser([String? authId]) async {
    final targetAuthId = authId ?? _currentAuthId;
    if (targetAuthId == null) {
      throw StateError('ユーザーがログインしていません');
    }

    try {
      await _supabase.from('users').delete().eq('auth_id', targetAuthId);
    } catch (e) {
      debugPrint('UserService.deleteUser error: $e');
      rethrow;
    }
  }
}

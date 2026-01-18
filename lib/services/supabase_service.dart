import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase認証サービス
///
/// 今後は認証専用として扱い、データ永続化はローカルサービスに委譲する。
class SupabaseService {
  // Supabaseクライアントへのアクセス（遅延初期化）
  SupabaseClient get _supabase {
    try {
      return Supabase.instance.client;
    } catch (e) {
      throw StateError(
        'Supabaseが初期化されていません。SupabaseConfig.initialize()を先に呼び出してください。',
      );
    }
  }

  /// メールアドレスとパスワードでサインアップ
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signUp(email: email, password: password);
  }

  /// メールアドレスとパスワードでサインイン
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// サインアウト
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// アカウントを削除
  ///
  /// Supabase Functionsのdelete-accountエッジ関数を呼び出して
  /// ユーザーのデータとAuthアカウントを削除します
  Future<void> deleteAccount() async {
    final response = await _supabase.functions.invoke(
      'delete-account',
      body: {'confirm': true},
    );

    if (response.status != 200) {
      final errorData = response.data;
      final errorMessage = errorData?['error'] ?? 'アカウントの削除に失敗しました';
      throw Exception(errorMessage);
    }
  }

  /// 現在のユーザー情報を取得
  User? getCurrentUser() {
    try {
      return _supabase.auth.currentUser;
    } catch (e) {
      debugPrint('getCurrentUser error: $e');
      return null;
    }
  }

  /// 認証状態の変更ストリーム
  Stream<AuthState> get authStateChanges {
    try {
      return _supabase.auth.onAuthStateChange;
    } catch (e) {
      debugPrint('authStateChanges error: $e');
      // エラーが発生した場合、空のストリームを返す（エラーを無視）
      // これにより、AuthGateでエラーハンドリングが可能になる
      return Stream<AuthState>.empty();
    }
  }
}

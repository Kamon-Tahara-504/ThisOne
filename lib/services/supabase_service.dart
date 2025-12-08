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

  /// Google OAuthでサインイン
  Future<bool> signInWithGoogle() async {
    try {
      return await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: null, // アプリ構成に応じて設定
      );
    } catch (e) {
      debugPrint('Google認証エラー: $e');
      rethrow;
    }
  }

  /// X(Twitter) OAuthでサインイン
  Future<bool> signInWithTwitter() async {
    try {
      return await _supabase.auth.signInWithOAuth(
        OAuthProvider.twitter,
        redirectTo: null, // アプリ構成に応じて設定
      );
    } catch (e) {
      debugPrint('X認証エラー: $e');
      rethrow;
    }
  }
}

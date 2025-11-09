import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Supabaseクライアントを使用
final supabase = Supabase.instance.client;

/// Supabase認証サービス
///
/// 今後は認証専用として扱い、データ永続化はローカルサービスに委譲する。
class SupabaseService {
  /// メールアドレスとパスワードでサインアップ
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signUp(email: email, password: password);
  }

  /// メールアドレスとパスワードでサインイン
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// サインアウト
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  /// 現在のユーザー情報を取得
  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }

  /// 認証状態の変更ストリーム
  Stream<AuthState> get authStateChanges => supabase.auth.onAuthStateChange;

  /// Google OAuthでサインイン
  Future<bool> signInWithGoogle() async {
    try {
      return await supabase.auth.signInWithOAuth(
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
      return await supabase.auth.signInWithOAuth(
        OAuthProvider.twitter,
        redirectTo: null, // アプリ構成に応じて設定
      );
    } catch (e) {
      debugPrint('X認証エラー: $e');
      rethrow;
    }
  }
}



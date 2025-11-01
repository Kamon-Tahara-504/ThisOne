import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class SupabaseConfig {
  // Supabase設定（認証専用）
  // フォールバック値を設定して環境変数がなくても動作するように
  static String get supabaseUrl {
    const url = String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: 'https://gpbyfivahcqkebvvpuuo.supabase.co',
    );
    return url;
  }

  static String get supabaseAnonKey {
    const key = String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdwYnlmaXZhaGNxa2VidnZwdXVvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgzMzAwNTUsImV4cCI6MjA2MzkwNjA1NX0.T-NC0Q6ogfDg3-XsAl9zNdx6ShJwoYJyyjQ1wiOrcdA',
    );
    return key;
  }

  static Future<void> initialize() async {
    try {
      // セキュリティチェック: URLとキーの基本検証
      _validateConfiguration();

      await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

      if (kDebugMode) {
        print('Supabase初期化完了');
        print('URL: ${supabaseUrl.substring(0, 20)}...'); // セキュリティのため一部のみ表示
      }
    } catch (e) {
      if (kDebugMode) {
        print('Supabase初期化エラー: $e');
      }
      // 本番環境では詳細なエラー情報を隠す
      if (kReleaseMode) {
        throw Exception('データベースの初期化に失敗しました。');
      }
      rethrow;
    }
  }

  /// 設定値の検証（警告のみ、エラーは投げない）
  static void _validateConfiguration() {
    final url = supabaseUrl;
    final key = supabaseAnonKey;

    // URLの基本検証（警告のみ）
    if (!url.startsWith('https://')) {
      if (kDebugMode) {
        print('警告: Supabase URLがhttpsで始まっていません');
      }
    }

    // キーの基本検証（警告のみ）
    if (!key.contains('.') || key.split('.').length != 3) {
      if (kDebugMode) {
        print('警告: Supabaseキーが正しいJWT形式ではありません');
      }
    }
  }
}

// Supabaseクライアントへの簡単なアクセス
final supabase = Supabase.instance.client;

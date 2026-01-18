import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class SupabaseConfig {
  // ディープリンクスキーム（パスワードリセット等で使用）
  static const String deepLinkScheme = 'thisone';
  static const String passwordResetRedirectUrl = 'thisone://reset-password';

  // Supabase設定（認証専用）
  // 開発モード: フォールバック値を使用（利便性のため）
  // リリースモード: 環境変数必須（セキュリティのため）
  static String get supabaseUrl {
    const url = String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue:
          kReleaseMode
              ? '' // リリースモードではデフォルト値なし
              : 'https://gpbyfivahcqkebvvpuuo.supabase.co', // 開発用
    );

    // リリースモードで環境変数が設定されていない場合はエラー
    if (kReleaseMode && url.isEmpty) {
      throw Exception(
        'SUPABASE_URL環境変数が設定されていません。\n'
        'リリースビルド時は --dart-define=SUPABASE_URL=... を指定してください。',
      );
    }

    return url;
  }

  static String get supabaseAnonKey {
    const key = String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue:
          kReleaseMode
              ? '' // リリースモードではデフォルト値なし
              : 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdwYnlmaXZhaGNxa2VidnZwdXVvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgzMzAwNTUsImV4cCI6MjA2MzkwNjA1NX0.T-NC0Q6ogfDg3-XsAl9zNdx6ShJwoYJyyjQ1wiOrcdA', // 開発用
    );

    // リリースモードで環境変数が設定されていない場合はエラー
    if (kReleaseMode && key.isEmpty) {
      throw Exception(
        'SUPABASE_ANON_KEY環境変数が設定されていません。\n'
        'リリースビルド時は --dart-define=SUPABASE_ANON_KEY=... を指定してください。',
      );
    }

    return key;
  }

  static Future<void> initialize() async {
    try {
      // セキュリティチェック: URLとキーの基本検証
      _validateConfiguration();

      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        authOptions: FlutterAuthClientOptions(authFlowType: AuthFlowType.pkce),
      );

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

// Supabaseクライアントへの簡単なアクセス（遅延初期化）
SupabaseClient get supabase {
  try {
    return Supabase.instance.client;
  } catch (e) {
    throw StateError(
      'Supabaseが初期化されていません。SupabaseConfig.initialize()を先に呼び出してください。',
    );
  }
}

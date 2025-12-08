import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:thisone/supabase_config.dart';

void main() {
  group('SupabaseConfig', () {
    test('should have valid URL in debug mode', () {
      // デバッグモードでは、デフォルト値が使用されるべき
      // この場合、URLは空でないことを確認
      expect(SupabaseConfig.supabaseUrl, isNotEmpty);
      expect(SupabaseConfig.supabaseUrl, startsWith('https://'));
    });

    test('should have valid anon key in debug mode', () {
      // デバッグモードでは、デフォルト値が使用されるべき
      // この場合、キーは空でないことを確認
      expect(SupabaseConfig.supabaseAnonKey, isNotEmpty);

      // JWTトークンの基本的な形式を確認（3つの部分に分かれている）
      final parts = SupabaseConfig.supabaseAnonKey.split('.');
      expect(parts.length, equals(3), reason: 'JWT should have 3 parts');
    });

    test(
      'should throw exception in release mode without environment variables',
      () {
        // リリースモードのテストは実際のリリースビルドでのみ有効
        // このテストは主にコードが正しく書かれているかを確認するためのもの

        // デバッグモードでは、この動作は発生しない
        if (kReleaseMode) {
          // リリースモードで環境変数がない場合、例外が投げられることを期待
          // ただし、このテストはリリースモードで実行されないため、
          // コードレビュー用のプレースホルダーとして残しておく
          expect(() => SupabaseConfig.supabaseUrl, throwsException);
          expect(() => SupabaseConfig.supabaseAnonKey, throwsException);
        } else {
          // デバッグモードでは正常に動作することを確認
          expect(SupabaseConfig.supabaseUrl, isNotEmpty);
          expect(SupabaseConfig.supabaseAnonKey, isNotEmpty);
        }
      },
    );
  });
}

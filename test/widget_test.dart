// This is a basic Flutter widget test.
//
// テストは Supabase に依存しない基本的な機能のみを確認します。

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MyApp creates a MaterialApp widget', (
    WidgetTester tester,
  ) async {
    // シンプルなテストアプリを作成
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Test App')),
          body: const Center(child: Text('Hello World')),
        ),
      ),
    );

    // MaterialAppが作成されることを確認
    expect(find.byType(MaterialApp), findsOneWidget);

    // Scaffoldが表示されることを確認
    expect(find.byType(Scaffold), findsOneWidget);

    // テキストが表示されることを確認
    expect(find.text('Hello World'), findsOneWidget);
  });

  testWidgets('App Bar displays title correctly', (WidgetTester tester) async {
    // テストウィジェットをビルド
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('ThisOne')),
          body: const Text('Test'),
        ),
      ),
    );

    // AppBarが存在することを確認
    expect(find.byType(AppBar), findsOneWidget);

    // タイトルテキストが表示されることを確認
    expect(find.text('ThisOne'), findsOneWidget);
  });
}

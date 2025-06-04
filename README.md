# ThisOne - 生産性向上アプリ

**ThisOne**は、タスク管理・スケジュール管理・メモ機能を統合したFlutter製の生産性向上アプリです。  
モダンなダークテーマとオレンジ-イエローのカスタムグラデーションが特徴的なUIを持ち、Supabaseをバックエンドとして使用します。

## ✨ 主要機能

### 📱 アプリ機能
- **タスク管理**: タスクの追加・完了・削除機能
- **スケジュール管理**: カレンダー表示での予定管理
- **メモ機能**: ノート作成・編集・削除
- **ユーザー認証**: サインアップ・ログイン・ログアウト
- **設定画面**: アプリケーション設定管理

### 🎨 UI/UX
- **カスタムテーマ**: オレンジ→黄色のグラデーション
- **ダークモード**: 統一された黒基調（#2B2B2B）のUI
- **Material 3**: 最新のマテリアルデザイン採用
- **タブナビゲーション**: 5つの主要機能へのアクセス
- **レスポンシブデザイン**: 各種画面サイズに対応

### 🗄️ データ管理
- **Supabaseバックエンド**: PostgreSQLデータベース
- **認証システム**: Supabase Auth統合
- **セキュリティ**: Row Level Security (RLS) 実装
- **リアルタイム**: データ同期機能（将来実装予定）

## 📁 プロジェクト構造

```
lib/
├── main.dart                    # アプリエントリーポイント・ナビゲーション
├── gradients.dart              # カスタムグラデーション関数群
├── supabase_config.dart        # Supabase接続設定
├── services/
│   └── supabase_service.dart   # データベース操作サービス
└── screens/
    ├── task_screen.dart        # タスク管理画面
    ├── schedule_screen.dart    # スケジュール管理画面
    ├── memo_screen.dart        # メモ機能画面
    ├── auth_screen.dart        # 認証画面
    └── settings_screen.dart    # 設定画面

supabase_schema.sql             # データベーススキーマ定義
```

## 🗃️ データベース構造

### テーブル一覧
```sql
-- ユーザープロファイル
user_profiles (id, user_id, display_name, avatar_url, created_at, updated_at)

-- タスク管理
tasks (id, user_id, title, description, is_completed, priority, due_date, created_at, updated_at, completed_at)

-- スケジュール管理
schedules (id, user_id, title, description, schedule_date, start_time, end_time, is_all_day, location, reminder_minutes, created_at, updated_at)

-- メモ機能
memos (id, user_id, title, content, tags, is_pinned, color_tag, created_at, updated_at)

-- ユーザー設定
user_settings (id, user_id, theme_mode, notification_enabled, default_reminder_minutes, first_day_of_week, created_at, updated_at)
```

## 🚀 セットアップ手順

### 1. 依存関係のインストール

```bash
flutter pub get
```

### 2. Supabaseプロジェクトの設定

1. [Supabase](https://supabase.com)でアカウント作成・プロジェクト作成
2. ダッシュボードの「Settings」→「API」から以下を取得：
   - **Project URL**
   - **Anon public key**

### 3. データベーススキーマの作成

1. Supabaseダッシュボードの「SQL Editor」を開く
2. `supabase_schema.sql`の内容をコピー&実行
3. テーブルとRLSポリシーが自動作成される

### 4. 設定ファイルの更新

`lib/supabase_config.dart`を編集：

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'YOUR_PROJECT_URL';
  static const String supabaseAnonKey = 'YOUR_ANON_KEY';
  // ...
}
```

### 5. アプリの実行

```bash
flutter run
```

## 📊 現在の実装状況

### ✅ 完了機能
- [x] 基本UI・ナビゲーション設計
- [x] カスタムグラデーションシステム
- [x] タスク管理（ローカル動作）
- [x] スケジュール管理（ローカル動作） 
- [x] メモ機能（ローカル動作）
- [x] 認証画面UI
- [x] Supabase設定・サービス層
- [x] データベーススキーマ設計・作成
- [x] RLSセキュリティ設定

### 🚧 開発中・今後の予定
- [ ] Supabaseとの実際のデータ連携
- [ ] リアルタイムデータ同期
- [ ] プッシュ通知機能
- [ ] データエクスポート機能
- [ ] オフライン対応
- [ ] ダークモード切り替え機能

## 🛠️ 技術スタック

- **Frontend**: Flutter 3.7.2+ (Dart)
- **Backend**: Supabase (PostgreSQL)
- **認証**: Supabase Auth
- **状態管理**: StatefulWidget（基本）
- **UI**: Material 3 + カスタムテーマ
- **カレンダー**: table_calendar パッケージ

## 📝 主要な依存関係

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  supabase_flutter: ^2.5.6
  table_calendar: ^3.0.9
```

## 🔧 開発環境

- **Flutter SDK**: 3.7.2+
- **Dart**: 3.0+
- **プラットフォーム**: iOS, Android, Web対応

## 🛡️ セキュリティ

- **Row Level Security (RLS)**: 各ユーザーは自分のデータのみアクセス可能
- **認証必須**: 全ての機能で認証が必要
- **APIキー管理**: 本番環境では環境変数使用推奨

## 📚 参考リソース

- [Flutter Documentation](https://docs.flutter.dev/)
- [Supabase Documentation](https://supabase.com/docs)
- [Material 3 Design](https://m3.material.io/)
- [Table Calendar Package](https://pub.dev/packages/table_calendar)

## 🤝 Contributing

プロジェクトへの貢献は歓迎します！  
新しい機能の提案やバグ報告は、GitHubのIssueでお知らせください。

READMEはAIによる分析生成

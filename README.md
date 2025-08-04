# ThisOne - 生産性向上アプリ

**ThisOne**は、タスク管理・スケジュール管理・メモ機能を統合したFlutter製の生産性向上アプリです。  
モダンなダークテーマとオレンジ-イエローのカスタムグラデーションが特徴的なUIを持ち、Supabaseをバックエンドとして使用します。

##  主要機能

###  アプリ機能
- **タスク管理** ✅: タスクの追加・完了・削除・更新（Supabase連携済み）
- **メモ機能** ✅: リッチテキストエディタ搭載、自動保存機能、Supabase連携済み
- **ユーザー認証** ✅: サインアップ・ログイン・ログアウト（Supabase Auth完全連携）
- **アカウント管理** ✅: プロフィール編集、ユーザー情報管理
- **スケジュール管理** 🚧: カレンダー表示での予定管理（ローカル動作）
- **設定画面** 🚧: アプリケーション設定管理

###  UI/UX
- **カスタムテーマ**: オレンジ→黄色のグラデーション
- **ダークモード**: 統一された黒基調（#2B2B2B）のUI
- **Material 3**: 最新のマテリアルデザイン採用
- **タブナビゲーション**: 5つの主要機能へのアクセス
- **レスポンシブデザイン**: 各種画面サイズに対応
- **リッチテキストエディタ**: Flutter Quillによる高機能メモエディタ
- **国際化対応**: 日本語ロケール設定済み

###  データ管理
- **Supabaseバックエンド**: PostgreSQLデータベース
- **認証システム**: Supabase Auth統合済み
- **セキュリティ**: Row Level Security (RLS) 実装済み
- **自動保存**: メモの変更内容を自動的に保存
- **リアルタイムデータ同期**: 基盤実装済み

##  プロジェクト構造

```
lib/
├── main.dart                    # アプリエントリーポイント・ナビゲーション
├── gradients.dart              # カスタムグラデーション関数群
├── supabase_config.dart        # Supabase接続設定
├── services/
│   └── supabase_service.dart   # データベース操作サービス（認証・タスク・メモ）
├── screens/
│   ├── task_screen.dart        # タスク管理画面
│   ├── schedule_screen.dart    # スケジュール管理画面
│   ├── memo_screen.dart        # メモ一覧画面
│   ├── memo_detail_screen.dart # メモ詳細・編集画面
│   ├── auth_screen.dart        # 認証画面
│   ├── account_screen.dart     # アカウント管理画面
│   └── settings_screen.dart    # 設定画面
├── widgets/
│   ├── memo_back_header.dart   # メモ画面ヘッダー
│   ├── memo_save_manager.dart  # メモ自動保存管理
│   ├── quill_color_panel.dart  # カラーパネル
│   ├── quill_rich_editor.dart  # リッチテキストエディタ
│   └── quill_toolbar.dart      # エディタツールバー
└── utils/
    └── color_utils.dart        # カラーユーティリティ

supabase_schema.sql             # データベーススキーマ定義
supabase_*_migration.sql        # データベースマイグレーションファイル
```

##  データベース構造

### テーブル一覧
```sql
-- ユーザープロファイル
user_profiles (id, user_id, display_name, phone_number, avatar_url, created_at, updated_at)

-- タスク管理（完全実装済み）
tasks (id, user_id, title, description, is_completed, priority, due_date, created_at, updated_at, completed_at)

-- メモ機能（完全実装済み）
memos (id, user_id, title, content, mode, rich_content, is_pinned, color_tag, created_at, updated_at)

-- スケジュール管理（準備済み）
schedules (id, user_id, title, description, schedule_date, start_time, end_time, is_all_day, location, reminder_minutes, created_at, updated_at)

-- ユーザー設定（準備済み）
user_settings (id, user_id, theme_mode, notification_enabled, default_reminder_minutes, first_day_of_week, created_at, updated_at)
```

##  セットアップ手順

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
3. 必要に応じてマイグレーションファイルも実行：
   - `supabase_memo_mode_migration.sql`
   - `supabase_phone_migration.sql`
   - `supabase_rich_content_migration.sql`

### 4. 設定ファイルの更新

`lib/supabase_config.dart`を編集：

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
}
```

### 5. アプリの実行

```bash
flutter run
```

##  現在の実装状況

### ✅ 完了機能
- [x] 基本UI・ナビゲーション設計
- [x] カスタムグラデーションシステム
- [x] **認証システム（Supabase完全連携）**
  - [x] サインアップ・ログイン・ログアウト
  - [x] 認証状態管理
  - [x] エラーハンドリング
- [x] **タスク管理（Supabase完全連携）**
  - [x] タスクの追加・完了・削除・更新
  - [x] 優先度・期日管理
  - [x] リアルタイム同期
- [x] **メモ機能（Supabase完全連携）**
  - [x] リッチテキストエディタ（Flutter Quill）
  - [x] 自動保存機能
  - [x] メモの追加・編集・削除
  - [x] リッチコンテンツ保存（JSON Delta形式）
- [x] **アカウント管理**
  - [x] ユーザープロフィール編集
  - [x] 表示名・電話番号管理
  - [x] プロフィール自動作成
- [x] Supabase設定・サービス層
- [x] データベーススキーマ設計・作成
- [x] RLSセキュリティ設定
- [x] 国際化設定（日本語対応）

### 🚧 開発中・今後の予定
- [ ] **スケジュール管理のSupabase連携**
  - [x] UI・カレンダー表示（ローカル動作）
  - [ ] Supabaseとのデータ連携
- [ ] **設定画面の実装**
  - [ ] テーマ設定
  - [ ] 通知設定
  - [ ] ユーザー設定管理
- [ ] **追加機能**
  - [ ] プッシュ通知機能
  - [ ] データエクスポート機能
  - [ ] オフライン対応
  - [ ] タスクとカレンダーの連携機能
  - [ ] モバイル通知欄でのタスク表示
  - [ ] 他言語対応（英語）
  - [ ] データインポート機能

##  技術スタック

- **Frontend**: Flutter 3.7.2+ (Dart)
- **Backend**: Supabase (PostgreSQL)
- **認証**: Supabase Auth
- **状態管理**: StatefulWidget + Stream監視
- **UI**: Material 3 + カスタムテーマ
- **カレンダー**: table_calendar パッケージ
- **リッチテキスト**: flutter_quill パッケージ
- **国際化**: intl + flutter_localizations
- **フォント**: google_fonts パッケージ

##  主要な依存関係

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  
  # Supabase dependencies
  supabase_flutter: ^2.5.6
  
  # UI関連
  table_calendar: ^3.0.9
  google_fonts: ^6.1.0
  
  # 国際化
  flutter_localizations:
    sdk: flutter
  intl: ^0.20.2
  
  # リッチテキストエディタ
  flutter_quill: ^11.4.1
  flutter_quill_extensions: ^11.0.0
```

##  開発環境

- **Flutter SDK**: 3.7.2+
- **Dart**: 3.0+
- **プラットフォーム**: iOS, Android, Web対応

##  セキュリティ

- **Row Level Security (RLS)**: 各ユーザーは自分のデータのみアクセス可能
- **認証必須**: 全ての機能で認証が必要
- **APIキー管理**: 本番環境では環境変数使用推奨
- **自動ログアウト**: セッション管理による安全な認証状態管理

### 自動保存システム
- メモ編集中の内容を自動的に保存
- ネットワーク接続状態を考慮した堅牢な保存機能
- 保存状態の視覚的フィードバック

### リッチテキストエディタ
- 太字、斜体、下線などの基本的なテキスト装飾
- カラーパレットによる文字色・背景色変更
- インデント・リスト機能
- JSON Delta形式での効率的なデータ保存

### 統合認証システム
- Supabase Authによる安全な認証
- 自動プロフィール作成
- 認証状態の監視とリアルタイム更新

##  参考リソース

- [Flutter Documentation](https://docs.flutter.dev/)
- [Supabase Documentation](https://supabase.com/docs)
- [Material 3 Design](https://m3.material.io/)
- [Table Calendar Package](https://pub.dev/packages/table_calendar)
- [Flutter Quill Documentation](https://pub.dev/packages/flutter_quill)

##　comimitメッセージ

- fix：バグ修正
- hotfix：クリティカルなバグ修正
- add：新規（ファイル）機能追加
- update：機能修正（バグではない）
- change：仕様変更
- clean：整理（リファクタリング等）
- disable：無効化（コメントアウト等）
- remove：削除（ファイル）
- upgrade：バージョンアップ
- revert：変更取り消し

##  Contributing

プロジェクトへの貢献は歓迎します！  
新しい機能の提案やバグ報告は、GitHubのIssueでお知らせください。

*README最終更新: 2024年12月*  
*AIによる分析と現在の実装状況に基づく生成*

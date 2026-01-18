# ThisOne - 生産性向上アプリ

**ThisOne**は タスク管理・スケジュール・メモ機能の三つを一つに統合し、
それぞれの連携力を高め日常の生産性向上を目的としたアプリケーションです。
ダークテーマとオレンジ-イエローのカスタムグラデーションが特徴的なUIを持ち Supabaseをバックエンドとして使用しています。

### プロジェクト体制
- **開発メンバー**: 一人
- **開発者**: Kamon-Tahara-504

### プロジェクト工程
- **開発開始日**: 2025/ 5/27
- **リリース日**: 2025/ 12/18

##  主要機能

###  アプリ機能
- **タスク管理** : タスクの追加・完了・削除・更新
- **スケジュール管理** : カレンダー表示での予定管理
- **メモ機能** : リッチテキストエディタ搭載、自動保存機能
- **ユーザー認証** : サインアップ・ログイン・ログアウト
- **アカウント管理** : プロフィール編集、ユーザー情報管理

- **設定画面** : アプリケーション設定管理（基本UI実装済み）

###  UI/UX
- **カスタムテーマ**: オレンジ→黄色のグラデーション
- **ダークモード**: 統一された黒基調（#2B2B2B）のUI
- **Material 3**: 最新のマテリアルデザイン採用
- **タブナビゲーション**: 5つの主要機能へのアクセス
- **レスポンシブデザイン**: 各種画面サイズに対応
- **リッチテキストエディタ**: Flutter Quillによる高機能メモエディタ
- **国際化対応**: 日本語ロケール設定済み
- **アニメーション**: スムーズなページ遷移とヘッダー制御
- **カスタムスクロール**: ページスワイプとヘッダー表示制御

###  データ管理
- **Supabaseバックエンド**: PostgreSQLデータベース
- **認証システム**: Supabase Auth統合済み
- **セキュリティ**: Row Level Security (RLS) 実装済み
- **自動保存**: メモの変更内容を自動的に保存（デバウンス機能付き）
- **リアルタイムデータ同期**: 基盤実装済み
- **スマートトリガー**: メモの実際の内容変更時のみ更新時刻を更新
- **データベースマイグレーション**: 段階的な機能追加に対応

##  プロジェクト構造

```
lib/
├── main.dart                          # アプリエントリーポイント・ナビゲーション
├── gradients.dart                     # カスタムグラデーション関数群
├── supabase_config.dart               # Supabase接続設定
├── controllers/
│   ├── header_controller.dart         # ヘッダー制御コントローラー
│   ├── page_controller.dart           # ページ制御コントローラー
│   └── scroll_controller_manager.dart # スクロール制御マネージャー
├── examples/
│   └── gradient_showcase.dart         # グラデーション表示例
├── models/
│   ├── app_error.dart                 # アプリエラーモデル
│   ├── memo.dart                      # メモモデル
│   ├── schedule.dart                  # スケジュールモデル
│   ├── schedule_template.dart        # スケジュールテンプレートモデル
│   ├── task.dart                      # タスクモデル
│   └── task_template.dart             # タスクテンプレートモデル
├── services/
│   ├── supabase_service.dart          # Supabaseデータベース操作サービス（認証・タスク・メモ・スケジュール）
│   ├── user_service.dart              # ユーザー管理サービス
│   ├── settings_service.dart          # 設定管理サービス
│   ├── main_data_service.dart         # メインデータ管理サービス
│   ├── data_export_service.dart       # データエクスポートサービス
│   ├── data_import_service.dart       # データインポートサービス
│   ├── local_database_service.dart    # ローカルデータベースサービス
│   ├── local_task_service.dart        # ローカルタスクサービス
│   ├── local_task_template_service.dart # ローカルタスクテンプレートサービス
│   ├── local_memo_service.dart        # ローカルメモサービス
│   ├── local_schedule_service.dart    # ローカルスケジュールサービス
│   └── local_schedule_template_service.dart # ローカルスケジュールテンプレートサービス
├── screens/
│   ├── auth/                          # 認証関連画面
│   │   ├── unified_auth_screen.dart   # 統合認証画面（ログイン・新規登録）
│   │   └── password_reset_screen.dart # パスワードリセット画面
│   ├── task/
│   │   └── task_screen.dart           # タスク管理画面
│   ├── schedule/                      # スケジュール関連画面
│   │   ├── schedule_screen.dart       # スケジュール管理画面
│   │   ├── schedule_calendar.dart     # スケジュールカレンダー
│   │   ├── schedule_calendar_header.dart # カレンダーヘッダー
│   │   ├── schedule_list_title.dart   # スケジュールリストタイトル
│   │   └── empty_schedule_state.dart  # 空のスケジュール状態表示
│   ├── memo/                          # メモ関連画面
│   │   ├── memo_screen.dart           # メモ一覧画面
│   │   └── memo_detail_screen.dart    # メモ詳細・編集画面
│   └── settings/                      # 設定画面群
│       ├── settings_screen.dart       # 設定メイン画面
│       ├── account_settings_screen.dart    # アカウント設定画面
│       ├── app_info_screen.dart           # アプリ情報画面
│       ├── data_management_screen.dart     # データ管理画面
│       ├── help_screen.dart               # ヘルプ画面
│       ├── license_screen.dart            # ライセンス画面
│       ├── notification_settings_screen.dart # 通知設定画面
│       ├── privacy_settings_screen.dart    # プライバシー設定画面
│       ├── privacy_policy_screen.dart      # プライバシーポリシー画面
│       ├── terms_screen.dart               # 利用規約画面
│       └── theme_settings_screen.dart      # テーマ設定画面
├── utils/
│   ├── calculator_utils.dart          # 計算ユーティリティ
│   ├── color_utils.dart               # カラーユーティリティ
│   ├── error_handler.dart             # エラーハンドリングユーティリティ
│   ├── network_utils.dart             # ネットワークユーティリティ
│   ├── phone_validator.dart           # 電話番号バリデーター
│   └── text_selection_menu_builder.dart # テキスト選択メニュービルダー
└── widgets/
    ├── account/                        # アカウント関連ウィジェット
    │   ├── account_deletion_dialog.dart # アカウント削除ダイアログ
    │   ├── account_info_item.dart      # アカウント情報アイテム
    │   ├── logged_in_view.dart         # ログイン済み表示
    │   ├── logout_dialog.dart          # ログアウトダイアログ
    │   └── not_logged_in_view.dart     # 未ログイン表示
    ├── app_bars/                       # ヘッダー関連ウィジェット
    │   ├── collapsible_app_bar.dart    # 折りたたみ可能なアプリバー
    │   ├── custom_app_bar.dart         # カスタムアプリバー
    │   └── static_header_guideline.dart # 静的ヘッダーガイドライン
    ├── auth/                           # 認証関連ウィジェット
    │   ├── login_bottom_sheet.dart     # ログインボトムシート
    │   ├── signup_bottom_sheet.dart    # サインアップボトムシート
    │   └── password_reset_email_bottom_sheet.dart # パスワードリセットメール送信ボトムシート
    ├── common/                         # 共通ウィジェット
    │   ├── bottom_sheet_header.dart   # ボトムシートヘッダー
    │   ├── count_badge.dart           # カウントバッジ
    │   └── time_picker_bottom_sheet.dart # 時間選択ボトムシート
    ├── error/                          # エラー関連ウィジェット
    │   └── error_banner.dart          # エラーバナー
    ├── memo/                           # メモ関連ウィジェット
    │   ├── color_filter_bottom_sheet.dart # カラーフィルターボトムシート
    │   ├── empty_memo_state.dart       # 空のメモ状態表示
    │   ├── memo_back_header.dart       # メモ画面ヘッダー
    │   ├── memo_color_selector.dart    # メモカラーセレクター
    │   ├── memo_dialog.dart            # メモダイアログ
    │   ├── memo_edit_dialog.dart       # メモ編集ダイアログ
    │   ├── memo_edit_form_header.dart  # メモ編集フォームヘッダー
    │   ├── memo_edit_submit_button.dart # メモ編集送信ボタン
    │   ├── memo_filter_header.dart     # メモフィルターヘッダー
    │   ├── memo_filter.dart            # メモフィルター
    │   ├── memo_item_card.dart         # メモアイテムカード
    │   ├── memo_mode_selector.dart     # メモモードセレクター
    │   └── memo_save_manager.dart       # メモ自動保存管理
    ├── navigation/
    │   └── bottom_navigation_bar.dart # カスタムボトムナビゲーション
    ├── overlays/
    │   ├── account_info_overlay.dart   # アカウント情報オーバーレイ
    │   ├── memo_sort_overlay.dart      # メモソートオーバーレイ
    │   └── sort_overlay.dart           # ソートオーバーレイ
    ├── schedule/                       # スケジュール関連ウィジェット
    │   ├── color_picker_bottom_sheet.dart # カラーピッカーボトムシート
    │   ├── notification_settings.dart  # 通知設定ウィジェット
    │   ├── schedule_basic_settings.dart # スケジュール基本設定
    │   ├── schedule_card.dart           # スケジュールカード
    │   ├── schedule_dialog.dart        # スケジュールダイアログ
    │   ├── schedule_form_header.dart   # スケジュールフォームヘッダー
    │   ├── schedule_form_submit_button.dart # スケジュールフォーム送信ボタン
    │   ├── schedule_template_bottom_sheet.dart # スケジュールテンプレートボトムシート
    │   └── schedule_time_selector.dart # スケジュール時間セレクター
    ├── settings/                       # 設定関連ウィジェット
    │   ├── settings_action_item.dart   # 設定アクションアイテム
    │   ├── settings_navigation_item.dart # 設定ナビゲーションアイテム
    │   ├── settings_selection_item.dart # 設定選択アイテム
    │   ├── settings_toggle_item.dart   # 設定トグルアイテム
    │   └── tappable_settings_card.dart # タップ可能な設定カード
    ├── task/                           # タスク関連ウィジェット
    │   ├── task_card.dart              # タスクカード
    │   ├── task_dialog.dart            # タスクダイアログ
    │   ├── task_due_date_selector.dart # タスク期日セレクター
    │   ├── task_form_header.dart       # タスクフォームヘッダー
    │   ├── task_form_submit_button.dart # タスクフォーム送信ボタン
    │   ├── task_priority_selector.dart # タスク優先度セレクター
    │   ├── task_template_bottom_sheet.dart # タスクテンプレートボトムシート
    │   └── task_title_input.dart       # タスクタイトル入力
    ├── template/                       # テンプレート関連ウィジェット
    │   ├── empty_template_state.dart   # 空のテンプレート状態表示
    │   └── template_create_button.dart # テンプレート作成ボタン
    ├── color_palette.dart              # カラーパレット
    ├── quill_color_panel.dart          # Quillカラーパネル
    ├── quill_rich_editor.dart          # リッチテキストエディタ
    └── quill_toolbar.dart              # エディタツールバー
```

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
- **アニメーション**: Flutter Animation Framework
- **データベース**: PostgreSQL with RLS

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

- **言語**: Dart 3.9.2
- **Flutter SDK**: 3.35.3 (stable channel)
- **OS**: macOS 15.6.1 (darwin-arm64)
- **プラットフォーム**: iOS, Android, Web対応
- **Android SDK**: 36.0.0 (API 36)
- **Xcode**: 16.4 (Build 16F6)
- **Java**: OpenJDK 21.0.7
- **CocoaPods**: 1.16.2
- **IDE**: Android Studio 2025.1 / VS Code 1.103.2 / IntelliJ IDEA 2025.2.1
- **バージョン管理**: GitHub
- **バックエンド**: Supabase (PostgreSQL)
- **パッケージ管理**: pub.dev

##  セキュリティ

- **Row Level Security (RLS)**: 各ユーザーは自分のデータのみアクセス可能
- **認証必須**: 全ての機能で認証が必要
- **APIキー管理**: 本番環境では環境変数使用推奨
- **自動ログアウト**: セッション管理による安全な認証状態管理

### 自動保存システム
- メモ編集中の内容を自動的に保存（デバウンス機能付き）
- ネットワーク接続状態を考慮した堅牢な保存機能
- 保存状態の視覚的フィードバック
- スマートトリガーによる効率的な更新時刻管理

### リッチテキストエディタ
- 太字、斜体、下線などの基本的なテキスト装飾
- カラーパレットによる文字色・背景色変更
- インデント・リスト機能
- JSON Delta形式での効率的なデータ保存
- カスタムツールバーとカラーパネル

### 統合認証システム
- Supabase Authによる安全な認証
- 自動プロフィール作成
- 認証状態の監視とリアルタイム更新
- 統合認証画面（サインアップ・ログイン統合）

### スケジュール管理システム
- カレンダー表示による直感的な予定管理
- 日時指定・終日設定対応
- リマインダー機能
- カラーテーマによる視覚的分類
- Supabase完全連携によるデータ同期

### UI/UX改善
- スムーズなページ遷移アニメーション
- カスタムスクロール制御
- ヘッダーの動的表示/非表示
- レスポンシブデザイン対応

##  参考リソース

- [Flutter Documentation](https://docs.flutter.dev/)
- [Supabase Documentation](https://supabase.com/docs)
- [Material 3 Design](https://m3.material.io/)
- [Table Calendar Package](https://pub.dev/packages/table_calendar)
- [Flutter Quill Documentation](https://pub.dev/packages/flutter_quill)

##  commitメッセージ

- feat：新機能追加
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
- docs：ドキュメント修正（README、コメント等）
- tyle：コードフォーマット修正（インデント、スペース等）
- perf：パフォーマンス改善
- test：テストコード追加・修正
- ci：CI/CD 設定変更（GitHub Actions 等）
- build：ビルド関連変更（依存関係、ビルドツール設定等）
- chore：雑務的変更（ユーザーに直接影響なし）
 

##  Contributing

プロジェクトへの貢献は歓迎します！  
新しい機能の提案やバグ報告は、GitHubのIssueでお知らせください。

*README最終更新: 2025/1/19*  
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

/// ローカルデータベースサービス
///
/// SQLiteを使用してデバイス内にデータを保存します。
/// すべてのデータ（メモ、タスク、スケジュール）はローカルに保存され、
/// Supabaseには一切保存されません。
class LocalDatabaseService {
  static Database? _database;
  static const String _databaseName = 'thisone.db';
  static const int _databaseVersion = 4;

  /// データベースインスタンスを取得
  ///
  /// シングルトンパターンを使用して、アプリ全体で1つのデータベース接続を共有
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// データベースを初期化
  ///
  /// アプリのドキュメントディレクトリにデータベースファイルを作成
  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// データベース作成時の処理
  ///
  /// 初回起動時にすべてのテーブルを作成
  Future<void> _onCreate(Database db, int version) async {
    // 各テーブルを作成
    await _createMemosTable(db);
    await _createTasksTable(db);
    await _createSchedulesTable(db);
    await _createUserProfilesTable(db);
    await _createScheduleTemplatesTable(db);
    await _createTaskTemplatesTable(db);
  }

  /// データベースアップグレード時の処理
  ///
  /// バージョンアップ時にテーブル構造を変更
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createUserProfilesTable(db);
    }
    if (oldVersion < 3) {
      await _createScheduleTemplatesTable(db);
    }
    if (oldVersion < 4) {
      await _createTaskTemplatesTable(db);
    }
  }

  /// メモテーブルを作成
  ///
  /// メモデータを保存するテーブル
  Future<void> _createMemosTable(Database db) async {
    await db.execute('''
      CREATE TABLE memos (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        mode TEXT NOT NULL,
        rich_content TEXT,
        tags TEXT NOT NULL,
        is_pinned INTEGER NOT NULL DEFAULT 0,
        color_tag TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        synced_at TEXT,
        is_deleted INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // インデックスの作成（検索パフォーマンス向上）
    await db.execute('CREATE INDEX idx_memos_user_id ON memos(user_id)');
    await db.execute('CREATE INDEX idx_memos_updated_at ON memos(updated_at)');
    await db.execute('CREATE INDEX idx_memos_is_deleted ON memos(is_deleted)');
  }

  /// ユーザープロフィールテーブルを作成
  ///
  /// アカウント情報を保存するテーブル
  Future<void> _createUserProfilesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_profiles (
        user_id TEXT PRIMARY KEY,
        display_name TEXT,
        phone_number TEXT,
        avatar_url TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_user_profiles_phone ON user_profiles(phone_number)',
    );
  }

  /// タスクテーブルを作成
  ///
  /// タスクデータを保存するテーブル
  Future<void> _createTasksTable(Database db) async {
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        is_completed INTEGER NOT NULL DEFAULT 0,
        priority INTEGER NOT NULL,
        due_date TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        completed_at TEXT,
        synced_at TEXT,
        is_deleted INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // インデックスの作成
    await db.execute('CREATE INDEX idx_tasks_user_id ON tasks(user_id)');
    await db.execute('CREATE INDEX idx_tasks_due_date ON tasks(due_date)');
    await db.execute('CREATE INDEX idx_tasks_is_deleted ON tasks(is_deleted)');
  }

  /// スケジュールテーブルを作成
  ///
  /// スケジュールデータを保存するテーブル
  Future<void> _createSchedulesTable(Database db) async {
    await db.execute('''
      CREATE TABLE schedules (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        schedule_date TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT,
        is_all_day INTEGER NOT NULL DEFAULT 0,
        location TEXT,
        reminder_minutes INTEGER NOT NULL DEFAULT 0,
        color_hex TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        synced_at TEXT,
        is_deleted INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // インデックスの作成
    await db.execute(
      'CREATE INDEX idx_schedules_user_id ON schedules(user_id)',
    );
    await db.execute(
      'CREATE INDEX idx_schedules_date ON schedules(schedule_date)',
    );
    await db.execute(
      'CREATE INDEX idx_schedules_is_deleted ON schedules(is_deleted)',
    );
  }

  /// スケジュールテンプレートテーブルを作成
  ///
  /// スケジュールテンプレートデータを保存するテーブル
  Future<void> _createScheduleTemplatesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS schedule_templates (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        start_time TEXT NOT NULL,
        end_time TEXT,
        is_all_day INTEGER NOT NULL DEFAULT 0,
        location TEXT,
        reminder_minutes INTEGER NOT NULL DEFAULT 0,
        color_hex TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // インデックスの作成
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_schedule_templates_user_id ON schedule_templates(user_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_schedule_templates_created_at ON schedule_templates(created_at)',
    );
  }

  /// タスクテンプレートテーブルを作成
  ///
  /// タスクテンプレートデータを保存するテーブル
  Future<void> _createTaskTemplatesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS task_templates (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        priority INTEGER NOT NULL DEFAULT 0,
        due_date TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // インデックスの作成
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_task_templates_user_id ON task_templates(user_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_task_templates_created_at ON task_templates(created_at)',
    );
  }

  /// データベースを閉じる
  ///
  /// アプリ終了時に呼び出し
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// データベースを削除（デバッグ用）
  ///
  /// 開発中のみ使用。本番環境では使用しない
  Future<void> deleteDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}

import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/memo.dart';
import 'local_database_service.dart';

/// ローカルメモサービス
///
/// SQLiteを使用してメモデータのCRUD操作を実行
class LocalMemoService {
  final LocalDatabaseService _dbService = LocalDatabaseService();

  /// メモを追加
  ///
  /// [userId] ユーザーID
  /// [title] タイトル
  /// [content] 内容
  /// [mode] モード（メモ、計算機、リッチテキスト）
  /// [richContent] リッチコンテンツ（JSON形式）
  /// [tags] タグリスト
  /// [isPinned] ピン留めフラグ
  /// [colorTag] カラータグ
  ///
  /// 戻り値: 作成されたMemoオブジェクト
  Future<Memo> addMemo({
    required String userId,
    required String title,
    required String content,
    required MemoMode mode,
    String? richContent,
    List<String> tags = const [],
    bool isPinned = false,
    String colorTag = '#FFD700',
  }) async {
    final db = await _dbService.database;
    final id = const Uuid().v4();
    final now = DateTime.now().toIso8601String();

    final memo = Memo(
      id: id,
      userId: userId,
      title: title,
      content: content,
      mode: mode,
      richContent: richContent,
      tags: tags,
      isPinned: isPinned,
      colorTag: colorTag,
      createdAt: DateTime.parse(now),
      updatedAt: DateTime.parse(now),
    );

    await db.insert('memos', {
      'id': memo.id,
      'user_id': memo.userId,
      'title': memo.title,
      'content': memo.content,
      'mode': memo.mode.value,
      'rich_content': memo.richContent,
      'tags': jsonEncode(memo.tags),
      'is_pinned': memo.isPinned ? 1 : 0,
      'color_tag': memo.colorTag,
      'created_at': now,
      'updated_at': now,
    });

    return memo;
  }

  /// ユーザーのメモを全取得
  ///
  /// [userId] ユーザーID
  ///
  /// 戻り値: メモリスト（更新日時の降順）
  Future<List<Memo>> getMemos(String userId) async {
    final db = await _dbService.database;
    final maps = await db.query(
      'memos',
      where: 'user_id = ? AND is_deleted = 0',
      whereArgs: [userId],
      orderBy: 'updated_at DESC',
    );

    return maps.map((map) => Memo.fromMap(map)).toList();
  }

  /// IDでメモを取得
  ///
  /// [memoId] メモID
  ///
  /// 戻り値: メモ（存在しない場合はnull）
  Future<Memo?> getMemoById(String memoId) async {
    final db = await _dbService.database;
    final maps = await db.query(
      'memos',
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [memoId],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Memo.fromMap(maps.first);
  }

  /// メモを更新
  ///
  /// [memo] 更新するMemoオブジェクト
  Future<void> updateMemo(Memo memo) async {
    final db = await _dbService.database;
    await db.update(
      'memos',
      {
        'title': memo.title,
        'content': memo.content,
        'mode': memo.mode.value,
        'rich_content': memo.richContent,
        'tags': jsonEncode(memo.tags),
        'is_pinned': memo.isPinned ? 1 : 0,
        'color_tag': memo.colorTag,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [memo.id],
    );
  }

  /// メモを削除（論理削除）
  ///
  /// [memoId] 削除するメモID
  Future<void> deleteMemo(String memoId) async {
    final db = await _dbService.database;
    await db.update(
      'memos',
      {'is_deleted': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [memoId],
    );
  }

  /// ピン留めを切り替え
  ///
  /// [memoId] メモID
  /// [isPinned] ピン留めフラグ
  Future<void> togglePin(String memoId, bool isPinned) async {
    final db = await _dbService.database;
    await db.update(
      'memos',
      {
        'is_pinned': isPinned ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [memoId],
    );
  }

  /// 完全削除（論理削除されたメモを物理削除）
  ///
  /// [memoId] メモID
  Future<void> permanentlyDeleteMemo(String memoId) async {
    final db = await _dbService.database;
    await db.delete('memos', where: 'id = ?', whereArgs: [memoId]);
  }

  /// ユーザーのすべてのメモを削除
  ///
  /// [userId] ユーザーID
  Future<void> deleteAllMemos(String userId) async {
    final db = await _dbService.database;
    await db.update(
      'memos',
      {'is_deleted': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
}

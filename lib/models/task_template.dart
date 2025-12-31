import 'dart:convert';
import 'task.dart';

/// 型安全なタスクテンプレートモデルクラス
class TaskTemplate {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final TaskPriority priority;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TaskTemplate({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.priority,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
  });

  /// MapからTaskTemplateオブジェクトを作成
  factory TaskTemplate.fromMap(Map<String, dynamic> map) {
    return TaskTemplate(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      priority: TaskPriority.fromValue(map['priority'] as int? ?? 0),
      dueDate:
          map['due_date'] != null
              ? DateTime.parse(map['due_date'] as String).toLocal()
              : null,
      createdAt: DateTime.parse(map['created_at'] as String).toLocal(),
      updatedAt: DateTime.parse(map['updated_at'] as String).toLocal(),
    );
  }

  /// TaskTemplateオブジェクトをMapに変換
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'priority': priority.value,
      'due_date': dueDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// JSON文字列からTaskTemplateオブジェクトを作成
  factory TaskTemplate.fromJson(String source) {
    return TaskTemplate.fromMap(jsonDecode(source) as Map<String, dynamic>);
  }

  /// TaskTemplateオブジェクトをJSON文字列に変換
  String toJson() {
    return jsonEncode(toMap());
  }

  /// テンプレートのコピーを作成（指定されたフィールドを更新）
  TaskTemplate copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    TaskPriority? priority,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskTemplate(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 期限日の表示文字列を取得
  String get dueDateDisplayString {
    if (dueDate == null) return '期限なし';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final yesterday = today.subtract(const Duration(days: 1));

    final dueDay = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);

    if (dueDay == today) {
      return '今日';
    } else if (dueDay == tomorrow) {
      return '明日';
    } else if (dueDay == yesterday) {
      return '昨日';
    } else {
      return '${dueDate!.month}/${dueDate!.day}';
    }
  }

  /// 優先度の色を取得
  String get priorityColorHex {
    switch (priority) {
      case TaskPriority.low:
        return '#4CAF50'; // Green
      case TaskPriority.medium:
        return '#FF9800'; // Orange
      case TaskPriority.high:
        return '#F44336'; // Red
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TaskTemplate &&
        other.id == id &&
        other.userId == userId &&
        other.title == title &&
        other.description == description &&
        other.priority == priority &&
        other.dueDate == dueDate;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      title,
      description,
      priority,
      dueDate,
    );
  }

  @override
  String toString() {
    return 'TaskTemplate(id: $id, title: $title, priority: ${priority.displayName}, dueDate: $dueDate)';
  }
}


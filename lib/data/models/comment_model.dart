
// =================================================================

// lib/data/models/comment_model.dart
class CommentModel {
  final String id;
  final String taskId;
  final String authorId;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> mentions;

  CommentModel({
    required this.id,
    required this.taskId,
    required this.authorId,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.mentions = const [],
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      taskId: json['taskId'] as String,
      authorId: json['authorId'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
      mentions: List<String>.from(json['mentions'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'authorId': authorId,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'mentions': mentions,
    };
  }

  CommentModel copyWith({
    String? content,
    DateTime? updatedAt,
    List<String>? mentions,
  }) {
    return CommentModel(
      id: id,
      taskId: taskId,
      authorId: authorId,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      mentions: mentions ?? this.mentions,
    );
  }
}

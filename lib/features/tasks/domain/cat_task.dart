import 'dart:convert';

class CatTask {
  final String id;
  final String title;
  final DateTime? deadline;
  final bool isHunted;

  CatTask({
    required this.id,
    required this.title,
    this.deadline,
    this.isHunted = false,
  });

  CatTask copyWith({
    String? title,
    DateTime? deadline,
    bool? isHunted,
  }) {
    return CatTask(
      id: id,
      title: title ?? this.title,
      deadline: deadline ?? this.deadline,
      isHunted: isHunted ?? this.isHunted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'deadline': deadline?.toIso8601String(),
      'isHunted': isHunted,
    };
  }

  factory CatTask.fromMap(Map<String, dynamic> map) {
    return CatTask(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      deadline: map['deadline'] != null ? DateTime.parse(map['deadline']) : null,
      isHunted: map['isHunted'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory CatTask.fromJson(String source) => CatTask.fromMap(json.decode(source));
}

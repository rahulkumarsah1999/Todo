import 'dart:math';

enum Priority {
  high,
  medium,
  low,
}

class Todo {
  final String id;
  final String title;
  final String? description;
  final String category;
  final Priority priority;
  final DateTime? dueDAte;
  final DateTime createdAt;
  bool isCompleted;

  Todo ({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    this.priority = Priority.medium,
    this.dueDAte,
    DateTime? createdAt,
    this.isCompleted = false,
}) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority.name,
      'dueDate': dueDAte?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory Todo.fromMap(Map map) {
    return Todo(
        id: map['id'],
        title: map['title'],
        description: map['description'],
        category: map['category'],
      priority: Priority.values.firstWhere(
          (e) => e.name == map['priority']
      ),
      dueDAte: map['dueDAte'] != null
        ? DateTime.parse(map['dueDAte'])
          :null,
      createdAt: DateTime.parse(map['createdAt']),
      isCompleted: map['isCompleted'],
    );

  }
}

enum TaskType { todo, note }

class Task {
  final String id;
  final String title;
  final String description;
  final TaskType type;
  final bool isDone;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.isDone = false,
    required this.createdAt,
    this.updatedAt,
  });

  // Factory constructor for creating new task
  factory Task.create({
    required String title,
    required String description,
    TaskType type = TaskType.todo,
  }) {
    return Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      type: type,
      isDone: false,
      createdAt: DateTime.now(),
    );
  }

  // CopyWith for immutable updates
  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskType? type,
    bool? isDone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt ?? DateTime.now(),
    );
  }

  // Serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.index,
      'isDone': isDone,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: TaskType.values[json['type'] as int],
      isDone: json['isDone'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  // Backward compatibility with old toMap/fromMap
  @Deprecated('Use toJson instead')
  Map<String, dynamic> toMap() => toJson();

  @Deprecated('Use fromJson instead')
  factory Task.fromMap(Map<String, dynamic> map) => Task.fromJson(map);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Task &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Task(id: $id, title: $title, isDone: $isDone)';
  }
}
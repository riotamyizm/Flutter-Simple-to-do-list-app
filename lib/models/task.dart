enum TaskType { todo, note }

class Task {
  final String id;
  String title;
  String description;
  TaskType type;
  bool isDone;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.isDone = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'type': type.index,
    'isDone': isDone,
  };

  factory Task.fromMap(Map<String, dynamic> map) => Task(
    id: map['id'],
    title: map['title'],
    description: map['description'],
    type: TaskType.values[map['type']],
    isDone: map['isDone'],
  );
}

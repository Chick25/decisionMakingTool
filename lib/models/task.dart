class Task{
  String title;
  bool isDone;

  DateTime createdAt;
  DateTime? deadline;

  Task({
    required this.title, 
    this.isDone = false,
    DateTime? createdAt,
    this.deadline,
  }) : createdAt = createdAt ?? DateTime.now();
}
